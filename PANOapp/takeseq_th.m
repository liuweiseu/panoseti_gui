%%%Threshold vs p.e.
datadir='C:\Users\jerome\Documents\panoseti\DATA\'

quaboconfig=importquaboconfig('C:\Users\jerome\Documents\panoseti\defaultconfig\quabo_config.txt');
%[ia,indexstim]=ismember('STIM_LEVEL ',quaboconfig);
[ia,indexdac]=ismember('DAC1',quaboconfig);

%%set gain
if 1==0
setgain=21
indcol=1:4;
for pp=0:63
    [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
    
    quaboconfig(indexgain,indcol+1)={['0x' dec2hex(setgain)]};
end
end

%iniate board:
sendconfig2Maroc(quaboconfig)
%give time to apply change:
pause(3)
% quaboconfig(index,2)=string(value);
% app.currentconfig=quaboconfig;

%stimleveltab=[1:2:11   15 20 25 30 35 40 45 50 75 100 125 150 175 200 225 250];
%dactab=[700 680 660 650 645 640 635 630 625 620 615 610 600 580 560 540 520 500 480 460 440 420 400 390 380 370 360 350 340 320 310 300 290];
dactab=[700   650  630   600:-20:220 218:-2:206];
indcol=1:4;
%stimvspe=zeros(size(stimleveltab,2),size(dactab,2));

%stimvspeallpix=zeros(size(stimleveltab,2),64,4);

 % figure
  
%for ctest=1:1
    %change pixel to be stimm'd
%    [ig,indexctest]=ismember(['CTEST_' num2str(ctest)] ,quaboconfig);
 %   for ctestquad=1:1
    %    quaboconfig(indexctest,ctestquad+1)={'1'};
         idaclast=1;
         nbim=10;
        for idaca=1:numel(dactab)
            disp(['idac: ' num2str(idac)])
            
           
           
              %apply change:
                quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(idac))]};
                sendconfig2Maroc(quaboconfig)
                
                 pause(3)
                
                %give time to acquire:
                for nbi=1:nbim
              im=recordimage;
                end
            end
    
        

        
load gong.mat
sound(y)