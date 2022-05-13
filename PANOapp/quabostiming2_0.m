clear all
close all
format long 
%figini
direc='C:\Users\jerome\Documents\panoseti\DATA\1Hzlowthresh\';
%direc='/Users/jeromemaire/Documents/SETI/PANOSETI/detectors/coincid/';
%files = dir([direc 'p_d0w0m0q0_20190215_020025_57385' '*.fits']);
%files = dir([direc 'p_d0w0m0q0_20190215_184639_60566' '*.fits']);

%files = dir([direc 'p_d0w0m0q0_20190217_011115_36685' '*.fits']);
files = dir([direc 'p_d0w0m0q0_20190219_211220_64505' '*.fits']);

for i=1:numel(files)
ima=fitsread([direc files(i).name]);
info = fitsinfo([direc files(i).name]);

nbim=size(info.Image,2);
images=zeros(16,16,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);
format long
     for nima=1:nbim
         disp(['Reading image keywords #' num2str(nima) '/' num2str(nbim)])
        packetno(nima)=cell2mat(info.Image(nima).Keywords(13,2));
        boarloc(nima)=cell2mat(info.Image(nima).Keywords(14,2));
        utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
        nanosec(nima)=cell2mat(info.Image(nima).Keywords(16,2));
        timecomp(nima)=cell2mat(info.Image(nima).Keywords(17,2));
        images(:,:,nima)=fitsread([direc files(i).name],'Image',nima);
     end
        format
     indquabo1 = find(boarloc==4660);
        packetno1=packetno(indquabo1);
        boarloc1=boarloc(indquabo1);
        utc1=utc(indquabo1);
        nanosec1=nanosec(indquabo1);
        timecomp1=timecomp(indquabo1);
        
     indquabo2 = find(boarloc==4661);
        packetno2=packetno(indquabo2);
        boarloc2=boarloc(indquabo2);
        utc2=utc(indquabo2);
        nanosec2=nanosec(indquabo2);
        timecomp2=timecomp(indquabo2);
     
      figure
      subplot(4,2,1)
      plot(packetno1-packetno1(1))
      xlabel('Ima #')
      ylabel('quabo1 packet no')
            subplot(4,2,2)
      plot(packetno2-packetno2(1))
      xlabel('Ima #')
      ylabel('quabo2 packet no')

           % figure
      subplot(4,2,3)
       plot(utc1-utc1(1))
     % plot(utc1,ones(1,numel(utc1)))
      xlabel('Ima #')
      ylabel('quabo1 utc')
      
            subplot(4,2,4)
      plot(utc2-utc2(1))
      xlabel('Ima #')
      ylabel('quabo2 utc')
      
            subplot(4,2,5)
       plot( 3600*24*(timecomp1- timecomp1(1)))
     % plot(utc1,ones(1,numel(utc1)))
      xlabel('Ima #')
      ylabel('quabo1 time comp')
      
            subplot(4,2,6)
      plot( 3600*24*(timecomp2- timecomp2(1)))
      xlabel('Ima #')
      ylabel('quabo2 time comp')
      
      
