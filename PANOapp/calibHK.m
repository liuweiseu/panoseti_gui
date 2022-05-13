
ttot=tph+tima+tadc;
fromlast=floor(ttot/2.7)

 [hk] = getlastHK(fromlast)
 hktimecomp=hk.timecomp;
 timecomp=24.*3600*(hktimecomp-hktimecomp(1));
 
   figure('Position',[10 10 1200 900])
set(gcf,'Color','w')
subplot(3,1,1)
title([' Quabo SN' quaboSNstr ', started' datestr(hktimecomp(1),'yyyy-mm-dd HH:MM') ])
hold on
plot(timecomp,hk.hvmon0,'b-')
plot(timecomp,hk.hvmon1,'r-')
plot(timecomp,hk.hvmon2,'g-')
plot(timecomp,hk.hvmon3,'m-')
hold off
xlabel('Time [s] ')
ylabel('HV [V]')
leg=legend('Q0','Q1','Q2','Q3')
set(leg,'color','none')
set(gca,'YLim',[53 56])
box on
grid on

subplot(3,1,2)
hold on
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ0,'b-+')
plot(timecomp,hk.ihvmon0,'b-')
plot(timecomp,hk.ihvmon1,'r-')
plot(timecomp,hk.ihvmon2,'g-')
plot(timecomp,hk.ihvmon3,'m-')
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ2,'g-+')
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ3,'m-+')
hold off
xlabel('Time [s] ')
ylabel('I [\muA]')
leg=legend('Q0','Q1','Q2','Q3' )
set(leg,'color','none')
box on
grid on

subplot(3,1,3)
hold on
plot(timecomp,hk.temp1,'b-')
%plot(timecomp,hk.temp2,'r-')
hold off
xlabel('Time [s] ')
ylabel('Temperature [C]')
leg=legend(['TMP125'])%,...
   % ['Temp. FPGA'])
set(leg,'color','none')
grid on
box on

        filenmhk=[calibdir  'HK_SN' quaboSNstr '_' datenow ];
        saveas(gcf,[filenmhk '.png'])
        saveas(gcf,[filenmhk '.fig'])
        
        
  %add cps curves:
        if makereport==1
                 import mlreportgen.report.*
    import mlreportgen.dom.*
                sec7 = Section;
    sec7.Title = ['HK during calibrations'];
        add(sec7,Paragraph([' Quabo SN' quaboSNstr ', started ' datestr(hktimecomp(1),'yyyy-mm-dd HH:MM') ]));
        plot1=Image([filenmhk '.png']);
        widthch=plot1.Width;
        widthima=str2num(widthch(1:strfind(widthch,'px')-1));
        heightch=plot1.Height;
        heightima=str2num(heightch(1:strfind(heightch,'px')-1));
        plot1.Width='600px';
        plot1.Height=[ num2str(floor(600/widthima*heightima)) 'px'];
        add(sec7,plot1);
         add(sec7,Paragraph(['Duration of FPGA upgrade: ' addcoma(round(tfpga)) ' sec' ]));
         add(sec7,Paragraph(['Duration of Imaging-mode acquisitions (darks): ' addcoma(round(tima)) ' sec']));
          add(sec7,Paragraph(['Duration of PH-mode (counting) acquisitions (darks): ' addcoma(round(tph)) ' sec']));
           add(sec7,Paragraph(['Duration of PH-mode ADC acquisitions: ' addcoma(round(tadc)) ' sec']));
            add(sec7,Paragraph(['Total elapsed time: ' addcoma(round(ttot)) ' sec']));
add(rpt,sec7)
        end
        