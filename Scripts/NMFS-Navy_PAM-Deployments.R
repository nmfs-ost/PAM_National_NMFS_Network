# NAVY PAM Deployments Annual Report - this script will return the final report 
# All past, active, and planned PAM deployments must be reported annually for given time range

# Lines to update
  # Set your working directory in line 10
  # Set the reporting date range (start and end date) in line 20
  # Set the path to save file outputs in lines 72 & 73

#SET WORKING DIRECTORY AND LOAD PACKAGES
setwd('Path to working directory')
library(lubridate)


#COMPLETED DEPLOYMENTS
# Download 'NEW DEPLOYMENT TO SAVE' as a csv from Deployment Details spreadsheet and read it in (https://docs.google.com/spreadsheets/d/10bxlwfVOe1LFfj69B_YddxcA0V14m7codYwgD2YncFk/edit#gid=395545420)
DeployDetails <- read.csv('Deployment Details - NEW DEPLOYMENT TO SAVE.csv')

# Use lubridate package to convert date format and exclude drifts outside of reporting date
DeployDetails$Date..UTC <- mdy(DeployDetails$Date..UTC) # convert Character to proper Date format
DeployDetails <- DeployDetails[DeployDetails$Date..UTC >= ymd("Report Start Date") & DeployDetails$Date..UTC <= ymd("Report End Date"), ] #used 'Date UTC' column to avoid issues with drifts missing deployment/recovery dates (i.e. sunk or lost drifts)

# Subset required columns and save as new dataframe
NavyDF_completed <- subset(DeployDetails, select = c(Status...In.Prep.....preparing.buoy.for.deployment..Active....at.sea.and.we.plan.to.recover..Lost....at.sea.but.unlikely.we.can.recover..Sunk....only.recovered.partial.buoy..assumed.dead..sunk..and.highly.unlikely.to.recover..Complete.....buoy.recovered.and.data.is.in.house, 
                                                     Platform, Deployment_Latitude, Deployment_Longitude, Deployment_Date_UTC, Recovery_Date_UTC, SampleRate_kHz, 
                                                     RecordingDuration_m, RecordingInterval_m, Deployment_Depth_m.))

# Convert dates and combine into one date range column
NavyDF_completed$Deployment_Date_UTC <- mdy_hms(NavyDF_completed$Deployment_Date_UTC, truncated = 3) # convert Character deployment date to proper Date format
NavyDF_completed$Recovery_Date_UTC <- mdy_hms(NavyDF_completed$Recovery_Date_UTC, truncated = 3) # convert Character recovery date to proper Date format

NavyDF_completed$Deployment_Date_UTC <- format(NavyDF_completed$Deployment_Date_UTC, "%m/%d/%y") # format deployment dates into mm/dd/yy
NavyDF_completed$Recovery_Date_UTC <- format(NavyDF_completed$Recovery_Date_UTC, "%m/%d/%y") # format recovery dates into mm/dd/yy

NavyDF_completed$DeploymentRecovery_Dates <- paste(NavyDF_completed$Deployment_Date_UTC, '-', NavyDF_completed$Recovery_Date_UTC) # combine dates to make one deployment date range column

# Combine lat and lon into one location column
NavyDF_completed$Location <- paste(NavyDF_completed$Deployment_Latitude, ',', NavyDF_completed$Deployment_Longitude)

#Subset again to remove separated columns (deployment/recover dates and lat/lon)
NavyDF_completed <- subset(NavyDF_completed, select = c(Status...In.Prep.....preparing.buoy.for.deployment..Active....at.sea.and.we.plan.to.recover..Lost....at.sea.but.unlikely.we.can.recover..Sunk....only.recovered.partial.buoy..assumed.dead..sunk..and.highly.unlikely.to.recover..Complete.....buoy.recovered.and.data.is.in.house, 
                                                        Platform, Location, DeploymentRecovery_Dates, SampleRate_kHz, 
                                                        RecordingDuration_m, RecordingInterval_m, Deployment_Depth_m.))

# Change sensor types to be more descriptive
NavyDF_completed[NavyDF_completed == 'drift'] <- 'Drifting Vertical Array w/Soundtraps'
NavyDF_completed[NavyDF_completed == 'towed'] <- 'Towed Hydrophone Array w/Soundtraps'

# Add units to depth column
NavyDF_completed$Deployment_Depth_m. <- paste(NavyDF_completed$Deployment_Depth_m.,'m')

# Add units to sampling rate
NavyDF_completed$SampleRate_kHz <- paste(NavyDF_completed$SampleRate_kHz,'kHz')

# Rename columns following Navy reporting format
colnames(NavyDF_completed) <- c('Status', 'Sensor Type', 'Location',	'DeploymentRecovery_Date', 'Sampling Rate', 
                                'Sampling Schedule - Recording Duration', 'Sampling Schedule - Recording Interval',
                                'Approximate Sensor Depth')


#PLANNED DEPLOYMENTS
# Create dataframe
NavyDF_planned <- data.frame(Status = c("Planned", "Planned", "Planned", "Planned"), 
                             Sensor_Type = c("Drifting Vertical array w/Soundtraps", "Drifting Vertical array w/Soundtraps", "Drifting Vertical array w/Soundtraps", "Drifting Vertical array w/Soundtraps"), 
                             Location = c("~30 miles offshore Newport", "~30 miles offshore Eureka", "~15 miles offshore San Francisco", "~30 miles offshore Morro Bay"),	
                             DeploymentRecovery_Date = c("variable", "variable", "variable", "variable"), 
                             Sampling_Rate = c("384 kHz", "384 kHz", "384 kHz", "384 kHz"), 
                             Sampling_Schedule = c("Continuous", "Continuous", "Continuous", "Continuous"),
                             Approximate_Sensor_Depth = c("100m", "100m", "100m", "100m"))


#EXPORT DATAFRAMES
write.csv(NavyDF_completed, "Working directory/2022-23_NMFS-Navy_Agreement-PA_Instruments_Completed.csv", row.names=FALSE)
write.csv(NavyDF_planned, "Working directory/2022-23_NMFS-Navy_Agreement-PA_Instruments_Planned.csv", row.names=FALSE)