%       figure
%       subplot(2,1,1)
%        plot(nanosec1,ones(1,numel(nanosec1)),'+')
%      % xlabel('Ima #')
%       xlabel('quabo1 nanosec')
%             subplot(2,1,2)
%        plot(nanosec2,ones(1,numel(nanosec2)),'+')
%       %xlabel('Ima #')
%       xlabel('quabo2 nanosec')

      %3.125 comes from 320MHz oscillator
     % figure
      subplot(4,2,7)
       plot(3.125*nanosec1)
      xlabel('Ima #')
      ylabel('quabo1 nanosec')
       subplot(4,2,8)
       plot(3.125*nanosec2)
      xlabel('Ima #')
      ylabel('quabo2 nanosec')
      
      figure
       subplot(3,1,1)
      hold on
      plot( indquabo1,ones(1,numel( indquabo1)),'+b')
       plot( indquabo2,ones(1,numel( indquabo2)),'or')
       hold off
       legend('quabo1','quabo2')
       
       subplot(3,1,2)
        hold on
       plot( 3600*24*(timecomp1- timecomp1(1)) ,ones(1,numel( indquabo1)),'+b' )
       plot( 3600*24*(timecomp2- timecomp1(1)) ,ones(1,numel( indquabo2)),'or')
       plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
       plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
       hold off
     % plot(utc1,ones(1,numel(utc1)))
      ylabel('Ima #')
      xlabel(' time comp')
      ylim([0 3])
        legend('quabo1','quabo2')
      
      subplot(3,1,3)
        hold on
       plot( 3600*24*(timecomp1- timecomp1(1)) ,3.125*nanosec1,'+b' )
       plot( 3600*24*(timecomp2- timecomp1(1)) ,3.125*nanosec2,'or')
      % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
      % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
       hold off
     % plot(utc1,ones(1,numel(utc1)))
      ylabel('Ima #')
      xlabel(' time comp')
     
      %issues with
      %intercept
      
%           figure
%         hold on
%        plot( 3600*24*(timecomp1- timecomp1(1)) ,2*1e-9*nanosec1+3600*24*(timecomp1- timecomp1(1)),'+b' )
%        plot( 3600*24*(timecomp2- timecomp1(1)) ,2*1e-9*nanosec2+3600*24*(timecomp2- timecomp1(1)),'or')
%       % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
%       % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
%        hold off
%      % plot(utc1,ones(1,numel(utc1)))
%       ylabel('Ima #')
%       xlabel(' time comp')
%       
% 

%%low thresh test intensities
%figure;imagesc(images(:,:,1))
ima1=images(:,:,indquabo1);
ima2=images(:,:,indquabo2);
figure
subplot(3,1,1)
hold on
plot(24*3600*(timecomp1(:)-timecomp1(1)),squeeze(ima1(4,11,:)),'-+')
plot(24*3600*(timecomp1(:)-timecomp1(1)),squeeze(max(ima1(:,:,:),[],[1 2])),'r')
hold off
subplot(3,1,2)
hold on
plot(24*3600*(timecomp2(:)-timecomp1(1)),squeeze(ima2(14,9,:)),'-+')
plot(24*3600*(timecomp2(:)-timecomp1(1)),squeeze(max(ima2(:,:,:),[],[1 2])),'r')
hold off
% coefficients = polyfit([x1, x2], [y1, y2], 1);
% a = coefficients (1);
% b = coefficients (2);
% Y = a X +b
indpt1=2
indpt2=3
coefficients = polyfit([3600*24*(timecomp2(indpt1)- timecomp1(1)),3600*24*(timecomp2(indpt2)- timecomp1(1))],...
                        [2*1e-9*nanosec2(indpt1), 2*1e-9*nanosec2(indpt2)], 1);
a = coefficients (1);
b = coefficients (2);
%a=a+0.2
%tzero Y=0
tzero=-b/a 

corrline1=a*(3600*24*(timecomp1- timecomp1(1)))+b;
corrline2=a*(3600*24*(timecomp2- timecomp1(1)))+b;
 
%Generate 10 periods of a sawtooth wave with a fundamental frequency of 50 Hz. The sample rate is 1 kHz.
% T = 10*(1/50);
% Fs = 1000;
% dt = 1/Fs;
% t = 0:dt:T-dt;
% x = sawtooth(2*pi*50*t);
% shopuld be on 10sec interval:
period=((10-1e-9*(nanosec1(13)-nanosec1(3)))/6);
T = 10*(period);
Fs = 1000;
dt = 1/Fs;
t = -1:dt:T-dt;
toffset1stpt=period-1e-9*3.125*nanosec1(3);

