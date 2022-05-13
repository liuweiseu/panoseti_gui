#PANOSETI Quadrant Board Housekeeping Data Logger
#v01 Oct 17, 2018 RR
#v02 fixed 1.0v shunt value
#v03 Nove 14, 2018 Added support for three values read from the FPGA XADC
#       and for detecting the first packet after boot

import time
import string
import socket
import sys
import os

#VREF is the HK ADC full-scale voltage
VREF =1250

hk_interval = 1

#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

logfilename = ".\quabo_hklog.csv"
#Send to hard-coded quabo address
QUABO_IP_ADD = "192.168.1.10"
#quabo expects commands on this port and will respond with housekeeping data to this port
UDP_HK_PORT= 60002
UDP_CMD_PORT= 60000

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
    sock.sendto(bytes(payload), (QUABO_IP_ADD, UDP_CMD_PORT))
    time.sleep(.001)



print ("Quadrant Board Data Logger")

try :
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    print ("Socket Created")
except socket.error as msg :
    print ('Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()    
sock.settimeout(10)

#Should not need to bind to the port, since we're not sending a reply.  But we do.
try:
    sock.bind(("", UDP_HK_PORT))
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
cmd_payload[0] = 0x20
cmd_payload[1] = hk_interval
#flush_rx_buf()
sendit(cmd_payload)


print("loc\ttemp\tftemp\thv0\thv1\thv2\thv3\tihv0\tihv1\tihv2\tihv3\trawhv\tv12 \tv18 \tv33 \tv37 \tf10 \tf18 \tI10 \tI18\tI33\t")
while (1):
    reply = sock.recvfrom(64)
    now =time.ctime().split(" ")[4]
    fhand.write(now + ',')
    #print ("Bytes Received =" + str(len(reply[0])))
    bytesback = reply[0]
    #print(bytesback)
    #for n in range(64):
    #    print (hex(int(bytesback[n])))
    val_array=[]
    firstboot = bytesback[1]
    if firstboot != 0:
        print("*********************** Firstboot byte = " + hex(firstboot) + "**************\n")
    for n in range(22):
        val_array.append(int(bytesback[2*n]) + 256*int(bytesback[2*n+1]))
        #print (str(val_array[n]))
    board_loc = val_array[1]
    print(hex(board_loc) + "\t", end='')
    fhand.write(hex(board_loc) + ',')
    #print ("Board Location = " + hex(board_loc) +"\n")
    temp = val_array[18]/4
    if temp>127.75: temp = temp - 128
    print (str(temp) +"\t", end='')
    fhand.write(str(temp) + ',')
    ##the temp from the FPGA XADC
    ftemp = val_array[19]
    ftemp = (((ftemp/65536)/0.00198421639) - 273.15)
    print ('{:2.2f}\t'.format(ftemp), end='')
    fhand.write('{:2.2f}\t'.format(ftemp))
    #Print the HV Mons
    for n in range(2,6):
        HVmon = (VREF/65536) * 10/158 * val_array[n]  # in volts
        print ('{:2.2f}\t'.format(HVmon),end='')
        fhand.write('{:2.2f},'.format(HVmon))
    #Print the IHVMons
    for n in range(6,10):
        IHVmon = ((65535 - val_array[n])/65536)*(VREF)/499 *1000# in uA
        print ('{:4.2f}\t'.format(IHVmon),end='')
        fhand.write('{:2.2f},'.format(IHVmon))
    #Print HVRaw
    HVmon = (VREF/65536) * 10/158 * val_array[10]
    print ('{:2.2f}\t'.format(HVmon),end='')
    fhand.write('{:2.2f},'.format(HVmon))
    #Print the 1.2v monitor
    HVmon = (VREF/65536) * val_array[11] /1000  #in volts
    print ('{:1.3f}\t'.format(HVmon),end='')
    fhand.write('{:1.3f},'.format(HVmon))
    #Print the 1.8v monitor
    HVmon = (VREF/65536) * 2 * val_array[12] /1000 # in volts
    print ('{:1.3f}\t'.format(HVmon),end='')
    fhand.write('{:1.3f},'.format(HVmon))
    #Print the 3.3v monitor
    HVmon = (VREF/65536) * 13.3/3.3 * val_array[13] / 1000 # in volts
    print ('{:1.3f}\t'.format(HVmon),end='')
    fhand.write('{:1.3f},'.format(HVmon))
    #Print the 3.7v monitor
    HVmon = (VREF/65536) * 13.3/3.3 * val_array[14] / 1000 # in volts
    print ('{:1.3f}\t'.format(HVmon),end='')
    fhand.write('{:1.3f},'.format(HVmon))
    #Print the VCCINT value from the FPGA
    HVmon = (val_array[20]*3/65536)  #in volts
    print ('{:1.3f}\t'.format(HVmon),end='')
    fhand.write('{:1.2f},'.format(HVmon))
    #Print the VCCAUX value from the FPGA
    HVmon = (val_array[21]*3/65536)  #in volts
    print ('{:1.3f}\t'.format(HVmon),end='')
    fhand.write('{:1.2f},'.format(HVmon))
  
    HVmon = (VREF/65536) /(.0077 * 21) * val_array[15] /1000  #in amps
    print ('{:1.2f}\t'.format(HVmon),end='')
    fhand.write('{:1.2f},'.format(HVmon))
    #Print the 1.8v current monitor
    HVmon = (VREF/65536) /.505 * val_array[16] /1000 # in amps
    print ('{:1.2f}\t'.format(HVmon),end='')
    fhand.write('{:1.2f},'.format(HVmon))
    #Print the 3.3v current monitor
    HVmon = (VREF/65536) /.505 * val_array[17] /1000 # in amps
    print ('{:1.2f}'.format(HVmon))
    fhand.write('{:1.2f},'.format(HVmon))
    fhand.write('\n')

