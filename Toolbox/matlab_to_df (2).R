# matlab_to_df.R, (c) Elisa Granato, 2019

###############################
# reading file from matlab

#!!! important: file has to be saved from Matlab with "save -v6" !!

library(R.matlab)
library(data.table)
tracks <- R.matlab::readMat(file.choose())
proc <- tracks$procTracks
proc_sub <- proc[,1,]

colnames(proc_sub) <- paste("cell",seq(ncol(proc_sub)))

output_collect <- list()
for(i in seq(ncol(proc_sub))){
  tmp <- proc_sub[,i]
  tmp <- lapply(tmp, as.numeric)
  
  tmp2 <- unlist(tmp)
  tmp_dt <- data.table(
    value = tmp2,
    observation = names(tmp2),
    cell = colnames(proc_sub)[i]
  )
  
  output_collect[[i]] <- tmp_dt
}

clean_dat <- rbindlist(output_collect, fill = T)
clean_dat <- as.data.frame(clean_dat)

#############################

#rename channel1, 2, 3 by fluorophore to remove non-frame numbers from those labels

clean_dat <- data.frame(lapply(clean_dat, function(x) {gsub("channel.1", "bf", x)}))
clean_dat <- data.frame(lapply(clean_dat, function(x) {gsub("channel.2", "gfp", x)}))
clean_dat <- data.frame(lapply(clean_dat, function(x) {gsub("channel.3", "pi", x)}))

clean_dat$value <- as.character(clean_dat$value)
clean_dat$value <- as.numeric(clean_dat$value)
clean_dat$cell <- as.character(clean_dat$cell)
clean_dat$observation <- as.character(clean_dat$observation)


#############################


# copy dataframe before major data wrangling

all.tracks <-  clean_dat
setDT(all.tracks)

#############################

#reshaping the data to have column names with variables

# EDIT VARIABLE NAMES HERE
# Most variable names correspond to the fields of procTracks. Channel names should be written in the order of their indices (e.g. in the below case, channel 1 = brightfield, channel 2 = GFP, channel 3 = Pi)

variables <- c("x","y","smoothx","smoothy","theta","vmag","smoothTheta","smoothVmag","majorLen","minorLen","area","phi","bf.mean","gfp.mean","pi.mean","bf.std","gfp.std","pi.std")
leftovers <- c("start","end","length")

# all observation variables "x, y," etc) will be turned into columns.
# times, start, end, and length need to be transformed into a new "frame.real" column, which denotes the absolute frame number where each measurement was taken.
# "frame.real" is calculated for each measurement: start (for the cell measured) + relative.frame (the number tacked onto the measurement variables at the moment) minus 1

#separate the factors from the frames
all.tracks[
    , observation_cat := gsub(pattern = "[0-9]", replacement = "", ignore.case = T,x = observation)][
    , observation_frame := gsub(pattern = "[A-Z.]", replacement = "", ignore.case = T,x = observation)][
    , observation_frame := as.numeric(observation_frame)]

#pull out the start, length, end stuff
lse.tracks <- all.tracks[observation %in% leftovers] 
other.tracks <- all.tracks[!observation %in% leftovers] 


#now do some calculations:

other.tracks[ , frame.real := lse.tracks[observation == "start"][match(other.tracks$cell,cell)]$value + observation_frame -1 ]

other.tracks_sub <- other.tracks[, c("cell","value","frame.real","observation_cat"), with = F]

#generate final dataframe

final_df <- dcast(other.tracks_sub, formula = cell+frame.real ~ observation_cat, value.var = "value")

#remove redundant "times" column
final_df <- subset(final_df, select=-c(times))