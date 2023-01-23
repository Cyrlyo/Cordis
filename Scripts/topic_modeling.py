import gensim
from gensim.utils import simple_preprocess
from gensim.parsing.preprocessing import STOPWORDS
from nltk.stem import WordNetLemmatizer, SnowballStemmer
from nltk.stem.porter import *
import numpy as np
from typing import List
import nltk
from pandas import DataFrame

np.random.seed(2018)
nltk.download('wordnet')
nltk.download('omw-1.4')

def preprocess_data(data: DataFrame, column_name: str) -> List[str]:
    processed_data = []
    for text in data[column_name]:
        processed_data.append(preprocess(text))
    return processed_data
    
def preprocess(text):
    result = []
    for token in gensim.utils.simple_preprocess(text):
        if token not in gensim.parsing.preprocessing.STOPWORDS and len(token) > 3:
            result.append(lemmatize_stemming(token))
    return result

def lemmatize_stemming(text: str):
    stemmer = SnowballStemmer("english")
    return stemmer.stem(WordNetLemmatizer().lemmatize(text, pos='v'))

def create_dictionnary(processed_data):
    # Créer un dictionnaire à partir des données pré-traitées
    dictionary = gensim.corpora.Dictionary(processed_data)
    return dictionary

def create_corpus(dictionary,processed_data):
    # Créer un corpus à partir des données pré-traitées
    corpus = [dictionary.doc2bow(doc) for doc in processed_data]
    return corpus

def train_lda_model(corpus,dictionary):
    # Entraîner le modèle LDA
    ldamodel = gensim.models.ldamodel.LdaModel(corpus, num_topics=5, id2word=dictionary, passes=15)
    return ldamodel

def topicModeling(data: DataFrame, column_name: str):
    processed_data = preprocess_data(data, column_name)
    dictionary = create_dictionnary(processed_data)
    corpus = create_corpus(dictionary,processed_data)
    ldamodel = train_lda_model(corpus,dictionary)
    for i, row in data.iterrows():
        topic = ldamodel.get_document_topics(dictionary.doc2bow(processed_data[i]))
        topic_word = ldamodel.show_topic(topic[0][0])[0][0]
        # topic_word = ldamodel.show_topic(topic)
        print("Texte : ", row[column_name])
        print("Topic : ", topic_word)