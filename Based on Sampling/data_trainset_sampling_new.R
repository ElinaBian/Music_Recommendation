#members<-read.csv("C:/Users/lz2570/Downloads/members.csv")
#train<-read.csv("C:/Users/lz2570/Downloads/train.csv")
#songs<-read.csv("C:/Users/lz2570/Downloads/songs.csv")

###Packages

library(dplyr)
library(tidyr)
library(stringr)

###new train dataset
setwd('/Users/lingyizhao/Desktop/5291 proj')


###new train dataset

training<-read.csv("training.csv",stringsAsFactors = F)
testing<-read.csv("testing.csv",stringsAsFactors = F)
total<-rbind(training, testing)

total<-total[-c(3,4,5,10:16)]
#save(total, file="total.csv")
#save(total, file="total.RData")

usercount<-count(total, vars=total$msno)

top_10000<-function(df, col){
  temp_df<-df %>%
    arrange(desc(n))%>%
    print
  return(temp_df)
}


vvtop<-top_10000(usercount, usercount$n)[1:100,]

merge<-subset(total, msno %in% vvtop$vars)

genre<-merge$genre_ids

cot<-rep(NA,length(genre))
for (i in 1:length(genre)){
  cot[i]<-str_count(genre[i],"\\|")+1
}

merge.expanded <- merge[rep(row.names(merge), cot),]

genre_split<-unlist(strsplit(genre,"\\|"))
merge.expanded$genre_ids<-genre_split 


weight<-unlist(lapply(cot,function(i){return(rep(1/i, i))} ))
merge.expanded$weight<-weight

# save(merge.expanded,file = "entire_cleaned_data.csv")
# save(merge.expanded,file = "entire_cleaned_data.RData")



 #vvtop<-top_10000(usercount, usercount$n)[1:100,]

 merge<-subset(total, msno %in% vvtop$vars)

 #sepreate 7:3
 merge_new<-merge.expanded[order(merge.expanded[,1]),]
 train<-data.frame()
 test<-data.frame()
 trainsong<-data.frame()
 users<-data.frame()
 for (i in vvtop$vars){
   train_number<-round(vvtop[which(vvtop$vars==i),2]*0.7)
   #print(train_number)
   test_number<-vvtop[which(vvtop$vars==i),2]-train_number$n
   song<-merge_new[which(merge_new$msno==i),2]
   #print(length(song))
   train<-sample(song,size = train_number$n)
   train<-data.matrix(train)
   #print(length(train))
   #train<-merge_new[which(merge_new$song_id %in% train),]
   user<-data.matrix(rep(i,train_number))
   users<-rbind(users,user)
   #print(nrow(users))
   trainsong<-rbind(trainsong, train)
   print(nrow(trainsong))
 }
 trainset<-data.frame()
 trainset<-subset(merge_new, song_id %in% trainsong$V1 & msno %in% users$V1)
 
 testset<-data.frame()
 #testset<-merge_new[ !(merge_new$song_id %in% trainsong$V1 && merge_new$msno %in% users$V1), ]
 testset<-setdiff(merge_new, trainset)
 