filesize=50000;
nbfiles=100;
packetsperfile=800;

 prefix='p' ;
 capture_filter_str='';
 
 
 
% create the night directory if needed
utc=-1.*(getutcdelay('LICK'))/24.;% in days
time=now; %in days 
timeutc=time+utc;
dateutc=datestr(timeutc,'yyyymmdd');
 nightdir=[getuserdir filesep 'panoseti' filesep 'DATA' filesep dateutc]; 
if ~isequal(exist(nightdir, 'dir'),7)
   % mkdir(nightdir)
    comman=['sudo mkdir ' nightdir];
    eval(['[status cmdout]=system("' comman '")'])
end

while 1==1
timeutc=now+utc;
 datadir=[nightdir filesep datestr(timeutc,'yyyymmddHHMMSS') filesep]; 
 if ~isequal(exist(datadir, 'dir'),7)
 %mkdir(datadir)
    comman=['sudo mkdir ' datadir];
    eval(['[status cmdout]=system("' comman '")'])
 end
 
  panocap(filesize, nbfiles, packetsperfile, datadir, prefix, capture_filter_str)
end