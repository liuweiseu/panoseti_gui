  function sendconfigCHANMASK(quaboconfig)
  %              quaboconfig=app.currentconfig;
  %              %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
  %             utcshift=7/24;
  %              filename=[app.configdir 'config_d0w0m0q0_' datestr(time+utcshift,'yyyymmdd_HHMMSS') '.txt']
  %              app.lastconfigfile=filename;
  %              savequaboconfig(filename, quaboconfig);
  filename=saveconfigfile(quaboconfig);
  fhand=py.open(filename);
  %system('python control_quabo_matlab7.py')

      cmd_payload=py.control_quabo_v04mask.send_trigger_mask(fhand);
 
  
  [ia,index]=ismember('IP',quaboconfig);
  IP=(quaboconfig(index,3));
  answ=    sendpacket2board(cmd_payload,IP);

%   answmat=char(py.str(answ));
%   sentmat=char(py.str(cmd_payload));
%     %compare
%   isempty(strfind(sentmat,answmat(1:end-3)))
  
  
  
  
  end