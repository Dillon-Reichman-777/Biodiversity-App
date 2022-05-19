
source("packages.R")
source("data_processing_functions.R")
# creating merge conflict
# Read data into R
#testing branch creation


# creating merge conflict 2


# hello world 
# hey


poland_species_data <- read_excel("poland_data_image_url.xlsx",guess_max = 50000,sheet = "Sheet 1")
poland_data<-cleaned_data(poland_species_data)[[1]]
poland_data_default_map_view<-data_default_map_veiw(poland_species_data)[[1]]
timeline_data_defualt<-data_default_timeline(poland_species_data)[[1]]

source("modules.R")
# source("unit_tests/test_cleaned_data.R")
# source("unit_tests/test_data_default_map_view.R")
# source("unit_tests/test_data_default_timeline.R")

sidebar<-dashboardSidebar(
    sidebarMenu(    
    menuItem("Dashboard", tabName = "dashboard_2", icon = icon("dashboard",verify_fa = FALSE)),

    menuItem("Filters", icon = icon("filter", lib = "glyphicon",verify_fa = FALSE),
          
           menuSubItem(icon = NULL,ScientificName_input_UI(id="id_1")),
           menuSubItem(icon = NULL,VernacularName_input_UI(id="id_1"))),
    
    menuItem(icon = NULL,default_view_UI(id="id_1"))
    )
)

body<-dashboardBody( 
    tabItems(
        tabItem(tabName = "dashboard_2",

                fluidRow(
                    style="height:100px;",
                    infobox_output_count_UI(id="id_1"),
                    infobox_output_kingdom_UI(id="id_1"),
                    infobox_output_family_UI(id="id_1")

                ),


                fluidRow(box(title = header_map_output_UI(id="id_1"),status = "info",solidHeader = T,width =6,map_output_UI(id="id_1")),
                         box(title = header_timeline_output_UI(id="id_1"),status ="info",solidHeader = T,width = 6,timeline_output_UI(id="id_1"))),
                    

                fluidRow(box(title =header_datatable_output_UI(id="id_1"),status = "info",solidHeader =T,width = 12,datatable_output_UI(id="id_1")))
        )
        

    ))

title <- tags$a(href="https://www.gbif.org/occurrence/search?dataset_key=8a863029-f435-446a-821e-275f4f641165",
                tags$img(src="Biodiversity_icon.png",height='40',width='40'),
                "BIODIVERSITY APP")

ui <- tagList(
  tags$head(
    tags$link(rel = "stylesheet"),
    tags$title("Data for Good")
  ),
  dashboardPage(skin = "black",
    dashboardHeader(title = title, titleWidth = 300),
    sidebar,
    body

)
)

server <- function(input, output,session) {
  
  

species_server(id="id_1",poland_data,poland_data_default_map_view,timeline_data_defualt)
  
}

shinyApp(ui, server)




        



