#PANOSETI Quadrant Board Science Logger
#v01 Oct 14, 2018 RR

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
UDP_SCI_PORT= 60000

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

#Need to "bind" socket to the HK port since the quabo will send data to this port
try:
    #sock.bind((QUABO_IP_ADD, UDP_HK_PORT))    
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
cmd_payload = bytearray(64)
for i in range(64): cmd_payload[i]=0
# #flush_rx_buf()
sendit(cmd_payload)


while (1):
    reply = sock.recvfrom(512)
    now =time.ctime().split(" ")[4]
    fhand.write(now + ',')
    #print ("Bytes Received =" + str(len(reply[0])))
    bytesback = reply[0]
    print(bytesback)
    #for n in range(64):
    #    print (hex(int(bytesback[n])))
