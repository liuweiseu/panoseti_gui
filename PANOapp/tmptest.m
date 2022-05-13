
%%FIG LightADC_LIGHT
%IntenspixGen=zeros(numel(petab),numel(gaintabtab),4,numel(currtabExp));
for th =1:numel(petab)
figure('Position',[100 100 1000 800])
set(gcf,'Color','w')
subplot(2,2,1)
hold on
for ig=1:numel(gaintabtab)
    plot(powerdet,squeeze(IntenspixGen(th,ig,1,:)))
end
xlabel('Light Intensity [nW/pix]')
ylabel('ADC value')
hold off
title(['Q' num2str(0) ', Threshold [pe#]: ' num2str(petab(th))  ])

leg={};
    for ii=1:numel(gaintabtab)
        leg(ii)={ ['Gain: ' num2str(gaintabtab(ii))]};
    end
legend(leg,'Location','SouthWest')
box on
grid on

subplot(2,2,2)
hold on
for cc=1:numel(currtabExp)
     plot(powerdet,squeeze(IntenspixGen(th,ig,1,:)))
end
hold off
title(['Q' num2str(1)])

leg={};
    for ii=1:numel(gaintabtab)
         leg(ii)={ ['Gain: ' num2str(gaintabtab(ii))]};
    end
legend(leg,'Location','SouthWest')
box on
grid on



subplot(2,2,3)
hold on
for cc=1:numel(currtabExp)
     plot(powerdet,squeeze(IntenspixGen(th,ig,1,:)))
end
hold off
title(['Q' num2str(2)])

leg={};
    for ii=1:numel(gaintabtab)
          leg(ii)={ ['Gain: ' num2str(gaintabtab(ii))]};
    end
legend(leg,'Location','SouthWest')
box on
grid on



subplot(2,2,4)
hold on
for cc=1:numel(currtabExp)
     plot(powerdet,squeeze(IntenspixGen(th,ig,1,:)))
end
hold off
title(['Q' num2str(3)])

leg={};
    for ii=1:numel(gaintabtab)
        leg(ii)={ ['Gain: ' num2str(gaintabtab(ii))]};
    end
legend(leg,'Location','SouthWest')
box on
grid on

datenow=datestr(now,'yymmddHHMMSS');
saveas(gcf,[calibdir 'LightADC_DAC_'   datenow '_masked.png'])
saveas(gcf,[calibdir 'LightADCvsDAC_'    datenow '_masked.fig'])

end
