ScientificName_input_UI<-function(id){
  ns<-NS(id)
  tagList(
    selectizeInput(ns("Scientific_Name"), "Scientific Name:",choices =NULL,
                width = '98%')
  )
  
}

VernacularName_input_UI<-function(id){
  ns<-NS(id)
  tagList(
    selectizeInput(ns("Vernacular_Name"), "Vernacular Name:",choices = NULL,
                width = '98%') 
  )
}

map_output_UI<-function(id){
  ns<-NS(id)
  tagList(
    leafletOutput(ns("species_map"))
  )
}

timeline_output_UI<-function(id){
  ns<-NS(id)
  tagList(
    plotlyOutput(ns("timeline"))
  )
}

datatable_output_UI<-function(id){
  ns<-NS(id)
  tagList(
    DT::dataTableOutput(ns("bio_data"))
  )
}



infobox_output_count_UI<-function(id){
  ns<-NS(id)
  tagList(
    infoBoxOutput(ns("Count"),width =4)
  )
}

infobox_output_kingdom_UI<-function(id){
  ns<-NS(id)
  tagList(
    infoBoxOutput(ns("Kingdom"),width =4)
  )
}

infobox_output_family_UI<-function(id){
  ns<-NS(id)
  tagList(
    infoBoxOutput(ns("Family"),width =4)
  )
}

header_map_output_UI<-function(id){
  ns<-NS(id)
  tagList(
    textOutput(ns("location_species_header"))
  )
}

header_timeline_output_UI<-function(id){
  ns<-NS(id)
  tagList(
    textOutput(ns("timeline_header"))
  )
}

header_datatable_output_UI<-function(id){
  ns<-NS(id)
  tagList(
    textOutput(ns("data_table_header"))
  )
}

default_view_UI<-function(id){
  ns<-NS(id)
  tagList(
    uiOutput(ns("default_view"))
    )
}

