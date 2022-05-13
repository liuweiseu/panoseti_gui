#PANOSETI Quadrant Board Control
#Run this code in a command window to permit sending command packets to the Quabo
#v01 Oct 17 2018 RR
#v02 Changed config directory
#v03: support for PH Baseline cal
#       removed 'L' option (load all)
#       added 'R' reset option (was a do-nothing before)
#       added support for MAROC readback checking
#       removed housekeeping 'H' command
#       added support for setting stim rate 0 to 7 for 190 to 24,400 Hz
#v04:   Added 'VV' to turn off HV
#       Added support for baseline readback


import time
import string
import socket
import sys
import os
#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

configfilename = ".\config\quabo_config.txt"
baseline_fname = ".\quabo_baseline.csv"
#Send to hard-coded quabo address
UDP_DEST_IP = "192.168.1.10"
#quabo expects commands on this port and will respond with housekeeping data to this port
UDP_CMD_PORT= 60000

sleep_time = 0
debug_print = 0
debug_file = 0
#set this to 1 to set the MS bit of the command byte, telling quabo to echo back the command
echo_command = 1
#Set to 0 to disable periodic HK update.
#Housekeeping packet rate is about 1 per (hk_interval * 3 seconds)
hk_interval = 1

connected = 1

VREF = 1250

#Four 104-byte arrays in which to form the 829-bit sequences to be sent to the MAROC chips
#the LS Bit of byte[0] of each array will be sent out first, and is the ON/OFF_otabg bit
MAROC_regs=[]
for i in range (4):
    MAROC_regs.append([0 for x in range(104)])

#Store the HV values so we can update one at a time if we want
HV_vals=[0,0,0,0]
    
SERIAL_COMMAND_LENGTH = 829
#Set bits in the command_buf according to the input values.  Maximum value
# for field_width is 16 (a value can only span three bytes)
def set_bits(chip, lsb_pos, field_width, value):
    #print("setbits " + str(chip) + " " + str(lsb_pos) + " " + str(field_width) + " " + str(value)  + "\n")
    if (field_width >16): return
    if ((field_width + lsb_pos) > SERIAL_COMMAND_LENGTH): return
    shift = (lsb_pos % 8)
    byte_pos = int((lsb_pos+7-shift)/8)
    mask=0
    for ii in range(0, field_width):
        mask = mask << 1
        mask = (mask | 0x1)
    mask = mask << shift

    MAROC_regs[chip][byte_pos] = MAROC_regs[chip][byte_pos] & ((~mask) & 0xff)
    MAROC_regs[chip][byte_pos] = MAROC_regs[chip][byte_pos] | ((value << shift) & 0xff)
    #if field spans a byte boundary
    if ((shift + field_width) > 8):
        MAROC_regs[chip][byte_pos + 1] = MAROC_regs[chip][byte_pos + 1] & ((~(mask>>8)) & 0xff)
        MAROC_regs[chip][byte_pos + 1] = MAROC_regs[chip][byte_pos + 1] | (((value >> (8-shift))) & 0xff)
    if ((shift + field_width) > 16):
        MAROC_regs[chip][byte_pos + 2] = MAROC_regs[chip][byte_pos + 2] & ((~(mask>>16)) & 0xff)
        MAROC_regs[chip][byte_pos + 2] = MAROC_regs[chip][byte_pos + 2] | (((value >> (16-shift))) & 0xff)

def reverse_bits(data_in, width):
    data_out = 0
    for ii in range(width):
        data_out = data_out << 1
        if (data_in & 1): data_out = data_out | 1
        data_in = data_in >> 1
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

#payload is a bytearray of the desired length
def sendit(payload):
    sock.sendto(bytes(payload), (UDP_DEST_IP, UDP_CMD_PORT))
    time.sleep(.001)
    if debug_print: print (payload)

#take a 4-element list and call set_bits 4 times
def set_bits_4(tag, vals, lsb_pos, field_width):
    #vals = instring.split(",")
    if (len(vals) != 4):
        print("need 4 elements for " + tag +"\n")
        return
    set_bits(0, lsb_pos, field_width, vals[0])
    set_bits(1, lsb_pos, field_width, vals[1])
    set_bits(2, lsb_pos, field_width, vals[2])
    set_bits(3, lsb_pos, field_width, vals[3])

