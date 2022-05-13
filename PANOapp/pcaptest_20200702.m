clear all; close all;
clear decodeas_and_dissector
filter='ip.addr==192.168.0.4'
filter='ip.addr >= 192.168.0.4 and ip.addr <= 192.168.4.4'
capture_stop_criteria=100;
% decodeas_and_dissector.sn = [43 44 45 46]
% decodeas_and_dissector.timestamp = [47:54]
  decodeas_and_dissector.Data = [1:256];
decodeas_and_dissector1= {'frame.number';'data.data'}; %'Data.Data';
%filenm='C:\Users\User\Desktop\test2.pcapng';
%filenm='C:\Users\User\Documents\panoseti\DATA\20200603\testconversion\data_00026_20200604205637';
%filenm='C:\Users\User\Documents\panoseti\DATA\20200603\9\data_00924_20200604045602.pcapng';
dateconsider='20200702\20200702225100\'
%dateconsider='20200603\9\'
myfolder=['C:\Users\User\Documents\panoseti\DATA\' dateconsider];
MyFolderInfo = dir([myfolder '*.pcapng']);
nbfiles=size(MyFolderInfo,1);
file1 = MyFolderInfo(1).name;
filenm=[myfolder file1];

%capture = pcap2matlab(filter, decodeas_and_dissector2,  filenm)
[capture0 cap] = pcap2mat(filter, decodeas_and_dissector1,  filenm, capture_stop_criteria)
%capture0 is a fail

decodeas_and_dissector2= {'frame.number';'frame.time';'frame.time_epoch'}; %'Data.Data';
[capture cap0] = pcap2mat(filter, decodeas_and_dissector2,  filenm, capture_stop_criteria)
%datetime(capture(2).frametime,'ConvertFrom','posixtime','format','yyyy/MM/DD hh:mm:ss.SSSSSS')
datetime(capture(2).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles')

%tshark -r test.pcap -Y udp -Tfields -e data.data

%capture = pcap2matlab([], decodeas_and_dissector2,  5, 1000)

%%second packet to check transition:
testtransition=0;
if testtransition==1
file2 = MyFolderInfo(nbfiles-49).name;
filenm=[myfolder file2];
%capture = pcap2matlab(filter, decodeas_and_dissector2,  filenm)
[capture02 cap2] = pcap2mat(filter, decodeas_and_dissector1,  filenm)
end

testpack;

% rotateframes;
% 
% panohighevents3;
% 
% imamultiresanalysis;



