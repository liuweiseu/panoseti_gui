function boardSN=IP2SN(IP)


load([getuserdir  filesep 'panoseti' filesep 'Calibrations' filesep 'Panoconfig2.mat' ], 'config2')
IPy=3;
indIP=find(contains(config2(:,IPy),IP)); 
if isempty(indIP)
    IPy=9;
indIP=find(contains(config2(:,IPy),IP));
end
if isempty(indIP)
    IPy=15;
indIP=find(contains(config2(:,IPy),IP));
end
if isempty(indIP)
    IPy=21;
indIP=find(contains(config2(:,IPy),IP));
end


SNboardstr=cell2mat(config2(indIP,IPy+1));
 boardSN=str2num(SNboardstr(end-2:end));
 
end
