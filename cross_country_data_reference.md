# Cross-Country GDP Data & Web Scraping: R and Julia Reference

A collection of approaches for downloading cross-country GDP per capita data and scraping web tables, covering R, Julia, and interop between the two.

---

## 1. R: The `WDI` Package

The `WDI` package provides a convenient interface to the World Bank's World Development Indicators database.

```r
install.packages("WDI")
library(WDI)

# GDP per capita (current US$) for all countries, single year
gdp <- WDI(indicator = "NY.GDP.PCAP.CD", start = 2022, end = 2022)

# Search for indicators by keyword
WDIsearch("gdp per capita")
```

### Commonly Used GDP Per Capita Indicator Codes

| Code                  | Description                                        |
|-----------------------|----------------------------------------------------|
| `NY.GDP.PCAP.CD`     | GDP per capita, current US$                        |
| `NY.GDP.PCAP.KD`     | GDP per capita, constant 2015 US$                  |
| `NY.GDP.PCAP.PP.CD`  | GDP per capita, PPP (current international $)      |
| `NY.GDP.PCAP.PP.KD`  | GDP per capita, PPP (constant 2021 international $)|

### Other Useful R Packages

- **`wbstats`** — Another World Bank API wrapper with caching and a slightly different interface.
- **`pwt10`** (or `pwt`) — Penn World Table data, popular in growth economics for cross-country comparisons of real GDP.
- **`countrycode`** — Converts between country name/code formats (ISO2, ISO3, UN, etc.). Pairs well with any of the above.

---

## 2. Julia: `WorldBankData.jl`

Julia's native equivalent of the R `WDI` package. Wraps the same World Bank API.

```julia
using WorldBankData

# GDP per capita for all countries, single year
df = wdi("NY.GDP.PCAP.CD", "all", 2022, 2022)

# Search for indicators
search_wdi("gdp")
```

Good for straightforward WDI pulls. Use one of the approaches below if you need data beyond what this package provides.

---

## 3. Julia: Calling R via `RCall.jl`

When you need access to R's broader ecosystem (Penn World Table, `wbstats`, `rvest`, etc.) without leaving Julia.

```julia
using RCall

R"""
library(WDI)
gdp <- WDI(indicator = "NY.GDP.PCAP.CD", start = 2022, end = 2022)
"""

# Pull the R data frame into Julia
@rget gdp
```

Worth the overhead when you rely on multiple R-specific data packages regularly; overkill for a single data pull.

---

## 4. Julia: Direct API Access with `HTTP.jl` + `JSON3.jl`

Hit the World Bank REST API (or any JSON API) directly, with no wrapper-package dependency.

### `HTTP.jl` — Julia's `requests`

```julia
using HTTP

# GET request
resp = HTTP.get("https://api.example.com/data")
String(resp.body)

# With query parameters
resp = HTTP.get("https://api.example.com/data",
    query = ["key" => "value", "page" => "1"])

# POST with a JSON body
resp = HTTP.post("https://api.example.com/submit",
    ["Content-Type" => "application/json"],
    JSON3.write(my_data))

# Status code
resp.status  # 200, 404, etc.
```

Also supports streaming, async requests, retries, redirects, and file downloads.

### `JSON3.jl` — Fast, Type-Aware JSON Parsing

```julia
using JSON3

# Parse a JSON string
obj = JSON3.read("""{"name": "Canada", "gdp": 52000.5}""")
obj.name  # "Canada"

# Parse directly into a Julia struct
struct Country
    name::String
    gdp::Float64
end
c = JSON3.read("""{"name": "Canada", "gdp": 52000.5}""", Country)

# Write Julia objects to JSON
JSON3.write(Dict("x" => 1, "y" => [2, 3, 4]))
```

Typed deserialization into structs catches malformed data early and keeps downstream code clean.

### World Bank API Example

```julia
using HTTP, JSON3, DataFrames

url = "https://api.worldbank.org/v2/country/all/indicator/NY.GDP.PCAP.CD?date=2022&format=json&per_page=300"
resp = HTTP.get(url)
data = JSON3.read(resp.body)[2]  # first element is metadata, second is the data
```

### Bonus: `CSV.jl` for Tabular Downloads

Many APIs and open data portals offer CSV. One-liner to pull straight into a DataFrame:

```julia
using CSV, HTTP, DataFrames
df = CSV.read(HTTP.download(url), DataFrame)
```

---

## 5. Scraping HTML Tables

### Pure Julia: `Gumbo.jl` + `Cascadia.jl`

- **`Gumbo.jl`** — HTML parser (like Python's BeautifulSoup). Parses raw HTML into a traversable tree.
- **`Cascadia.jl`** — Adds CSS selector support on top of Gumbo.

```julia
using HTTP, Gumbo, Cascadia, DataFrames

# Fetch and parse
resp = HTTP.get("https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)_per_capita")
html = parsehtml(String(resp.body))

# Select the first wikitable
tables = eachmatch(sel"table.wikitable", html.root)
table = tables[1]

# Extract rows
rows = eachmatch(sel"tr", table)
```

From here, loop through rows and cells (`sel"td"`, `sel"th"`) to build a DataFrame. Works, but Wikipedia tables can be messy (colspan, rowspan, footnotes, nested links).

### Easier Route: `pandas.read_html` via `PythonCall.jl`

For Wikipedia tables specifically, `pandas.read_html` handles the ugly edge cases automatically.

```julia
using PythonCall, DataFrames

pd = pyimport("pandas")
tables = pd.read_html("https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)_per_capita")
df = DataFrame(pytable(tables[0]))  # first table on the page
```

The R equivalent via `RCall.jl` would use `rvest`:

```julia
using RCall

R"""
library(rvest)
page <- read_html("https://en.wikipedia.org/wiki/List_of_countries_by_GDP_(nominal)_per_capita")
tables <- html_table(page, fill = TRUE)
gdp <- tables[[1]]
"""

@rget gdp
```

---

## Quick Decision Guide

| Situation                                    | Recommended Approach                        |
|----------------------------------------------|---------------------------------------------|
| Just need WDI data in R                      | `WDI` package                               |
| Just need WDI data in Julia                  | `WorldBankData.jl`                          |
| Need Penn World Table or other R-only data   | `RCall.jl`                                  |
| Want no wrapper dependency in Julia           | `HTTP.jl` + `JSON3.jl` (direct API)        |
| Scraping a clean HTML table                  | `Gumbo.jl` + `Cascadia.jl`                 |
| Scraping a messy Wikipedia table             | `PythonCall.jl` with `pandas.read_html`     |
| Pulling a CSV from a URL into a DataFrame    | `CSV.read(HTTP.download(url), DataFrame)`   |
