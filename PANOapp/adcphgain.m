
gains=[33 40 55 70];
ADC=zeros(1,4);
figure('Position','')
hold on
lega={};
for pet=2:15
ADC(1)=2.2706*pet+9.4504;
ADC(2)=2.898*pet+10.0857;
ADC(3)=3.7506*pet+14.4026;
ADC(4)=5.5679*pet+14.3071;
plot(gains, ADC,'+-')
lega=[lega {[num2str(pet) ' pe']}]
end
hold off
xlabel('gain')
ylabel('ADC')
legend(lega,'Location','NorthWest','FontSize',8)
box on
grid on
         saveas(gcf,[resultdir '\png\' 'ADCphgain.png'])
        saveas(gcf,[resultdir '\fig\' 'ADCphgain.fig'])
 