def send_maroc_params(fhand):
    cmd_payload = bytearray(492)
    for line in fhand:
        if debug_print == 1:print (line)
        if line.startswith("*"): continue
        #strip off the comment
        strippedline = line.split('*')[0]
        #Split the tag field from the cs value field
        fields = strippedline.split("=")
        if len(fields) !=2: continue
        tag = fields[0].strip()
        #Make a list of the should-be 4 ascii values
        vals = fields[1].split(",")
        #Make a list of integers
        vals_int = []
        for i in range(len(vals)): vals_int.append(int(vals[i],0))
        #For each tag, set the appropriate bit field
        if (tag == "OTABG_ON"): set_bits_4(fields[0], vals_int, 0, 1)
        if (tag == "DAC_ON"): set_bits_4(fields[0], vals_int, 1, 1)
        if (tag == "SMALL_DAC"): set_bits_4(fields[0], vals_int, 2, 1)
        if (tag == "DAC2"): 
            #need to reverse the bits
            vals_revbits = []
            for i in range (4):
                vals_revbits.append(reverse_bits(int(vals[i],0),10))
            set_bits_4(fields[0], vals_revbits, 3, 10)
        if (tag == "DAC1"): 
            vals_revbits = []
            for i in range (4):
                vals_revbits.append(reverse_bits(int(vals[i],0),10))
            set_bits_4(fields[0], vals_revbits, 13, 10)
        if (tag == "ENB_OUT_ADC"): set_bits_4(fields[0], vals_int, 23, 1)
        if (tag == "INV_START_GRAY"): set_bits_4(fields[0], vals_int, 24, 1)
        if (tag == "RAMP8B"): set_bits_4(fields[0], vals_int, 25, 1)
        if (tag == "RAMP10B"): set_bits_4(fields[0], vals_int, 26, 1)
        if (tag == "CMD_CK_MUX"): set_bits_4(fields[0], vals_int, 155, 1)
        if (tag == "D1_D2"): set_bits_4(fields[0], vals_int, 156, 1)
        if (tag == "INV_DISCR_ADC"): set_bits_4(fields[0], vals_int, 157, 1)
        if (tag == "POLAR_DISCRI"): set_bits_4(fields[0], vals_int, 158, 1)
        if (tag == "ENB3ST"): set_bits_4(fields[0], vals_int, 159, 1)
        if (tag == "VAL_DC_FSB2"): set_bits_4(fields[0], vals_int, 160, 1)
        if (tag == "SW_FSB2_50F"): set_bits_4(fields[0], vals_int, 161, 1)
        if (tag == "SW_FSB2_100F"): set_bits_4(fields[0], vals_int, 162, 1)
        if (tag == "SW_FSB2_100K"): set_bits_4(fields[0], vals_int, 163, 1)
        if (tag == "SW_FSB2_50K"): set_bits_4(fields[0], vals_int, 164, 1)
        if (tag == "VALID_DC_FS"): set_bits_4(fields[0], vals_int, 165, 1)
        if (tag == "CMD_FSB_FSU"): set_bits_4(fields[0], vals_int, 166, 1)
        if (tag == "SW_FSB1_50F"): set_bits_4(fields[0], vals_int, 167, 1)
        if (tag == "SW_FSB1_100F"): set_bits_4(fields[0], vals_int, 168, 1)
        if (tag == "SW_FSB1_100K"): set_bits_4(fields[0], vals_int, 169, 1)
        if (tag == "SW_FSB1_50k"): set_bits_4(fields[0], vals_int, 170, 1)
        if (tag == "SW_FSU_100K"): set_bits_4(fields[0], vals_int, 171, 1)
        if (tag == "SW_FSU_50K"): set_bits_4(fields[0], vals_int, 172, 1)
        if (tag == "SW_FSU_25K"): set_bits_4(fields[0], vals_int, 173, 1)
        if (tag == "SW_FSU_40F"): set_bits_4(fields[0], vals_int, 174, 1)
        if (tag == "SW_FSU_20F"): set_bits_4(fields[0], vals_int, 175, 1)
        if (tag == "H1H2_CHOICE"): set_bits_4(fields[0], vals_int, 176, 1)
        if (tag == "EN_ADC"): set_bits_4(fields[0], vals_int, 177, 1)
        if (tag == "SW_SS_1200F"): set_bits_4(fields[0], vals_int, 178, 1)
        if (tag == "SW_SS_600F"): set_bits_4(fields[0], vals_int, 179, 1)
        if (tag == "SW_SS_300F"): set_bits_4(fields[0], vals_int, 180, 1)
        if (tag == "ON_OFF_SS"): set_bits_4(fields[0], vals_int, 181, 1)
        if (tag == "SWB_BUF_2P"): set_bits_4(fields[0], vals_int, 182, 1)
        if (tag == "SWB_BUF_1P"): set_bits_4(fields[0], vals_int, 183, 1)
        if (tag == "SWB_BUF_500F"): set_bits_4(fields[0], vals_int, 184, 1)
        if (tag == "SWB_BUF_250F"): set_bits_4(fields[0], vals_int, 185, 1)
        if (tag == "CMD_FSB"): set_bits_4(fields[0], vals_int, 186, 1)
        if (tag == "CMD_SS"): set_bits_4(fields[0], vals_int, 187, 1)
        if (tag == "CMD_FSU"): set_bits_4(fields[0], vals_int, 188, 1)

        #Look for a MASKOR1 value; chan is in range 0-63, with a quad of values, one for each chip
        if tag.startswith("MASKOR1"):
            chan = tag.split('_')[1]
            chan = int(chan)
            set_bits_4(fields[0], vals_int, 154-(2*chan), 1)
        #Look for a MASKOR2 value; chan is in range 0-63, with a quad of values, one for each chip
        if tag.startswith("MASKOR2"):
            chan = tag.split('_')[1]
            chan = int(chan)
            set_bits_4(fields[0], vals_int, 153-(2*chan), 1)
        #Look for a CTEST value; chan is in range 0-63, with a quad of values, one for each chip
        if tag.startswith("CTEST"):
            chan = tag.split('_')[1]
            chan = int(chan)
            #if chan in range(4):
                #vals_int = [0,0,0,0]
            set_bits_4(fields[0], vals_int, 828-chan, 1)
            #print(fields[0], vals_int, chan)

        #Look for a GAIN value; chan is in range 0-63, with a quad of values, one for each chip
        if tag.startswith("GAIN"):
            chan = tag.split('N')[1]
            chan = int(chan)
            #Another list, with integer values, bits reversed
            vals_revbits = []
            for i in range (4):
                vals_revbits.append(reverse_bits((vals_int[i]),8))
            set_bits_4(fields[0], vals_revbits, 757-9*chan,8)
        if (echo_command): cmd_payload[0] = 0x81
        else: cmd_payload[0] = 0x01
        for ii in range(104): 
            cmd_payload[ii+4] = MAROC_regs[0][ii]
            cmd_payload[ii+132] = MAROC_regs[1][ii]
            cmd_payload[ii+260] = MAROC_regs[2][ii]
            cmd_payload[ii+388] = MAROC_regs[3][ii]
    if (debug_file):
        try:
            fdebug = open(".\debug.txt", 'w')
        except Exception as e:
            print (e)
            #continue
        for i in range(492):
            fdebug.write((hex(cmd_payload[i])) + "\n")
        fdebug.close()
        try:
            fdebug_bits = open(".\debug_bits.txt", 'w')
        except Exception as e:
            print (e)
            #continue
        for i in range(4,108):
            for j in range(8):
                fdebug_bits.write((str((int(cmd_payload[i])>>j) & 1))+"\n")
                #print(i,j)
        fdebug_bits.close()
    if connected == 1:
        flush_rx_buf()
        sendit(cmd_payload)
        if echo_command:  #We will check the reurned values against those sent out
            time.sleep(.2)
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
                match=1
                for i in range(108):
                    if cmd_payload[i]!=bytesback[i]: match=0
                for i in range(132,236):
                    if cmd_payload[i]!=bytesback[i]: match=0
                for i in range(260,364):
                    if cmd_payload[i]!=bytesback[i]: match=0
                for i in range(388,492):
                    if cmd_payload[i]!=bytesback[i]: match=0
                    
                if match: print("Data read from MAROCs MATCHES that sent out")
                else: print("Data read back DOESN'T MATCH that sent out")
            
