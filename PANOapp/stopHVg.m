quaboSN=num2str(IP2SN(IP));%input('Enter quabo SN:','s');
quaboSNstr=num2str(str2num(quaboSN),'%03d');
%disp(['You decided to use quabo SN' quaboSNstr])


%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config.txt']);
%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_DUAL.txt']);
%quaboconfig=importquaboconfig([getuserdir '\panoseti\defaultconfig\quabo_config_PHdual.txt']);
quaboconfig=importquaboconfig([getuserdir filesep 'panoseti' filesep 'defaultconfig' filesep 'quabo_config.txt']);

%disp('Starting HV...')
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'IP'};quaboconfig(szq+1,3)={IP};
szq=size(quaboconfig,1);
quaboconfig(szq+1,1)={'QuaboSN'};quaboconfig(szq+1,3)={str2num(quaboSN)};

stopHV(quaboconfig)