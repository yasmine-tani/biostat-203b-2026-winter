*Yasmine Tani*

### Overall Grade: 186/200

### Quality of report: 10/10

-   Is the homework submitted (git tag time) before deadline? Take 10 pts off per day for late submission.  

-   Is the final report in a human readable format (html, pdf)? 

-   Is the report prepared as a dynamic document (Quarto) for better reproducibility?

-   Is the report clear (whole sentences, typos, grammar)? Do readers have a clear idea what's going on and how results are produced by just reading the report? Take some points off if the solutions are too succinct to grasp, or there are too many typos/grammar. 

### Completeness, correctness and efficiency of solution: 140/150

- Q1 (20/20)
    - Q1.1 (10/10) Correctly identifies `fread` as fastest, compares data types and memory usage across all three functions.
    - Q1.2 (10/10) Memory reduced to 48.19 MB (< 50 MB) by using `col_factor()` for categorical columns.

- Q2 (69/80)

    - Q2.1 (10/10) Reports that the process took over 3 minutes and was aborted. Explanation is acceptable.
    
    - Q2.2 (8/10) Explains it ingested but took significant time; however, the expected answer is that it does not fully solve the ingestion issue (the file is still too large for efficient in-memory reading).
        - -2: Should more clearly state that selecting columns alone does not solve the memory/time issue.
    
    - Q2.3 (15/15) Correct lab item IDs including 50862. Row count is 33,712,352. Uses `arrange()` for display. Bash command correctly extracts columns $2, $5, $7, $10.
    
    - Q2.4 (9/15)
        - -5: Missing `arrange(subject_id, charttime, itemid)` so first 10 rows may not match Q2.6 (deducted once for Q2.4–Q2.6).
        - -1: Uses `head(arrow_subset)` which shows 6 rows instead of the requested 10.
    
    - Q2.5 (14/15)
        - -1: Uses `head(parquet_subset)` which shows 6 rows instead of the requested 10.
    
    - Q2.6 (14/15)
        - -1: Uses `head(duckdb_subset)` which shows 6 rows instead of the requested 10.

- Q3 (30/30) Correct vital sign item IDs. Row count is 30,195,426. Columns subject_id, charttime, itemid, valuenum are present.

- Q4 (20/20) Provides response about AI usage (Gemini Pro) with screenshots of AI errors.
	    
### Usage of Git: 10/10

-   Are branches (`main` and `develop`) correctly set up? Is the hw submission put into the `main` branch?

-   Are there enough commits (>=5) in develop branch? Are commit messages clear? The commits should span out not clustered the day before deadline. 
          
-   Is the hw2 submission tagged? 

-   Are the folders (`hw1`, `hw2`, ...) created correctly? 
  
-   Do not put auxiliary and big data files into version control. 

### Reproducibility: 10/10

-   Are the materials (files and instructions) submitted to the `main` branch sufficient for reproducing all the results? Just click the `Render` button will produce the final `html`? 

-   If necessary, are there clear instructions, either in report or in a separate file, how to reproduce the results?

### R code style: 16/20

For bash commands, only enforce the 80-character rule. Take 2 pts off for each violation. 

-   [Rule 2.2.4] -2: Missing space after `<-` operator on lines 41, 55, 66, 94 (e.g., `function1 <-read.csv(...)` should be `function1 <- read.csv(...)`).

-   [Rule 2.2.1] -2: Missing space after commas on line 156 (`col_select =c(subject_id,itemid,charttime,valuenum)` should have spaces after each comma).
