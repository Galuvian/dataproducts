library(ggplot2)
library(maps)
library(mapproj)

states <- read.table("data/states.csv", sep = ",", quote="\"", header=TRUE)
states$name <- tolower(states$Name)
states$Abbr <- tolower(states$Abbr)

ui_states <- as.character(states$Name)
ui_states <- rbind(c("All",ui_states))


fsc_data <- read.table("data/FSC.csv", sep = ",", quote="\"", header=TRUE)


mapcounties <- map_data("county")
mapstates <- map_data("state")

raw_data <- read.table("data/raw_data.csv", sep = ",", quote="\"", header=TRUE)


equip_data <- raw_data
equip_data$state <- tolower(equip_data$State)
equip_data$county <- tolower(equip_data$County)

agg1 <- aggregate(I(Quantity * Acquisition.Cost) ~ state + county, data=equip_data, FUN=sum )

colnames(agg1) <- c("state","county","total")

#bins <- quantile(agg1$total, 0:10/10,names=FALSE)
bins <- c(0,10000,25000,50000,100000,1000000,10000000,100000000)
binLabels <- c(">$0",">$10,000",">$25,000",">$50,000",">$100,000",">$1,000,000",">$10,000,000",">$100,000,000")

agg2 <- agg1
agg2$bin <- findInterval(agg2$total,bins)
agg2$bin2 <- as.factor(bins[agg2$bin])
agg2$bin3 <- formatC(agg2$bin2, format="d", big.mark=',')
agg2$bin4 <- paste('$',agg2$bin3,sep='')

agg2 <- merge(agg2,states,by.x="state",by.y="Abbr")
agg2$state.county <- with(agg2,paste(name,county,sep=","))


mapcounties$county <- with(mapcounties , paste(region, subregion, sep = ","))
mergedata <- merge(mapcounties, agg2, by.x = "county", by.y = "state.county")
mergedata <- mergedata[order(mergedata$order),]


myColors2 <- c( "#EEF0FC",
  "#B5BBDE",
  "#929BCC",
  "#7480BD",
  "#5869B1",
  "#3A53A8",
  "#023FA5" ,         
               "#8A1923")

getDefaultMap <- function() {
  
  map <- ggplot(mergedata, aes(long,lat,group=group)) + geom_polygon(aes(fill=bin2))
  map <- map +
    coord_map(project="globular") +
    #scale_fill_brewer(palette="Accent")
    scale_fill_manual(values=myColors2,labels=binLabels,name="Total $")
  
  map <- map + geom_path(data = mapcounties, colour = "white", size = .5, alpha = .1)
  map <- map + geom_path(data = mapstates, colour = "white", size = .75)
  map
}

defaultMap <- getDefaultMap()

shinyServer(
  function(input,output) {
    output$choose_state <- renderUI({
      selectInput("state", "State", ui_states)
    })
    
    selected_state <- reactive(input$state)
    
    output$mainGraph <- renderPlot({

      
      if(!is.null(input$state) && input$state !="All")
      {
      
        chosenState <- states[states$Name==input$state,]
        graphData <- mergedata[mergedata$state==chosenState$Abbr,]
        graphCounties <- mapcounties[mapcounties$region==chosenState$name,]
        graphStates <- mapstates[mapstates$region==chosenState$name,]
      
      } else {
        return(defaultMap)
      }
      
      
    
      
      

      map <- ggplot(graphData, aes(long,lat,group=group)) + geom_polygon(aes(fill=bin2))
      map <- map +
        coord_map(project="globular") +
        #scale_fill_brewer(palette="Accent")
        scale_fill_manual(values=myColors2,labels=binLabels,name="Total $")
    
        
      
      #draw state lines
      map <- map + geom_path(data = graphStates, colour = "white", size = .75)
      #draw county lines
      map <- map + geom_path(data = graphCounties, colour = "white", size = .5, alpha = .1)
      
      
      map
      
      
    })
  }
)