def send_HV_params(fhand):
    cmd_payload = bytearray(64)
    for i in range(64): cmd_payload[i]=0
    if (echo_command): cmd_payload[0] = 0x82
    else: cmd_payload[0] = 0x02
    for line in fhand:
        if line.startswith("*"): continue
        #strip off the comment
        strippedline = line.split('*')[0]
        #Split the tag field from the cs value field
        fields = strippedline.split("=")
        if len(fields) !=2: continue
        tag = fields[0].strip()
        if (tag.startswith("HV")):
            chan = tag.split('_')[1]
            chan = int(chan)
            val = int(fields[1],0)
            HV_vals[chan]=val
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[2*chan+2]=LSbyte
            cmd_payload[2*chan+3]=MSbyte
            #print(hex(MSbyte),hex(LSbyte))
            
    if connected ==1:
        flush_rx_buf()
        sendit(cmd_payload)
        
def send_acq_parameters(fhand): 
    cmd_payload = bytearray(64)
    for i in range(64): cmd_payload[i]=0
    if (echo_command): cmd_payload[0] = 0x83
    else: cmd_payload[0] = 0x03
    for line in fhand:
        if line.startswith("*"): continue
        #strip off the comment
        strippedline = line.split('*')[0]
        #Split the tag field from the cs value field
        fields = strippedline.split("=")
        if len(fields) !=2: continue
        tag = fields[0].strip()
        if (tag == "ACQMODE"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[2]=LSbyte
            cmd_payload[3]=MSbyte
        if (tag == "ACQINT"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[4]=LSbyte
            cmd_payload[5]=MSbyte
        if (tag == "HOLD1"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[6]=LSbyte
            cmd_payload[7]=MSbyte
        if (tag == "HOLD2"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[8]=LSbyte
            cmd_payload[9]=MSbyte
        if (tag == "ADCCLKPH"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[10]=LSbyte
            cmd_payload[11]=MSbyte
        if (tag == "MONCHAN"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = (val >> 8) & 0xff
            cmd_payload[12]=LSbyte
            cmd_payload[13]=MSbyte
        if (tag == "STIMON"):
            val = int(fields[1],0)
            LSbyte = val & 0x01
            MSbyte = 0
            cmd_payload[14]=LSbyte
            cmd_payload[15]=MSbyte
        if (tag == "STIM_LEVEL"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = 0
            cmd_payload[16]=LSbyte
            cmd_payload[17]=MSbyte
        if (tag == "STIM_RATE"):
            val = int(fields[1],0)
            LSbyte = val & 0xff
            MSbyte = 0
            cmd_payload[18]=LSbyte
            cmd_payload[19]=MSbyte
            
            
    if connected ==1:
        flush_rx_buf()
        sendit(cmd_payload)

def send_trigger_mask(fhand):
    cmd_payload = bytearray(64)
    for i in range(64): cmd_payload[i]=0
    if (echo_command): cmd_payload[0] = 0x86
    else: cmd_payload[0] = 0x06
    for line in fhand:
        if line.startswith("*"): continue
        #strip off the comment
        strippedline = line.split('*')[0]
        #Split the tag field from the cs value field
        fields = strippedline.split("=")
        if len(fields) !=2: continue
        tag = fields[0].strip()
        chan_mask = [0,0,0,0,0,0,0,0,0]
        if (tag.startswith("CHANMASK")):
            chan = tag.split('_')[1]
            chan = int(chan)
            val = int(fields[1],0)
            chan_mask[chan]=val
            for i in range (4):
                cmd_payload[4*chan+4]=val & 0xff
                cmd_payload[4*chan+5]=(val>>8) & 0xff
                cmd_payload[4*chan+6]=(val>>16) & 0xff
                cmd_payload[4*chan+7]=(val>>24) & 0xff            
    if connected ==1:
        flush_rx_buf()
        return cmd_payload
        #sendit(cmd_payload)
    
##########################################################    
##########################################################    
##########################################################    


print ("Quadrant Board Control")
