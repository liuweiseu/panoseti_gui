IP='192.168.1.10'

quaboSN=input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
disp(['You decided to calibrate quabo SN' quaboSNstr])


quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

maskmode=0;
    quaboconfig = changemask(maskmode,[],quaboconfig); %maskmode: unmask all pix (=0); mask all excepted some (=1)
 


    %%%%%%%%%%%%%%%%%%%
    IP='192.168.1.10'

quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
quaboSN=input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
disp(['You decided to calibrate quabo SN' quaboSNstr])

szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};


quaboconfig = changemask(1,[4 1],quaboconfig);
gain=60;
quaboconfig=changegain(gain, quaboconfig,1); % third param is using an adjusted gain map (=1) or not (=0)
quaboconfig=changepe(8.5,gain,quaboconfig);



 %%%%%%%%%%%%%%%%%%%
    IP='192.168.1.11'

quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
quaboSN=input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
disp(['You decided to calibrate quabo SN' quaboSNstr])


quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};


quaboconfig = changemask(1,[4 1],quaboconfig);
gain=60;
quaboconfig=changegain(gain, quaboconfig,1); % third param is using an adjusted gain map (=1) or not (=0)
quaboconfig=changepe(8.5,gain,quaboconfig);



