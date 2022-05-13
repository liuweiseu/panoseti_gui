#process_sweep program.  Open a set of sweep files
# and process the data into a single file, finding a trigger threshold point
# for each pixel, for each level
#the channels are arranged as they appear in the image: column 0, then column 1, etc
# This means there are 8 values from U1, then 8 from u2, then 8 from U1, etc
#Set the flag arrange_data_by_chip to organize the data so we get all of U1, then all of U2, etc

import time
import string
import sys
import os
#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

arrange_data_by_chip = 1

#Make a list of trigger values for each pixel, then find the place where
# the number of trggers drops to 1/2 of thresh, and make a list of this values
def proc_file(fhand, mintrigs, outlist):
	#Make an empty list for each pixel
	listoflists = []
	for n in range(256):
		val_list = []
		listoflists.append(val_list)
	#A list of the thresholds
	threshlist=[]
	line_num=0
	for line in fhand:
		#skip the first line;it's junk from a previous test
		if line_num == 0: 
			line_num+=1
			continue
		vals = line.split(',')
		#first column is the threshold
		threshlist.append(int(vals[0]))
		for n in range(1,257):
			listoflists[n-1].append(int(vals[n]))
		line_num+=1
	num_vals = line_num-1
	#Now we should have a list of N thresholds and 256 lists of N trigger
	#values each.  Starting at the end, find the transition point when the 
	#value goes from 0 to <=mintrigs, and append this thresh
	# value to outlist
	#print(listoflists[0])
	for chan in range(256):
		for val in range(num_vals,1,-1):
			#print(val)
			if(listoflists[chan][val-1] >= mintrigs): 
				outlist.append(threshlist[val-1])
				break
	#print(min(outlist), max(outlist))

def arrange_by_chip(fhand,alist):
	for i in range(8):
		for j in range(8):
					fhand.write (str(alist[16*i+j]) + ",")
	for i in range(8):
		for j in range(8):
					fhand.write (str(alist[16*i+j+8]) + ",")
	for i in range(8):
		for j in range(8):
					fhand.write (str(alist[16*i+j+128]) + ",")
	for i in range(8):
		for j in range(8):
					fhand.write (str(alist[16*i+j+136]) + ",")
		
	
pathname = '.\data'


inp = input("Input serial no (SN05)")
if inp =='': inp = "SN05"
if arrange_data_by_chip == 0:
	outfilename = "\sweep_summmary_" +inp+ ".csv"
else:
	outfilename = "\sweep_summmary_bychip_" +inp+ ".csv"
try:
    outhand = open(pathname+outfilename,'w')
except Exception as e:
    print (e)
    quit()

#We'll call proc_file for each of the sweep data files, and
# find the thresh at which trigger drops below the mintrigs value
# and write that thresh value out to the outfile for each channel
infilename = "\quabo_sweep_0STIM_" + inp + ".csv"
try:
    inhand = open(pathname+infilename)
except Exception as e:
    print (e)
    quit()
thresh0list = []
proc_file(inhand, 1, thresh0list)
inhand.close()
if arrange_data_by_chip == 0:
	for val in thresh0list:
		outhand.write (str(val) + ",")
else:
	arrange_by_chip(outhand, thresh0list)
outhand.write ("\n")

infilename = "\quabo_sweep_32STIM_" + inp + ".csv"
try:
    inhand = open(pathname+infilename)
except Exception as e:
    print (e)
    quit()
thresh0list = []
proc_file(inhand, 1, thresh0list)
inhand.close()
if arrange_data_by_chip == 0:
	for val in thresh0list:
		outhand.write (str(val) + ",")
else:
	arrange_by_chip(outhand, thresh0list)
outhand.write ("\n")

infilename = "\quabo_sweep_64STIM_" + inp + ".csv"
try:
    inhand = open(pathname+infilename)
except Exception as e:
    print (e)
    quit()
thresh0list = []
proc_file(inhand, 1, thresh0list)
inhand.close()
if arrange_data_by_chip == 0:
	for val in thresh0list:
		outhand.write (str(val) + ",")
else:
	arrange_by_chip(outhand, thresh0list)
outhand.write ("\n")
outhand.close()

