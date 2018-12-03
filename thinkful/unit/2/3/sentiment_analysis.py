import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import scipy
from sklearn.naive_bayes import BernoulliNB
from sklearn.naive_bayes import MultinomialNB
from sklearn.model_selection import cross_val_score
from sklearn.metrics import confusion_matrix
from sklearn.model_selection import train_test_split
import re
import nltk
import yaml
from nltk.sentiment.vader import SentimentIntensityAnalyzer
from nltk.tokenize import word_tokenize # or use some other tokenizer

'''
Author: Mitchell Murphy
Date: 1 Dec 2019
This basic sentiment analysis came from: http://fjavieralba.com/basic-sentiment-analysis-with-python.html
'''


'''
    INPUT: single sentence 
    OUTPUT: list of values: [negative, neutral, positive, compound]
'''
def nltk_sentiment(sentence, return_list = True):
    nltk_sentiment = SentimentIntensityAnalyzer()
    score = nltk_sentiment.polarity_scores(sentence)
    # score will look like:
    # {'neg': 0.0, 'neu': 0.667, 'pos': 0.333, 'compound': 0.3612}
    if return_list:
        # [0.0, 0.667, 0.333, 0.3612]
        score = [ item[1] for item in score.items() ]
        return score[0], score[1], score[2], score[3]
    else:
        return score


def percent_capitalized_words(review, return_number = False):
    # first we need to get each sentence
    pattern = re.compile("[A-Z]{2,}")
    words_to_ignore = ["US", "USA", "PC", "AC", "DC", "MP", "PDA",
                    "RAZR", "QWERTY", "BT", "DNA", "HS850", "OS"]
    found = 0  

    sentences = review.split('.')
    num_words = len(sentences)
    for sentence in sentences:
        words = sentence.split(' ') 
        for word in words:
            if word in words_to_ignore:
                continue
            if pattern.match(word):
                found += 1
    if return_number:
        return found
    else:
        return found / num_words


class Splitter(object):
    def __init__(self):
        self.nltk_splitter = nltk.data.load('tokenizers/punkt/english.pickle')
        self.nltk_tokenizer = nltk.tokenize.TreebankWordTokenizer()

    def split(self, text):
        """
        input format: a paragraph of text
        output format: a list of lists of words.
            e.g.: [['this', 'is', 'a', 'sentence'], ['this', 'is', 'another', 'one']]
        """
        sentences = self.nltk_splitter.tokenize(text)
        tokenized_sentences = [self.nltk_tokenizer.tokenize(sent) for sent in sentences]
        return tokenized_sentences


class POSTagger(object):
    def __init__(self):
        pass
        
    def pos_tag(self, sentences):
        """
        input format: list of lists of words
            e.g.: [['this', 'is', 'a', 'sentence'], ['this', 'is', 'another', 'one']]
        output format: list of lists of tagged tokens. Each tagged tokens has a
        form, a lemma, and a list of tags
            e.g: [[('this', 'this', ['DT']), ('is', 'be', ['VB']), ('a', 'a', ['DT']), ('sentence', 'sentence', ['NN'])],
                    [('this', 'this', ['DT']), ('is', 'be', ['VB']), ('another', 'another', ['DT']), ('one', 'one', ['CARD'])]]
        """

        pos = [nltk.pos_tag(sentence) for sentence in sentences]
        #adapt format
        pos = [[(word, word, [postag]) for (word, postag) in sentence] for sentence in pos]
        return pos

class DictionaryTagger(object):
    def __init__(self, dictionary_paths):
        files = [open(path, 'r') for path in dictionary_paths]
        dictionaries = [yaml.load(dict_file) for dict_file in files]
        map(lambda x: x.close(), files)
        self.dictionary = {}
        self.max_key_size = 0
        for curr_dict in dictionaries:
            for key in curr_dict:
                if key in self.dictionary:
                    self.dictionary[key].extend(curr_dict[key])
                else:
                    self.dictionary[key] = curr_dict[key]
                    self.max_key_size = max(self.max_key_size, len(key))

    def tag(self, postagged_sentences):
        return [self.tag_sentence(sentence) for sentence in postagged_sentences]

    def tag_sentence(self, sentence, tag_with_lemmas=False):
        """
        the result is only one tagging of all the possible ones.
        The resulting tagging is determined by these two priority rules:
            - longest matches have higher priority
            - search is made from left to right
        """
        tag_sentence = []
        N = len(sentence)
        if self.max_key_size == 0:
            self.max_key_size = N
        i = 0
        while (i < N):
            j = min(i + self.max_key_size, N) #avoid overflow
            tagged = False
            while (j > i):
                expression_form = ' '.join([word[0] for word in sentence[i:j]]).lower()
                expression_lemma = ' '.join([word[1] for word in sentence[i:j]]).lower()
                if tag_with_lemmas:
                    literal = expression_lemma
                else:
                    literal = expression_form
                if literal in self.dictionary:
                    #self.logger.debug("found: %s" % literal)
                    is_single_token = j - i == 1
                    original_position = i
                    i = j
                    taggings = [tag for tag in self.dictionary[literal]]
                    tagged_expression = (expression_form, expression_lemma, taggings)
                    if is_single_token: #if the tagged literal is a single token, conserve its previous taggings:
                        original_token_tagging = sentence[original_position][2]
                        tagged_expression[2].extend(original_token_tagging)
                    tag_sentence.append(tagged_expression)
                    tagged = True
                else:
                    j = j - 1
            if not tagged:
                tag_sentence.append(sentence[i])
                i += 1
        return tag_sentence

def value_of(sentiment):
    if sentiment == 'positive': return 1
    if sentiment == 'negative': return -1
    return 0


def sentence_score(sentence_tokens, previous_token, acum_score):    
    if not sentence_tokens:
        return acum_score
    else:
        current_token = sentence_tokens[0]
        tags = current_token[2]
        token_score = sum([value_of(tag) for tag in tags])
        if previous_token is not None:
            previous_tags = previous_token[2]
            if 'inc' in previous_tags:
                token_score *= 2.0
            elif 'dec' in previous_tags:
                token_score /= 2.0
            elif 'inv' in previous_tags:
                token_score *= -1.0
        return sentence_score(sentence_tokens[1:], current_token, acum_score + token_score)

def sentiment_score(review):
    return sum([sentence_score(sentence, None, 0.0) for sentence in review])


def get_score_for_word(reviews, word):
    q = 'review.str.contains(" {} ")'.format(word)
    return reviews.query(q).score.mean()

def get_top_words(reviews, num_of_words):
    # lets determine which "buzzwords" are more frequent 
    word_counts = reviews.review.str.split(expand=True).stack().value_counts().to_frame()
    
    
    word_counts_positive = reviews.query("score == 1").review.str.split(expand=True).stack().value_counts()
    word_counts_negative = reviews.query("score == 0").review.str.split(expand=True).stack().value_counts()
    # get the words unique to negative review
    words_negative = word_counts_negative.index.difference(word_counts_positive.index)
    words_positive = word_counts_positive.index.difference(word_counts_negative.index)
    x = word_counts_positive[words_positive].sort_values(ascending = False).head(num_of_words).index
    pos_words = x.to_series().apply(str.lower).values
    # also need to pull out the punctuation
    y = word_counts_negative[words_negative].sort_values(ascending = False).head(num_of_words).index
    neg_words = y.to_series().apply(str.lower).values
    return neg_words, pos_words

def convert_review(review):
    # input is a string
    return re.sub(r'([^a-zA-Z\'\s]+?)', '', review.lower())