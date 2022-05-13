import time
import serial
import sys      #For checking python version
#run this under Python 3.x
assert sys.version_info < (3,0)

sleep_time = .1
debug_print = 0

def ser_slow(text):
    ser.write(text)
    time.sleep(sleep_time)
    
print ("Panoseti Stepper Control")
try:
    ser = serial.Serial('COM16', 9600)
except:
    print ("Check Serial Port Connection")
    quit()
print("Serial port used: " + ser.name)         # check which port was really used
n=0
while n<10:
    a = ser.readline()
    print (a)
    if a.startswith("ard_hi"): 
        ser_slow("h")
        break
    time.sleep(sleep_time)
    n=n+1
    
#Dump anything in the receive buffer   
ser.reset_input_buffer()

    
while True:

    #inp = raw_input("Enter a pair of values: 0 or 1 (direction) and num steps (0 to 65535) or q to quit")
    #if inp == 'q':
        #ser.close()
        #quit()
    
    ser_slow("00010\r")
    time.sleep(1)
    print("* ")
     
ser.close()
quit()

