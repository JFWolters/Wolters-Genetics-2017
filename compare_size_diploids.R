#####################################################################################
#######This script was initially built by CRLandry, JBLeducq and modified by CEberlein
#####################################################################################
###it was further modified by GCharron
##and then edited by JFWolters

#####################################################################################
# reading data and preparing table
#####################################################################################


classes = c("numeric","numeric","character","numeric","factor","numeric","factor","factor")
#           Row        Col         Name    Size     Media     Timepoint Temp    Array(D or H)

setwd("./data")

df = read.table("consolidated_data.txt",header=T, colClasses=classes)

##Add a column with "Condition whichis the combination of Media and Temperature
Condition = paste(df$Media, df$Temp, sep = "_")
Well=paste("r",df$Row,"c",df$Col,sep="")
df$Condition = factor(Condition)
df$Well = Well


# #log transform the size
# logsize <- log(df$Size)
# df$LogSize = logsize


####RENAME THE STRAIN NAMES
####include vectors with nuclear and mito designation
info = read.table("JW Strain List for May 2016 mailed strains.txt",
                  header=T, sep = "\t", colClasses = c("character"))
for(i in 1:81){
  info$Foil.No.[i] = paste("h",info$Foil.No.[i],sep="")
}
for(i in 82:129){
  info$Foil.No.[i] = paste("d",info$Foil.No.[i],sep="")
}
df$Nuc = vector(length=nrow(df))
df$Mito = vector(length=nrow(df))
for(i in 1:nrow(info)){
  id = info$Foil.No.[i]
  df$Nuc[df$Name == id] = info$Nuclear[i]
  df$Mito[df$Name == id] = info$Mito[i]
  df$Name[df$Name == id] = info$Strain.Name[i] #order is important, must replace name last
}

df$Nuc[df$Name == "by"] = "by"
df$Mito[df$Name == "by"] = "by"


####CLEAN AND TRANSFORM THE DATA
#SEE data_cleaning_notes.txt
# contaminated = c("h18","h70","h73","h81","d96") #foil numbers
contaminated = c("273614NY12",
                 "SK1BC187",
                 "SK1Y12",
                 "Y12Y12",
                 "YJM975YJM975 rho YJM975/Y12 G1 d99",
                 "YJM975YJM975 rho YJM975/Y12 G1 d111",
                 "YJM975YJM975 rho YJM975/Y12 d113") #actual names

#need to go back and check if h66 or h67 needs to be removed
#removing h81 not because of contamination but because I am quite sure it is not the strain
#that I think it is, unfortunately this means S1s1 is gone from the screen
df = subset(df,!df$Name %in% contaminated)

##remove time point 1 due to problems with this set
df = subset(df, !(df$Time.Point == 4.53))

##remove the outer rings of spots because this data is not meaningful
df = subset(df, !(df$Row < 3 | df$Row > 30 | df$Col < 3 | df$Col > 46))


#The L2 nuclear background was unusable due to flocculation
#removing it from the data frame
df = subset(df,df$Nuc != "SK1")

###AVERAGE THE REPLICATES
agg = aggregate(formula = Size ~ Name + Condition + Time.Point + Array + Nuc + Mito, data=df, FUN=median)


#####Determine size difference average
#Take the size difference between time at 26 hours and time 0
agg_t0 = agg[agg$Time.Point == 0 , ]
agg_t26 = agg[agg$Time.Point == 26.02 ,]

size_diff = agg_t26$Size - agg_t0$Size

diff_df = cbind(agg_t0, size_diff)
#drop columns that no longer have meaning
diff_df = diff_df[, c(1,2,4,5,6,8)]

####Subset for diploids
diff_df = subset(diff_df, diff_df$Array == "D")

#record the gsize_diff data table
write.table(diff_df,file="diploid_size_diff.tab",row.names=FALSE,sep="\t")

####REPEAT BUT THIS TIME OUTPUT ALL REPLICATES
#Take the size difference between time at 26 hours and time 0
df_t0 = df[df$Time.Point == 0 , ]
df_t26 = df[df$Time.Point == 26.02 ,]
df_t47 = df[df$Time.Point == 47.15, ]

# size_diff = df_t26$Size - df_t0$Size
size_diff = df_t47$Size - df_t0$Size

diff_df = cbind(df_t0, size_diff)
#drop columns that no longer have meaning
diff_df = diff_df[, c(1,2,3,5,7,8,9,11,12,13)]

####Subset for diploids
diff_df = subset(diff_df, diff_df$Array == "D")

#record the gsize_diff data table
write.table(diff_df,file="diploid_size_diff.all_reps.tab",row.names=FALSE,sep="\t")


