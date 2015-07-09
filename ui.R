shinyUI(fluidPage(
    titlePanel("OpenFEMA Dataset: Disaster Declarations"),
    sidebarLayout(
        sidebarPanel(
            p("FEMA Disaster Declarations Summary is a summarized dataset describing all federally declared disasters. This dataset lists all official FEMA Disaster Declarations, beginning with the first disaster declaration in 1953 and features all three disaster declaration types: major disaster, emergency, and fire management assistance. The dataset includes declared recovery programs and geographic areas (county not available before 1964; Fire Management records are considered partial due to historical nature of the dataset)."),
            p(
                "At the time of writing, the data and more information can be found directly on ", 
                a("the FEMA website.", href="http://www.fema.gov/openfema-dataset-disaster-declarations-summaries-v1")
            ),
            dateRangeInput("dates", 
                           "Date range:",
                           start = "1953-01-01", 
                           end = as.character(Sys.Date())),
            uiOutput("types")
        ),
        mainPanel(
            plotOutput("map")
        )
    )
))