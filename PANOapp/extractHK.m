clear all; close all;
SaveHKData=1
clear decodeas_and_dissector
filter='udp.dstport == 60002'
%filter='ip.addr >= 192.168.0.4 and ip.addr <= 192.168.4.4'
capture_stop_criteria=100000;
% decodeas_and_dissector.sn = [43 44 45 46]
% decodeas_and_dissector.timestamp = [47:54]
decodeas_and_dissector.Data = [1:32];
decodeas_and_dissector1= {'frame.number';'data.data'}; %'Data.Data';
%filenm='C:\Users\User\Desktop\test2.pcapng';
%filenm='C:\Users\User\Documents\panoseti\DATA\20200603\testconversion\data_00026_20200604205637';
%filenm='C:\Users\User\Documents\panoseti\DATA\20200603\9\data_00924_20200604045602.pcapng';
dateutc='20200709';%datestr(timeutc,'yyyymmdd');
dateconsider=[dateutc '\20200709112818\']
%dateconsider='20200603\9\'
myfolder=['C:\Users\User\Documents\panoseti\DATA\' dateutc  filesep];
MyFolderInfo = dir([myfolder '**/*.pcapng']);  
nbfiles=size(MyFolderInfo,1);


for ck=1:nbfiles
filenm=[ MyFolderInfo(1).folder filesep  MyFolderInfo(1).name];

%capture = pcap2matlab(filter, decodeas_and_dissector2,  filenm)
hkdata=1;
[capture0 cap] = pcap2mat(filter, decodeas_and_dissector1,  filenm, capture_stop_criteria,hkdata)
%capture0 is a fail

decodeas_and_dissector2= {'frame.number';'frame.time';'frame.time_epoch'}; %'Data.Data';
[capture cap0] = pcap2mat(filter, decodeas_and_dissector2,  filenm, capture_stop_criteria)
%datetime(capture(2).frametime,'ConvertFrom','posixtime','format','yyyy/MM/DD hh:mm:ss.SSSSSS')
datetime(capture(2).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles')
for dd=1:size(capture,2)
    cap(dd).jd=juliandate(datetime(capture(dd).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles'))
end
hk=cap;
%%%%%%%save HK
%  utclag=-1.*(getutcdelay('LICK')/24.);% in days
%                     time=now; %in days --break here for different time in observability plots
%                     timeutc=time+utclag;
%                     dateutc=datestr(timeutc,'yyyymmdd');


%rep=[readconfig('maindatadirectory') dateutc '\'];
if ~exist([getuserdir '\panoseti\'],'dir')
    mkdir([getuserdir '\panoseti\'])
end
rep=[getuserdir  '\panoseti\panoHK\'];
if ~exist(rep,'dir')
    mkdir(rep)
end

if ~isequal(exist(rep, 'dir'),7)
    mkdir(rep)
end

if isequal(exist([rep 'HKn_' dateutc  '.mat']),2)
    load([rep 'HKn_' dateutc  '.mat'])


     byte0tab=[byte0tab hk(:).byte0  ];
    boardloc=[ boardloc hk(:).boardloc ];
        hvmon0tab=[ hvmon0tab hk(:).hvmon0 ];
        hvmon1tab=[hvmon1tab hk(:).hvmon1 ];
        hvmon2tab=[ hvmon2tab hk(:).hvmon2];
        hvmon3tab=[ hvmon3tab hk(:).hvmon3];
        ihvmon0tab=[ ihvmon0tab hk(:).ihvmon0 ];
        ihvmon1tab=[ihvmon1tab hk(:).ihvmon1 ];
        ihvmon2tab=[ihvmon2tab hk(:).ihvmon2 ];
        ihvmon3tab=[ ihvmon3tab hk(:).ihvmon3];
        rawhvmontab=[ rawhvmontab hk(:).rawhvmon];
        v12montab=[v12montab hk(:).v12mon ];
        v18montab=[v18montab hk(:).v18mon ];
        v33montab=[v33montab hk(:).v33mon ];
        v37montab=[v37montab hk(:).v37mon ];
        i10montab=[i10montab hk(:).i10mon ];
        i18montab=[i18montab hk(:).i18mon ];
        i33montab=[ i33montab hk(:).i33mon ];
        temp1tab=[temp1tab hk(:).temp1c ];
        temp2tab=[temp2tab hk(:).temp2c ];
        vccinttab=[vccinttab hk(:).vccint ];
        vccauxtab=[vccauxtab hk(:).vccaux ];
%        utctab=[utctab hk(:).utc ];
        uidtab=[uidtab hk(:).uid ];
        shutterstatustab=[shutterstatustab hk(:).shutterstatus ];
        lightsensorstatustab=[ lightsensorstatustab hk(:).lightsensorstatus];
        firmwtimetab=[firmwtimetab hk(:).firmwtime ];
        firmwtab=[firmwtab hk(:).firmw ];
        jdtab=[jdtab hk(:).jd ];
%resort?
if min(jdtab(2:end)-jdtab(1:end-1))<0
    [jdtab,indsort] = sort(jdtab);
     byte0tab=[byte0tab(indsort)  ];
    boardloc=[ boardloc(indsort) ];
        hvmon0tab=[ hvmon0tab(indsort) ];
        hvmon1tab=[hvmon1tab(indsort) ];
        hvmon2tab=[ hvmon2tab(indsort)];
        hvmon3tab=[ hvmon3tab(indsort)];
        ihvmon0tab=[ ihvmon0tab(indsort) ];
        ihvmon1tab=[ihvmon1tab(indsort) ];
        ihvmon2tab=[ihvmon2tab(indsort) ];
        ihvmon3tab=[ ihvmon3tab(indsort)];
        rawhvmontab=[ rawhvmontab(indsort)];
        v12montab=[v12montab(indsort)];
        v18montab=[v18montab(indsort) ];
        v33montab=[v33montab(indsort) ];
        v37montab=[v37montab(indsort) ];
        i10montab=[i10montab(indsort) ];
        i18montab=[i18montab(indsort) ];
        i33montab=[ i33montab(indsort) ];
        temp1tab=[temp1tab(indsort) ];
        temp2tab=[temp2tab(indsort) ];
        vccinttab=[vccinttab(indsort) ];
        vccauxtab=[vccauxtab(indsort) ];
        uidtab=[uidtab(indsort) ];
        shutterstatustab=[shutterstatustab(indsort) ];
        lightsensorstatustab=[ lightsensorstatustab(indsort)];
        firmwtimetab=[firmwtimetab(indsort) ];
        firmwtab=[firmwtab(indsort) ];
        jdtab=[jdtab(indsort) ];
end
    
else
    
    byte0tab=[hk(:).byte0];
    boardloc=[hk(:).boardloc];
        hvmon0tab=[hk(:).hvmon0];
        hvmon1tab=[hk(:).hvmon1];
        hvmon2tab=[hk(:).hvmon2];
        hvmon3tab=[hk(:).hvmon3];
        ihvmon0tab=[hk(:).ihvmon0];
        ihvmon1tab=[hk(:).ihvmon1];
        ihvmon2tab=[hk(:).ihvmon2];
        ihvmon3tab=[hk(:).ihvmon3];
        rawhvmontab=[hk(:).rawhvmon];
        v12montab=[hk(:).v12mon];
        v18montab=[hk(:).v18mon];
        v33montab=[hk(:).v33mon];
        v37montab=[hk(:).v37mon];
        i10montab=[hk(:).i10mon];
        i18montab=[hk(:).i18mon];
        i33montab=[hk(:).i33mon];
        temp1tab=[hk(:).temp1c];
        temp2tab=[hk(:).temp2c];
        vccinttab=[hk(:).vccint];
        vccauxtab=[hk(:).vccaux];
        uidtab=[hk(:).uid];
        shutterstatustab=[hk(:).shutterstatus];
        lightsensorstatustab=[hk(:).lightsensorstatus];
        firmwtimetab=[hk(:).firmwtime];
        firmwtab=[hk(:).firmw];
        jdtab=[hk(:).jd];
        
end
if SaveHKData==1
    save([rep 'HKn_' dateutc  '.mat'], ...
        'byte0tab',...
        'boardloc',...
        'hvmon0tab',...
        'hvmon1tab',...
        'hvmon2tab',...
        'hvmon3tab',...
        'ihvmon0tab',...
        'ihvmon1tab',...
        'ihvmon2tab',...
        'ihvmon3tab',...
        'rawhvmontab',...
        'v12montab',...
        'v18montab',...
        'v33montab',...
        'v37montab',...
        'i10montab',...
        'i18montab',...
        'i33montab',...
        'temp1tab',...
        'temp2tab',...
        'vccinttab',...
        'vccauxtab','uidtab',...
        'shutterstatustab',...
        'lightsensorstatustab','firmwtimetab','firmwtab',...
        'jdtab')
    
end
end
%tshark -r test.pcap -Y udp -Tfields -e data.data

%capture = pcap2matlab([], decodeas_and_dissector2,  5, 1000)

%testpack;

% rotateframes;
%
% panohighevents3;
%
% imamultiresanalysis;



