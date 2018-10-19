import numpy as np
import matplotlib.pyplot as plt

plt.axis([0, 10, 0, 1])

while(True):
    y = np.random.random()
    i = np.random.random()
    x = plt.scatter(i, y)
    plt.pause(0.2)
    x.remove()

plt.show()
 