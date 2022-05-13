#PANOSETI Quadrant Board Science Logger
#This program can be run in a command window to acquire and store the "science"
# packets sent by quabo
#v01 Oct 17, 2018 RR
#v02 Oct 18, 2018 RR
#   Added delta elapsed time calc
#v03: Changed to store all data in one row, 64 from Chip0, then 64 from Chip1, then 64 from Chip2, then 64 from Chip3
#v04: added store_in_pixel_order option so we can write the data to the file in the order it appears in the image
#v05: Accumulated a set number of events, formed average.

import time
import string
import socket
import sys
import os

last_ET = 0;
print_values = 0

store_in_pixel_order = 1

#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

logfilename = ".\quabo_sci_log.csv"
#Send to hard-coded quabo address
QUABO_IP_ADD = "192.168.1.10"
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



print ("Quadrant Board Data Logger")

try :
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    print ("Socket Created")
except socket.error as msg :
    print ('Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()    
sock.settimeout(10)

#Need to "bind" socket to the SCI port since the quabo will send data to this port
try:
    sock.bind(("", UDP_SCI_PORT))
except socket.error as msg:
    print ('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
     
print ('Socket bind complete')



while (1):
    inp = input("How many events to get?")
    try:
        fhand = open(logfilename, 'w')
    except Exception as e:
        print (e)
    numtoget= int(inp)
    avg_val = []
    for n in range(256): avg_val.append(0)
    for n in range (numtoget):
        reply = sock.recvfrom(2048)
        now =time.ctime().split(" ")[4]
        #fhand.write(now + ',')
        #print ("Bytes Received =" + str(len(reply[0])))
        bytesback = reply[0]
        pktno = bytesback[3]*256 +bytesback[2]
        ET = bytesback[13]*256*256*256 + bytesback[12]*256*256 + bytesback[11]*256 +bytesback[10]
        delta_ET = ET - last_ET
        last_ET = ET
        #print(len(bytesback))
        print("acqmode= " + str(bytesback[0])+ ", pktno = " + str(pktno) + ", bdloc= " + hex(bytesback[5]*256 +bytesback[4]),end='')
        print(", elapsed time= " + str(ET) + ", delta ET = " + str(delta_ET))
        #Make an array for each chip
        chip0=[]
        chip1=[]
        chip2=[]
        chip3=[]
        #The data come with a 12b word in each pair of bytes in order chip3,chip2,chip1,chip0
        for n in range(256):
            if store_in_pixel_order:
                if n<64:chip0.append(bytesback[2*n+16]+256*bytesback[2*n+17])
                elif n<128:chip1.append(bytesback[2*n+16]+256*bytesback[2*n+17])
                elif n<192:chip2.append(bytesback[2*n+16]+256*bytesback[2*n+17])
                else: chip3.append(bytesback[2*n+16]+256*bytesback[2*n+17])
            else:
                half_row = int(n/8)
                if n<128:
                    if(half_row & 0x01)== 1:
                        chip0.append(bytesback[2*n+16]+256*bytesback[2*n+17])
                    else:
                        chip1.append(bytesback[2*n+16]+256*bytesback[2*n+17])
                else:
                    if(half_row & 0x01)== 1:
                        chip3.append(bytesback[2*n+16]+256*bytesback[2*n+17])
                    else:
                        chip2.append(bytesback[2*n+16]+256*bytesback[2*n+17])
        for n in range(64):
            fhand.write (str(chip0[n] & 0xfff) + ',')
            avg_val[n] += (chip0[n] & 0xfff)
        for n in range(64):
            fhand.write (str(chip1[n] & 0xfff) + ',')
            avg_val[n+64] += (chip1[n] & 0xfff)
        for n in range(64):
            fhand.write (str(chip2[n] & 0xfff) + ',')
            avg_val[n+128] += (chip2[n] & 0xfff)
        for n in range(63):
            fhand.write (str(chip3[n] & 0xfff) + ',')                 
            avg_val[n+192] += (chip3[n] & 0xfff)
        fhand.write('\n')
    for n in range(256):
        fhand.write (str(avg_val[n]/numtoget) + ',')
    fhand.close()