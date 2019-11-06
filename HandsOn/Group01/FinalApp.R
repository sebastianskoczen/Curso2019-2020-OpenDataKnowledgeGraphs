#devtools::install_github("dkahle/ggmap", ref = "tidyup")
#install.packages("digest", type="source")
library(ggplot2)
library(ggmap)
library(redland)
library(rdflib)
library(tidyverse)
library(RColorBrewer)

doc <- "https://raw.githubusercontent.com/sebastianskoczen/Curso2019-2020-OpenDataKnowledgeGraphs/master/HandsOn/Group01/rdf/dataset-sample.rdf"
rdf <- rdf_parse(doc, format="rdfxml")

sparql <-
  'PREFIX yess:  <http://smartcity.linkeddata.es/YESS/ontology/ontologyExample#>
   PREFIX  wgs:  <http://www.w3.org/2003/01/geo/wgs84_pos#>
SELECT ?timestamp ?speed ?lat ?lon
WHERE {
?measurement  a yess:Measurement;
              yess:measuredIn ?segment;
              yess:speed ?speed;
              yess:timeStamp ?timestamp.

?segment      a yess:Segment;
              yess:startPoint ?point;
              yess:endPoint ?endPoint.

?point        a wgs:Point;
              wgs:lat ?lat;
              wgs:long ?lon.

              
} LIMIT 1000'

results <- rdf_query(rdf, sparql, data.frame = TRUE)

ggmap::register_google(key = "AIzaSyCconY2IAqvbPrK-Yc8w_YZ3showplPTF4")
getOption("ggmap")

p <- ggmap(get_googlemap(center = c(lon = -87.6298, lat = 41.8781),
                         zoom = 11, scale = 2,
                         maptype ='terrain',
                         color = 'color'))


p + stat_density2d(
  aes(x = lon, y = lat, fill = ..level.., alpha = 0.25),
  size = 0.01, bins = 30, data = results,
  geom = "polygon"
) +
  scale_fill_distiller(palette= 'RdYlGn')+
  geom_density2d(data = results, 
                 aes(x = lon, y = lat), size = 0.3
                 )+
  labs(title =" Traffic Congestion", x = "Longitude", y = "Latitude")+
  theme(
    plot.title = element_text( color= "grey45", size=14, face="bold.italic", family="Times"),
    axis.title.x = element_text(color= "grey45", size=12, face="bold",family="Times"),
    axis.title.y = element_text(color= "grey45", size=12, face="bold",family="Times")
  )
  
