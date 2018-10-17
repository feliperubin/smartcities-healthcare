import os
path = "/tmp/my_program.fifo"
os.mkfifo(path)
fifo = open(path,"w")
fifo.write("Message from sender!\n")
fifo.close()