species_server<-function(id,data_1,data_2,data_3){
  ns<-NS(id)
  moduleServer(
    id,
    function(input,output,session){
      
      updateSelectizeInput(session, "Scientific_Name", 
                           choices = unique(data_1$scientificName),
                           selected = character(0), 
                           server=TRUE)
      
      updateSelectizeInput(session, "Vernacular_Name", 
                           choices = unique(data_1$vernacularName),
                           selected = character(0), 
                           server=TRUE)
      
      observeEvent(input$Vernacular_Name, ignoreInit = TRUE, {
        updateSelectizeInput(session, "Scientific_Name",
                             selected = data_1[data_1$vernacularName == input$Vernacular_Name, "scientificName", drop = TRUE])
      })



       observeEvent(input$Scientific_Name,{

        updateSelectizeInput(session, "Vernacular_Name",
                             selected = data_1[data_1$scientificName == input$Scientific_Name, "vernacularName", drop = TRUE])

       
        poland_data_stats<-data_1 %>% filter(scientificName==input$Scientific_Name)
        output$Count <- renderInfoBox({
          
          if (input$Scientific_Name=="") {
            infoBox(
              "Total Count of Occurrences", paste0(sum(data_1$individualCount)), icon = icon("bar-chart-o",verify_fa = FALSE),
              color = "purple"
            )}
          else{
            infoBox(
              "Total Count of Occurrences", paste0(sum(poland_data_stats$individualCount)), icon = icon("bar-chart-o",verify_fa = FALSE),
              color = "purple"
            )}
         
        })

        output$Kingdom <- renderInfoBox({
          infoBox(
            "Kingdom", paste0(unique(poland_data_stats$kingdom)), icon = icon("king", lib = "glyphicon",verify_fa = FALSE),
            color = "black"
          )
        })

        output$Family <- renderInfoBox({
          infoBox(
            "Family", paste0(unique(poland_data_stats$family)), icon = icon("heart-empty", lib = "glyphicon"),
            color = "red"
          )
        })

        ### Default view
        if(input$Scientific_Name==""){
          # title for default map
          output$location_species_header<-renderText({
            if(input$Scientific_Name==""){
              return(toupper(paste("Average position of species by locality in Poland")))
            }
          })
          # title for default timeline
          output$timeline_header<-renderText({
            if(input$Scientific_Name==""){
              return(toupper(paste("Total occurrences for each year according to Kingdom")))
            }
          })
          # title for default datatable
          output$data_table_header<-renderText({
            if(input$Scientific_Name==""){
              return(toupper(paste("Biodiversity Data")))
            }
          })

          output$bio_data <- renderDataTable({
            poland_data_subset_1<-data_1 %>% select(scientificName,kingdom,family,vernacularName,individualCount,
                                                    eventDate,Year,Locality_new,references2)
            
            colnames(poland_data_subset_1) <- c("Scientific Name","Kingdom","Family","Vernacular Name","Occurrences",
                                                "Date of Event","Year","Locality in Poland","References")
            
            datatable(poland_data_subset_1,rownames=FALSE,escape = FALSE,selection = "none",filter = "top",
                      options=list(scrollY = '300px',columnDefs = list(list(className = 'dt-head-center',targets = "_all"))))})

          output$species_map<-renderLeaflet({

            icons <- awesomeIcons(
              icon = 'ios-close',
              iconColor = 'white',
              library = 'ion',
              markerColor = "blue"
            )

            map_1<-leaflet() %>% addTiles() %>%
              addAwesomeMarkers(data = data_2,lng =~avg_long,lat =~avg_lat,group ="Locality_new",icon =icons,
                                label =~paste("Location: ",Locality_new),
                                popup =~paste(sep = "<br/>",paste("Location: ",Locality_new),
                                                            paste('Average Longitude: ',round(avg_long,2)),
                                                            paste('Average Latitude: ',round(avg_lat,2)),
                                                            paste("Number of Animalia Occurrences: ",Animalia),
                                                            paste("Number of Fungi Occurrences: ",Fungi),
                                                            paste("Number of Plantae Occurrences: ",Plantae),
                                                            paste("Number of Undetermined Occurrences: ",Undetermined)))

            map_1

             })

          output$timeline <- renderPlotly({

            timeline_default <- plot_ly(data_3, type = 'scatter', mode = 'lines+markers')%>%
              add_trace(x = ~Year, y = ~Animalia, name = 'Animalia')%>%
              add_trace(x = ~Year, y = ~Fungi, name = 'Fungi')%>%
              add_trace(x = ~Year, y = ~Plantae, name = 'Plantae')%>%
              add_trace(x = ~Year, y = ~Undetermined, name = 'Undetermined')%>%
              layout(showlegend = T) %>%
              layout(legend=list(title=list(text='Kingdom')), yaxis = list(title = 'Sum of Occurrences'))

            timeline_default

          })


        }else{
          
          poland_data_3<-data_1 %>% filter(scientificName==input$Scientific_Name)
          
          # show default view button
          output$default_view<-renderUI({
            actionButton(ns("default_view_1"),"Reset to Default View")
          })
          # title for map filtered by scientificName
          output$location_species_header<-renderText({
            if(input$Scientific_Name!=""){
              return(toupper(paste0("Location of observed species for ",input$Scientific_Name)))
            }
          })
          # title for timeline filtered by scientificName
          output$timeline_header<-renderText({
            if(input$Scientific_Name!=""){
              return(toupper(paste0("Total occurrences of species for ",input$Scientific_Name," according to date of event")))
            }
          })
          # title for datatable filtered by scientificName
          output$data_table_header<-renderText({
            if(input$Scientific_Name!=""){
              return(toupper(paste0("Biodiversity data filtered by ",input$Scientific_Name)))
            }})

          output$bio_data <- renderDataTable({
            poland_data_subset_1<-data_1 %>% select(scientificName,kingdom,family,vernacularName,
                                                    individualCount,eventDate,Year,Locality_new,references2)
            
            poland_data_filter_sceintific_name<-poland_data_subset_1 %>% filter(scientificName==input$Scientific_Name)
            
            colnames(poland_data_filter_sceintific_name) <- c("Scientific Name","Kingdom","Family","Vernacular Name",
                                                              "Occurrences","Date of Event","Year","Locality in Poland","References")
            
            datatable(poland_data_filter_sceintific_name,rownames=FALSE,escape =FALSE,filter = "top",
                      options = list(scrollY = '300px',columnDefs = list(list(className = 'dt-head-center',targets = "_all"))))})
          
          
          output$species_map<-renderLeaflet({

           map_2<-leaflet() %>% addTiles() %>%
                                addCircleMarkers(data = poland_data_3,stroke = TRUE,weight = 0.9, opacity=0.9,color="#CD5555",
                                                radius=10,fillOpacity=0.8,lng =~longitudeDecimal,lat =~latitudeDecimal,
                                                label=~paste("Scientific Name: ",input$Scientific_Name),
                                                popup =~paste(sep = "<br/>",
                                                         paste('Number of Occurrences: ',individualCount),
                                                         paste('Uncertainty of Location in Metres: ',coordinateUncertaintyInMeters),
                                                         paste('Reference Link: ','<a href = ',references,'> Click here for more info </a>'),
                                                         paste('Image Link: ','<a href =' ,accessURI,'>',paste(accessURI),'</a>'),
                                                         paste('Event Date: ',eventDate)))

            map_2
            
               })
          
          observeEvent(input$bio_data_rows_selected,{
           
            if(length(input$bio_data_rows_selected)>0) {
              
              output$species_map<-renderLeaflet({
              map_3<-leaflet(rbind(poland_data_3,poland_data_3[input$bio_data_rows_selected,])) %>% 
                        addTiles() %>%
                        addCircleMarkers(data = poland_data_3,stroke = TRUE,weight = 0.9, opacity=0.9,color="#CD5555",radius=10,
                                        fillOpacity=0.8,lng =~longitudeDecimal,lat =~latitudeDecimal,
                                        label=~paste("Scientific Name: ",input$Scientific_Name),
                                        popup =~paste(sep = "<br/>",
                                                paste('Number of Occurrences: ',individualCount),
                                                paste('Uncertainty of Location in Metres: ',coordinateUncertaintyInMeters),
                                                paste('Reference Link: ','<a href = ',references,'> Click here for more info </a>'),
                                                paste('Image Link: ','<a href =' ,accessURI,'>',paste(accessURI),'</a>'),
                                                paste('Event Date: ',eventDate))) %>%
                       addCircleMarkers(data = poland_data_3[input$bio_data_rows_selected,],stroke = TRUE,weight = 0.9, 
                                        opacity=0.9,color="blue",radius=10,fillOpacity=0.8,lng =~longitudeDecimal,lat =~latitudeDecimal,
                                        label=~paste("Scientific Name: ",input$Scientific_Name),
                                        popup =~paste(sep = "<br/>",
                                                     paste('Number of Occurrences: ',individualCount),
                                                     paste('Uncertainty of Location in Metres: ',coordinateUncertaintyInMeters),
                                                     paste('Reference Link: ','<a href = ',references,'> Click here for more info </a>'),
                                                     paste('Image Link: ','<a href =' ,accessURI,'>',paste(accessURI),'</a>'),
                                                     paste('Event Date: ',eventDate)))
              
              map_3
              })
          
          }})
          

          output$timeline <- renderPlotly({
            
            poland_data_timeline <- data_1 %>%
            filter(scientificName==input$Scientific_Name) %>%
            group_by(eventDate) %>%
            summarize(sum_occurrences =sum(individualCount))

            colnames(poland_data_timeline) <- c("Date","Sum of Occurrences")

            timeline <- ggplot(poland_data_timeline,aes(x=Date,y=`Sum of Occurrences`) )+
                        geom_segment(data=poland_data_timeline, aes(y=`Sum of Occurrences`,yend=0,xend=Date), color='black', size=0.1) +
                        geom_point(aes(y=`Sum of Occurrences`),size=2,color="#8B475D") +
                        scale_x_date(limits = c(min(poland_data_timeline$Date),max(poland_data_timeline$Date)),date_breaks = "2 year",
                                      date_labels =  "%Y")+
                        scale_y_continuous(expand = c(0, 0), limits = c(0, max(poland_data_timeline$`Sum of Occurrences`)+8))+
                       theme(axis.line.y=element_blank(), axis.text.y=element_blank(),axis.title.y=element_blank(),axis.ticks.y=element_blank())

            timeline_filter <- ggplotly(timeline)
            
            timeline_filter

          } )


        }

      })
      
      
      

      observeEvent(input$default_view_1,{
              if(input$Vernacular_Name!=""|input$Scientific_Name!=""){
                updateSelectInput(session,"Scientific_Name",choices =c("",unique(data_1$scientificName)))
                updateSelectInput(session,"Vernacular_Name",choices =c("",unique(data_1$vernacularName)))
        }
      })
      
    }
  )
}




