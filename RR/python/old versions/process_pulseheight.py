#process_pulseheight program.  Open a set of pulseheight files
# and process the data into a single file, averaging the PH data for each pixel at each level
#the channels are arranged as they appear in the image: column 0, then column 1, etc
# This means there are 8 values from U1, then 8 from u2, then 8 from U1, etc
#Set the flag arrange_data_by_chip to organize the data so we get all of U1, then all of U2, etc

#Modified to process only a single amplitude- see commented parts below

import time
import string
import sys
import os
#run this under Python 3.x
if (sys.version_info < (3,0)):
	print("Must run under python 3.x")
	quit()

arrange_data_by_chip = 1

#Average the values in each column; report averages in outlist
def proc_file(fhand, outlist):
	numsamps = 0
	for line in fhand:
		stripped_line = line.strip()
		vals = stripped_line.split(',')
		#for val in vals:print(int(val))
		if numsamps==0:
			for val in vals:
				#there's a comma after the last value, so skip the null string
				#  that results
				if val == '':continue
				outlist.append(int(val))
		else:
			for n in range(len(vals)-1):
				outlist[n]+=int(vals[n])
		numsamps+=1
	for n in range(len(outlist)):
		outlist[n] = outlist[n]/numsamps
	#print(outlist)
		

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
					if 16*i+j+136== 255:continue
					fhand.write (str(alist[16*i+j+136]) + ",")
		
	
pathname = '.\data'


inp = input("Input serial no (SN05)")
if inp =='': inp = "SN05"
if arrange_data_by_chip == 0:
	#outfilename = "\PH_summmary_" +inp+ ".csv"
	outfilename = "\PH_average_" +inp+ ".csv"
else:
	#outfilename = "\PH_summmary_bychip_" +inp+ ".csv"
	outfilename = "\PH_average_bychip_" +inp+ ".csv"
try:
    outhand = open(pathname+outfilename,'w')
except Exception as e:
    print (e)
    quit()

#We'll call proc_file for each of the PH data files, and
#  average the values for each pixel
#infilename = "\quabo_sci_PH32_" + inp + ".csv"
infilename = "\quabo_sci_PH_flash_" + inp + ".csv"
try:
    inhand = open(pathname+infilename)
except Exception as e:
    print (e)
    quit()
outlist = []
proc_file(inhand, outlist)
inhand.close()
if arrange_data_by_chip == 0:
	for val in outlist:
		outhand.write (str(val) + ",")
else:
	arrange_by_chip(outhand, outlist)
outhand.write ("\n")

# infilename = "\quabo_sci_PH64_" + inp + ".csv"
# try:
    # inhand = open(pathname+infilename)
# except Exception as e:
    # print (e)
    # quit()
# outlist = []
# proc_file(inhand, outlist)
# inhand.close()
# if arrange_data_by_chip == 0:
	# for val in outlist:
		# outhand.write (str(val) + ",")
# else:
	# arrange_by_chip(outhand, outlist)
# outhand.write ("\n")


# infilename = "\quabo_sci_PH128_" + inp + ".csv"
# try:
    # inhand = open(pathname+infilename)
# except Exception as e:
    # print (e)
    # quit()
# outlist = []
# proc_file(inhand, outlist)
# inhand.close()
# if arrange_data_by_chip == 0:
	# for val in outlist:
		# outhand.write (str(val) + ",")
# else:
	# arrange_by_chip(outhand, outlist)
# outhand.write ("\n")

outhand.close()

