# Twelve Common Stata Commands, Done in R with data.table

## 1. Insheet, Import a CSV File

```r
library(data.table)
DT <- fread("path_to_my.csv")
```
R advantages: faster for huge files, usually guesses what you want, can work with files from the internet or zipped files.

## 2. Replace `y` If `x` Meets a Condition

```r
DT[, y := x]  # Initialize a new variable y equal to existing variable x
DT[x > 5, y := 5]  # Censor y where x > 5
DT[is.na(x), y := 0]  # Replace missing values of x with 0 in y
```
In Stata, `replace y = x if condition` is used. In R, the `:=` operator modifies the data.table in place.

## 3. Rename Variables

```r
setnames(DT, old = c("blah", "blah_blah"), new = c("x1", "x2"))
```
This renames `blah` to `x1` and `blah_blah` to `x2`, keeping all other variable names unchanged. The old variable names can also be specified as a range using column indices, e.g., `old = 5:12`.

## 4. Sort a Data Table (`gsort x -y` in Stata)

```r
setorder(DT, x, -y)
```
Sorts `DT` by `x` in ascending order and `y` in descending order.

## 5. Merge Datasets

```r
DT1 <- merge(DT1, DT2, by = c("id1", "id2"), all.x = TRUE)
```
This is equivalent to Stata’s `merge 1:1 id1 id2 using DT2.dta` followed by `drop if _merge==2`. If you want to retain all rows, use `all = TRUE`.

To merge with different variable names:

```r
DT1 <- merge(DT1, DT2, by.x = c("iso", "year"), by.y = c("iso3", "yr"), all.x = TRUE)
```
This allows merging when the same identifiers have different names in each dataset.

## 6. Collapse and `egen`

```r
DTc <- DT[, .(x_i = mean(x_it)), by = year]  # Equivalent to collapse (mean) in Stata
DT[, x_i := mean(x_it), by = year]  # Equivalent to egen x_i = mean(x_it), by(year)
```
If there are multiple `by` variables, use `.(iso, year)`. The `:=` operator modifies in place.

## 7. Reshape Long and Wide

### Reshape Long (Equivalent to `reshape long` in Stata)

```r
DTl <- melt(DTw, id.vars = c("iso_d", "year"), measure = patterns("^MFN_"),
            value.name = "MFN", variable.factor = FALSE)
DTl[, product := substr(variable, 5, nchar(variable))]  # Extract product code
DTl[, variable := NULL]  # Drop unnecessary column
```

### Reshape Wide (Equivalent to `reshape wide` in Stata)

```r
DTw2 <- dcast(DTl, iso_d + year ~ product, value.var = "MFN")
```
In `dcast()`, variables before `~` remain as rows, while the one after `~` becomes the new column names.

## 8. Drop/Keep Conditionally

```r
DT <- DT[!is.na(x) & y != 0]  # Drop observations where x is missing or y == 0
```
In data.table, dropping is done by keeping only the desired rows.

## 9. Save and Load Data

First, ensure that RStudio is **not** set to save/restore `.Rdata`. It’s best to restart R sessions regularly.

```r
DT <- readRDS("path_to_file/file.rds")  # Equivalent to Stata's `use`
saveRDS(DT, "path_to_file/file.rds")  # Equivalent to Stata's `save`
```
Saving in `.rds` format automatically compresses the data.

## 10. Fixed Effects Regression (`reghdfe` in Stata)

```r
res.ols <- fixest::feols(log(y) ~ educ + age + I(age^2) | worker_id + firm_id, data = DT)
summary(res.ols)
```
`fixest::feols()` is a fast and flexible alternative to `lfe::felm()`.

## 11. Poisson Regression with Fixed Effects (`ppmlhdfe` in Stata)

```r
res.ppml <- fixest::fepois(y ~ educ + age + I(age^2) | worker_id + firm_id, data = DT)
```
Setting `combine.quick = FALSE` is useful when using interactive fixed effects.

## 12. Export Regression Results to LaTeX (`esttab` in Stata)

```r
fixest::etable(res.ols, res.ppml, sdBelow = TRUE, digits = 3, fitstat = ~sq.cor + pr2,
               tex = TRUE, file = "Tables/AKM_regs.tex", signifCode = "letters",
               cluster = "worker_id", replace = TRUE)
```
`fixest::etable()` is a good alternative to `stargazer` for producing LaTeX tables.

---
This guide translates common Stata commands into `data.table`-based R equivalents, optimizing for speed and efficiency.

