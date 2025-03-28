# How-to-do (mainly for data.table) - Complete Version

## 1. Sample from a data.table
Draw N length vectors of `tauD`, `tauR`, `tauF`:
```r
tauDRF <- tau_data[sample(nrow(tau_data), N, replace = TRUE)]
```

## 2. Create a group variable based on a vector of other variables
```r
V_id <- c("V_iso_o", "V_plant", "V_type", "V_brand", "V_model", "V_platform")
DT3[, Vnum := .GRP, by = V_id]
```

## 3. Selecting columns using variable names
```r
select_cols <- c("arr_delay", "dep_delay")
flights[, ..select_cols]  # .. prefix goes one step up to get select_cols, like in Unix "cd .."
```
This is equivalent to:
```r
flights[, select_cols, with = FALSE]
```
And to augment the vector:
```r
flights[, c(select_cols, "another_var"), with = FALSE]
```

## 4. Merge multiple columns into one
Suppose you have income categories in different columns and only one non-NA per row:
```r
income.vars <- colnames(EB[, 512:528])  # confirm this is v511-v527
EB[, income.c := do.call(paste, mget(income.vars))]  # the tricky bit
EB[, income.c := gsub("NA", "", income.c)]
EB[, income.c := as.integer(income.c)]
```

## 5. Create a variable showing decile and quartile classification
Decile:
```r
VEX[, distEV_decile := cut(distEV, quantile(distEV, probs = 0:10/10), include.lowest = TRUE, labels = FALSE)]
```
Quartile (two ways):
```r
dt[, quartile1 := dplyr::ntile(x, 4)]
```
Or:
```r
dt[, quartile2 := cut(x, breaks = quantile(x, probs = seq(0, 1, 0.25)),
                       labels = c("Q1", "Q2", "Q3", "Q4"))]
```

## 6. Divide a single pasted entity into multiple variables
```r
UP <- unique(DU[, .(plant = paste(part, U_iso_o, U_mfr, U_plant, sep = "_"))])
VP <- unique(DU[, .(plant = paste(V_iso_o, V_mfr_group, V_plant, sep = "_"))])
VET <- CJ(U4 = UP$plant, V4 = VP$plant)
VET[, c("part", "U_iso_o", "U_owner", "U_plant") := tstrsplit(U4, "_", fixed = TRUE)]
VET[, c("V_iso_o", "V_owner", "V_plant") := tstrsplit(V4, "_", fixed = TRUE)]
```

