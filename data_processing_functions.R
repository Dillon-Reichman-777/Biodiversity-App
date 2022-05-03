
cleaned_data<-function(data){
  # subset data for relevant columns 
  poland_species_subset<-data %>% select(scientificName,kingdom,family,vernacularName,individualCount,
                                                        longitudeDecimal,latitudeDecimal,coordinateUncertaintyInMeters,
                                                        locality,eventDate,references,accessURI)
  # creating urls for reference links
  
  poland_species_subset$references2 <- sapply(poland_species_subset$references, function(x) paste('<a href =',x,'>',paste(x),'</a>'))
  
  # replace missing values 
  poland_species_subset$accessURI[is.na(poland_species_subset$accessURI)]<-"Undetermined"
  poland_species_subset$vernacularName[is.na(poland_species_subset$vernacularName)]<-"Unknown"
  poland_species_subset$kingdom[is.na(poland_species_subset$kingdom)]<-"Undetermined"
  
  # ensure eventDate is of type date
  
  poland_species_subset$eventDate<-as.Date(poland_species_subset$eventDate,format="%Y-%m-%d")
  
  poland_species_subset<-poland_species_subset %>% mutate(Year=as.numeric(format(poland_species_subset$eventDate,"%Y")))
  
  # create additional col for locality excluding the word Poland 
  location_vec<-c()
  
  for (i in poland_species_subset$locality) {
    if (grepl("-",i,fixed = TRUE)) {
      string<-strsplit(i,"-")
      location<-string[[1]][2]
      location_no_white_space<-trimws(location,which="left")
      location_vec<-c(location_vec,location_no_white_space)
    }else{
      string<-strsplit(i,"/")
      location<-string[[1]][2]
      location_no_white_space<-trimws(location,which="left")
      location_vec<-c(location_vec,location_no_white_space)
    }
  }
  
  # append location_vec to poland_species_subset
  
    poland_species_subset$Locality_new<-location_vec
  
  
  dups<-poland_species_subset[duplicated(poland_species_subset),]
  # check to see if any duplicates in the data exist 
  if(nrow(dups)!=0){
    poland_species_subset<-poland_species_subset %>% distinct()
  }
  
  return(list(poland_species_subset,length(location_vec),nrow(poland_species_subset),sum(is.na(poland_species_subset)),
              any("-"==location_vec),any("/"==location_vec)))
  

}

data_default_map_veiw<-function(data){
  
  # call cleaned_data() function
  
  cleaned_data_new<-cleaned_data(data)[[1]]
  
  # obtain average geo_coordinates for each locality
  # obtain sum of individual counts within each locality according to kingdom
  
    df_avg_geocodes<-cleaned_data_new %>% group_by(Locality_new) %>% summarise(avg_long=mean(longitudeDecimal),avg_lat=mean(latitudeDecimal))
    df_kingdom<-dcast(data =cleaned_data_new,formula =Locality_new~kingdom,fun.aggregate = sum,value.var ="individualCount")
    
  # combine both df's using a left join
    combined_data<-left_join(df_avg_geocodes,df_kingdom,by=c("Locality_new"="Locality_new"))
    
  return(list(combined_data,nrow(df_avg_geocodes),nrow(combined_data)))
  
}

data_default_timeline<-function(data){
  
  # call cleaned_data() function
  cleaned_data_new_2<-cleaned_data(data)[[1]]
  
  # pivot data for year grouped by kingdom 
  df_timeline_pivot<-dcast(data =cleaned_data_new_2,formula =Year~kingdom,fun.aggregate = sum,value.var ="individualCount")
  
  return(list(df_timeline_pivot,length(colnames(df_timeline_pivot)),length(unique(cleaned_data_new_2$kingdom))+1))
}



