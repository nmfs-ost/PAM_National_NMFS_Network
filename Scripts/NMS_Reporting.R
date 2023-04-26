# NOAA National Marine Sanctuary Permit MULTI-2019-005 - this script will return the final report
# All activities conducted in National Marine Sanctuary waters must be reported annually for given time range
# Ensure that the sanctuary column of the deployment details spreadsheet is filled in before running this script

# Lines to update
  # Set your working directory in line 12
  # Set the reporting date range (start and end date) in line 38
  # Edit line 51 if you want to include Chumash Heritage National Marine Sanctuary in report
  # Set the path to save file output in line 61

#SET WORKING DIRECTORY AND LOAD PACKAGES
setwd('Path to working directory')
library(readr)
library(tidyr)
library(lubridate)

# Import Deployment Details
deployDetails <- read_csv("Deployment Details - NEW DEPLOYMENT TO SAVE.csv")

# We will record all drifts (planned and opportunistic) and towed arrays for given reporting year
# Notify permit coordinators that all sightings have been reported through the SpotterPro app

#CLEAN/EXTRACT DRIFT AND TOWED ARRAY DATA
# Subset and rename required permit columns
sanctDeployments <- subset(deployDetails, select = c(`Date- UTC`, Project, DeploymentID, Cruise, SanctuaryPermit, `Status \n"In Prep" -  preparing buoy for deployment\n"Active" - at sea and we plan to recover\n"Lost" - at sea but unlikely we can recover\n“Sunk” - only recovered partial buoy, assumed dead, sunk, and highly unlikely to recover\n“Complete” -  buoy recovered and data is in house`,
                                                     Platform, Deployment_Latitude, Deployment_Longitude,
                                                     Deployment_Date_UTC,	`Deployment_Depth_m\n`,	`Deploy Vessel`,
                                                     Recovery_Date_UTC,	Recovery_Latitude,	Recovery_Longitude,
                                                     Retrieve_Vessel, `Data_Start_UTC (defined once data is recovered by scanning LTSA)`,	
                                                     `Data_End_UTC (defined once data is recovered by scanning LTSA)`, Notes))

colnames(sanctDeployments) <- c('Date', 'Project', 'Deployment ID',	'Cruise',	'Sanctuary',	'Status',	'Platform',	'Deployment_Latitude',
                                'Deployment_Longitude', 'Deployment_Date_UTC', 'Deployment_Depth_m', 'Deploy_Vessel', 'Recovery_Date_UTC',
                                'Recovery_Latitude',	'Recovery_Longitude',	'Retrieve_Vessel', 'Data_Start', 'Data_End',	'Notes')

# Subset drifts by reporting date range
sanctDeployments$Date <- mdy(sanctDeployments$Date)
sanctDeployments <- sanctDeployments[sanctDeployments$Date >= ymd("Start Date") & sanctDeployments$Date <= ymd("End Date"),]

# Remove additional date column
sanctDeployments <- subset(sanctDeployments, select = c(Project, `Deployment ID`,	Cruise,	Sanctuary,	Status,	Platform,	Deployment_Latitude,
                                                        Deployment_Longitude, Deployment_Date_UTC, Deployment_Depth_m, Deploy_Vessel, Recovery_Date_UTC,
                                                        Recovery_Latitude, Recovery_Longitude, Retrieve_Vessel, Data_Start, Data_End, Notes))

# Subset only drifts in sanctuary waters
sanctDeployments <- subset(sanctDeployments, !is.na(Sanctuary))
sanctDeployments <- subset(sanctDeployments, Sanctuary != 'No NMS entered')

# Remove drifts in proposed Chumash Heritage National Marine Sanctuary 
# Do not run this line if permit coordinators ask for drifts within this sanctuary as well
sanctDeployments <- subset(sanctDeployments, Sanctuary != 'CHNMS')

# Clean dates 
sanctDeployments$Deployment_Date_UTC <- mdy_hms(sanctDeployments$Deployment_Date_UTC, truncated = 3) 
sanctDeployments$Recovery_Date_UTC <- mdy_hms(sanctDeployments$Recovery_Date_UTC, truncated = 3)

sanctDeployments$Deployment_Date_UTC <- format(as.POSIXct(sanctDeployments$Deployment_Date_UTC, format='%m%d%y %H:%M:%S'), format = "%m/%d/%Y") 
sanctDeployments$Recovery_Date_UTC <- format(sanctDeployments$Recovery_Date_UTC, "%m/%d/%Y")

#EXPORT FINAL DRIFTS
write.csv(sanctDeployments, "Working Directory/2022_NMS-Deployments.csv", row.names=FALSE)
