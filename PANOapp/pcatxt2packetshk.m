 

tmp = importfilepcatxt("C:\Users\User\Documents\panoseti\PANOapp\tmp.txt", [1, Inf]);
 %tmp = importfilepcatxt("C:\Users\User\Documents\panoseti\DATA\20200603\testconversion\data_00026_20200604205637", [1, Inf]);

nbpac=size(tmp,1) ;
aa=char(table2array(tmp(:,2)));
sizepa=zeros(1,nbpac);
for ff=1:nbpac
  
sizepa(ff)=strlength(strtrim(aa(ff,:)));
end
indscience=find((sizepa==2*64));
nbfr=numel(indscience);

                             
for fr=1:nbfr
 disp(['Reading frame#' num2str(fr) '/' num2str(nbfr)])
 aa=char(strtrim(table2array(tmp(indscience(fr),2))));
szp=0.5* size(aa,2);
packet0=(reshape(aa,2,szp)');
packet= strcat(packet0(:,1), packet0(:,2));

       %convert values
                    sz=size(packet);
                    szp=sz(1);
                    Vref=1250.;
                    
                    %% read data
                    if szp==64 %HK data
                       
                        hk(fr).byte0=hex2dec([ packet0(1,:)]);
                        %if byte0~ should display Firstboot
                        hk(fr).boardloc=hex2dec([ packet0(4,:)  packet0(3,:)]);
                        hk(fr).hvmon0=Vref*(10/(65536*158))*hex2dec([ packet0(6,:)  packet0(5,:)]);
                        hk(fr).hvmon1=Vref*(10/(65536*158))*hex2dec([ packet0(8,:)  packet0(7,:)]);
                        hk(fr).hvmon2=Vref*(10/(65536*158))*hex2dec([ packet0(10,:)  packet0(9,:)])
                        hk(fr).hvmon3=Vref*(10/(65536*158))*hex2dec([ packet0(12,:)  packet0(11,:)]);
                        hk(fr).ihvmon0=Vref/499 *1000 * ((1/65536)*(65535 -hex2dec([ packet0(14,:)  packet0(13,:)]))) ;
                        hk(fr).ihvmon1=Vref/499 *1000 * ((1/65536)*(65535 -hex2dec([ packet0(16,:)  packet0(15,:)]))) ;
                        hk(fr).ihvmon2=Vref/499 *1000 * ((1/65536)*(65535 -hex2dec([ packet0(18,:)  packet0(17,:)]))) ;
                        hk(fr).ihvmon3=Vref/499 *1000 * ((1/65536)*(65535 -hex2dec([ packet0(20,:)  packet0(19,:)]))) ;
                        hk(fr).rawhvmon= (Vref/65536) * 10/158 * hex2dec([ packet0(22,:)  packet0(21,:)]);
                        hk(fr).v12mon=(Vref/65536/1000) * hex2dec([ packet0(24,:)  packet0(23,:)]) ;
                        hk(fr).v18mon=(2*Vref/65536/1000) *hex2dec([ packet0(26,:)  packet0(25,:)]);
                        hk(fr).v33mon=(Vref/65536/ 1000) * 13.3/3.3 * hex2dec([ packet0(28,:)  packet0(27,:)]);
                        hk(fr).v37mon= (Vref/65536/ 1000) * 13.3/3.3 * hex2dec([ packet0(30,:)  packet0(29,:)])  ;
                        hk(fr).i10mon=(Vref/65536) /.105 * hex2dec([ packet0(32,:)  packet0(31,:)]) /1000;
                        hk(fr).i18mon=(Vref/65536) /.505 * hex2dec([ packet0(34,:)  packet0(33,:)]) /1000 ;
                        hk(fr).i33mon=(Vref/65536) /.505 * hex2dec([ packet0(36,:)  packet0(35,:)]) /1000 ;
                        hk(fr).temp1=hex2dec([ packet0(38,:)  packet0(37,:)]);
                        
                        hk(fr).temp2=hex2dec([ packet0(40,:)  packet0(39,:)]);
                        %disp temps
                        temp1c = (hk(fr).temp1)/4
                        if temp1c>127.75
                            hk(fr).temp1c = temp1c - 128;
                        else
                             hk(fr).temp1c = temp1c;
                        end
                        hk(fr).temp2c = (((hk(fr).temp2/65536)/0.00198421639) - 273.15);
                        %                         if temp2c>127.75
                        %                             temp2c = temp2c - 128;
                        %                         end
                        hk(fr).vccint=(3/65536)*hex2dec([ packet0(42,:)  packet0(41,:)]);
                        hk(fr).vccaux=(3/65536)*hex2dec([ packet0(44,:)  packet0(43,:)]);
                        %                           vcodac0=typecast((packet(41:42)),'uint16');
                        %                         vcodac1=typecast((packet(43:44)),'uint16');
                       % uid=double(typecast((packet(45:52)),'uint64'));
                       hk(fr).uid=hex2dec([ packet0(52,:)  packet0(51,:)  packet0(50,:)  packet0(49,:)]);
                        hk(fr).shutterstatus=hex2dec(packet0(53,1)) 
                       hk(fr).lightsensorstatus=hex2dec(packet0(53,2))
                        %utc=double(typecast((packet(53:56)),'uint32'));
                        %nanosec= hex2dec([ packet0(60,:)  packet0(59,:)  packet0(58,:)  packet0(57,:)]);
                        hk(fr).firmwtime=[char(hex2dec(packet0(60,:))) char(hex2dec(packet0(59,:))) char(hex2dec(packet0(58,:))) '.' char(hex2dec(packet0(57,:)))];
                        hk(fr).firmw=[char(hex2dec(packet0(64,:))) char(hex2dec(packet0(63,:))) char(hex2dec(packet0(62,:))) '.' char(hex2dec(packet0(61,:)))];
                    end
                                    
end
 
 