x = period*(sawtooth(mod(pi*(1/period)*(-toffset1stpt+tzero+t),pi)+pi));


          figure
        hold on
       plot( 3600*24*(timecomp1- timecomp1(1)) ,corrline1+2*1e-9*nanosec1+3600*24*(timecomp1- timecomp1(1)),'+b' )
       plot( 3600*24*(timecomp2- timecomp1(1)) ,corrline2+2*1e-9*nanosec2+3600*24*(timecomp2- timecomp1(1)),'or')
      % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
      % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
      
       hold off
     % plot(utc1,ones(1,numel(utc1)))
      ylabel('Ima #')
      xlabel(' time comp')
      
      deltananosec=3.125*1e-9*(nanosec1(1)-nanosec2(2))
      figure
        hold on
       plot( 3600*24*(timecomp1- timecomp1(1)) ,3.125*1e-9*nanosec1,'+b' )
       plot( 3600*24*(timecomp2- timecomp1(1)) ,3.125*1e-9*nanosec2,'or')
       plot(t,x)
      % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
      % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
       hold off
       
       format long
       
      %%%max nanosec 2nd try
      indstartmatch1=1;
      indstartmatch2=2;
      ecartnano12=nanosec1(indstartmatch1:end)-nanosec2(indstartmatch2:end);
      
     nanosec2(3)+ nanosec2(3)-nanosec2(2)-nanosec2(4)
              
     
       nanosecdelta1=[];
       for jj=2:numel(nanosec1)
           if (nanosec1(jj)-nanosec1(jj-1) >0)
               nanosecdelta1=[nanosecdelta1 nanosec1(jj)-nanosec1(jj-1)];
           end
       end
       deltanano1=round(median(nanosecdelta1))
      
     
       nanosecdelta2=[];
       for jj=2:numel(nanosec2)
           if (nanosec2(jj)-nanosec2(jj-1) >0)
               nanosecdelta2=[nanosecdelta2 nanosec2(jj)-nanosec2(jj-1)];
           end
       end
       deltanano2=round(median(nanosecdelta2))
      
     
        nanosechmax1=[];
       for jj=2:numel(nanosec1)
           if (nanosec1(jj)-nanosec1(jj-1) <0)
                nanosechmax1=[nanosechmax1 deltanano1-nanosec1(jj)+nanosec1(jj-1)];
           end
       end
       deltahmax1=round(median(nanosechmax1))
      
            nanosechmax2=[];
       for jj=2:numel(nanosec2)
           if (nanosec2(jj)-nanosec2(jj-1) <0)
                nanosechmax2=[nanosechmax2 deltanano2-nanosec2(jj)+nanosec2(jj-1)];
           end
       end
       deltahmax2=round(median(nanosechmax2))
      
        maxnanosecdeduced=round(median([nanosechmax1 nanosechmax2]))
      
            %histos
       nanosectot1=nanosec1;
       for jj=2:numel(nanosec1)
           if (nanosec1(jj)-nanosec1(jj-1) <0)
               nanosectot1(jj:end)=nanosectot1(jj:end)+maxnanosecdeduced;
           end
       end
       diffnano=nanosectot1(2:end)-nanosectot1(1:end-1);
       diffsec=diffnano;
       figure
       subplot(2,3,1)
       histogram(diffsec,100)
           
            thresh=3.19e8;
            indhaut=find(diffsec>thresh);
            indbas=find(diffsec<=thresh);
             subplot(2,3,2)
              histogram(3.125*diffsec(indbas),'BinWidth',3.125)
              subplot(2,3,3)
              histogram(3.125*diffsec(indhaut),'BinWidth',3.125)
       
        nanosectot2=nanosec2;
       for jj=2:numel(nanosec2)
           if (nanosec2(jj)-nanosec2(jj-1) <0)
               nanosectot2(jj:end)=nanosectot2(jj:end)+maxnanosecdeduced;
           end
       end
       diffnano2=nanosectot2(2:end)-nanosectot2(1:end-1);
       diffsec2=diffnano2;
       %figure
       subplot(2,3,4)
       histogram(diffsec2,100)
        thresh=3.19e8;
            indhaut=find(diffsec2>thresh);
            indbas=find(diffsec2<=thresh);
             subplot(2,3,5)
              histogram(diffsec2(indbas),'BinWidth',1)
              subplot(2,3,6)
              histogram(diffsec2(indhaut),'BinWidth',1)
       
              
   %%%COINCID quabo#1 #2
   %calcul delta12
     nanosecCoindelta1=[];
     coindindadd2=1;
     
     %prepare nanosecmatch1
     nanosec1match1=nanosec1;
     nanosec2match1=nanosec2(1+coindindadd2:end);
     if numel(nanosec2match1)>numel(nanosec1)
         nanosec2match1=nanosec2match1(1:numel(nanosec1))
     elseif numel(nanosec2match1)<numel(nanosec1)
         nanosec1match1=nanosec1(1:numel(nanosec2match1))
     end
     
     nanosecCoindelta=[];
     %calc delta coin to correct
       for jj=1:numel(nanosec1match1)
           if (nanosec1match1(jj)-nanosec2match1(jj) >0)
               nanosecCoindelta=[nanosecCoindelta nanosec1match1(jj)-nanosec2match1(jj)];
           end
            if (nanosec1match1(jj)-nanosec2match1(jj) <0)
               nanosecCoindelta=[nanosecCoindelta nanosec1match1(jj)-nanosec2match1(jj)+ maxnanosecdeduced];
            end
           
       end
       deltaCoinnano=round(median(nanosecCoindelta))
      
     %% recale second images
     nanosec2match1nanocaled=deltaCoinnano+nanosec2match1;
      for jj=1:numel(nanosec2match1nanocaled)
           if (nanosec2match1nanocaled(jj) > maxnanosecdeduced)
               nanosec2match1nanocaled(jj)=nanosec2match1nanocaled(jj)-maxnanosecdeduced;
           end
      end
     coindiff=nanosec1match1-nanosec2match1nanocaled;
     figure
     histogram(coindiff,20)
      
      
     
      if makevideo==1 
       %make video
       images1=images(:,:,indquabo1);
       images2=images(:,:,indquabo2(1+coindindadd2:end));
       
       figure
       set(gcf,'Position',[100 100 1300 600])
       mincolor=1;
       maxcolor=max([max(images1,[],'all') max(images2,[],'all')])
       xt=1;yt=2;
       set(gcf,'Color','White')
       
       
       for imac=1:numel(nanosec1match1)
       subplot(1,2,1)
       imagesc(log10(images1(:,:,imac)),log10([mincolor maxcolor]))
       text(xt,yt,['Quabo#1 ' ],'FontSize',20,'Color','y')
       text(xt,yt+1,['Nanosec: ' num2str(nanosec1match1(imac))],'FontSize',20,'Color','y')
       
       text(xt+2,yt-2.5,['Setup: Red laser pulsating at 1Hz with beam splitter inside dark box; 10MHz ref only, no 1pps'],'FontSize',20,'Color','r')
       
       text(xt,16,['Time comp: ' datestr(timecomp1(imac),'mmm.dd,yyyy HH:MM:SS.FFF')],'FontSize',16,'Color','w')
       set(gca,'FontSize',12)
       cb=colorbar
       cb.Label.String='Log10(Intensity)';
       cb.FontSize=16;
       cb.Label.FontSize=18;
       %set(cb,'Label','Log10(Intensity)')
       axis image
       subplot(1,2,2)
       imagesc(log10(images2(:,:,imac)),log10([mincolor maxcolor]))
       text(xt,yt,['Quabo#2'],'FontSize',20,'Color','y')
      text(xt,yt+1,['Nanosec (raw): ' num2str(nanosec2match1(imac))],'FontSize',20,'Color','y')
       text(xt,16,['Time comp: ' datestr(timecomp2(imac+coindindadd2),'mmm.dd,yyyy HH:MM:SS.FFF')],'FontSize',16,'Color','w')
       set(gca,'FontSize',12)
             cb=colorbar
       cb.Label.String='Log10(Intensity)';
       cb.FontSize=16;
       cb.Label.FontSize=18;
       axis image
        text(-15,17.5,['Quabo#1 Nanosec       [3.125ns]: ' num2str(nanosec1match1(imac))],'FontSize',20,'Color','b')
        text(-15,18.3,['Quabo#2 Nanosec +\Delta [3.125ns]: ' num2str(nanosec2match1nanocaled(imac))],'FontSize',20,'Color','b')
       % text(-7,20,['Quabo#2 Nanosec (raw): ' num2str(nanosec2match1(imac))],'FontSize',20,'Color','b')
        text(-15,19.1,['Delta Nanosec [3.125ns]: ' num2str(coindiff(imac))],'FontSize',20,'Color','r')
 text(-15,19.9,['Coincidence detected (within 10ns): YES'],'FontSize',20,'Color','r')
 
 text(4,18,['Board reset timing: ' num2str(1/(3.125*1e-9*maxnanosecdeduced)) 'pps; T[s]: ' num2str(3.125*1e-9*maxnanosecdeduced)],'FontSize',14,'Color','k')
