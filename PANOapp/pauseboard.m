quaboconfig=importquaboconfig([getuserdir filesep 'panoseti' filesep 'defaultconfig' filesep 'quabo_config.txt']);

[ig,indexacqmode]=ismember(['ACQMODE '] ,quaboconfig);
    quaboconfig(indexacqmode,2)={"0x0"};

    
    quaboSN=num2str(IP2SN(IP));%input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
%disp(['You decided to use quabo SN' quaboSNstr])


szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

    
    
    
  % quaboconfig=changepe(30.,gain,quaboconfig); 
    sentacqparams2board(quaboconfig)