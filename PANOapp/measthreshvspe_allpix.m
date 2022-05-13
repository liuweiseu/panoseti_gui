%%%Threshold vs p.e.
datadir='C:\DATA\201901\'

quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_configPHnostim.txt');
[ia,indexstim]=ismember('STIM_LEVEL ',quaboconfig);
[ia,indexdac]=ismember('DAC1',quaboconfig);

%%set gain
setgain=74
indcol=1:4;
for pp=0:63
    [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);
    
    quaboconfig(indexgain,indcol+1)={['0x' dec2hex(setgain)]};
end

%iniate board:
sendconfig2Maroc(quaboconfig)
%give time to apply change:
pause(3)
% quaboconfig(index,2)=string(value);
% app.currentconfig=quaboconfig;

stimleveltab=[1:2:11   15 20 25 30 35 40 45 50 75 100 125 150 175 200 225 250];
%dactab=[700 680 660 650 645 640 635 630 625 620 615 610 600 580 560 540 520 500 480 460 440 420 400 390 380 370 360 350 340 320 310 300 290];
dactab=[700   650  630   600:-20:220 218:-2:206];
indcol=1:4;
stimvspe=zeros(size(stimleveltab,2),size(dactab,2));

stimvspeallpix=zeros(size(stimleveltab,2),64,4);

  figure
  
for ctest=1:1
    %change pixel to be stimm'd
    [ig,indexctest]=ismember(['CTEST_' num2str(ctest)] ,quaboconfig);
    for ctestquad=1:1
        quaboconfig(indexctest,ctestquad+1)={'1'};
         idaclast=1;
        for istimlevel=1:size(stimleveltab,2)
            disp(['ctest: ' num2str(ctest) ' quadr: ' num2str(ctestquad)])
            disp(['Starting istim ' num2str(istimlevel) '/' num2str(size(stimleveltab,2))])
            %apply change:
            quaboconfig(indexstim,2)=string(num2str(stimleveltab(istimlevel)));
            sentacqparams2board(quaboconfig)
            pause(3)
           
            idac=idaclast-3;
            if idac<1
                idac=1;
            end
            stopiter=0
            while (idac <=size(dactab,2)) && (stopiter==0)
                % for idac=1:size(dactab,2)
                 disp(['ctest: ' num2str(ctest) ' quadr: ' num2str(ctestquad)])
                 disp(['istim: ' num2str(istimlevel) '/' num2str(size(stimleveltab,2))])
                 disp(['Starting idac ' num2str(idac) '/' num2str(size(dactab,2))])
                %apply change:
                quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(idac))]};
                sendconfig2Maroc(quaboconfig)
                
                
                
                %give time to acquire:
                %pause(1)
                olddir=dir(datadir);
                pause(4)
                %test if new data arrived:
                newdir=dir(datadir);
                if ~isequal(newdir, olddir)
                    'New files'
                    stopiter=1;
                    %if new data, do sanity check (pulse detected?)
                    
                    stimvspe(istimlevel,idac)=dactab(idac);
                    %if needed, use HK
                    idaclast=idac;
                end
                idac=idac+1;
            end
        end
        
        %figure stimvspe
        
        stimvspe2=zeros(1,size(stimleveltab,2));
        for ii=1:size(stimleveltab,2)
            indnonzeros=find(stimvspe(ii,:));
            if numel(indnonzeros)>0
                stimvspe2(ii)= stimvspe(ii,indnonzeros(1));
            end
        end
%         figure
%         plot(stimleveltab,stimvspe2,'-+','LineWidth',2.4)
%         xlabel('Stim Level (0-255)')
%         ylabel('Threshold Level (0-1023)')
%         set(gcf,'Color','w')
%         title(['Threshold vs pe, gain: ' num2str(setgain)])
        
       
        hold on
        plot(23/255*stimleveltab,stimvspe2,'-+','LineWidth',2.4)
        hold off
       
        
        
        stimvspeallpix(:,ctest,ctestquad)=stimvspe2;
        quaboconfig(indexctest,ctestquad+1)={'0'};
    end
end
xlabel('Stim Level (p.e.)')
        ylabel('Threshold Level (0-1023)')
        %set(gca,'FontSize',18)
        gca.FontSize=18
        set(gcf,'Color','w')
        title(['Threshold vs pe, gain: ' num2str(setgain)])
        hold on
        xl=xlim;
        yl=ylim;
        for tt=1:numel(dactab)
            plot(xl, [dactab(tt) dactab(tt)],'--')
        end
        for tt=1:numel(stimleveltab)
            plot( [23/255*stimleveltab(tt) 23/255*stimleveltab(tt)],yl,'--')
        end
        hold off
        box on
        
load gong.mat
sound(y)