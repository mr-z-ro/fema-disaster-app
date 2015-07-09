library(ggplot2)
library(maps)
library(plyr)
source("helper.R")

# Load FEMA data
# From original data at http://www.fema.gov/openfema-dataset-disaster-declarations-summaries-v1
#  disasters <- read.csv("data/DisasterDeclarationsSummaries.csv")
#  disasters$declarationDate <- as.Date(disasters$declarationDate)
#  disasters$stateName <- as.factor(sapply(disasters$state, getStateName))
#  save(disasters, file="data/DisasterDeclarationSummariesFormatted.RData")
# From formatted data stored by the code above
load("data/DisasterDeclarationSummariesFormatted.RData")

# Load state geo data
all_states <- map_data("state")

# Set interaction flag
interacted = FALSE

shinyServer(
    
    function(input, output) {
        
        # Filter the incidents by date
        disastersDateFiltered <- reactive({
            start <- input$dates[1]
            end <- input$dates[2]
            disasters[disasters$declarationDate > start & disasters$declarationDate < end,]
        })
        
        selected <- reactive({
            if(!interacted) {
                interacted = TRUE
                c("Drought","Earthquake","Hurricane")
            } else {
                input$incidentType
            }
        })
        
        # Set a plot variable to be displayed in the UI
        output$map <- renderPlot({
            # Filter them by type
            disastersFiltered <- disastersDateFiltered()[disastersDateFiltered()$incidentType %in% input$incidentType,]
            
            # Get totals for the values that are left
            disastersInRange <- ddply(disastersFiltered,~stateName,summarise,freq=length(stateName))
            
            # Validate inputs
            validate(
                need(nrow(disastersInRange) > 0, 'No incidents of the selected type(s) were found for this date range.\n\nPlease try adjusting your parameters for better results.')
            )
            
            # Plot on a map
            ggplot(disastersInRange, aes(map_id = stateName)) + 
                geom_map(data=all_states, fill = "#FFF8EA", color = "#444444", map=all_states, aes(map_id=region)) +
                geom_map(aes(fill = freq), map = all_states) +
                scale_fill_gradientn(colours=c("#FFF8EA","#881111")) + 
                expand_limits(x = all_states$long, y = all_states$lat) +
                ggtitle("FEMA Declared Disasters by State") +
                xlab("lon") +
                ylab("lat")
        })
        
        # Prepare dynamically generated inputs for Incident Type
        output$types <- renderUI({
            checkboxGroupInput("incidentType", "Incident Type:", levels(disastersDateFiltered()$incidentType), selected=selected())
        })
    }
)