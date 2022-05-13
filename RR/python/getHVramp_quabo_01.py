#PANOSETI Quadrant Board HV Ramp Acq Program
#This program can be run in a command window to get teh data generated when sweeping the threshold
#v01 Nov 27, 2018 Started with store_sci_data_quabo_v02
#v02 Fixed data ordering in output


import time
import string
import socket
import sys
import os

handshake_filename = "HS_quabo.txt"
wait_after_each_test = .2
wait_after_handshake = 16

last_ET = 0;
print_values = 0
write_file = 1

#VREF is the HK ADC full-scale voltage
VREF =1250

#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

logfilename = ".\quabo_HVramp.csv"
#Send to hard-coded quabo address
QUABO_IP_ADD = "192.168.1.11"
#quabo expects commands on this port 
UDP_CMD_PORT= 60000
#and will send science data to this port
UDP_HK_PORT= 60002

def flush_rx_buf():
    sock.settimeout(.1)
    dumpcount = 0    
    #How big is the UDP buffer?  This is just guesswork
    while (dumpcount<32):
        try:
            #print (dumpcount)
            dumpbytes = sock.recvfrom(64)
            dumpcount +=1
        except:
            break    

def sendit(payload):
    sock.sendto(bytes(payload), (QUABO_IP_ADD, UDP_HK_PORT))
    time.sleep(.001)



print ("Quadrant Board Data Logger")

try :
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    print ("Socket Created")
except socket.error as msg :
    print ('Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()    
sock.settimeout(.1)

#Need to "bind" socket to the SCI port since the quabo will send data to this port
try:
    sock.bind(("", UDP_HK_PORT))
except socket.error as msg:
    print ('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
     
print ('Socket bind complete')

if write_file:
    try:
        fhand = open(logfilename, 'w')
    except Exception as e:
        print (e)

old_setting = -1
first_pass = 1
while (1):
    #Check to see if a new HV value has been written to the Quabo
    fhand_hs = open(handshake_filename)
    for line in fhand_hs:
        if line.startswith("HV="):
            HVsetting = int(line.split('=')[1])
    fhand_hs.close()
    time.sleep(wait_after_each_test)
    if (HVsetting != old_setting):
        flush_rx_buf()
        time.sleep(wait_after_handshake)
        print("Getting data for HV setting ", HVsetting)
        old_setting = HVsetting
        sock.settimeout(10)
        reply = sock.recvfrom(64)
        
        print ("Bytes Received =" + str(len(reply[0])))
        bytesback = reply[0]
        val_array=[]
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
        fhand.write('{:2.2f},'.format(ftemp))
        #Print the HV Setting
        fhand.write('{:4.2f},'.format(HVsetting))
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
        if (HVsetting == 0) & (first_pass == 0): 
            fhand.close()
            quit()
        else: first_pass = 0