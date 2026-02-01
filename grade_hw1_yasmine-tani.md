*TANI, YASMINE (yasmine-tani)*

### Overall Grade: 99/140

---

### Quality of report: 5/10

- Is the homework submitted (git tag time) before deadline? **Yes**

- Is the final report in a human readable format html? **-5 points**- No screenshots are shown in your qmd/html files or put in submission

- Is the report clear (whole sentences, typos, grammar)? **Yes** - Well-organized with clear explanations and personal notes.

---

### Completeness, correctness and efficiency of solution: 73/90

**Q1 (10/10)**

- Repository name correctly set up.

**Q2 (0/20)**

- **-20 points**: CITI training completion links NOT provided. Only "Q2 - completed" is written without verification links.

**Q3 (20/20)**

- Q3.1: OK - Used `~/mimic/` path correctly.

- Q3.2: OK - Displayed contents of both hosp and icu folders. Good explanation for `.csv.gz` format.

- Q3.3: OK - All four commands (`zcat`, `zless`, `zmore`, `zgrep`) explained correctly.

- Q3.4: OK - Loop output correctly explained. Line count loop implemented correctly.

- Q3.5: OK - Correct answer that patient counts don't match with good explanation.

- Q3.6: OK - All four variables shown with correct columns and counts in decreasing order.

- Q3.7: OK - Correctly counted ICU stays (94,458) and unique patients (65,366).

- Q3.8: OK - Compared file sizes and run times. Good discussion of trade-off.

**Q4 (13/10)**

- Q4.1: OK - `wget` command is executed during rendering. Explanation of `wget -nc` is correct. Uses `grep -o` which counts words. **Bonus +5 points** for counting words instead of just lines.

- Q4.2: OK - Correctly explained the difference between `>` (overwrite) and `>>` (append).

- Q4.3: **-2 points** - Output and positional parameters explained, but no code execution for `./middle.sh`. Only mentions using vi editor manually. No dynamic generation code in qmd.

**Q5 (10/10)**

- All commands executed and interpreted correctly. Excellent explanations for each command including the Gregorian calendar transition.

**Q6 (10/10)**

- Screenshot of Section 4.1.5 included (referenced as `images/clipboard-1533758585.png`).

**Q7 (10/10)**

- Which AI assistant: Gemini (1/1)
- Which AI model: Gemini 3 (1/1)
- How do you use them: Help when stuck, error fixing (1/1)
- Do you think they help improve productivity: Yes, with noted issues (2/2)
- 5 instances of AI errors: All 5 instances provided with screenshots (5/5)

---

### Usage of Git: 10/10

- Branches correctly set up.
- hw1 submission tagged.
- Folders created correctly.
- No auxiliary files in version control.

---

### Reproducibility: 5/10

- **-5 points**: `middle.sh` not submitted with the assignment and no dynamic generation code in qmd. Student mentions using vi editor manually but no executable code.
- `pg42671.txt` is downloaded during rendering.

---

### R code style: 6/20

80-character rule violations in bash chunks:

1. Line 80: `gzcat ~/mimic/hosp/admissions.csv.gz | tail -n +2 | awk -F, '{print $2}' | sort | uniq | wc -l` (94 chars) **VIOLATION**

2. Line 87: `gzcat ~/mimic/hosp/admissions.csv.gz | tail -n +2 | awk -F, '{print $1}' | sort | uniq | wc -l` (94 chars) **VIOLATION**

3. Line 101: `gzcat ~/mimic/hosp/admissions.csv.gz | tail -n +2 | awk -F, '{print $6}' | sort | uniq -c | sort -nr` (100 chars) **VIOLATION**

4. Line 106: `gzcat ~/mimic/hosp/admissions.csv.gz | tail -n +2 | awk -F, '{print $8}' | sort | uniq -c | sort -nr` (100 chars) **VIOLATION**

5. Line 111: `gzcat ~/mimic/hosp/admissions.csv.gz | tail -n +2 | awk -F, '{print $10}' | sort | uniq -c | sort -nr` (101 chars) **VIOLATION**

6. Line 116: `gzcat ~/mimic/hosp/admissions.csv.gz | tail -n +2 | awk -F, '{print $13}' | sort | uniq -c | sort -nr` (101 chars) **VIOLATION**

7. Line 132: `gzcat ~/mimic/icu/icustays.csv.gz | tail -n +2 | awk -F, '{print $1}' | sort | uniq | wc -l` (91 chars) **VIOLATION**

**7 violations × 2 points = -14 points**
