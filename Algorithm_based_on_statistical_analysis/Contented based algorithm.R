# This file contains the source code of the content-based approach of our music recommendation
# algorithm.
# Author: Sizhu Chen, Ye Yue, Lingyi Zhao, Binhan Wang


library(dplyr)
library(tidyr)
library(stringr)

##### Load existing train and test data; combine them so that we can split them later
training<-read.csv("training.csv",stringsAsFactors = F)
testing<-read.csv("testing.csv",stringsAsFactors = F)
total<-rbind(training, testing)

total<-total[-c(3,4,5,10:16)] # drop unwanted variables
# save(total, file="total.RData") # this line is used to store data locally
############################################################################

##### Extract the users with the most listening history
usercount<-count(total, vars=total$msno)

top_10000<-function(df, col){
  temp_df<-df %>%
    arrange(desc(n))%>%
    print
  return(temp_df)
}

# To change userbase size, edit the next line
vvtop<-top_10000(usercount, usercount$n)[1:21000,]
# get the first 21000 users since the other 9000 have fewer songs listened

merge<-subset(total, msno %in% vvtop$vars)
############################################################################

##### Create music library
songpool<-count(total, var=song_id)
names(songpool)<-c("song_id","fre")


total_pool<-total[,c(2,5,6)]
total_pool<-total_pool[!duplicated(total_pool),]# nrow=nrow(songpool)
total_pool<-merge(total_pool,songpool,by="song_id")

#expand total_pool by genre

cot1<-rep(NA,nrow(total_pool))
for (i in 1:nrow(total_pool)){
  cot1[i]<-str_count(total_pool$genre_ids[i],"\\|")+1
}
total_pool_expand<- total_pool[rep(row.names(total_pool), cot1),]

genre_split1<-unlist(strsplit(total_pool$genre_ids,"\\|"))
total_pool_expand$genre_ids<-genre_split1 
total_pool<-total_pool_expand

total_pool<-total_pool[order(total_pool$fre,decreasing = T),]
############################################################################

##### Create training and test set
library(parallel)
library(doParallel)
registerDoParallel(detectCores())

vvtop$train_num<-round(vvtop$n*0.7)

train1 <- foreach(i = 1:nrow(vvtop)) %dopar% {
  train1<-data.frame()
  each_user<-subset(merge,msno==vvtop$vars[i])
  set.seed(2018)
  trainset<-each_user[sample(1:nrow(each_user),size = vvtop$train_num[i]),]
}

library(plyr)
train1 <- ldply(train1)

test<-setdiff(merge, train1)

#save(train1, file = "../train21000.RData")
#save(test, file = "../test21000.RData")
############################################################################

##### Expand multiple genres in training set
cot2<-rep(NA,nrow(train1))
for (i in 1:nrow(train1)){
  cot2[i]<-str_count(train1$genre_ids[i],"\\|")+1
}

train_expanded <- train1[rep(row.names(train1), cot2),]
train_expanded$genre_ids<-unlist(strsplit(train1$genre_ids,"\\|")) 
trainset<-train_expanded
############################################################################

##### Create user profile
# write a function to get (genre, language) pair for each user
getpair <- function(df) {
  ct <- table(df$language, df$genre_ids)
  lname <- rownames(ct) # language id
  gname <- colnames(ct) # genre id
  m <- max(ct)
  idx <- which(ct == m, arr.ind = T)
  l <- lname[idx[1]]
  g <- gname[idx[2]]
  return(c(l, g))
}

# top pair for each user
feature21 <- foreach(u = vvtop$vars) %dopar% {
  user <- u
  topl <- getpair(trainset[trainset$msno == u, ])[1]
  topg <- getpair(trainset[trainset$msno == u, ])[2]
  print(c(user, topl, topg))
}

feature21 <- ldply(feature21)
colnames(feature21) <- c("user", "language", "genre")
#save(feature21, file = "../feature21000.RData")
############################################################################

##### Make recommendation
recom_table <- foreach (g = feature21$user) %dopar% {
  recom_set<-subset(total_pool,
                    !(song_id %in% train1$song_id[train1$msno==g]))
  recommend<-subset(recom_set, 
                    recom_set$genre_ids == feature21$genre[feature21$user==g] &
                      recom_set$language == feature21$language[feature21$user==g])
  
  
  if(nrow(recommend)==0){
    recommend<-recom_set$song_id[1:10]
  }
  else{
    recommend<-recommend$song_id[1:10]}
  
  print(data.frame(users=rep(g,10),recom_music=recommend))
  
}

recom_table <- ldply(recom_table)
############################################################################

##### Evaluate performance
# Only count repeating songs as success
test_target1<-test[test$target==1,]

# get performance score for each user
score21 <- foreach (p = unique(recom_table$users)) %dopar% {
  testsong<-test_target1$song_id[test_target1$msno==p]
  score<-sum(testsong %in% recom_table$recom_music[recom_table$users==p])
}
# Transform into overall percentage
sum(unlist(score21))/(10*nrow(vvtop))
