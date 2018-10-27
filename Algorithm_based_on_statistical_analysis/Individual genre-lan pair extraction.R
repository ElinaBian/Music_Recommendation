# function that takes one user's history and return 
# the first few (genres, language) pairs


mostfreq3 <- function(df) {
  ct <- table(df$genre_ids, df$language)
  dn <- dimnames(ct)
  first5 <- sort(ct, decreasing = T)[1:5]
  
  result.pair <- rbind(which(ct == first5[1], arr.ind = T), which(ct == first5[2], arr.ind = T),
                 which(ct == first5[3], arr.ind = T), which(ct == first5[4], arr.ind = T),
                 which(ct == first5[4], arr.ind = T))
  
  # extract dimension names by index
  dnpair <- function(p) {
                     return(c(dn[[1]][p[1]], dn[[2]][p[2]]))
}
  
  res <- apply(result.pair,1, dnpair)
  return(res)
}