text(4,18.7,['Board reset nanosec [3.125ns]: ' num2str( maxnanosecdeduced)],'FontSize',14,'Color','k')
text(4,19.4,['Pulser period [3.125ns]: ' num2str( deltanano1) ' (' num2str((3.125*deltanano1)) 'ns)'],'FontSize',14,'Color','k')
  text(4,20.1,['\Delta nanosec quabo#1-quabo#2 [3.125ns]: ' num2str(deltaCoinnano)],'FontSize',14,'Color','k')
      
      
       coinfilename=['coindidence1Hz_'  datestr(now,'yyyymmdd_HHMMSS') '.gif']
         frame = getframe(gcf,[100, 1, 1200, 550]);
                          im = frame2im(frame); %,
                         [imind,cm] = rgb2ind(im,256);
                         delay=1;
                        if imac == 1;
                            imwrite(imind,cm,coinfilename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
                        else
                             imwrite(imind,cm,coinfilename,'gif','WriteMode','append','DelayTime',delay);
                        end
       end
       
      end
       
       
      %%%fig raw nanosec vs timecomp
      %Generate 10 periods of a sawtooth wave with a fundamental frequency of 50 Hz. The sample rate is 1 kHz.
% T = 10*(1/50);
% Fs = 1000;
% dt = 1/Fs;
% t = 0:dt:T-dt;
% x = sawtooth(2*pi*50*t);
% shopuld be on 10sec interval:
period=(3.125*1e-9*maxnanosecdeduced);
T = 10*(period);
Fs = 1000;
dt = 1/Fs;
t = -1:dt:T-dt;
toffset1stpt=period-1e-9*3.125*nanosec1(3);

x = period*(sawtooth(mod(pi*(1/period)*(-toffset1stpt+tzero+t),pi)+pi));


       figure
       set(gcf,'Position',[100 100 1300 600])
       set(gcf,'Color','White')
 yyaxis left
        hold on
       plot( 3600*24*(timecomp1- timecomp1(1)) ,3.125*1e-9*nanosec1,'-+b' ,'MarkerSize',10,'LineWidth',2)
       plot( 3600*24*(timecomp2(1+coindindadd2:end)- timecomp1(1)) ,3.125*1e-9*nanosec2(1++coindindadd2:end),'-or','MarkerSize',10,'LineWidth',2)
       plot(t,x,'--','LineWidth',1.)
       plot([0 3600*24*(timecomp1(end)- timecomp1(1))],3.125*1e-9*[maxnanosecdeduced maxnanosecdeduced],'-.r','LineWidth',1.)
      % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
      % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
       hold off
       xlabel('Time computer reference [s]')
       ylabel('Nanosec counter time [s]')
       leg=legend('Quabo#1','Quabo2','Time flow in Quabo#1','Deduced Board reset time','Location','southeast')
     set(leg,'FontSize',22)
       grid on
       axisleftlim=get(gca,'YLim')
         set(gca,'YColor','k')
       yyaxis right
       
       ylabel('Nanosec counter Time [3.125ns]')
       ylim((1/(3.125*1e-9))*axisleftlim)
       set(gca,'YColor','k')
       
       %%fig with quabo nanosec corrige
          figure
       set(gcf,'Position',[100 100 1300 600])
       set(gcf,'Color','White')
 yyaxis left
        hold on
       plot( 3600*24*(timecomp1- timecomp1(1)) ,3.125*1e-9*nanosec1,'-+b' ,'MarkerSize',10,'LineWidth',2)
       plot( 3600*24*(timecomp2(1+coindindadd2:end)- timecomp1(1)) ,3.125*1e-9*nanosec2match1nanocaled,'-or','MarkerSize',10,'LineWidth',2)
       plot(t,x,'--','LineWidth',1.)
       plot([0 3600*24*(timecomp1(end)- timecomp1(1))],3.125*1e-9*[maxnanosecdeduced maxnanosecdeduced],'-.r','LineWidth',1.)
      % plot( 3600*24*(timecomp1- timecomp1(1)) ,2*ones(1,numel( indquabo1)),'+b' )
      % plot( 3600*24*(timecomp2- timecomp2(1)) ,2*ones(1,numel( indquabo2)),'or')
       hold off
       xlabel('Time computer reference [s]')
       ylabel('Nanosec counter time [s]')
       leg=legend('Quabo#1','Quabo2','Time flow in Quabo#1','Deduced Board reset time','Location','southeast')
     set(leg,'FontSize',22)
       grid on
       axisleftlim=get(gca,'YLim')
         set(gca,'YColor','k')
       yyaxis right
       
       ylabel('Nanosec counter Time [3.125ns]')
       ylim((1/(3.125*1e-9))*axisleftlim)
       set(gca,'YColor','k')
       
       
       
       %%%HISTOS
          %histos
format long
       figure
       set(gcf,'Color','w')
       subplot(3,1,1)
       EDGES=3.125*[min(diffsec):max(diffsec)+1]-3.125/2;
       EDGELIM=3.125*[min([min(diffsec) min(diffsec2)]) max([max(diffsec) max(diffsec2)])]-3.125/2;
       histogram(3.125*diffsec,EDGES)
       gcahis1=gca;
       xtick=get(gca,'xtick');
       xlim1=xlim;
       set(gca,'XLim',EDGELIM)
       xtickstr=cell(1,numel(xtick));
       for xx=1:numel(xtick)
           xtickstr(xx)={num2str(xtick(xx),'%10i')};
       end
       set(gca,'xticklabel',xtickstr,'FontSize',16)
       xlabel('Period [ns]')
        ylabel('Occurence')
        legend('Quabo#1','Location','NorthWest')
       subplot(3,1,2)
          EDGES=3.125*[min(diffsec2):max(diffsec2)+1]-3.125/2;
    
       histogram(3.125*diffsec2,EDGES)
       xlim2=xlim;
      % set(gcahis1,'XLim',xlim2)
        xtick=get(gca,'xtick');
       xtickstr=cell(1,numel(xtick));
       for xx=1:numel(xtick)
           xtickstr(xx)={num2str(xtick(xx),'%10i')};
       end
       set(gca,'xticklabel',xtickstr,'FontSize',16)
              xlabel('Period [ns]')
        ylabel('Occurence')
         legend('Quabo#2','Location','NorthWest')
         set(gca,'XLim',EDGELIM)
         % set(gca,'XLim',xlim2)
         %  set(gcahis1,'XLim',xlim2)
        subplot(3,1,3)
         EDGES=3.125*[min(coindiff):max(coindiff)+1]-3.125/2;
    
        histogram(3.125*coindiff,EDGES)
              xlabel('Coincidence time difference [ns]')
        ylabel('Occurence')
         legend('Coincidence time difference','Location','NorthWest')
         set(gca,'FontSize',16)
      
       
end

format