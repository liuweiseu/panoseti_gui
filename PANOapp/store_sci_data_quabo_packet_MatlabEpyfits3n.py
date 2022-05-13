#PANOSETI Quadrant Board Science Logger
#This program can be run in a command window to acquire and store the "science"
# packets sent by quabo
#v01 Oct 17, 2018 RR
#v02 Oct 18, 2018 RR
#   Added delta elapsed time calc


import time
import string
import socket
import sys
import os
import pyfits
import numpy as np


logfilename = ".\quabo_sci_log_test.csv"
#Send to hard-coded quabo address
QUABO_IP_ADD = "192.168.1.11"
#quabo expects commands on this port 
UDP_CMD_PORT= 60000
#and will send science data to this port
UDP_SCI_PORT= 60001

def flush_rx_buf():
    dumpcount = 0    
    #How big is the UDP buffer?  This is just guesswork
    while (dumpcount<32):
        try:
            #print (dumpcount)
            dumpbytes = sock.recvfrom(2048)
            dumpcount +=1
        except:
            break    

def sendit(payload):
    sock.sendto(bytes(payload), (QUABO_IP_ADD, UDP_SCI_PORT))
    time.sleep(.001)


def makeim(sock,fullfilename,nbimmax):
    print ("Quadrant Board Data Logger")
    nbim = 0 
    #last_ET = 0;
    print_values = 0
    while nbim<nbimmax:
        reply = sock.recvfrom(2048)
        now =time.ctime().split(" ")[4]
        #fhand.write(now + ',')
        #print ("Bytes Received =" + str(len(reply[0])))
        bytesback = reply[0]
        pktno = bytesback[3]*256 +bytesback[2]
        nanosec = bytesback[13]*256*256*256 + bytesback[12]*256*256 + bytesback[11]*256 +bytesback[10]
        utc =  bytesback[9]*256*256*256 + bytesback[8]*256*256 + bytesback[7]*256 +bytesback[6]
        #delta_ET = ET - last_ET
        #last_ET = ET
        if nbim==0:
            fhand = open(fullfilename+ '_'+str(pktno)+'.txt', 'w')
        #print(len(bytesback))
        #print("acqmode= " + str(bytesback[0])+ ", pktno = " + str(pktno) + ", bdloc= " + hex(bytesback[5]*256 +bytesback[4]),end='')
        #print(", elapsed time= "+', nanosec=' + str(nanosec) + ", delta ET = " + str(delta_ET))
        fhand.write (now + "acqmode= " + str(bytesback[0])+ ", pktno = " + str(pktno) +", nanosec=" + str(nanosec)+", utc=" + str(utc)+  ", bdloc= " + hex(bytesback[5]*256 +bytesback[4]) + "\n")
        #Make an array for each chip
        chip0=[]
        chip1=[]
        chip2=[]
        chip3=[]
        #The data come with a 12b word in each pair of bytes in order chip3,chip2,chip1,chip0
        for n in range(256):
            if(n & 0x03)== 1:
                chip3.append(bytesback[2*n+16]+256*bytesback[2*n+17])
            if(n & 0x03)== 0:
                chip2.append(bytesback[2*n+16]+256*bytesback[2*n+17])
            if(n & 0x03)== 3:
                chip1.append(bytesback[2*n+16]+256*bytesback[2*n+17])
            if(n & 0x03)== 2:
                chip0.append(bytesback[2*n+16]+256*bytesback[2*n+17])
        for n in range(64):
            #if (print_values):
            #    print (n, hex(chip0[n]),hex(chip1[n]),hex(chip2[n]),hex(chip3[n]))
            fhand.write (str(chip0[n] & 0xfff) +',' + str(chip1[n] & 0xfff) +',' + str(chip2[n] & 0xfff) +','+ str(chip3[n] & 0xfff) +'\n')
        #chip4 = chip0 + chip1 + chip2 + chip3
        nbim +=1 
        #chip4.append(pktno)
        #return (chip0, chip1, chip2, chip3)
        #return chip4
        #print(str(nbim))
        #pyfits.append('test2.fits',np.array(chip4))
    