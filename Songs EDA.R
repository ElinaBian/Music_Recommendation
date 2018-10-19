# First, load `songs` into R

# top 10 genres
barplot(sort(table(songs$genre_ids), decreasing = T)[1:10], cex.names = 0.5, cex.axis = 0.5)
# 465 takes a huge portion in all the genres.

# distribution of song length
hist(songs$song_length, xlim = c(0, 1000000), breaks = 1000)
# The majority of the songs have lengths normally distributed under 6 minutes.

# language
barplot(sort(table(songs$language), decreasing = T))
# top favorate languages of users are language 52, -1, 3; language 52 takes the largest portion.

# artist
barplot(sort(table(songs$artist_name), decreasing = T)[3:13], cex.names = 0.5, cex.axis = 0.5, las = 2)
# potential problem: simplified and traditional Chinese causes multiple categories