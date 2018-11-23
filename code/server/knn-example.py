import numpy as np  
import matplotlib.pyplot as plt  
import pandas as pd  
from sklearn.model_selection import train_test_split  
from sklearn.neighbors import KNeighborsClassifier  


# Based on: https://stackabuse.com/k-nearest-neighbors-algorithm-in-python-and-scikit-learn/
#url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
# Assign colum names to the dataset
names = ['sepal-length', 'sepal-width', 'petal-length', 'petal-width', 'Class']

# Read dataset to pandas dataframe
# dataset = pd.read_csv(url, names=names)  
dataset = pd.read_csv('iris.data', names=names)
print(dataset.head())


# Returns train_x,test_x,train_y,test_y
def prepare_dataset(df,train_percent):
	X = df.iloc[:,:-1].values
	Y = df.iloc[:,4].values
	return train_test_split(X, Y, test_size=train_percent)
	
def create_classifier(train_x,train_y):
	classifier = KNeighborsClassifier(n_neighbors=5)  
	classifier.fit(train_x, train_y)
	return classifier
	# return classifier.predict(test_x)

def prediction(x):
	predict([x])
def rescale():


	return 0


info = prepare_dataset(dataset,0.2)
cls = create_classifier(info[0],info[2])
# print(info[1][0])
print(info[2])
# print(cls.predict([info[1][0]]))


def test():
	return 0

def train():
	return 0

def __main__():
	
	return 0

__main__()