## 7. Joining two data.tables based on inequalities
See details on [StackOverflow](https://stackoverflow.com/questions/67612087/matching-yearly-time-points-to-preceding-365-days-of-data-in-r/67625036#67625036).

## 8. More tstrsplit tricks for lat/lon extraction
```r
DT[, c("lat_str", "lon_str") := tstrsplit(V11, " ")]
DT[, c("lat_dm", "lat_dir") := tstrsplit(sub('(?<=.{4})', "_", lat_str, perl = TRUE), "_")]
DT[, c("lon_dm", "lon_dir") := tstrsplit(sub('(?<=.{5})', "_", lon_str, perl = TRUE), "_")]
```
For more on Perl regex, see [here](https://jkorpela.fi/perl/regexp.html).

## 9. Multiple operations inside DT[, j]
Basic plotting:
```r
DT[, { plot(xvar, yvar); abline(0, 1) }]
```
Grouped operations:
```r
dt[, {
  tmp1 <- mean(mpg)
  tmp2 <- mean(abs(mpg - tmp1))
  tmp3 <- round(tmp2, 2)
  list(tmp2 = tmp2, tmp3 = tmp3)
}, by = cyl]
```

## 10. Saving text results to a file
Using `cat`:
```r
cat("A", "Z", "\n")
```
Using `writeLines`:
```r
writeLines(c("A", "Z"))
```

## 11. Create a new column as the sum of selected columns
```r
DQ[, debate_sum := rowSums(.SD), .SDcols = debate.cols]
```

## 12. Adding a legend with a white background
```r
legend("topright", legend = c("FR-DE-IT-GB-BE", "EU15"), pch = c(15, 16), col = c("black", "blue"), bg = "white")
```

## 13. Removing attributes from a data.table
```r
attr(y) <- NULL
DT <- DT[, lapply(.SD, as.vector)]
```
More info: [Attributes in R](https://www.r-bloggers.com/2020/10/attributes-in-r/) and [this package](https://cran.r-project.org/web/packages/labelled/vignettes/intro_labelled.html#:~:text=To%20get%20the%20variable%20label%2C%20simply%20call%20var_label()%20.&text=To%20remove%20a%20variable%20label%2C%20use%20NULL%20.&text=In%20RStudio%2C%20variable%20labels%20will%20be%20displayed%20in%20data%20viewer)

## 14. Using get() and eval() for dynamic evaluation
```r
x_1 <- c(1, 0)
index <- 1
get(paste0("x_", index))[1]
```
And using eval():
```r
x <- c(0, 1)
index <- 1
value <- eval(parse(text = paste0("x[", index, "]")))
```

## 15. Reformulating a model
```r
reformulate(c("var1", "var2"), response = "outcome")  # outcome ~ var1 + var2
```

## 16. Dividing variables by another variable and creating new columns
```r
setDT(df1)[, paste0(names(df1)[3:4], "_SVL") := lapply(.SD, `/`, df1$SVL), .SDcols = HDL:HDW]
```

## 17. Generating output with xtable
```r
sink(file = paste("../Tables/CF_MM/", mix, "/CF_monte_", pan, "OG_", OGpct, ".tex", sep = ""))
print(xtable(monte.summary, digits = c(1, 1, 1, 0, 0, 2, 2, 2, 1, 2, 2, 2, 2, 0, 1, 1, 1, 1)),
      include.colnames = FALSE, include.rownames = FALSE,
      only.contents = TRUE, hline.after = NULL, comment = FALSE)
sink()
```

## 18. Extracting column names matching a pattern
```r
fcols <- which(colnames(DM) %like% "^f")
colnames(DM[, ..fcols])
```

## 19. Regular expression tricks: trimming and cutting parentheses
Trim spaces:
```r
trim <- function(x) gsub("^\\s+|\\s+$", "", x)
```
Remove text in parentheses:
```r
new <- gsub("\\s*\\([^\\)]+\\)", "", as.character(old))
```

## 20. Extract numbers from a string
```r
extract_nums <- function(x) as.numeric(gsub("[^0-9]", "", x))
```
To match non-alphanumeric characters, use `[^\a-zA-Z0-9]`.

## 21. Removing variables matching a pattern
```r
cn <- colnames(VS)
oldboreg <- cn[cn %like% "^border.*[A-Z]$"]
VS[, (oldboreg) := NULL]  # note the parentheses around oldboreg
```

## 22. Additional regex examples and references
For more gsub() examples, see *Method/Rfiles/falsify_malthus.R*. Also, for extended regular expressions (e.g., punct, digit, alpha, alnum), refer to:
[Extended Regex in R](https://stat.ethz.ch/R-manual/R-devel/library/base/html/regex.html)

## 23. Replacing accented characters
```r
base::iconv('áéóÁÉÓçã', to = "ASCII//TRANSLIT")
stringi::stri_trans_general(c("á", "é", "ó"), "latin-ascii")
base::chartr("áéó", "aeo", mydata)
```

## 24. Replacing missing values in multiple columns
```r
debate.cols <- paste0("debate_", 1:6)
keep <- c("name", debate.cols)
NAto0 <- function(x) fifelse(is.na(x), 0, x)
DQ[, (debate.cols) := lapply(.SD, NAto0), .SDcols = debate.cols]
```

## 25. Creating objects with dynamic names
```r
assign(paste0("DT", year.chosen), DT[year == year.chosen])
do.call("<-", list("my_string_2", 1:5))
```

## 26. Other matrix operations
For example, using `matrixStats::rowSds` for row standard deviations.

## 27. Row-wise operations using row names
```r
DC[, U_in_V := grepl(U_PLANT, V_PLANT, fixed = TRUE), by = row.names(DC)]
```

## 28. Reading RDS directly from a URL
```r
url.ghr <- "https://github.com/ckhead/SharedData/raw/main/gravdata_1948_2018.rds"
GD <- readRDS(url(url.ghr, "rb"))
```
Or
```r
url.dropbox <- "https://www.dropbox.com/s/t87ly58v30g187n/gravdata_1948_2018.rds?dl=1"
```

## 29. Leaving out means
Refer to the discussion on [StackOverflow](https://stackoverflow.com/questions/72856012/r-data-table-leave-out-mean-by-group).

## 30. Equivalent of Stata's table command using dcast
```r
dcast(LF, E_fuel_type ~ E_prop_sys, value.var = "num_models")  # NAs for non-existent combinations
dcast(DTl, E_fuel_type ~ E_prop_sys, value.var = "V_model", fun.aggregate = uniqueN)  # zeros instead of NAs
```

## 31. Creating a small data.table with column names first
```r
DT <- fread("
A, B, C
1, 2, 3
")
```

## 32. Summing columns in data.table
Row-wise sum:
```r
DT[, D := rowSums(.SD), .SDcols = 1:3]
```
```r
mat[ , col4 := sum(col1, col2, na.rm=TRUE), by=1:NROW(mat)]
```

## 33. Get Cartesian index of a matrix
```r
weak_mat_pos <- which(weak_mat == 1, arr.ind = TRUE)
```

## 34. Splitting a list-type column into multiple columns
```r
nm_dt1 <- nm_dt[, transpose(V1)][]
```

## 35. Macros à la Stata
```r
affix <- function(str1, str2) eval(as.name(paste0(str1, str2)), parent.frame())
suffix <- function(thevar, choice) eval(as.name(paste0(thevar, choice)), parent.frame())
prefix <- function(thevar, choice) eval(as.name(paste0(choice, thevar)), parent.frame())
```
**Demonstration:**
```r
myset <- "A"
yourset <- "B"
set.A <- 1:5
B.setting <- 10:13
mean(prefix("set.", myset))
mean(suffix("set.", myset))
mean(prefix(".setting", yourset))
```

## 36. Looping with computation of "hats" from two different data.tables
```r
hatmon.vars <- c("w_", "A_", "real_wage_", "Y_", "P_", "violence_", "MRV_", "open_", "selftrade_")
HATMON.DT <- data.table(group)
for (v in hatmon.vars) {
  HATMON.DT[, paste0(v, "hat") := counterfactualDT$eq_monadic[, .(get(v))] / 
                           factualDT$eq_monadic[, .(get(v))]]
}
```

## 37. Plots with broken axis using gap.plot
Refer to the [gap.plot documentation](https://www.rdocumentation.org/packages/plotrix/versions/3.8-4/topics/gap.plot) and [RStudio Pubs example](https://rstudio-pubs-static.s3.amazonaws.com/235467_5abd31ab564a43c9ae0f18cdd07eebe7.html).

