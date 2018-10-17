#Example from timmurphy.org/2013/11/11/using-fifos-in-python/
import os
import sys
path = "/tmp/my_program.fifo"
fifo = open(path,"r")
for line in fifo:
	print("Received: ",line)
fifo.close()
