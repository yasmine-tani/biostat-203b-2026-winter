library(shiny)
library(tidyverse)
library(gtsummary)
library(bigrquery)
library(gt)
library(bslib)

# setup
options(gargle_oauth_cache = FALSE, gargle_oauth_email = NA)
icu_cohort <- read_rds("mimic_icu_cohort.rds")
bq_auth(path = "biostat-203b-2026-winter-92fefbfab477.json")

con <- dbConnect(
  bigrquery::bigquery(),
  project = "biostat-203b-2025-winter",
  dataset = "mimiciv_3_1",
  billing = "biostat-203b-2025-winter"
)

ui <- page_navbar(
  title = "MIMIC-IV Explorer Pro",
  theme = bs_theme(bootswatch = "lux", primary = "#2c3e50"),
  nav_panel("Cohort Analytics",
            layout_sidebar(
              sidebar = sidebar(
                selectInput("var", "clinical variable", 
                            choices = c("age", "gender", "race", "admission_type", 
                                        "first_careunit", "last_careunit", "los")),
                checkboxInput("show_stats", "show summary table", TRUE)
              ),
              card(plotOutput("cohort_plot")),
              card(gt_output("summary_tbl"))
            )),
  nav_panel("Patient Search",
            layout_column_wrap(
              width = 1,
              card(selectizeInput("patient_id", "enter subject id:", choices = NULL)),
              card(plotOutput("adt_plot", height = "450px")),
              card(plotOutput("vitals_plot", height = "500px"))
            ))
)

server <- function(input, output, session) {
  updateSelectizeInput(session, "patient_id", choices = sort(unique(icu_cohort$subject_id)), server = TRUE)
  
  # Tab 1: No changes
  output$cohort_plot <- renderPlot({
    req(input$var)
    if(is.numeric(icu_cohort[[input$var]])) {
      ggplot(icu_cohort, aes(x = .data[[input$var]])) + geom_histogram(fill = "#2c3e50", bins = 30) + theme_minimal()
    } else {
      ggplot(icu_cohort, aes(x = .data[[input$var]])) + geom_bar(fill = "#e67e22") + coord_flip() + theme_minimal()
    }
  })
  
  output$summary_tbl <- render_gt({
    req(input$show_stats, input$var)
    icu_cohort %>% select(all_of(input$var)) %>% tbl_summary() %>% as_gt()
  })
  
  # Tab 2: ADT Trajectory
  output$adt_plot <- renderPlot({
    req(input$patient_id)
    p_id <- as.numeric(input$patient_id)
    p_data <- icu_cohort %>% filter(subject_id == p_id) %>% head(1)
    
    diag <- tbl(con, "diagnoses_icd") %>% 
      filter(subject_id == !!p_id) %>%
      left_join(tbl(con, "d_icd_diagnoses"), by = c("icd_code", "icd_version")) %>%
      arrange(seq_num) %>% head(3) %>% collect()
    diag_sub <- paste(diag$long_title, collapse = "\n")
    
    trans <- tbl(con, "transfers") %>% 
      filter(subject_id == !!p_id, eventtype != "discharge") %>% collect() %>%
      mutate(intime = as.POSIXct(intime), outtime = as.POSIXct(outtime))
    
    labs <- tbl(con, "labevents") %>% 
      filter(subject_id == !!p_id) %>% collect() %>%
      mutate(charttime = as.POSIXct(charttime))
    
    procs <- tbl(con, "procedures_icd") %>% 
      filter(subject_id == !!p_id) %>%
      left_join(tbl(con, "d_icd_procedures"), by = c("icd_code", "icd_version")) %>%
      collect() %>% 
      mutate(charttime = as.POSIXct(chartdate), 
             short_title = str_trunc(long_title, 30))
    
    ggplot() +
      geom_segment(data = trans, aes(x = intime, xend = outtime, y = "ADT", yend = "ADT", 
                                     color = careunit, linewidth = str_detect(careunit, "ICU|CCU"))) +
      geom_point(data = labs, aes(x = charttime, y = "Lab"), shape = 3, size = 2) +
      geom_point(data = procs, aes(x = charttime, y = "Procedure", shape = short_title), size = 3) +
      scale_y_discrete(limits = c("Procedure", "Lab", "ADT")) +
      scale_linewidth_manual(values = c("TRUE" = 4, "FALSE" = 1)) +
      theme_minimal() + # Switched to minimal to match vitals
      theme(legend.position = "bottom", legend.box = "vertical") +
      guides(linewidth = "none") +
      labs(title = paste0("Patient ", p_id, ", ", p_data$gender, ", ", round(p_data$age), " years old, ", p_data$race),
           subtitle = diag_sub, x = "Calendar Time", y = NULL, color = "Care Unit", shape = "Procedure")
  })
  
  # Vitals
  output$vitals_plot <- renderPlot({
    req(input$patient_id)
    p_id <- as.numeric(input$patient_id)
    vitals <- tbl(con, "chartevents") %>% filter(subject_id == !!p_id) %>%
      filter(itemid %in% c(220045, 220179, 220180, 220210, 223761)) %>% collect() %>%
      mutate(charttime = as.POSIXct(charttime),
             label = case_when(itemid == 220045 ~ "HR", itemid %in% c(220179, 220180) ~ "BP",
                               itemid == 220210 ~ "RR", itemid == 223761 ~ "Temp"))
    ggplot(vitals, aes(x = charttime, y = valuenum, color = label)) +
      geom_line() + facet_grid(label ~ ., scales = "free_y") + theme_minimal() + 
      theme(legend.position = "none") +
      labs(x = "Calendar Time", y = "Value")
  })
}

shinyApp(ui, server)