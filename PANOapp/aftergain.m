%openfig('C:\DATA\res\Gain1pe175muAgains21.fig')
openfig('C:\DATA\res\Gain1pe100muAgains21.fig')
h=gcf;
axesObjs=get(h,'Children')
dataObjs=get(axesObjs,'Children')
aa=get(axesObjs,'Title');
titletxt=aa{2}.String;
imdata=dataObjs{2}.CData;

histogram(imdata,20)
xlabel('Gain')
ylabel('Number of pixels')

title(titletxt)



%ydata=get(dataObjs,'YData');
% xdata
% xd=xdata(45);
% yd=ydata(45);
% xd
% cell2mat(xd)
% xd=cell2mat(xdata(45));
% yd=cell2mat(ydata(45));
% yd
% xd=cell2mat(xdata(53));
% yd=cell2mat(ydata(53));
% datape=xd;
% datath=yd;
% th1=350 %what pe?
% pe=interp1(datath,datape,th1,'cubic')
% datath
% datath(8)
% datath(8)=646
% datath(9)=648
% datath(11)=652
% pe=interp1(datath,datape,th1,'cubic')
% pe1=3. %what th?
% th=interp1(datape,datath,pe11,'cubic')
% pe1=3. %what th?
% th=interp1(datape,datath,pe1,'cubic')
% petab=1:5;
% % thtab=interp1(datape,datath,petab,'cubic')
% % datath
% % datape
% datath2=datath(2:end);
% datape2=datape(2:end);
% petab=1:5;
% % thtab2=interp1(datape2,datath2,petab,'cubic')
% % 
% % phdpe=interp1(dactab,phd1,thpecal,'pchip')
% 
% thpecal=interp1(datape2,datath2,petab,'cubic')