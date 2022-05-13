%%%Threshold vs p.e.
%%need panotv ON, saving fits!
datadir='C:\DATA\20181206\'

 quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_configPH.txt');
 %% quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_configIma.txt');
            [ia,indexstim]=ismember('STIM_LEVEL ',quaboconfig);
            [ia,indexdac]=ismember('DAC1',quaboconfig);
             %iniate board:
     %         sendconfig2Maroc(quaboconfig)
              %give time to apply change:
              pause(5)
             % quaboconfig(index,2)=string(value);
             % app.currentconfig=quaboconfig;
            
%stimleveltab=[ 10 25 50 75 100 125 150 175 200 225 250];
stimleveltab=[ 5:10:255];
 indcol=1:4;
dactab=[300];
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(1))]};
%gaintab=10:10:50 %250;
gaintab=50:50:250;
stimvspe=zeros(size(stimleveltab,2),size(gaintab,2));
stimvspep=zeros(size(stimleveltab,2),size(gaintab,2));
       
for igain=1:numel(gaintab)
    %change gain
     for pp=0:63 
        [ig,indexgain]=ismember(['GAIN' num2str(pp)] ,quaboconfig);

        quaboconfig(indexgain,indcol+1)={['0x' dec2hex(gaintab(igain))]};
     end
         sendconfig2Maroc(quaboconfig)



%  indexquabo=find(ismember(quaboconfig,['GAIN' num2str(indlingainpixselected(gg)-1)]));
          %  quaboconfig(indexquabo,indcol+1)={newgain};
          

for istimlevel=1:size(stimleveltab,2)
    disp(['Starting istem ' num2str(istimlevel) '/' num2str(size(stimleveltab,2))])
     %apply change:
          quaboconfig(indexstim,2)=string(num2str(stimleveltab(istimlevel)));
   sentacqparams2board(quaboconfig)
   pause(3)
   idac=1;%stopiter=0
  % while (idac <=size(dactab,2)) && (stopiter==0)
   % for idac=1:size(dactab,2)
       % disp(['Starting idac ' num2str(idac) '/' num2str(size(dactab,2))])
        %apply change:
         
            
      

        %give time to acquire:
       % pause(5)
        olddir=dir(datadir);
        pause(2)
        %test if new data arrived:
        newdir=dir(datadir);
        if ~isequal(newdir, olddir)
            'New files'
               % stopiter=1
            %if new data, do sanity check (pulse detected?)
    %open data and read max value
    latestfile = getlatestfile(datadir)
     %open fits file
            import matlab.io.*
            fptr = fits.openFile([datadir latestfile]);
            pixels = fits.readImg(fptr);
           fits.closeFile(fptr)
            
%             info = fitsinfo([path file])
%             testifmsind=any(strcmp(info.PrimaryData.Keywords,'MSIND'));
            stimvspep(istimlevel,igain)=max(max(pixels));
            stimvspe(istimlevel,igain)=pixels(13,2);
            %if needed, use HK
        end
        %idac=idac+1
    end

end
%figure stimvspe

% figure
% plot(stimleveltab,stimvspe,'+-')
% xlabel('Stim Level (0-255)')
% ylabel('Pulse Height (0-1023)')
indzeros=find(stimvspe==0);
stimvspe2=stimvspe;
stimvspe2(indzeros)=NaN;


figure
hold on
colortable=['b','r','g','m','c','k','y'];
legtab={};
for ig=1:numel(gaintab)
plot(stimleveltab,stimvspe2(:,ig),['+-' colortable(ig)])
legtab(ig)={['Gain=' num2str(gaintab(ig))]};
end
xlabel('Stim Level (0-255)')
ylabel('Pulse Height (cts)')
%set(gca,'FontSize',18)
ylim([2000 3600])
%ylim([0 1000])
%set(gca,'YLim',[2000 3000])
set(gcf,'Color','w')
legend(legtab,'Location','SouthEast')


figure
hold on
colortable=['b','r','g','m','c','k','y'];
legtab={};
for ig=1:numel(gaintab)
plot(23/255*stimleveltab,stimvspe2(:,ig),['+-' colortable(ig)])
legtab(ig)={['Gain=' num2str(gaintab(ig))]};
end
xlabel('Stim Level (p.e.)')
ylabel('Pulse Height (cts)')
%set(gca,'FontSize',18)
ylim([2000 3600])
%ylim([0 1000])
%set(gca,'YLim',[2000 3000])
set(gcf,'Color','w')
legend(legtab,'Location','SouthEast')

load gong.mat
sound(y)