import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import scipy
import math
import operator

class KNN:

    def __init__(self, k=1):
        self.neighbors = k

    def euclideanDistance(self, point1, point2):
        x1 = point1[0]
        y1 = point1[1]
        x2 = point2[0]
        y2 = point2[1]
        
        return math.sqrt((y2-y1)**2 + (x2-x1)**2)

    def computeDistances(self, x1, x2):
        # compute distances
        distances = np.zeros((self.data.shape[0],))
        idx = 0
        for point in self.data:
            if x1 == point[1] & x2 == point[0]:
                distances[idx] = 0.0
            else:
                distances[idx] = self.euclideanDistance((x2,x1), point)
            idx+=1
        return distances

    def fit(self, X, y):
        self.data = X
        self.target = y

    def predict(self, duration, loudness):
        # compute the distance from this point to every other
        distances = self.computeDistances(duration, loudness)
        return self.target[distances.argmin()]
        #return self.target[distances.argmin()]