  function sendTriggermask(quaboconfig)
  %              quaboconfig=app.currentconfig;
  %              %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
  %             utcshift=7/24;
  %              filename=[app.configdir 'config_d0w0m0q0_' datestr(time+utcshift,'yyyymmdd_HHMMSS') '.txt']
  %              app.lastconfigfile=filename;
  %              savequaboconfig(filename, quaboconfig);
  filename=saveconfigfile(quaboconfig);
  fhand=py.open(filename);
  %system('python control_quabo_matlab7.py')
  
      cmd_payload=py.control_quabo_v08Tc.send_trigger_mask(fhand);
  
  readback=0;
  [ia,index]=ismember('IP',quaboconfig);
  IP=(quaboconfig(index,3));
  answ=    sendpacket2board(cmd_payload,IP,readback);
  
%   answmat=char(py.str(answ));
%   sentmat=char(py.str(cmd_payload));
%     %compare
%   isempty(strfind(sentmat,answmat(1:end-3)))
  %if mode set to have readback from the board
  
   
  %should only some range of values be matching
%                 for i in range(108):
%                     if cmd_payload[i]!=bytesback[i]: match=0
%                 for i in range(132,236):
%                     if cmd_payload[i]!=bytesback[i]: match=0
%                 for i in range(260,364):
%                     if cmd_payload[i]!=bytesback[i]: match=0
%                 for i in range(388,492):
%                     if cmd_payload[i]!=bytesback[i]: match=0
%                     
%   
  
  readback=0;
  if readback ==1
      
      % reply=sock.recvfrom(uint8(492))
      %           test=reply(0)
      dolisten=1; port=60000
      
      while  (dolisten>0) && (dolisten<10)
          try
              [packet,SOURCEHOST]  = judp('RECEIVE',port,2048, 2000);
              dolisten=0
          catch
              packet=[];
              dolisten=dolisten+1
          end
         % packet;
          
      end
  end
  
  
  
  
  end