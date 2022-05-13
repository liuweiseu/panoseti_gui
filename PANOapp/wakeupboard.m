% [status, result]=dos('ping 192.168.0.4','-echo')
% [status, result]=dos('ping 192.168.3.251','-echo')
% strfind(result,'unreachable')

IPtab=["192.168.0.4","192.168.0.5","192.168.0.6","192.168.0.7",...
   "192.168.3.248","192.168.3.249","192.168.3.250","192.168.3.251" ];
%IP='192.168.0.4';
available=zeros(1,size(IPtab,2));
for IPn=1:size(IPtab,2)
    IP=IPtab(IPn);
    [status, result]=dos(['ping ' cell2mat(IP)],'-echo');
    if strfind(result,'unreachable')
        disp(['board IP ' cell2mat(IP) 'not reachable'])
    else
        available(IPn)=1;
    end
end

IPtabav=IPtab(available);
cd 'C:\Users\User\Documents\panoseti\FPGA\quabo_v010\'
import panoseti_tftp.*
py.client=tftpw('192.168.0.4')

cd C:\Users\User\Documents\panoseti\FPGA\quabo_v0010\
python
from panoseti_tftp import tftpw
client=tftpw('192.168.0.4')
client=tftpw('192.168.3.248')
client=tftpw('192.168.3.252')
client.put_bin_file('quabo_v0090_GOLD.bin',0x0)
client.put_bin_file('quabo_v0090.bin')
client.reboot()
