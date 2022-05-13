#PANOSETI Quadrant Board Sweep Data Acq Program
#This program can be run in a command window to get teh data generated when sweeping the threshold
#v01 Nov 27, 2018 Started with store_sci_data_quabo_v02


import time
import string
import socket
import sys
import os

handshake_filename = "HS_quabo.txt"
wait_after_each_setting = .2

last_ET = 0;
print_values = 0
write_file = 1

#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

logfilename = ".\quabo_sweep.csv"
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

if write_file:
    try:
        fhand = open(logfilename, 'w')
    except Exception as e:
        print (e)

old_thresh = -1

while (1):
    fhand_hs = open(handshake_filename)
    for line in fhand_hs:
        if line.startswith("THR="):
            thresh = int(line.split('=')[1])
    fhand_hs.close()
    time.sleep(wait_after_each_setting)
    if thresh != old_thresh:
        print("Getting data for threshold ", thresh)
        old_thresh = thresh
        reply = sock.recvfrom(2048)
        now =time.ctime().split(" ")[4]
        #print ("Bytes Received =" + str(len(reply[0])))
        bytesback = reply[0]
        pktno = bytesback[3]*256 +bytesback[2]
        ET = bytesback[13]*256*256*256 + bytesback[12]*256*256 + bytesback[11]*256 +bytesback[10]
        delta_ET = ET - last_ET
        last_ET = ET
        #print(len(bytesback))
        print("acqmode= " + str(bytesback[0])+ ", pktno = " + str(pktno) + ", bdloc= " + hex(bytesback[5]*256 +bytesback[4]))
        #print(", elapsed time= " + str(ET) + ", delta ET = " + str(delta_ET))
        #We'll write the threshold to file, and all of the 16-bit values
        #And we'll total and display the number of triggers
        total_trigs = 0
        fhand.write (str(thresh) + ',')
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
        for n in range (64):
            fhand.write(str(chip0[n]) + ',')
            total_trigs += chip0[n]
        for n in range (64):
            fhand.write(str(chip1[n]) + ',')
            total_trigs += chip1[n]
        for n in range (64):
            fhand.write(str(chip2[n]) + ',')
            total_trigs += chip2[n]
        for n in range (64):
            fhand.write(str(chip3[n]) + ',')
            total_trigs += chip3[n]
        fhand.write('\n')
        print ("Thresh = ", thresh, "Total number of triggers = ", total_trigs)
