# Biodiversity App

Link to the app: [Data for Good](https://dillon-reichman777.shinyapps.io/Bio_Diversity/).

This is the README file for an app created to visualise data based on that from the [Global Biodiversity Information Facility](https://www.gbif.org/occurrence/search?dataset_key=8a863029-f435-446a-821e-275f4f641165), with a particular focus on observations from Poland. 

## Overview of App Folder Structure:

* '*app.R*' incorporates the UI and server part of the app.
* '*Packages*' is an R script containing the packages used in the app. This is sourced into '*app.R*'.
* '*Unit Tests*' is a folder containing the unit tests for each function created in the app. This is sourced in '*app.R*' during testing of the app. 
* '*modules*' consists of UI and server functions. This is where the components of the app are incorporated. This is also sourced into '*app.R*'.
* '*www*' is a folder containing the png image used in the header of the app.

## Data Pre-processing:

### Data Pre-processing Outside of the App

The data was downloaded and extracted resulting in two CSV files: '*occurrence*' and '*multimedia*'. The '*occurrence*' data was imported into SQL using PostgreSQL. A connection to this database was made in R, from which the observations were filtered to include only those from Poland. The resulting data for Poland was then merged with the '*multimedia*' data. This version of the data is what is used in the Shiny app. 

Due to the size of the '*occurence*' data, this process was performed outside of the app in order to maintain the speed and performance of the app.

### Additional Data Pre-processing within the App

Functions were created for additional data pre-processing within the app. This includes the following: 
* '*cleaned_data*' which subsets the data for the relevant attributes, converts data types, creates new attributes, imputes for missing data and checks for duplicates. 
* '*data_default_map_view*' uses the resulting data from the previous function and performs an aggregation of the geo-coordinates according to locality, aggregates kingdom by locality and joins the two aggregated data sets. This is the data that is used in the map for the default view.
* '*data_default_timeline*' calls the data from the '*cleaned_data*' function and determines the total number of occurrences according to the kingdom for each year. This is used in a timeline plot for the default view.

## Unit Tests:

Each of the data pre-processing functions are tested using unit tests that exist within the unit test folder. 

## Components of the App:

* The '*Filters*' element consists of two dropdown boxes to select the species by the Scientific name or the Vernacular name. The two are connected to each other such that as one is selected, the selection for the other is autofilled with the corresponding name. Upon selection of either, a button appears to allow the user to go back to the default view of the app where no selection is made. The user can also erase their selection to go back to the default view. The user can also search for the names in either dropdown box.

* The three boxes in the top of the app give some descriptive measures/additonal information of the data when a Scientific or Vernacular name is selected. This includes:
    * '*TOTAL COUNT OF OCCURRENCES*' which provides the sum of the indidivual counts/occurrences for the selected species. 
    * '*KINGDOM*' which gives the kingdom that the selected species belongs to.
    * '*FAMILY*' which gives the family that the selected species belongs to.

* The app further contains a map, timeline plot and data table which update according to the filters.

## Default View of the App:

### Map:
The map for the deafult view displays the average position/GPS coordinates of all of the observations within each locality of Poland. When a point on the map is selected, a pop-up will display further information pertaining to the point.

### Timeline Plot:
This plot provides a sum of the occurrences/individual counts according to the kingdom of the species over the years for the full data set.

### Data Table:
This provides a table of the raw observations within Poland. 

## Filtered View of the App:

### Map:
The map displays the locations of the observations for the selected species according to the Scientific or Vernacular name. When a point on the map is selected, a pop-up will display further information pertaining to the observation, which includes a link to the reference and image (if available) of the selected species. Points on the map can be zoomed into.

### Timeline Plot:
This plot provides a sum of the occurrences/individual counts of the selected species according to the date of the observations. The height of the vertical lines correspond to the sum of the occurrences. The plot is interactive such that segments of it can be zoomed into.

### Data Table:
This provides a table of the raw observations for the selected species. Rows of this data can be selected which will display the corresponding observation on the map in blue. 

## Further Considerations for the App in Future:
* The full data from the [Global Biodiversity Information Facility](https://www.gbif.org/occurrence/search?dataset_key=8a863029-f435-446a-821e-275f4f641165) can be piped into the app using an API (integration). 

* The data can be integrated into the app using a server database which would allow for easier integration of the large data into the app. 

* Ways of optimising the code can be considered to reduce the loading time. 

* Using JavaScripts, CSS and HTML, the functionality of the app can be enhanced beyond Shiny and make it look more visually appealing. 
