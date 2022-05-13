 

tmp = importfilepcatxt("C:\Users\User\Documents\panoseti\PANOapp\tmp.txt", [1, Inf]);
 %tmp = importfilepcatxt("C:\Users\User\Documents\panoseti\DATA\20200603\testconversion\data_00026_20200604205637", [1, Inf]);

nbpac=size(tmp,1) ;
aa=char(table2array(tmp(:,2)));
sizepa=zeros(1,nbpac);
for ff=1:nbpac
  
sizepa(ff)=strlength(strtrim(aa(ff,:)));
end
indscience=find((sizepa==2*528) | (sizepa==2*272));
nbfr=numel(indscience);



imags=zeros(16,16,nbfr);
   acq_mode=zeros(1,nbfr);
                            packet_no=zeros(1,nbfr);
                            boardloc=zeros(1,nbfr);
                            utc=zeros(1,nbfr);
                            nanosec=zeros(1,nbfr);
                             
for fr=1:nbfr
 disp(['Reading frame#' num2str(fr) '/' num2str(nbfr)])
 aa=char(strtrim(table2array(tmp(indscience(fr),2))));
szp=0.5* size(aa,2);
packet0=(reshape(aa,2,szp)');
packet= strcat(packet0(:,1), packet0(:,2));

  if (szp==528) || (szp==272) %SCIENCE
                            
                            %acq_mode=typecast(uint8(packet2(1,:)),'uint8');
                            acq_mode(fr)=hex2dec(packet0(1,1:2));
                           % packet_no=typecast((packet(3:4)),'uint16');
                            packet_no(fr)=hex2dec([ packet0(4,1:2)  packet0(3,1:2)]);
                            %ct=[ct packet_no];
                           % boardloc=typecast((packet(5:6)),'uint16');
                            boardloc(fr)=hex2dec([ packet0(6,1:2)  packet0(5,1:2)]);
                           % utc=typecast(uint8(packet(7:10)),'uint32');
                            %nanosec=typecast(uint8(packet(11:14)),'uint32');
                              nanosec(fr)=hex2dec([ packet0(14,1:2)  packet0(13,1:2)   packet0(12,1:2)   packet0(11,1:2)]);
                            % ET_ticks=typecast(uint8(packet(3:6)),'uint32');
                            % ET_seconds1=typecast(uint8(packet(7:10)),'uint32');
                            % ET_seconds2=typecast(uint8(packet(11:14)),'uint32');
                            % ET_seconds3=typecast(uint8(packet(15:18)),'uint32');
                          %  pixels=typecast((packet(17:17+2*256-1)),'uint16');
                            pixels=zeros(1,256);
                            for pp=1:256
                                if szp==528
                                pixels(pp)=hex2dec([  packet0(17+2*pp-1,1:2)  packet0(17+2*(pp-1),1:2)]);
                                else
                                 pixels(pp)=hex2dec([  packet0(17+pp-1,1:2)  packet0(17+(pp-1),1:2)]);     
                                end
                             end
                              dimima=16;
           % shapedima
            imags(:,:,fr)= reshape(pixels,[dimima,dimima]);
           % imag(:,:,fr)=fliplr(shapedima);
           % figure; imagesc(fliplr(shapedima)); colorbar; axis image
  end                  
end
 
 