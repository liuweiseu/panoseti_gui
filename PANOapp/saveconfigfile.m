 function filename = saveconfigfile(quaboconfig,extraname)
 if ~exist('extraname','var')
     extraname=[];
 end
 
 [ia,index]=ismember('IP',quaboconfig);
  IP=(quaboconfig(index,3));
  bn=IP2bn(IP);
             utcshift=7/24; 
               %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
           configdir=[getuserdir filesep 'panoseti' filesep 'configs' filesep];
             filename=[configdir 'config' extraname '_b' num2str(bn) '_' datestr(now+utcshift,'yyyymmdd_HHMMSS') '.txt'];
             %app.lastconfigfile=filename;
             %quaboconfig=app.currentconfig;
             savequaboconfig(filename, quaboconfig);
            
end