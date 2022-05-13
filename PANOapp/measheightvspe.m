%%%Threshold vs p.e.
datadir='C:\DATA\20181206\'

  quaboconfig=importquaboconfig('C:\DATA\configs\tests\quabo_configPH.txt');
            [ia,indexstim]=ismember('STIM_LEVEL ',quaboconfig);
            [ia,indexdac]=ismember('DAC1',quaboconfig);
             %iniate board:
     %         sendconfig2Maroc(quaboconfig)
              %give time to apply change:
              pause(5)
             % quaboconfig(index,2)=string(value);
             % app.currentconfig=quaboconfig;
            
stimleveltab=[ 5:5:255];
dactab=[300];
 quaboconfig(indexdac,indcol+1)={['0x' dec2hex(dactab(1))]};
 

 
         sendconfig2Maroc(quaboconfig)
indcol=1:4;
stimvspe=zeros(size(stimleveltab,2),size(dactab,2));
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
          
            
%             info = fitsinfo([path file])
%             testifmsind=any(strcmp(info.PrimaryData.Keywords,'MSIND'));
            stimvspe(istimlevel)=max(max(pixels));
            %if needed, use HK
        end
        %idac=idac+1
    end


%figure stimvspe

figure
plot(stimleveltab,stimvspe,'+-')
xlabel('Stim Level (0-255)')
ylabel('Pulse Height (0-1023)')
ax=gca;
ax.FontSize=16
set(gcf,'Color','w')
ax.YLim=[2000 3000];
ylim([0 700])

figure
plot(23/255*stimleveltab,stimvspe,'+-')
xlabel('Stim Level (p.e.)')
ylabel('Pulse Height (cts)')
%set(gca,'FontSize',18)
ax=gca;
ax.FontSize=16
set(gcf,'Color','w')
ax.YLim=[2000 3000];
ylim([0 700])

load gong.mat
sound(y)