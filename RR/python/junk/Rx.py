import time
import string
import socket
import sys
import os

UDP_HK_PORT= 60002


try :
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    print ("Socket Created")
except socket.error as msg :
    print ('Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()    
sock.settimeout(10)

try:
    sock.bind(("", UDP_HK_PORT))
except socket.error as msg:
    print ('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
     
print ('Socket bind complete')

while (1):
    reply = sock.recvfrom(64)
    now =time.ctime().split(" ")[4]
    fhand.write(now + ',')
    print ("Bytes Received =" + str(len(reply[0])))
    bytesback = reply[0]
    for n in range(64):
        print (hex(int(bytesback[n])))
