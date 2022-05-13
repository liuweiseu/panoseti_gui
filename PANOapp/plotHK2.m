
quaboSNstr='5';date='20200227';%date='20200311';
load([getuserdir '\panoseti\panoHK\HK_' date '_' quaboSNstr '.mat'])
 hktimecomp=timecomptab;
 timecomp=24.*3600*(hktimecomp-hktimecomp(1));
 
   figure('Position',[10 10 1200 900])
set(gcf,'Color','w')
subplot(3,1,1)
title([' Quabo IP0.5'  ', started ' datestr(hktimecomp(1),'yyyy-mm-dd HH:MM') ])
hold on
plot(timecomp,hvmon0tab,'b-')
plot(timecomp,hvmon1tab,'r-')
plot(timecomp,hvmon2tab,'g-')
plot(timecomp,hvmon3tab,'m-')
hold off
xlabel('Time [s] ')
ylabel('HV [V]')
leg=legend('Q0','Q1','Q2','Q3')
set(leg,'color','none')
set(gca,'YLim',[53 56])
box on
grid on
ax = gca;
ax.XRuler.Exponent = 0;

subplot(3,1,2)
hold on
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ0,'b-+')
plot(timecomp,ihvmon0tab,'b-')
plot(timecomp,ihvmon1tab,'r-')
plot(timecomp,ihvmon2tab,'g-')
plot(timecomp,ihvmon3tab,'m-')
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ2,'g-+')
%plot(24.*3600*(timecomp-timecomp(1)),realcurQ3,'m-+')
hold off
xlabel('Time [s] ')
ylabel('I [\muA]')
leg=legend('Q0','Q1','Q2','Q3' )
set(leg,'color','none')
box on
grid on
ax = gca;
ax.XRuler.Exponent = 0;

subplot(3,1,3)
hold on
plot(timecomp,temp1tab,'b-')
%plot(timecomp,temp2tab,'r-')
hold off
xlabel('Time [s] ')
ylabel('Temperature [C]')
leg=legend(['TMP125'],...
    ['Temp. FPGA'])
set(leg,'color','none')
grid on
box on
ax = gca;
ax.XRuler.Exponent = 0;

filenmhk=[getuserdir '\panoseti\'  'HK' date '_IP' quaboSNstr 'b'];
        saveas(gcf,[filenmhk '.png'])
        saveas(gcf,[filenmhk '.fig'])
        
        