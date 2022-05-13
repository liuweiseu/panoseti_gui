import time
import serial
import sys      #For checking python version
#run this under Python 3.x
assert sys.version_info >= (3,0)

sleep_time = .1
debug_print = 0

def ser_slow(text):
    ser.write(text)
    time.sleep(sleep_time)
    
print ("Panoseti Stepper Control")
try:
    ser = serial.Serial('COM4', 9600)
except:
    print ("Check Serial Port Connection")
    quit()
print("Serial port used: " + ser.name)         # check which port was really used
n=0
while n<10:
    a = ser.readline()
    print (a)
    if a.startswith(b"ard_hi"): 
        ser_slow(b"h")
        break
    time.sleep(sleep_time)
    n=n+1
    
#Dump anything in the receive buffer   
ser.reset_input_buffer()

    
while True:

    inp = input("Enter a pair of values: 0 or 1 (direction) and num steps (0 to 65535) or q to quit\n\r")
    if inp == 'q':
        ser.close()
        quit()
    else:
        vals = inp.split(',')
        steps = hex(int(vals[1]))
        steps_stripped = steps.split('x')
        steps_padded = (4-len(steps_stripped[1]))*'0' + steps_stripped[1]
        val2send= vals[0] + steps_padded + '\r'
        #print (val2send)
        ser_slow(val2send.encode('utf-8'))
    #time.sleep(1)
    #print("* ")
     
ser.close()
quit()

