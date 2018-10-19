from mpl_toolkits.mplot3d import Axes3D
import matplotlib.pyplot as plt
import numpy as np
import os
import sys
# echo -n 'sup' > /tmp/my_program.fifo 
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
ax.set_xlabel('X Label')
ax.set_ylabel('Y Label')
ax.set_zlabel('Z Label')


path = "/tmp/my_program.fifo"

try: 
	fifo = open(path,"r")
except:
	os.mkfifo(path)
	fifo =  open(path,"r")

sct = ax.scatter(0,0,0,color="g",s=100)
while True:
	line = fifo.read()
	if len(line) > 0:
		point = line.split(",")
		print(point)
		
		sct.remove()
		sct = ax.scatter(int(point[0]), int(point[1]), int(point[2]), color="g", s=100)
		plt.pause(0.2)
		# print(line)

plt.show()

