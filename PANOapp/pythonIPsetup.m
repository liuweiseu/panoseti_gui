cd C:\Users\User\Documents\panoseti\FPGA\quabo_v0010\
python
from panoseti_tftp import tftpw
from panoseti_tftp import *
client=tftpw('192.168.0.4')
client=tftpw('192.168.3.248')
client=tftpw('192.168.3.252')
client.put_bin_file('quabo_v0090_GOLD.bin',0x0)
client.put_bin_file('quabo_v0090.bin')
client.reboot()

%%wireshark filter: ip.addr == 192.168.3.251