####Read in analyzed image data and consolidate into a single table
####Adds in all information include strain, media, time, etc. for every spot



#####################################################################################
#######This script was initially built by CRLandry, JBLeducq and modified by CEberlein
#####################################################################################
###it was further modified GCharron
##and then edited by JFWolters

#####################################################################################
# reading data and preparing table
#####################################################################################

setwd("./data")


#get information of strains with names on 1536 plate
h_array<-read.csv(file="array_48x32_h.csv", header=F)
d_array<-read.csv(file="array_48x32_d.csv",header=F)

convert_array = function(arr){
  rows = rep(seq(1,nrow(arr)),ncol(arr))
  cols = vector()
  for(i in 1:ncol(arr)){
    cols = append(cols, rep(i,nrow(arr)))
  }
  vec = unlist(arr)
  data = data.frame(Row=rows,Col=cols,Name=vec)
  return(data)
}

h_data = convert_array(h_array)
d_data = convert_array(d_array)

#import picture information from file
desc_image <- read.table("image_desc.txt", sep="\t", header=T, colClasses = c("factor"))
head(desc_image)


#create empty dataframe
df = data.frame(matrix(vector(), 0, 9, dimnames=list(
  c(), c("Strain","Column", "Row", "Size", "Media","Temp", "Time.Point", "Sel","Array"))))

##process each line of the file individually. pick the data file, open it, read it and keep data.
##we take each row from the the desc_image and read the name of the text file in this row. Then we associate each of the text file with the conditions in desc_image

#get the data using information from the desc_image file. this leads to image file etc.
# we go through each row, we ask for the name of the file and bind the information called data, selection, cond, time, colsizes to it

#set the folder where the analysis.txt files are located as a subdirectory of the working directory
folder = "Analysis"

for (i in 1:nrow(desc_image)){  #starting from first row, and go to last one (nrow) in file desc_image
  fn = as.character(desc_image[i,1])
  file = paste(folder,fn,sep = "/")
  data = read.table(file, sep="\t", header=T) #we take the filenames e.g. IMG_123.txt
  sel = desc_image$Selection[i]
  media = desc_image$Media[i]
  time.point = desc_image$Time[i]
  temp = desc_image$Temp[i]
  arr = desc_image$Array[i]
  
  size_file = paste(folder,as.character(desc_image$Name[i]),sep="/")
  
  print(i) #printing each line we worked with after another makes sure that we went through all lines in the file
  
  #we read the text files according to the filename under desc_image[i,1] and stores the file in a new vector
  if(arr == "D"){
    info = d_data
  }else if(arr == "H"){
    info = h_data
  }else{
    print('you done fucked up')
  }
  
  colsizes = read.table(size_file, sep="\t", header=T) #we read the table for colonysize
  
  info$Size = colsizes$IntDenBackSub
  
  media = rep(media,nrow(info))
  info$Media = media
  time.point = rep(time.point,nrow(info))
  info$Time.Point = time.point
  temp = rep(temp,nrow(info))
  info$Temp = temp
  arr = rep(arr,nrow(info))
  info$Array = arr
  
  df = rbind(df,info)
} 

head(df)


#Replace the time.point factor with the real times expressed as
#hours.fractionofhours e.g. 1 hour 30 minutes is 1.5 hours
times = c(0,4.53,68.17,8.75,16.75,21.45,26.02,32.05,42.77,47.15,56.75)
# df$Time.Point = factor(df$Time.Point,labels = times)
test = factor(df$Time.Point,labels = times)
test=as.character(test)
test=as.numeric(test)

df$Time.Point = test
write.table(df, "consolidated_data.txt", sep = "\t", row.names=F)
