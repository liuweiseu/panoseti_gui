#PANOSETI Quadrant Board Science Logger
#This program can be run in a command window to acquire and store the "science"
# packets sent by quabo
#v01 Oct 17, 2018 RR

import time
import string
import socket
import sys
import os


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

try:
    fhand = open(logfilename, 'w')
except Exception as e:
    print (e)
    #continue

#Need to send out an HK command to get things started
#cmd_payload = bytearray(64)
#for i in range(64): cmd_payload[i]=0
# #flush_rx_buf()
#sendit(cmd_payload)


while (1):
    reply = sock.recvfrom(2048)
    now =time.ctime().split(" ")[4]
    #fhand.write(now + ',')
    #print ("Bytes Received =" + str(len(reply[0])))
    bytesback = reply[0]
    pktno = bytesback[3]*256 +bytesback[2]
    ET = bytesback[13]*256*256*256 + bytesback[12]*256*256 + bytesback[11]*256 +bytesback[10]
    #print(len(bytesback))
    print("acqmode= " + str(bytesback[0])+ ", pktno = " + str(pktno) + ", bdloc= " + hex(bytesback[5]*256 +bytesback[4]),end='')
    print(", elapsed time= " + str(ET))
    fhand.write ("elapsed time= " + str(ET) + str(" pktno = ") + str(pktno) + "\n")
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
        print (n, hex(chip0[n]),hex(chip1[n]),hex(chip2[n]),hex(chip3[n]))
        #print (n, chip0[n] & 0xfff,chip1[n] & 0xfff, chip2[n] & 0xfff, chip3[n] & 0xfff)
        fhand.write (str(chip0[n] & 0xfff) +',' + str(chip1[n] & 0xfff) +',' + str(chip2[n] & 0xfff) +','+ str(chip3[n] & 0xfff) +'\n')
