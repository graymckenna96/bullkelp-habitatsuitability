# Ecology EIM Data 
# Gray McKenna
# 2022-04-10

# Purpose: calculate a series of summary tables to append to ArcGIS Pro points feature class from Ecology CTD Data


#### LOAD DATA & LIBRARIES ####

library(tidyverse)

light <- read.csv("./data/EIMContinuousDepthSeriesData_2022Apr10_800961.csv")

#### PREP LIGHT DATA ####

str(light)

# Convert date field to date format 

light$Date <- as.Date(light$Field_Collection_Date, format = "%m/%d/%Y")

# Create month and year variables for filtering later

light$month <- lubridate::month(light$Date)
light$year <- lubridate::year(light$Date)

#### CALCULATE mean winter max at 10m for Feb - May, 2007-2017 ####

mean.winter.daily.max.light <- light %>% filter(
  Depth_Value == 10, 
  month %in% 2:5, 
  year %in% 2007:2017
) %>% group_by(Location_Name, Date) %>% summarise(
  MaxDailyLight = max(Result_Value)
) %>% summarise(
  MeanMaxDailyLight = mean(MaxDailyLight)
)

# Visualize results 

winterlightplot <- ggplot(mean.winter.daily.max.light, aes(x=Location_Name, y=MeanMaxDailyLight))
winterlightplot + geom_point()
ggsave("./output/winterlightplot.png")
# Looks good, save 

write.csv(mean.winter.daily.max.light, file = "./output/EcologyLight_MeanWinterMax10m_2007_2017.csv")

#### CALCULATE mean summer max at >=1m for June - Sep, 2007-2017 ####

mean.summer.daily.max.light <- light %>% filter(
  Depth_Value >= 1, 
  month %in% 6:9, 
  year %in% 2007:2017
) %>% group_by(Location_Name, Date) %>% summarise(
  MaxDailyLight = max(Result_Value)
) %>% summarise(
  MeanMaxDailyLight = mean(MaxDailyLight)
)

# Visualize

summerlightplot <- ggplot(mean.summer.daily.max.light, aes(x=Location_Name, y=MeanMaxDailyLight))
summerlightplot + geom_point()
ggsave("./output/summerlightplot.png")
# Looks fine, write csv

write.csv(mean.summer.daily.max.light, file = "./output/EcologyLight_MeanSummerMax1m_2007_2017.csv")

# Check how many data points went into means

nlight <- light %>% filter(
  Depth_Value == 10, 
  month %in% 2:5, 
  year %in% 2007:2017
) %>% summarise(
  n = n()
)

nlight
