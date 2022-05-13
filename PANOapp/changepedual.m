function quaboconfig=changepedual(peval,peval2,gain,quaboconfig)


%%should it be DAC1 (bipolar) or DAC2 (halfbipolar)
%test if CMD_FSB_FSU=0,0,0,0 => DAC1 otherwise DAC2
% [ia,indexfsu]=ismember('CMD_FSB_FSU',quaboconfig);
%   [ia,indexchan]=ismember('CHANMASK_0 ',quaboconfig);
%  if strncmp((quaboconfig(indexchan,2)),'0x0',3)==1
%      dacnum='1'
%  else
%      dacnum='2'
%  end


% %dactab=[205:2:230 ]; 
% %petab=(1/A0)*(-B0 + dactab); % A0...A3
% %petab=3.2:0.3:5.5; 
% load(['pethresh_gain' num2str(gain) '.mat'])
 load(([getuserdir filesep 'panoseti' filesep 'Calibrations' filesep 'CalibrationDB.mat']))
  [ig,indexquabosn]=ismember(['QuaboSN'] ,quaboconfig);
 inddetrow=find(quaboDETtable(:,1)==str2num(cell2mat(quaboconfig(indexquabosn,3))));
A0=gain*quaboDETtable(inddetrow,7);
A1=gain*quaboDETtable(inddetrow,8);
A2=gain*quaboDETtable(inddetrow,9);
A3=gain*quaboDETtable(inddetrow,10);
B0=quaboDETtable(inddetrow,11);
B1=quaboDETtable(inddetrow,12);
B2=quaboDETtable(inddetrow,13);
B3=quaboDETtable(inddetrow,14);

dactab0=round(A0*peval+B0);
dactab1=round(A1*peval+B1);
dactab2=round(A2*peval+B2);
dactab3=round(A3*peval+B3);

  [ia,indexdac]=ismember(['DAC1'],quaboconfig);
  
  for my=1:4
if my==1
    dactab=dactab0;
elseif my==2
    dactab=dactab1;
elseif my==3
    dactab=dactab2;
elseif my==4
    dactab=dactab3;
end
if (dactab>=1024) || (dactab<=0) 
    disp('*********** DACTAB OUT OF RANGE; CHECK YOUR VALUES!*******')
end
%dactab=230;
  quaboconfig(indexdac,my+1)={['0x' dec2hex(dactab)]};
  end
   disp(['Sending Maroc comm...DAC1 Ima' ':' num2str(dactab0)  ' ' num2str(dactab1)  ' ' num2str(dactab2)  ' ' num2str(dactab3)  ' '])

  
  %%%%DAC2 for PH
  halfgain=0.5;
dactab0=round(halfgain*A0*peval2+B0);
dactab1=round(halfgain*A1*peval2+B1);
dactab2=round(halfgain*A2*peval2+B2);
dactab3=round(halfgain*A3*peval2+B3);


  [ia,indexdac2]=ismember(['DAC2'],quaboconfig);
  
  for my=1:4
if my==1
    dactab=dactab0;
elseif my==2
    dactab=dactab1;
elseif my==3
    dactab=dactab2;
elseif my==4
    dactab=dactab3;
end
if (dactab>=1024) || (dactab<=0) 
    disp('*********** DACTAB OUT OF RANGE; CHECK YOUR VALUES!*******')
end
%dactab=230;
  quaboconfig(indexdac2,my+1)={['0x' dec2hex(dactab)]};
  end
  
  
%     disp(['Sending Maroc comm...DAC2 PH '  ':' num2str(dactab0)  ' ' num2str(dactab1)  ' ' num2str(dactab2)  ' ' num2str(dactab3)  ' '])
%             sendconfig2Maroc(quaboconfig);
%%changing CHANMASKs
   for cc=0:7
        [ig,indexmask]=ismember(['CHANMASK_' num2str(cc) ' '] ,quaboconfig);
         quaboconfig(indexmask,2)={['0xffffffff']};
   end
   [ig,indexmask]=ismember(['CHANMASK_8 '] ,quaboconfig);
         quaboconfig(indexmask,2)={['0x155']};
    
    disp(['Sending Maroc comm...DAC2 PH '  ':' num2str(dactab0)  ' ' num2str(dactab1)  ' ' num2str(dactab2)  ' ' num2str(dactab3)  ' '])
            sendconfig2Maroc(quaboconfig);
%%applying T
     sendTriggermask(quaboconfig)  
end