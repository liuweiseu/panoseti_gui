  function sendconfig2Maroc(quaboconfig)
  %              quaboconfig=app.currentconfig;
  %              %dome (0-7), wavelength(0=VIS, 1=IR), module (0-127), quadrant (0-3), maroc (0-3), pixel (0-63) 
  %             utcshift=7/24;
  %              filename=[app.configdir 'config_d0w0m0q0_' datestr(time+utcshift,'yyyymmdd_HHMMSS') '.txt']
  %              app.lastconfigfile=filename;
  %              savequaboconfig(filename, quaboconfig);
  filename=saveconfigfile(quaboconfig);
  fhand=py.open(filename);
  %system('python control_quabo_matlab7.py')
  readback=0;
  if readback ==1
      cmd_payload=py.control_quabo_matlab7iecho6.send_maroc_params(fhand);
      %resans=py.control_quabo_matlab7iecho5.send_maroc_params(fhand)
  else
      cmd_payload=py.control_quabo_matlab7i.send_maroc_params(fhand);
  end
  
  [ia,index]=ismember('IP',quaboconfig);
  IP=(quaboconfig(index,3));
  answ=    sendpacket2board(cmd_payload,IP,readback);
   if readback ==1
    answ=    sendpacket2board(cmd_payload,IP,1);
   end
%   answmat=char(py.str(answ));
%   sentmat=char(py.str(cmd_payload));
%     %compare
%   isempty(strfind(sentmat,answmat(1:end-3)))
  %if mode set to have readback from the board
  
   if readback ==1
  %comparable to Rick's:
  aa=hex(cmd_payload);
  maa=char(aa);
  ac=(cell(answ));
  ab=hex(ac{1});
  mab=char(ab);
  
  match1=strmatch(maa(1:2*108) , mab(1:2*108));
  match2=strmatch(maa(2*132+1:2*236) , mab(2*132+1:2*236));
  match3=strmatch(maa(2*260+1:2*364) , mab(2*260+1:2*364));
  match4=strmatch(maa(2*388+1:2*492) , mab(2*388+1:2*492));
%   disp(maa(1:2*108))
%   disp( mab(1:2*108))
%   disp(maa(2*132+1:2*236))
%   disp(mab(2*132+1:2*236))
%   disp(maa(2*260+1:2*364))
%   disp( mab(2*260+1:2*364))
%   disp(maa(2*388+1:2*492) )
%   disp(mab(2*388+1:2*492))
   if numel(match1+match2+match3+match4)==0 || (match1+match2+match3+match4~=4)
     disp('* !!!!!! The board DID not apply the change !!!!!! *')
  else
       disp('***** Changes you requested were applied by the board  ****')
     
  end
   end
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