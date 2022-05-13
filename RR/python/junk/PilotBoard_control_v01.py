#PANOSETI Pilot Board Control

import time
import string
import socket
import sys
import os
#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

#Send to hard-coded zedboard address
UDP_DEST_IP = "192.168.1.10"
#zedboard expects commands on this port and will respond with housekeeping data to this port
UDP_CMD_PORT= 60001

sleep_time = 0
debug_print = 0

#104-byte array in which to form the 829-bit sequence to be sent to the MAROC chip
#the LS Bit of byte[0] of this array will be sent out first, and is the ON/OFF_otabg bit
MAROC_regs = [0 for x in range(104)] 

SERIAL_COMMAND_LENGTH = 829
#Set bits in the command_buf according to the input values.  Maximum value
# for field_width is 16 (a value can only span three bytes)
def set_bits(lsb_pos, field_width, value):
    if (field_width >16): return
    if ((field_width + lsb_pos) > SERIAL_COMMAND_LENGTH-1): return
    shift = (lsb_pos % 8)
    byte_pos = int((lsb_pos+7-shift)/8)
    mask=0
    for ii in range(0, field_width):
        mask = mask << 1
        mask = (mask | 0x1)
    mask = mask << shift

    MAROC_regs[byte_pos] = MAROC_regs[byte_pos] & ((~mask) & 0xff)
    MAROC_regs[byte_pos] = MAROC_regs[byte_pos] | ((value << shift) & 0xff)
    #if field spans a byte boundary
    if ((shift + field_width) > 8):
        MAROC_regs[byte_pos + 1] = MAROC_regs[byte_pos + 1] & ((~(mask>>8)) & 0xff)
        MAROC_regs[byte_pos + 1] = MAROC_regs[byte_pos + 1] | (((value >> (8-shift))) & 0xff)
    if ((shift + field_width) > 16):
        MAROC_regs[byte_pos + 2] = MAROC_regs[byte_pos + 2] & ((~(mask>>16)) & 0xff)
        MAROC_regs[byte_pos + 2] = MAROC_regs[byte_pos + 2] | (((value >> (16-shift))) & 0xff)

def reverse_bits(data_in, width):
    data_out = 0
    for ii in range(width):
        if (data_in & 1): data_out = data_out | 1
        data_in = data_in >> 1
        data_out = data_out << 1
    return data_out

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

#Use sendit(0) to send cmd_payload(1024 bytes) or sendit(1) to send pedmem_payload (1028 bytes)
#Only one size, 1024, for now
def sendit(size):
    if (size == 0):
        sock.sendto(bytes(cmd_payload), (UDP_DEST_IP, UDP_CMD_PORT))
    else:
        sock.sendto(bytes(pedmem_payload), (UDP_DEST_IP, UDP_CMD_PORT))       
    time.sleep(.001)
    if debug_print: print (cmd_payload)

    


##########################################################    
##########################################################    
##########################################################    


print ("Pilot Board Control")
try :
    sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM) # UDP
    print ("Socket Created")
except socket.error as msg :
    print ('Failed to create socket. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()    
sock.settimeout(0.5)
#os.system('arp -a')

#Need to "bind" socket to the 60001 port since the zed will respond to this port.  So host will send from 60001, 
# and therefore know to expect a response from 60001
try:
    sock.bind(("", UDP_CMD_PORT))
except socket.error as msg:
    print ('Bind failed. Error Code : ' + str(msg[0]) + ' Message ' + msg[1])
    sys.exit()
     
print ('Socket bind complete')
cmd_payload = bytearray(1024)
pedmem_payload = bytearray(1028)

while True:
    inp = input('''Enter 
    "L" to flash LEDs (interface test),
    "C" to send command data and report housekeeping,
    "M" to set acquisition mode,
    "ARP" to report ARP table,
    or "q" to quit
    ''')
    if inp == 'q':
        sock.close()
        quit()
    elif inp == 'L':
        led_time= .2
        leds = 0x01
        for i in range (8):
            cmd_payload[0] = 0x01
            cmd_payload[512] = leds
            sendit(0)
            time.sleep(led_time)
            leds = leds << 1
        
    elif inp == 'C':
        inp = input("Enter parameter filename (C:\config_files\Pilot_setup.txt)")
        if len(inp)<1: fname = "C:\config_files\Pilot_config.txt"
        else: fname = inp
        try:
            fhand = open(fname)
        except Exception as e:
            print (e)
            continue
        for line in fhand:
            if debug_print == 1:print (line)
            if line.startswith("*"): continue
            #strip off the comment
            strippedline = line.split('*')[0]
            fields = strippedline.split("=")
            if (fields[0] == "OTABG_ON"): set_bits(0,1,int(fields[1]))
            if (fields[0] == "DAC_ON"): set_bits(1,1,int(fields[1]))
            #Look for a GAIN value
            if fields[0].startswith("GAIN"):
                chan = fields[0].split('N')[1]
                chan = int(chan)
                val = int(fields[1],0)
                #print (chan, val)
                set_bits(764-8*chan,8,reverse_bits(val,8))
        fhand.close()
        cmd_payload[0] = 0x01
        for ii in range(104): cmd_payload[ii+1] = MAROC_regs[ii]
        flush_rx_buf()
        sendit(0)
        time.sleep(0.5)
        try:
            OK = 1
            reply = sock.recvfrom(1024)
        except:
            print ("No response from hardware")
            OK=0
        if OK:
            print ("Bytes Received =" + str(len(reply[0])))
            bytesback = reply[0]
            #print(bytesback)
            #for n in range(284,290):
                #print (hex(int(bytesback[n])))
            etime = 0
            for n in range(4):
                etime = 256*etime + int(bytesback[283-n])
            print ("Elapsed Time = ", etime)
            uid = 0
            for n in range(8):
                #print (hex(int(bytesback[291-n])))
                uid = 256*uid + int(bytesback[291-n])
            print ("Unique ID =", hex(uid))
    elif inp == 'M':
        inp1 = input("Set mode, 1, 2, or 3")
        mode = int(inp1)
        cmd_payload[0] = 0x01
        cmd_payload[160] = mode
        sendit(0)
    elif inp == 'ARP':
        os.system('arp -a')
    elif inp == '':
        inp1 = input("lsb_pos, width, value")
        vals = inp1.split(',')
        set_bits(int(vals[0]), int(vals[1]), int(vals[2]))
        for val in range(8): print(hex(MAROC_regs[val]))
        
        
