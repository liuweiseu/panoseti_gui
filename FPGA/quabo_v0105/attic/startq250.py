
print ("Start Py")
from panoseti_tftp import tftpw


client=tftpw('192.168.3.250')

client.reboot()
#fhand.close()
#time.sleep(.2)
#sock.close()
#quit()