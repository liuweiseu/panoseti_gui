 function filename = saveconfigfile(quaboconfig,extraname)
 if ~exist('extraname','var')
     extraname=[];
 end
             utcshift=7/24; 
               %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
           configdir='C:\Users\jerome\Documents\panoseti\configs\';
             filename=[configdir 'config' extraname '_d0w0m0q0_' datestr(now+utcshift,'yyyymmdd_HHMMSS') '.txt'];
             %app.lastconfigfile=filename;
             %quaboconfig=app.currentconfig;
             savequaboconfig(filename, quaboconfig);
            
end