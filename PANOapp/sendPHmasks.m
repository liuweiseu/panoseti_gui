  function sendPHmasks(quaboconfig)
%              quaboconfig=app.currentconfig;
%              %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
%             utcshift=7/24; 
%              filename=[app.configdir 'config_d0w0m0q0_' datestr(time+utcshift,'yyyymmdd_HHMMSS') '.txt']
%              app.lastconfigfile=filename;
%              savequaboconfig(filename, quaboconfig);
             filename=saveconfigfile(quaboconfig);
             fhand=py.open(filename);
             %system('python control_quabo_matlab7.py')
             cmd_payload=py.control_quabo_matlab8.send_trigger_mask(fhand);
              sendpacket2board(cmd_payload);


        end