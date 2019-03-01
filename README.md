Adavanced Data Analysis Project --- Music Recommendation 
======================

[Kaggle Link](https://www.kaggle.com/c/kkbox-music-recommendation-challenge)

# 1. Introduction and Motivation

    We now have 5 topics:

Music Recommendation
----

Nowadays, the music library is growing rapidly, and so is its variety. Being able to push tracks which match users’ tastes is playing an important role in the exploratory feature of music applications. In addition, the ability to successfully predict users' preference can enrich the users’ profile database and provide insight on future development. Thus, as a group, our goal is to find efficient and accurate methods to recommend music to enhance user experience and to create business value. 

We constructed three algorithms to reach our goal. The first one is a traditional memory-based algorithm which pushes similar tracks according to each user's listening history. The second one is clustering for users, figuring out the optimal size of the groups they have. The third algorithm we used is Alternating Least Squares Method (ALS) for Collaborative Filtering, exploiting other users and items along with their ratings and target user history to recommend an item that target user does not have ratings for.

# 2. Data Preparation

## 2.1 Download Data

Firstly, our data could get from [Kaggle link](https://www.kaggle.com/c/kkbox-music-recommendation-challenge/data). 

Also, here is a more convenient [Google Drive Link](https://drive.google.com/drive/folders/1l3O6N35fd6O7AUK8qaui_pu0QXX_KBw1) for data.

The datasets we will be using in this project is from KKBox, which is Asia's leading music streaming service, holding a library over 30 million tracks. After filtering and cleaning, our data contains 352,681 songs and 30,735 users. The essential variables contain user ID, song ID, genre, language, user age, artist, song length. Based on these fundamental variables, we compiled and extracted several other useful factors, such as the top five popular genre, the top three popular artists, and the top three common languages, which we computed through repeat times of listening. 

# 3. Experimental Data Analysis

First of all, we detected the dataset about users. There are outliers, such as negative values as well as values above 1000, in the age field. Meanwhile, there are 19932 records with 0 as age; this could be either outliers or missing values. After removing these values, we plotted in the age range 1-100 to show the real distribution. Figure 1 illustrates that the age distribution is skewed right, the mean age of user is around 35 years old. Though there is a lot of missing gender, Male and female are almost equal. 

![figure 1](https://raw.githubusercontent.com/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_1.png)

Secondly, we dig information from the dataset about songs. From figure 2, which is created from Tableau, we can see that the songs in our train dataset mainly distributed in Asia and US. In other words, Chinese songs and English songs account for most of the songs. In addition, the pie chart under figure 3 shows the most popular genres; genre 465 has preponderant influence over the song dataset. Moreover, from the word-cloud in figure 4, we found out Jay Chow and May Day, the mainstays of Chinese Pop music, are the artists whose songs being listened the most repeat times. Thus we can infer this music application is used in China. Meanwhile, in order to make sure whether there is influence of song length on users’ preference, we plot the distribution of song length. Figure 5 shows the song length is mainly concentrated around 4 minutes, which is a normal length. 

![figure 2](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_2.png)

![figure 3](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_3.png)

![figure 4](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_4.png)

![figure 5](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_5.png)

At the same time, in order to explore the relationship between genre and songs, we plot the Top 5 Repeatedly Listened Songs Distribution over Genres (figure 6), and discovered that the genre which includes more songs does not mean it will be repeatedly listened more times. Constructing the bridge between datasets of users and songs, we also pay attention to extract the correlations. From the plot about relationship between users’ age and genres they listened (figure 8), we found it is make sense that the age distribution is wider when the genre is more popular. The most popular genre is genre 465, and the age distribution of this genre is the widest. Meanwhile, in order to dig the connection the number of genre and the number of songs he or she listened, we created the scatter plot in terms of different age group (figure 9), and then we found there is a positive correlation between the number of songs and genres listened among every age group.

![figure 6](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_6.png)

![figure 7](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_7.jpg)

![figure 8](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_8.png)

![figure 9](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Experimental_Data_Analysis/final_figures/figure_9.png)


# 4. Algorithms 

## 4.1 Baseline

For benchmarking, we write a random algorithm as our baseline. Firstly, we create a song pool that contains all the songs according to their repeatedly listening probabilities as a measure of popularity. If target=0, this song will be included in the song pool once. If target=1, this song will be included in the song pool twice. The more times this song was repeatedly listened, the larger the probabilities this song would be recommended to the user. 

Then we pick up 10 songs from the song pool, which follows a multinomial distribution using relative popularity as parameter. Finally, we calculate the test error to evaluate the baseline algorithm. If the song was not listened or listened just once, we score it 0. If the song was listened and listened more than once, we score it 1. The test accuracy for baseline is 0.0131.

## 4.2 Content-based

The first algorithm we implemented is memory-based. The idea is to create a profile for each user and recommend tracks based on it. In this naive approach, we take genre and language as two features to create a user’s profile. The flow of this approach is as follows:
   1. Extract all songs a user has listened in the training set.
   2. Create a 2-way contingency table of listening history to find the top (language, genre) pair for this user.
   3. Filter the music library to find the songs which haven’t been listened by this user and are in the top (language, genre) group. 
   4. Recommend tracks from the filtered pool based on popularity.

### Data cleaning:

This algorithm depends the history record of each user, so we want each user to appear in both training and test data sets. Thus, we separate each user’s observations into training set and test set with split ratio 7:3. We plan to recommend 10 songs for each user. To be able to evaluate our algorithm’s performance, we have to make sure that each user in the test set has at least 10 observations. So we take the top 21000 users according to the number of songs they listened (i.e. the top 21000 users have at least 10 listening records in the test set).

Also, some songs are sorted to multiple genres. To get a more accurate top (language, genre) pair, we expand those observations with multiple-genres songs into multiple observations.

This algorithm’s logic is straightforward yet naive. It has its limitation. It highly depends on the user’s history information to make a prediction. Hence, it cannot serve the new app users since they have zero listening record. Also, the more songs a user listened, the more accurate our recommendation could be.  As we can observe from the table above, the performance is getting worse while we add more users with fewer records to our user base. As we conclude all viable users, the accuracy of this algorithm is about 21.5%.

## 4.3 Clustering-based

Besides the traditional method stated above we also use another recommendation system for the new music users.
First of all, we want to do the clustering for members and figuring out the optimal size of the groups they have. According to the data we have numerical data (ages, mean of the song lengths, the repeat ratio of the songs ID and the repeat ratio of the Genre ID) and text feature (language, artists information, song information and etc.). For the numeric data we use K-mean and Birch clustering algorithm to do the clustering (figure 10). For the text feature part we decide to use LDA topic clustering to finish the clustering.

![figure 10](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Algorithm_based_on_clustering/figure_10.png)

Secondly, the tricky part is how to combine these two algorithms together. Thanks for the essay from the Cornell Library we can use a LDA_Kmeans method to handle with numeric and text feature data based on the previous data.
The object similarity measure is derived from both numeric and categorical attributes. When applied to numeric data the algorithm is identical to k-means. In testing with real data, this algorithm has demonstrated a capability of partitioning data sets in the range of a hundred thousand records, described by more than 20 numeric and categorical attributes, into a 21 clusters in a couple of hours. We use K-prototype to combine two clustering algorithms together. The algorithm is built upon three processes, the initial prototypes selection, initial allocation, and re-allocation.

We set clusters and find out the optimal K values for the clusters(figure 11). The optimal cluster number is 21 groups for the users.

![figure 11](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Algorithm_based_on_clustering/figure_11.png)

After the clustering members and users we finally enter into the recommendation system for both old users based on the previous history and clusters information. For the new users, we might not do the prediction because we did not know their clusters, hence for the new enrolled users, they need to become ‘old’ user first in order to recommend applicable songs for them. 

Below figure is the result of our recommendation we have three column inside, the first column is that how many ID in that specific cluster group; the second column ‘All’ means the mean of the accuracy rate of users who did listen to the recommendation songs, ‘Target’ is the mean of the accuracy rate of users who listen the recommendation songs multiple times. We get several information from the data, firstly, NO.9 cluster group have low accuracy because there are only 9 users in the group, but for most groups we have roughly accuracy between 25%-33% which means among four or three recommendation songs they will definitely choose one song as their favorite types. And among recommend songs they choose 25% of the songs they will listen again.

That works pretty good, firstly, we use over 30 million data to test the accuracy; secondly, from my personal experience of the music app, every three or four recommended songs there is one song which fit your tastes better than most of the app music recommendation system. However, if we want to furthermore increase our accuracy we need to have more comprehensive data rather than asian users. For instance, NO.9 group might be the music member who only interested in some Indian songs, which might have a bias because of less sample here.
Overall, the results of our recommendation work somewhat efficiently and inexpensive. But if we want to improve more on the recommendation system, more comprehensive data will be required.

## 4.4 ALS-based(Alternating Least Squares)

The third algorithm we used is Alternating Least Squares Method(ALS) for Collaborative Filtering.

Collaborative Filtering(CF) is a subset of algorithms that exploit other users and items along with their ratings and target user history to recommend an item that target user does not have ratings for. Fundamental assumption behind this approach is that other users preference over the items could be used recommending an item to the user who did not see the item before. CF differs itself from content-based methods in the sense that user or the item itself does not play a role in recommendation but rather how and which user rated a particular item. (Preference of users is shared through a group of users who selected, purchased or rate items similarly).

### Mathematical Therory

We have users u for songs i matrix as in the following:            
        
        Qui=1  if song i is repeatedly listened by user i,   
        Qui=0  if song i is listened but not repeatedly listened by user i.
Qui is our rating matrix. If we have m users and n songs, then we want to learn a matrix of factors which represent songs. That is, the factor vector for each song and that would be how we represent the song in the feature space. We also want to learn a factor vector for each user in a similar way how we represent the song. Factor matrix for songs YRfnand factor matrix for users XRmf. However, we have two unknown variables. Therefore, we will adopt an alternating least squares approach with regularization. By doing so, we first estimate Y using X and estimate X by using Y. After enough number of iterations, we are aiming to reach a convergence point where either the matrices X and Y are no longer changing or the change is quite small. However, there is a small problem in the data. We have neither full user data nor full songs data, this is also why we are trying to build the recommendation engine in the first place. Therefore, we may want to penalize the songs that do not have ratings in the update rule. By doing so, we will depend on only the songs that have ratings from the users and do not make any assumption around the songs that are not rated in the recommendation. Let's call this weight matrix wui as such: if qui=0, wui=0; otherwise, wui=1. Then, cost functions that we are trying to minimize is in the following: 

      $$J(x_u) = (q_u-x_uY)W_u(q_u-x_uY)^T + x_ux_u^T$$
      $$J(y_i) = (q_i-Xy_i)W_i(q_i-Xy_i)^T + y_iy_i^T$$
Note that we need regularization terms in order to avoid the overfitting the data. Ideally, regularization parameters need to be tuned using cross-validation in the dataset for algorithm to generalize better. Solutions for factor vectors are given as follows:
      
      $$x_u = (YW_uY^T + I)^{-1}YW_uq_u$$
      $$y_i = (X^TW_iX + I)^{-1}X^TW_iq_i$$
Then, we can get the rating matrix between users and songs.

### Implementation

We implemented this algorithm using ALS package in MLlib of Pyspark, and used cross validation to select model parameters like the number of latent factors we included, the regularization parameters, etc. 

After getting the full rating matrix, we will recommend the top 10 songs which have the highest rating scores to every user. We notice that these songs are included both in training set and testing set, so we did result processing to finally recommended top 10 songs excluding the training set. This part introduced big data volume, so this is why we choose pyspark, which is better at dealing with big data. 

Our final result of test error is 0.6775. 

From the plot, we can find that there is positive correlation between the numbers of user records and recommendation accuracy.

![figure 12](https://raw.githubusercontent.com/ElinaBian/Music_Recommendation/Algorithm_based_on_Alternative_Least_Squares/figure_12.png)

# 5. Summary

Overall, all our algorithms performed better than the baseline random model. The accuracy drops as we increase the number of users in our data sets.

The content-based algorithm have an accuracy rate of 0.215, which means about 22% of recommended songs suit users’ tastes for a user base that is sufficiently large. This algorithm has the lowest accuracy among all three built by us, and it fails to make predictions for new users. Hence, this should not be the final solution. However, it can be considered as an option for the users who listened a lot more songs than others, as the evidence suggests that this algorithm has a fair performance for them.

For the clustering method, our accuracy will be roughly around 0.2 to 0.3 for different groups with a weighted mean accuracy rate 0.291, which means among three to four recommended songs there will be one fit users’ choices. Looks like this method performance quite well. However if we want to have more higher accuracy we need to consider more comprehensive data and broder cluster information.

For the ALS method, we have better performance, the final accuracy is 0.323. Since ALS is used to deal with the big data, we believe for large datasets it will perform better than most of the methods and algorithms.
