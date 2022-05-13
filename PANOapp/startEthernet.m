
%start ethernet with netsh
% netsh interface show interface    will show interfaces
% netsh interface set interface "Ethernet" admin=enable     to enable
% 
[~,cmdout]=system('cmd /C C:\Windows\System32\WindowsPowerShell\v1.0\powershell -Command "netsh interface set interface "Ethernet" admin=enable"')