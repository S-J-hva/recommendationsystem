import pandas as pd

#load the dataset into terminal
data = pd.read_csv("~/VE/userReviews.csv", sep=";")

#check columns and format of dataframe
print(data.head())

#create empty df with same column names as data
subset = pd.DataFrame(columns=data.columns.tolist())

'''
#create subset

for movie in range(len(data.movieName)):
if data.movieName.iloc[movie] == '2-fast-2-furious':
    row = data[movie:movie+1]
    subset = subset.append(row)
    
'''

# create subset on basis of favourite movie (faster way)
subset = data[data.movieName == '2-fast-2-furious']

#check dataframe with movies that have reviews of 2-fast-2-furious
print(subset)


#create dataframe for recommendations incl relative & absolute scores
recommendations = pd.DataFrame(columns=data.columns.tolist()+['rel_inc','abs_inc'])

print(recommendations)


#loop for users that watched same liked movies
for idx, Author in subset.iterrows():
    # check author and his review
    print(Author)
    
    #save author and his ranking as variables
    author = Author[['Author']].iloc[0]
    ranking = Author[['Metascore_w']].iloc[0]
    
    
    #create a unique dataframe with movies ranked by selected author with >ranking of 2-fast-2-furious
    #calculate relative and absolute ranking increase
    #create filter variables (vector)
    filter1= (data.Author == author)
    filter2 = (data.Metascore_w > ranking)

    #look at output
    print(filter1)
    print(filter2)


    possible_recommendations1 = data[filter1]
    print(possible_recommendations1)
    possible_recommendations2 = data[filter2]
    print(possible_recommendations2)


    #possible recommendations and calculate relative and absolute score
    possible_recommendations = data[filter1 & filter2]


    #check movies with higher score from author
    print(possible_recommendations.head())


    #create new columns, metascore divided by ranking (relative) and metascore minus ranking (absolute)
    possible_recommendations.loc[:,'rel_inc'] = possible_recommendations.Metascore_w/ranking
    possible_recommendations.loc[:,'abs_inc'] = possible_recommendations.Metascore_w - ranking

    #store in recommendations dataframe
    recommendations = recommendations.append(possible_recommendations)


#sorting the recommendations in descending order (relative 1st and absolute 2nd)
recommendations = recommendations.sort_values(['rel_inc','abs_inc'], ascending=False)

#drop double entries
recommendations = recommendations.drop_duplicates(subset='movieName', keep="first")
print(recommendations)

#write to csv and print best 50 recommendations
recommendations.head(50).to_csv("~/VE/recommendationsBasedOnMetascore2.csv", sep=";", index=False)
print(recommendations.head(50))
print(recommendations.shape)



