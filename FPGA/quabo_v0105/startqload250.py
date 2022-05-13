
print ("Start Py")
from panoseti_tftp import tftpw


client=tftpw('192.168.3.250')
client.put_bin_file('quabo_0103_22C57D1F.bin')
#client.put_bin_file('quabo_0105F_23175810.bin')
#client.put_bin_file('quabo_0105B_230E4CDF.bin')
#time.sleep(.2)
#client.reboot()
#fhand.close()
#time.sleep(.2)
#sock.close()
#quit()