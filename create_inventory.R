#Script matching tree dbh with sapflow data in both CB and LE synoptic sites
#The inventory CSVs were downloaded from the COMPASS drive - you must make sure they have the same column labels here for matching 
#Roberta Peixoto in 3-12-2026 

#Load packages
library(tidyr)
library(readr)
library(dplyr)
library(stringr)


#########################################   LE
#Load dataframes
LE_sapflow_inventory <- read.csv("LE_sapflow_inventory.csv")
LE_dbh_inventory <- read.csv("LE_TreePlotInventory.csv")

#Merge dataframes 
LE_inventory <- merge(LE_sapflow_inventory, LE_dbh_inventory, 
                   by = c("Site", "Tag"), all.x = TRUE)%>%
               dplyr::select(-"Table") # removing because there is no datalogger Table in the CB inventory

#########################################   CB
#Load dataframes
CB_sapflow_inventory <- read.csv("CB_sapflow_inventory.csv")
CB_dbh_inventory <- read.csv("CB_TreePlotInventory.csv")

#Merge dataframes 
CB_inventory <- merge(CB_sapflow_inventory, CB_dbh_inventory, 
                      by = c("Site", "Tag"), all.x = TRUE)

#########################################   Combinign info from LE and CB
LE_inventory <- LE_inventory[, !grepl("^X", names(LE_inventory))]
CB_inventory <- CB_inventory[, !grepl("^X", names(CB_inventory))]

inventory_all <- rbind(LE_inventory, CB_inventory)%>%
                 mutate(Sensor_ID = ifelse(str_detect(Tree_Code, "[-_]"),
                                           str_extract(Tree_Code, "(?<=[-_])[^-_]+$"),
                                           Tree_Code),
                        Sensor_ID = str_replace(Sensor_ID, "^([0-9]+)D$", "\\1"),
                        Sensor_ID = ifelse(str_detect(Sensor_ID, "^[0-9]+$"),
                                           as.character(as.numeric(Sensor_ID)),
                                           Sensor_ID),
                        Sensor_ID = ifelse(Sensor_ID %in% c("", "D"), NA, Sensor_ID))
  
#Save as RDS
saveRDS(inventory_all, file = "dbh.rds")
