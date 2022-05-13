  function stopHV(quaboconfig)
%              quaboconfig=app.currentconfig;
%              %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
%             utcshift=7/24; 
%              filename=[app.configdir 'config_d0w0m0q0_' datestr(time+utcshift,'yyyymmdd_HHMMSS') '.txt']
%              app.lastconfigfile=filename;
%              savequaboconfig(filename, quaboconfig);

[ia,index]=ismember('HV_0 ',quaboconfig);
quaboconfig(index,2)="0";
[ia,index]=ismember('HV_1 ',quaboconfig);
quaboconfig(index,2)="0";
[ia,index]=ismember('HV_2 ',quaboconfig);
quaboconfig(index,2)="0";
[ia,index]=ismember('HV_3 ',quaboconfig);
quaboconfig(index,2)="0";
             filename=saveconfigfile(quaboconfig,'HV');
           %  fhand=py.open(filename);
             %system('python control_quabo_matlab7.py')
           %  cmd_payload=py.control_quabo_matlab7i.send_maroc_params(fhand);
          


             fhand=py.open(filename);
             %system('python control_quabo_matlab7.py')
             cmd_payload=py.control_quabo_matlab7ihv.send_HV_params(fhand);
             % sendpacket(app,cmd_payload)

             
               
    [ia,index]=ismember('IP',quaboconfig);
    IP=(quaboconfig(index,3)) ;
                   sendpacket2board(cmd_payload,IP);
               
        %end