import numpy as np  
import pandas as pd  
from sklearn.model_selection import train_test_split  
from sklearn.neighbors import KNeighborsClassifier  
from sklearn.preprocessing import StandardScaler  




# def prediction(classifier,x):
# 	classifier.predict([x])

# X: Training samples characteristics e.g. [[1 2] [1 4]]
# Y: Classe of each training sample Xi
# neighbors: Number of Nearest-Neighbors
# def create_classifier(X,Y,neighbors,):
# 	classifier = KNeighborsClassifier(n_neighbors=5)  
# 	classifier.fit(X, Y)
# 	return classifier

class knn:
	def __init__(self,X=None,Y=None,neighbors=3):
		self.X = X
		self.Y = Y
		self.classifier = None
		self.neighbors = neighbors
		self.has_trained = False
	def feature_scale(self):
		scaler = StandardScaler()
		scaler.fit(self.X)
		self.X = scaler.transform(self.X)

	def train(self):

		self.classifier = KNeighborsClassifier(n_neighbors=self.neighbors,metric='euclidean')
		# self.feature_scale()
		# self.X = self.X.reshape(-1,1)
		self.classifier.fit(self.X, self.Y)
		self.has_trained = True

	def predict(self,x):
		return self.classifier.predict(x)


# Based on: https://stackabuse.com/k-nearest-neighbors-algorithm-in-python-and-scikit-learn/
#url = "https://archive.ics.uci.edu/ml/machine-learning-databases/iris/iris.data"
# Assign colum names to the dataset
# names = ['sepal-length', 'sepal-width', 'petal-length', 'petal-width', 'Class']

# Read dataset to pandas dataframe
# dataset = pd.read_csv(url, names=names)  
# dataset = pd.read_csv('iris.data', names=names)
# print(dataset.head())
# knnc = knn(dataset.iloc[:,:-1].values,dataset.iloc[:,4].values)
# knnc.train()
# knnc.predict(dataset.iloc[:,:-1])
# cls = create_classifier(info[0],info[2])


def __main__():
	
	return 0

__main__()