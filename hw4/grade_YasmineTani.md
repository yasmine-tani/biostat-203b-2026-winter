*Yasmine Tani*

### Overall Grade: 238/270

### Late penalty

- Is the homework submitted (git tag time) before deadline? Take 10 pts off per day for late submission.  

### Quality of report: 10/10

### Completeness, correctness and efficiency of solution: 190/220

- Q1 (75/100)
  - Q1.5 (-5): **Missing albumin (50862)**. Only 8 labs.
  - Q1.5: Uses `semi_join` + `left_join` by `subject_id`, `slice_max(storetime)`, `pivot_wider` + `rename`. `arrange(subject_id, stay_id)` present at end (line 113).
  - Q1.6: All 5 vital items correct. `semi_join` + `left_join` by `(subject_id, stay_id)`, `filter(charttime == min(charttime))`, `summarize(mean(...))`, `pivot_wider` + `rename`. Uses `charttime` for both ICU window and first-measurement filter (acceptable).
  - Q1.7 (-20): **Early `collect()`** `collect()` at line 163. Lab and chart tables joined after collect. `arrange(subject_id, hadm_id, stay_id)` and `print(width = Inf)` present. Correct age computation (equivalent formula).
  - Q1.8: `fct_lump_n` with n=4 via `across()`. Creative `fct_collapse` using `grep("ASIAN", levels(...), value = TRUE)` with `other_level = "Other"`. `los_long = los >= 2` correct.

- Q2 (95/100)

  - **Folder structure**: Separate `app.R` provided. No penalty.
  - **Tab 1 (Cohort Analytics)**: Single dropdown for 7 selected variables (age, gender, race, admission_type, first/last careunit, los). Histograms/bar plots with optional `tbl_summary` toggle via checkbox. Polished `bslib` theme (`page_navbar` with `bootswatch = "lux"`). Not organized into groups (no bonus).
  - **Tab 2 (Patient Search)**: Contains full HW3-style ADT timeline plot with all 3 layers: `geom_segment` for ADT (color = careunit, linewidth = ICU detection), `geom_point` for Lab (shape = 3), `geom_point` for Procedure (shape = `short_title`). `scale_y_discrete(limits = c("Procedure", "Lab", "ADT"))`. Diagnoses correctly sorted by `seq_num` (`arrange(seq_num) |> head(3)`). Vitals faceted plot present (`facet_grid(label ~ ., scales = "free_y")`). Patient ID via `selectizeInput` with server-side rendering.
  - (-5): Tab 1 limited to 7 variables; missing labs and vitals from dropdown.
  - **Error handling**: `req()`, `updateSelectizeInput` server-side.

- Q3 (20/20)

  - Lists AI tool (Gemini 3 Flash) and discusses use.
  - Provides 5 instances of AI errors: dropdown showing all 40+ variables, endless auth loop instead of using JSON token, non-existent gargle function, breaking other app elements when fixing one, file organization issues with token. Full credit.

### Usage of Git: 10/10

### Reproducibility: 10/10

### R code style: 18/20

-   [Rule 2.6](https://style.tidyverse.org/syntax.html#long-function-calls) The maximum line length is 80 characters.  
    - (-2) Line 85 (83 chars): `filter(itemid %in% c(50912, 50971, ...))`. Line 202 (118 chars): long `select()` call in Q1.8.

-   Other rules: No violations found.
