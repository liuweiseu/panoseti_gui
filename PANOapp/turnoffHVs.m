% insert(py.sys.path,int32(0),[getuserdir filesep 'panoseti' filesep 'pythonlib' filesep])


% modeacq={'0x02'};
% dualmode=0;
% threshPE= 4.; % non dual-mode threshold (use dual mode =0)
% threshPEIma=4.5; % dual Imaging (use dual mode =1)
% threshPEPH=13.5; % dual PH (use dual mode=1)




IPtab=["192.168.0.4","192.168.0.5","192.168.0.6","192.168.0.7",...
   "192.168.3.248","192.168.3.249","192.168.3.250","192.168.3.251" ]

%  IPtab=["192.168.0.4","192.168.0.5","192.168.0.6","192.168.0.7" ]

% IPtab=["192.168.0.4",...
%    "192.168.3.248" ]
% IPtab=["192.168.3.248" ]

%IPtab=[ "192.168.3.248","192.168.3.249","192.168.3.250","192.168.3.251" ]
%IPtab=["192.168.3.248","192.168.3.249" ]
%IP='192.168.0.4';

for IPn=1:8%size(IPtab,2)
    IP=IPtab(IPn);
 %startqNph
 %  changepeq
 %  pauseboard
 stopHVg
end






