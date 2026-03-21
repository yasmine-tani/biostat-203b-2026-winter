library(shiny)
library(tidyverse)
library(bslib)
library(bigrquery)
library(DBI)
library(gtsummary)
library(gt)
library(plotly)
library(shinyWidgets)
library(shinycssloaders)
library(shinyjs)

# --- 1. DATA LOADING ---
sepsis_data <- read_rds("sepsis_app_data.rds")
roc_plot_rds <- read_rds("roc_plot.rds")
lasso_df <- read_rds("sepsis_lasso_results.rds") 
traj_plot_rds <- read_rds("trajectory_plot.rds")

bq_auth(path = "biostat-203b-2026-winter-92fefbfab477.json")
con <- dbConnect(bigrquery::bigquery(), project = "biostat-203b-2025-winter", 
                 dataset = "mimiciv_3_1", billing = "biostat-203b-2025-winter")

# --- 2. UI ---
ui <- fluidPage(
  useShinyjs(),
  # Custom CSS for the "Insane" Light Look & Splash Screen
  tags$head(
    tags$style(HTML("
      body { background-color: #f4f7f6; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
      .navbar { background-image: linear-gradient(to right, #0047AB, #00B4DB) !important; }
      .nav-link { color: white !important; font-weight: 500; }
      #landing-page {
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: linear-gradient(135deg, #ffffff 0%, #d7e1ec 100%);
        z-index: 10000; display: flex; flex-direction: column;
        align-items: center; justify-content: center;
      }
      .enter-btn {
        padding: 20px 50px; font-size: 24px; border-radius: 50px;
        background: #0047AB; color: white; border: none;
        box-shadow: 0 10px 20px rgba(0,71,171,0.3); transition: 0.3s;
      }
      .enter-btn:hover { transform: scale(1.05); background: #003580; cursor: pointer; }
      .card { border-radius: 15px; border: none; box-shadow: 0 4px 12px rgba(0,0,0,0.05); }
      .sidebar { background: white; border-radius: 15px; padding: 20px; }
    "))
  ),
  
  # 1. CLICK TO ENTER SCREEN
  div(id = "landing-page",
      icon("shield-virus", class = "fa-5x", style = "color: #0047AB; margin-bottom: 20px;"),
      h1("SEPSIS PREDICTOR PRO", style = "font-weight: 800; color: #333;"),
      p("Advanced MIMIC-IV Clinical Decision Support System", style = "color: #666; margin-bottom: 30px;"),
      actionButton("enter_app", "ENTER SYSTEM PORTAL", class = "enter-btn")
  ),
  
  # 2. MAIN APP CONTENT (Hidden until button click)
  hidden(
    div(id = "main-content",
        page_navbar(
          title = "Sepsis Intelligence v2.0",
          theme = bs_theme(version = 5, bootswatch = "flatly", primary = "#0047AB"),
          
          nav_panel("Cohort Explorer",
                    layout_sidebar(
                      sidebar = sidebar(
                        title = "Data Controls",
                        pickerInput("var", "Clinical Variable", 
                                    choices = list(
                                      "Demographics" = c("Age" = "age_at_admit", "Gender" = "gender", "Race" = "race_group", "Insurance" = "insurance"),
                                      "Vitals" = c("Heart Rate" = "heart_rate", "Mean BP" = "mean_bp", "Systolic BP" = "sys_bp", "Resp Rate" = "resp_rate", "Temp F" = "temp_f"),
                                      "Labs" = c("Max Lactate" = "max_lactate", "Max Creatinine" = "max_creatinine", "Max Bilirubin" = "max_bilirubin", "Max WBC" = "max_wbc", "Min Platelets" = "min_platelets"),
                                      "Conditions" = c("Hypertension" = "hypertension", "Diabetes" = "diabetes", "CKD" = "ckd", "CVD" = "cvd", "Vasopressors" = "vasopressors")
                                    ),
                                    options = list(`live-search` = TRUE)),
                        checkboxInput("show_stats", "Show Analytics Summary", TRUE),
                        tags$hr(),
                        actionBttn("show_traj", "Trajectory Analytics", style = "gradient", color = "primary", icon = icon("chart-area"))
                      ),
                      card(card_header("Distribution Profile"), withSpinner(plotlyOutput("cohort_plot"))),
                      card(card_header("Statistical Overview"), gt_output("summary_tbl"))
                    )
          ),
          
          nav_panel("Model HUD",
                    layout_column_wrap(
                      width = 1/2,
                      card(card_header("ROC Curve Performance"), plotOutput("roc_plot")),
                      card(card_header("Lasso Feature Importance"), withSpinner(plotlyOutput("lasso_bar")))
                    ),
                    card(card_header("Predictive Metrics Matrix"), tableOutput("metrics_table"))
          ),
          
          nav_panel("Patient Search",
                    layout_sidebar(
                      sidebar = sidebar(
                        title = "Patient Search",
                        selectizeInput("patient_id", "Search ID:", choices = NULL),
                        tags$hr(),
                        helpText("Connected to BigQuery Engine")
                      ),
                      # YOUR UNTOUCHED ADT LOGIC
                      card(card_header("ADT Timeline & Procedures"), withSpinner(plotOutput("adt_plot", height = "500px"))),
                      card(card_header("ICU Vitals Stream"), withSpinner(plotOutput("vitals_plot", height = "500px")))
                    )
          )
        )
    )
  )
)

# --- 3. SERVER ---
server <- function(input, output, session) {
  
  # Handle the "Click to Enter" logic
  observeEvent(input$enter_app, {
    hide("landing-page", anim = TRUE, animType = "fade", time = 0.8)
    show("main-content")
  })
  
  updateSelectizeInput(session, "patient_id", choices = sort(unique(sepsis_data$subject_id)), server = TRUE)
  
  observeEvent(input$show_traj, {
    showModal(modalDialog(title = "Clinical Trajectories", plotOutput("traj_plot_modal", height = "600px"), size = "xl", easyClose = TRUE))
  })
  output$traj_plot_modal <- renderPlot({ traj_plot_rds })
  
  output$cohort_plot <- renderPlotly({
    req(input$var)
    p <- ggplot(sepsis_data, aes(x = .data[[input$var]])) + theme_minimal()
    if(is.numeric(sepsis_data[[input$var]])) {
      p <- p + geom_histogram(fill = "#0047AB", bins = 30, color = "white")
    } else {
      p <- p + geom_bar(fill = "#00B4DB") + coord_flip()
    }
    ggplotly(p)
  })
  
  output$summary_tbl <- render_gt({
    req(input$show_stats)
    sepsis_data %>% select(all_of(input$var)) %>% tbl_summary() %>% as_gt()
  })
  
  output$roc_plot <- renderPlot({ roc_plot_rds + theme_minimal() })
  output$lasso_bar <- renderPlotly({
    p <- lasso_df %>%
      filter(Predictor != "(Intercept)", Importance > 0) %>%
      mutate(Predictor = reorder(Predictor, Importance)) %>%
      ggplot(aes(x = Predictor, y = Importance)) +
      geom_col(fill = "#0047AB") + coord_flip() + theme_minimal()
    ggplotly(p)
  })
  
  output$metrics_table <- renderTable({
    tibble(Model = c("Lasso", "Random Forest", "XGBoost"), AUC = c(0.78, 0.75, 0.76), 
           Sensitivity = c("74.2%", "71.0%", "72.5%"), Specificity = c("70.8%", "68.5%", "70.1%"))
  })
  
  # --- YOUR EXACT ADT PLOT CODE ---
  output$adt_plot <- renderPlot({
    req(input$patient_id)
    p_id <- as.numeric(input$patient_id)
    p_data <- sepsis_data %>% filter(subject_id == !!p_id) %>% head(1)
    p_age <- if (!is.na(p_data$age_at_admit[1])) round(as.numeric(p_data$age_at_admit[1])) else ""
    p_title <- paste0("Patient ", p_id, ", ", p_data$gender[1], ", ", p_age, " years old, ", p_data$race_group[1])
    trans <- tbl(con, "transfers") %>% filter(subject_id == !!p_id, eventtype != "discharge") %>% collect() %>%
      mutate(intime = as.POSIXct(intime), outtime = as.POSIXct(outtime))
    labs <- tbl(con, "labevents") %>% filter(subject_id == !!p_id) %>% collect() %>% mutate(charttime = as.POSIXct(charttime))
    procs <- tbl(con, "procedures_icd") %>% filter(subject_id == !!p_id) %>%
      left_join(tbl(con, "d_icd_procedures"), by = c("icd_code", "icd_version")) %>% collect() %>%
      mutate(charttime = as.POSIXct(chartdate), short_title = str_trunc(long_title, 20))
    origin <- min(trans$intime, na.rm = TRUE)
    trans <- trans %>% mutate(x_in = as.numeric(difftime(intime, origin, units = "days")), x_out = as.numeric(difftime(outtime, origin, units = "days")))
    labs <- labs %>% mutate(x = as.numeric(difftime(charttime, origin, units = "days")))
    procs <- procs %>% mutate(x = as.numeric(difftime(charttime, origin, units = "days")))
    ggplot() +
      geom_segment(data = trans, aes(x = x_in, xend = x_out, y = "ADT", yend = "ADT", color = careunit), linewidth = 4) +
      geom_point(data = labs, aes(x = x, y = "Lab"), shape = 3, size = 2) +
      geom_point(data = procs, aes(x = x, y = "Procedure", shape = short_title), size = 3) +
      scale_y_discrete(limits = c("Procedure", "Lab", "ADT")) +
      scale_x_continuous(labels = function(x) paste0("Day ", round(x))) +
      theme_minimal() + theme(legend.position = "bottom", legend.box = "vertical") +
      labs(title = p_title, x = "Days from First Admission", y = NULL)
  })
  
  output$vitals_plot <- renderPlot({
    req(input$patient_id)
    p_id <- as.numeric(input$patient_id)
    vitals <- tbl(con, "chartevents") %>%
      filter(subject_id == !!p_id, itemid %in% c(220045, 220179, 220180, 220210, 223761)) %>% collect() %>%
      mutate(charttime = as.POSIXct(charttime),
             label = case_when(itemid == 220045 ~ "HR", itemid %in% c(220179, 220180) ~ "NBPs", 
                               itemid == 220210 ~ "RR", itemid == 223761 ~ "Temp"))
    ggplot(vitals, aes(x = charttime, y = valuenum, color = label)) +
      geom_line() + facet_grid(label ~ stay_id, scales = "free") +
      theme_minimal() + labs(title = "ICU Vitals Trends", x = "Calendar Time", y = "Value")
  })
}

shinyApp(ui, server)





