import pandas as pd
import numpy as np
import seaborn as sns
from collections import Counter
import matplotlib.pyplot as plt
import matplotlib
font = matplotlib.font_manager.FontProperties(fname=r"C:\Windows\Fonts\simsun.ttc")
from wordcloud import WordCloud  ####need help here
from scipy.misc import imread

artist=pd.read_csv('members_add_artist.csv')
print(artist.head())
#1. Get data. threshold is 70,filter useless artists(Various Artists)
art1_count=artist.groupby('artist_name3',as_index=False).count()
art11=pd.DataFrame(art1_count.iloc[:,0:2])
art11 = art11[ ~(art11['artist_name3'] =='Various Artists')]
art111=art11[art11['msno'] >= 70]
# 2. Bar plot
plt.figure(figsize=(18,12))
art1=plt.bar(art111['artist_name3'],art111['msno'], align='center', alpha=0.5,color="green")
plt.title('The Third Popular Artists')
plt.xlabel('Artist')
plt.xticks(fontsize=1,rotation=90,fontproperties =font )
# mask=bg_pic
plt.show()

#3. wordcloud and set the stopwords set
stopwords = ['Lin','Chou','Shi','Jay','Hsiao','The']
def displaywc(txt,title):
    bg_pic = imread('background.jpg')
    txt=""
    for i in g:
        txt+=str(i)
    wordcloud = WordCloud(background_color='white',font_path = 'msyhbd.ttf',stopwords=stopwords).generate(txt)
    plt.figure()
    plt.imshow(wordcloud, interpolation="bilinear")
    plt.axis("off")
    plt.title(title)
    plt.show()

g=art111.sort_values(by='msno',ascending=False)[:200].artist_name3.tolist()
txt=""
for i in g:
    txt+=str(i)
displaywc(txt,'The Third Popular Artists ')

