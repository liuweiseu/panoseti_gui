    function sentacqparams2board(quaboconfig)
             
%             [ia,index]=ismember('ACQMODE ',quaboconfig);
%             aqm=char(quaboconfig(index,2));
%             indx=strfind(aqm,'x');
%              ACQMODE=str2num(aqm(indx+1:end)) ;
%         %= 0x1 FOR PH, , 0x11 for PH, no BL subtract, 0x02 FOR IM
%         
%       %  ACQINT = 255 	%*frame interval for IMage mode, x1.024us
%          [ia,index]=ismember('ACQINT ',quaboconfig);
%              ACQINT=str2num(quaboconfig(index,2)) ;
% 
%       %  HOLD1 = 0	%*time after trigger that hold1 is asserted, x5ns, 0 to 15
%          [ia,index]=ismember('HOLD1 ',quaboconfig);
%              HOLD1=str2num(quaboconfig(index,2)) ;
% 
%        % HOLD2 = 0	%*time after trigger that hold1 is asserted, x5ns, 0 to 15
%          [ia,index]=ismember('HOLD2 ',quaboconfig);
%              HOLD2=str2num(quaboconfig(index,2)) ;
% 
%       %  ADCCLKPH = 5	%*phase of PH ADC clock, in 10ns steps, 0 to 7
%         % [ia,index]=ismember('ADCCLKPH ',quaboconfig);
%          %    ADCCLKPH=str2num(quaboconfig(index,2)) ;
% 
%        % MONCHAN = 70	%*Channel to stop the analog mux at for monitor points
%          [ia,index]=ismember('MONCHAN ',quaboconfig);
%             MONCHAN=str2num(quaboconfig(index,2)) ;
% 
%         %STIMON = 1
%         [ia,index]=ismember('STIMON ',quaboconfig);
%             STIMON=str2num(quaboconfig(index,2)) ;
%        
%        % STIM_LEVEL = 16%*0 to 255
%         [ia,index]=ismember('STIM_LEVEL ',quaboconfig);
%             STIM_LEVEL=str2num(quaboconfig(index,2)) ;
%             
%        % STIM_RATE = 
%         [ia,index]=ismember('STIM_RATE ',quaboconfig);
%             STIM_RATE=str2num(quaboconfig(index,2)) ;
%         
%         packet=int8(zeros(64,1));
%         packet(1)=int8(3);
%         %hv1=20000;
%         % hv1h=dec2hex(ACQMODE)
%         % LB=hv1h(3:4)
%         % MB=hv1h(1:2)
%         %packet(3)=int8(1);
%            packet(3)=int8(ACQMODE);
%            
%        acqint8= typecast(uint16(ACQINT),'uint8')
%           
%         packet(5)=int8(acqint8(1));
%              packet(6)=int8(acqint8(2));
%              
%         %packet(11)=int8(ADCCLKPH);
%         packet(13)=int8(MONCHAN);
%         packet(15)=int8(STIMON);
%         packet(17)=int8(STIM_LEVEL);
%         packet(19)=int8(STIM_RATE);
         filename=  saveconfigfile(quaboconfig);
          %filename=saveconfile(app)
             fhand=py.open(filename);
             %system('python control_quabo_matlab7.py')
           
             
             %%%%%%cmd_payload=py.control_quabo_v04acq.send_acq_parameters(fhand);
             cmd_payload=py.control_quabo_v07acqb.send_acq_parameters(fhand);
             
                           
    [ia,index]=ismember('IP',quaboconfig);
    IP=(quaboconfig(index,3)) 
              sendpacket2board(cmd_payload,IP,0);
       %% sendpacket2board(packet)
        
%              utcshift=7/24; 
%              filename=[app.configdir 'config_d0w0m0q0_' datestr(time+utcshift,'yyyymmdd_HHMMSS') '.txt']
%              app.lastconfigfile=filename;
%              savequaboconfig(filename, quaboconfig);
          
    sendTriggermask(quaboconfig) 
        end
        