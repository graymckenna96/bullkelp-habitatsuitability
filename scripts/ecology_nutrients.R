# Ecology Nutrient Data Script
# Gray McKenna
# 2022-04-03

# Purpose: Calculate nutrients in winter and summer at each station 

#### LOAD DATA AND LIBRARIES ####

library(tidyverse)
library(tibbletime)

df <- read.csv("./data/EcologyNutrientData.csv")

str(df)
head(df)

#### PREP DATA FOR ANALYSIS ####

# Filter data for rows where all Nutrient QC codes = 2 (data passed their quality check)

df <- df %>% filter(NH4_QC == 2 & NO2_QC == 2 & NO3_QC == 2)

# Calculate DIN by adding NH4, NO2, and NO3 (all are in uM)

df$DIN <- df$NH4_Lab + df$NO2_Lab + df$NO3_Lab

# Order df by ascending date (required for using tibble time package)

df$Date <- as.Date(df[,1:1], "%m/%d/%Y") # format date column
df <- df[order(df$Date),]

# Covert df to tibble time for analysis 

df <- as_tbl_time(df, index = Date)


#### CALCULATE WINTER NUTRIENTS AT DEPTH ####

# make a "winter" copy of df to manipulate 

winter <- df

# filter for depth = 0

winter <- winter %>% filter(NominalDepth == "10" | NominalDepth == "10J")

# filter for winter months. dataset starts Jan 2010 and goes to Dec 2019
# Since there are few observations, we will use all data where we have a complete winter time series

winter2011 <- as.data.frame(winter %>% filter_time(time_formula = "2010-11" ~ "2011-05"))
winter2012 <- as.data.frame(winter %>% filter_time(time_formula = "2011-11" ~ "2012-05"))
winter2013 <- as.data.frame(winter %>% filter_time(time_formula = "2012-11" ~ "2013-05"))
winter2014 <- as.data.frame(winter %>% filter_time(time_formula = "2013-11" ~ "2014-05"))
winter2015 <- as.data.frame(winter %>% filter_time(time_formula = "2014-11" ~ "2015-05"))
winter2016 <- as.data.frame(winter %>% filter_time(time_formula = "2015-11" ~ "2016-05"))
winter2017 <- as.data.frame(winter %>% filter_time(time_formula = "2016-11" ~ "2017-05"))
winter2018 <- as.data.frame(winter %>% filter_time(time_formula = "2017-11" ~ "2018-05"))
winter2019 <- as.data.frame(winter %>% filter_time(time_formula = "2018-11" ~ "2019-05"))

# Combine each winter back to one dataset 

winterN <- rbind(winter2011, winter2012, winter2013, winter2014, winter2015, winter2016, 
                 winter2017, winter2018, winter2019)

# Visualize results, look for outliers

winterNplot <- ggplot(winterN, aes(x=Date))
winterNplot + geom_point(aes(y=NH4_Lab), color = "blue") +
  geom_point(aes(y=NO2_Lab), color = "green") + 
  geom_point(aes(y=NO3_Lab), color = "red") +
  geom_point(aes(y=DIN), color = "black")
ggsave("./output/winterNplot.png")
# Looks ok. 

# Calculate mean NH4, No2, and NO3 AND DIN for each station

meanwinterN <- as.data.frame(winterN %>% group_by(Station) %>% 
  summarise(WinterMeanNH4 = mean(NH4_Lab), WinterMeanNO2 = mean(NO2_Lab), 
            WinterMeanNO3 = mean(NO3_Lab), WinterMeanDIN = mean(DIN)))

# Visualize result 

meanwinterNplot <- ggplot(meanwinterN, aes(x=Station))
meanwinterNplot + geom_point(aes(y=WinterMeanNH4), color = "blue") +
  geom_point(aes(y=WinterMeanNO2), color = "green") + 
  geom_point(aes(y=WinterMeanNO3), color = "red") +
  geom_point(aes(y=WinterMeanDIN), color = "black")
ggsave("./output/meanwinterNplot.png")

# Write .csv to join to layer in ArcGIS pro

write.csv(meanwinterN, file = "./output/Ecology_MeanWinterNutrients.csv")

#### CALCULATE MEAN SUMMER SURFACE NUTRIENTS ####

# create a copy of df to manipulate

summer <- df

# filter for summer dates (June - Sep)

sum2010 <- as.data.frame(summer %>% filter_time(time_formula = "2010-06" ~ "2010-09"))
sum2011 <- as.data.frame(summer %>% filter_time(time_formula = "2011-06" ~ "2011-09"))
sum2012 <- as.data.frame(summer %>% filter_time(time_formula = "2012-06" ~ "2012-09"))
sum2013 <- as.data.frame(summer %>% filter_time(time_formula = "2013-06" ~ "2013-09"))
sum2014 <- as.data.frame(summer %>% filter_time(time_formula = "2014-06" ~ "2014-09"))
sum2015 <- as.data.frame(summer %>% filter_time(time_formula = "2015-06" ~ "2015-09"))
sum2016 <- as.data.frame(summer %>% filter_time(time_formula = "2016-06" ~ "2016-09"))
sum2017 <- as.data.frame(summer %>% filter_time(time_formula = "2017-06" ~ "2017-09"))
sum2018 <- as.data.frame(summer %>% filter_time(time_formula = "2018-06" ~ "2018-09"))
sum2019 <- as.data.frame(summer %>% filter_time(time_formula = "2019-06" ~ "2019-09"))

# combine back to one data frame 

summerN <- rbind(sum2010, sum2011, sum2012, sum2013, sum2014, sum2015, sum2016, 
                 sum2017, sum2018, sum2019)

# Visualize result, look for outliers
summerNplot <- ggplot(summerN, aes(x=Date))
summerNplot + geom_point(aes(y=NH4_Lab), color = "blue") +
  geom_point(aes(y=NO2_Lab), color = "green") + 
  geom_point(aes(y=NO3_Lab), color = "red") +
  geom_point(aes(y=DIN), color = "black")
ggsave("./output/summerNplot.png")

# Calculate mean NH4, No2, and NO3 AND DIN for each station

meansummerN <- as.data.frame(summerN %>% group_by(Station) %>% 
                               summarise(SummerMeanNH4 = mean(NH4_Lab), SummerMeanNO2 = mean(NO2_Lab), 
                                         SummerMeanNO3 = mean(NO3_Lab), SummerMeanDIN = mean(DIN)))

# Visualize result 

meansummerNplot <- ggplot(meansummerN, aes(x=Station))
meansummerNplot + geom_point(aes(y=SummerMeanNH4), color = "blue") +
  geom_point(aes(y=SummerMeanNO2), color = "green") + 
  geom_point(aes(y=SummerMeanNO3), color = "red") +
  geom_point(aes(y=SummerMeanDIN), color = "black")
ggsave("./output/meansummerNplot.png")

# Looks ok

# write csv to join to layer in pro

write.csv(meansummerN, file = "./output/Ecology_MeanSummerNutrients.csv")

# Next steps are to bring csv files into pro for interpolation