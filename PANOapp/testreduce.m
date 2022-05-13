close all

direc=[getuserdir filesep 'panoseti' filesep 'DATA' filesep '20200603' filesep 'res' filesep]
disp('****** Packet analysis **************')

ind4=find(cap.boardloc==4);
ind5=find(cap.boardloc==5);
ind6=find(cap.boardloc==6);
ind7=find(cap.boardloc==7);
ind16=find(cap.boardloc==1016);
ind17=find(cap.boardloc==1017);
ind18=find(cap.boardloc==1018);
ind19=find(cap.boardloc==1019);

ind4ima=find(cap.acq_mode(ind4)==3);
ind4ph=find(cap.acq_mode(ind4)==1);
ind5ima=find(cap.acq_mode(ind5)==3);
ind5ph=find(cap.acq_mode(ind5)==1);
ind6ima=find(cap.acq_mode(ind6)==3);
ind6ph=find(cap.acq_mode(ind6)==1);
ind7ima=find(cap.acq_mode(ind7)==3);
ind7ph=find(cap.acq_mode(ind7)==1);
ind16ima=find(cap.acq_mode(ind16)==3);
ind16ph=find(cap.acq_mode(ind16)==1);
ind17ima=find(cap.acq_mode(ind17)==3);
ind17ph=find(cap.acq_mode(ind17)==1);
ind18ima=find(cap.acq_mode(ind18)==3);
ind18ph=find(cap.acq_mode(ind18)==1);
ind19ima=find(cap.acq_mode(ind19)==3);
ind19ph=find(cap.acq_mode(ind19)==1);

pack4ima=cap.packet_no(ind4(ind4ima));
missed4ima=(pack4ima(end)-pack4ima(1)+1)-numel(pack4ima);
disp(['Missed packets board4 ima:' num2str(missed4ima) ' (' num2str(numel(pack4ima)) ' fr.)'])
pack4ph=cap.packet_no(ind4(ind4ph));
missed4ph=(pack4ph(end)-pack4ph(1)+1)-numel(pack4ph);
disp(['Missed packets board4 ph:' num2str(missed4ph) ' (' num2str(numel(pack4ph)) ' fr.)'])

pack5ima=cap.packet_no(ind5(ind5ima));
missed5ima=(pack5ima(end)-pack5ima(1)+1)-numel(pack5ima);
disp(['Missed packets board5 ima:' num2str(missed5ima) ' (' num2str(numel(pack5ima)) ' fr.)'])
pack5ph=cap.packet_no(ind5(ind5ph));
missed5ph=(pack5ph(end)-pack5ph(1)+1)-numel(pack5ph);
disp(['Missed packets board5 ph:' num2str(missed5ph) ' (' num2str(numel(pack5ph)) ' fr.)'])

pack6ima=cap.packet_no(ind6(ind6ima));
missed6ima=(pack6ima(end)-pack6ima(1)+1)-numel(pack6ima);
disp(['Missed packets board6 ima:' num2str(missed6ima) ' (' num2str(numel(pack6ima)) ' fr.)'])
pack6ph=cap.packet_no(ind6(ind6ph));
missed6ph=(pack6ph(end)-pack6ph(1)+1)-numel(pack6ph);
disp(['Missed packets board6 ph:' num2str(missed6ph) ' (' num2str(numel(pack6ph)) ' fr.)'])

pack7ima=cap.packet_no(ind7(ind7ima));
missed7ima=(pack7ima(end)-pack7ima(1)+1)-numel(pack7ima);
disp(['Missed packets board7 ima:' num2str(missed7ima) ' (' num2str(numel(pack7ima)) ' fr.)'])
pack7ph=cap.packet_no(ind7(ind7ph));
missed7ph=(pack7ph(end)-pack7ph(1)+1)-numel(pack7ph);
disp(['Missed packets board7 ph:' num2str(missed7ph) ' (' num2str(numel(pack7ph)) ' fr.)'])



pack16ima=cap.packet_no(ind16(ind16ima));
missed16ima=(pack16ima(end)-pack16ima(1)+1)-numel(pack16ima);
disp(['Missed packets board16 ima:' num2str(missed16ima) ' (' num2str(numel(pack16ima)) ' fr.)'])
pack16ph=cap.packet_no(ind16(ind16ph));
missed16ph=(pack16ph(end)-pack16ph(1)+1)-numel(pack16ph);
disp(['Missed packets board16 ph:' num2str(missed16ph) ' (' num2str(numel(pack16ph)) ' fr.)'])

pack17ima=cap.packet_no(ind17(ind17ima));
missed17ima=(pack17ima(end)-pack17ima(1)+1)-numel(pack17ima);
disp(['Missed packets board17 ima:' num2str(missed17ima) ' (' num2str(numel(pack17ima)) ' fr.)'])
pack17ph=cap.packet_no(ind17(ind17ph));
missed17ph=(pack17ph(end)-pack17ph(1)+1)-numel(pack17ph);
disp(['Missed packets board17 ph:' num2str(missed17ph) ' (' num2str(numel(pack17ph)) ' fr.)'])

pack18ima=cap.packet_no(ind18(ind18ima));
missed18ima=(pack18ima(end)-pack18ima(1)+1)-numel(pack18ima);
disp(['Missed packets board18 ima:' num2str(missed18ima) ' (' num2str(numel(pack18ima)) ' fr.)'])
pack18ph=cap.packet_no(ind18(ind18ph));
missed18ph=(pack18ph(end)-pack18ph(1)+1)-numel(pack18ph);
disp(['Missed packets board18 ph:' num2str(missed18ph) ' (' num2str(numel(pack18ph)) ' fr.)'])

pack19ima=cap.packet_no(ind19(ind19ima));
missed19ima=(pack19ima(end)-pack19ima(1)+1)-numel(pack19ima);
disp(['Missed packets board19 ima:' num2str(missed19ima) ' (' num2str(numel(pack19ima)) ' fr.)'])
pack19ph=cap.packet_no(ind19(ind19ph));
missed19ph=(pack19ph(end)-pack19ph(1)+1)-numel(pack19ph);
disp(['Missed packets board19 ph:' num2str(missed19ph) ' (' num2str(numel(pack19ph)) ' fr.)'])

disp(['Total pack:' num2str(size(cap.boardloc,2))])

ti=datetime(capture(1).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles');
tf=datetime(capture(end).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles');
timetot=etime(datevec(tf),datevec(ti));
disp(['Tot time [s]:' num2str(timetot)])
disp(['frame rate [fr/s]:' num2str(size(cap.boardloc,2)/timetot)])


%%(to do take exact first and last fr time rather than timetot:)
disp(['Ima4 rate [fr/s]:' num2str(numel(ind4ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind4ima)/timetot)))])
disp(['Ima5 rate [fr/s]:' num2str(numel(ind5ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind5ima)/timetot)))])
disp(['Ima6 rate [fr/s]:' num2str(numel(ind6ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind6ima)/timetot)))])
disp(['Ima7 rate [fr/s]:' num2str(numel(ind7ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind7ima)/timetot)))])
disp(['Ima16 rate [fr/s]:' num2str(numel(ind16ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind16ima)/timetot)))])
disp(['Ima17 rate [fr/s]:' num2str(numel(ind17ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind17ima)/timetot)))])
disp(['Ima18 rate [fr/s]:' num2str(numel(ind18ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind18ima)/timetot)))])
disp(['Ima19 rate [fr/s]:' num2str(numel(ind19ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind19ima)/timetot)))])

disp(['ph4 rate [fr/s]:' num2str(numel(ind4ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind4ph)/timetot)))])
disp(['ph5 rate [fr/s]:' num2str(numel(ind5ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind5ph)/timetot)))])
disp(['ph6 rate [fr/s]:' num2str(numel(ind6ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind6ph)/timetot)))])
disp(['ph7 rate [fr/s]:' num2str(numel(ind7ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind7ph)/timetot)))])
disp(['ph16 rate [fr/s]:' num2str(numel(ind16ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind16ph)/timetot)))])
disp(['ph17 rate [fr/s]:' num2str(numel(ind17ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind17ph)/timetot)))])
disp(['ph18 rate [fr/s]:' num2str(numel(ind18ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind18ph)/timetot)))])
disp(['ph19 rate [fr/s]:' num2str(numel(ind19ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind19ph)/timetot)))])




%     if direct==1
%      iir=ii;
%     else
%        iir=numel(files)-ii+1;
%     end
%     pos=25.4*(24+1/8)+iir*0.8;
% ima=fitsread([direc files(ii).name]);
%  info = fitsinfo([direc files(ii).name]);
% if isfield(info,'Image') == 0
%     nbim0=1
% else
%   nbim0=size(info.Image,2);
%end
nbim0=size(cap.images,3);%numel(ind4ima);%nbim0;%*numel(files);
nbim=nbim0;

images=zeros(16,16,nbim);
acqmode=zeros(1,nbim);
packetno=zeros(1,nbim);
boarloc=zeros(1,nbim);
utc=zeros(1,nbim);
nanosec=zeros(1,nbim);
timecomp=zeros(1,nbim);
stdlev=zeros(1,nbim);
meanlev=zeros(1,nbim);
medianlev=zeros(1,nbim);
%  nbpixsup3std(iir)=numel(find(ima>meanlev+10*stdlev));



Intensmax=zeros(1,nbim);
Intenstot=zeros(1,nbim);


%
% tmp = importfilepcatxt("C:\Users\User\Documents\panoseti\PANOapp\tmp.txt", [1, Inf]);
%  %tmp = importfilepcatxt("C:\Users\User\Documents\panoseti\DATA\20200603\testconversion\data_00026_20200604205637", [1, Inf]);
%  aa=char(table2array(tmp(1,2)))
% szp=0.5* size(aa,2)
% packet0=(reshape(aa,2,528)');
% packet= strcat(packet0(:,1), packet0(:,2));
%
%   if szp==528 %SCIENCE
%
%                             %acq_mode=typecast(uint8(packet2(1,:)),'uint8');
%                             acq_mode=hex2dec(packet0(1,1:2))
%                            % packet_no=typecast((packet(3:4)),'uint16');
%                             packet_no=hex2dec([ packet0(4,1:2)  packet0(3,1:2)])
%                             %ct=[ct packet_no];
%                            % boardloc=typecast((packet(5:6)),'uint16');
%                             boardloc=hex2dec([ packet0(6,1:2)  packet0(5,1:2)])
%                             utc=typecast(uint8(packet(7:10)),'uint32');
%                             nanosec=typecast(uint8(packet(11:14)),'uint32');
%                               nanosec=hex2dec([ packet0(14,1:2)  packet0(13,1:2)   packet0(12,1:2)   packet0(11,1:2)])
%                             % ET_ticks=typecast(uint8(packet(3:6)),'uint32');
%                             % ET_seconds1=typecast(uint8(packet(7:10)),'uint32');
%                             % ET_seconds2=typecast(uint8(packet(11:14)),'uint32');
%                             % ET_seconds3=typecast(uint8(packet(15:18)),'uint32');
%                           %  pixels=typecast((packet(17:17+2*256-1)),'uint16');
%                             pixels=zeros(1,256);
%                             for pp=1:256
%
%                                 pixels(pp)=hex2dec([  packet0(17+2*pp-1,1:2)  packet0(17+2*(pp-1),1:2)]);
%                             end
%                               dimima=16;
%             shapedima= reshape(pixels,[dimima,dimima]);
%           %  figure; imagesc(fliplr(shapedima)); colorbar; axis image
%   end
%

images=cap.images;

format long
for nima=1:nbim0
    
    if (mod(nima,floor(nbim0/10))==0)  disp(['Acq:'  ' nim:' num2str(nima) '/' num2str(nbim0)]), end
    acqmode(nima)=cap.acq_mode(nima);%cell2mat(info.Image(nima).Keywords(12,2));
    packetno(nima)=cap.packet_no(nima);%cell2mat(info.Image(nima).Keywords(13,2));
    boarloc(nima)=cap.boardloc(nima);%cell2mat(info.Image(nima).Keywords(14,2));
    %utc(nima)=cell2mat(info.Image(nima).Keywords(15,2));
    nanosec(nima)=cap.nanosec(nima);%cell2mat(info.Image(nima).Keywords(16,2));
    
    dati=datetime(capture(nima).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles');
    timecomp(nima)=datenum(dati);
    
    % images(:,:,iir)=fitsread([direc files(ii).name],'Image',nima);
    %[head, ima]=FITSload([direc files(ii).name],nima);
    % images(:,:,nima)=ima;
    %             stdlev(nima)=std(images,1,'all');
    %             meanlev(nima)=mean(ima,'all');
    %             medianlev(nima)=mean(ima,'all');
    %  nbpixsup3std(iir)=numel(find(ima>meanlev+10*stdlev));
    
    
    
    %       Intensmax(nima)=max(ima,[],'all');
    %        Intenstot(nima)=sum(ima,[1 2]);
    %iir=iir+1;
end
imaf=zeros(32,64,nbim);
%%rotating images
for nima=1:nbim
    if (mod(nima,floor(nbim/10))==0) disp(['Rotating ima ' num2str(nima) '/' num2str(nbim)]),end
    dispima= boarloc(nima);
    shapedima=images(:,:,nima);
    switch dispima
        %                 case 0
        %                     parentUIaxes=app.UIAxes;
        %                     imadisp=fliplr(shapedima);
        case 4
            %parentUIaxes=app.UIAxes2;
            imadisp=fliplr(shapedima);
            xq=0;yq=0;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
            
        case 5
            %parentUIaxes=app.UIAxes3;
            imadisp=flipud(fliplr((shapedima)'));
            xq=0;yq=16;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
        case 6
            %parentUIaxes=app.UIAxes4;
            imadisp=flipud(shapedima);
            xq=16;yq=16;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
        case 7
            %parentUIaxes=app.UIAxes5;
            imadisp=shapedima';
            xq=16;yq=0;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
        case 1016
            %parentUIaxes=app.UIAxes2;
            imadisp=fliplr(shapedima);
            xq=0;yq=32;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
        case 1017
            %parentUIaxes=app.UIAxes3;
            imadisp=flipud(fliplr((shapedima)'));
            xq=0;yq=48;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
        case 1018
            %parentUIaxes=app.UIAxes4;
            imadisp=flipud(shapedima);
            xq=16;yq=48;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
        case 1019
            %parentUIaxes=app.UIAxes5;
            imadisp=shapedima';
            xq=16;yq=32;
            imaf(xq+(1:16),yq+(1:16),nima)=imadisp;
    end
    images(:,:,nima)=imadisp;
end







indboard4=find(boarloc==4);
indboard4IMA=indboard4(find(( (acqmode(indboard4)==3))));
indboard4PH=indboard4(find(acqmode(indboard4)==1));

indboard5=find(boarloc==5);
indboard5IMA=indboard5(find( acqmode(indboard5)==3));
indboard5PH=indboard5(find(acqmode(indboard5)==1));

indboard6=find(boarloc==6);
indboard6IMA=indboard6(find( acqmode(indboard6)==3));
indboard6PH=indboard6(find(acqmode(indboard6)==1));

indboard7=find(boarloc==7);
indboard7IMA=indboard7(find(acqmode(indboard7)==3));
indboard7PH=indboard7(find(acqmode(indboard7)==1));


indboard16=find(boarloc==1016);
indboard16IMA=indboard16(find(acqmode(indboard16)==3));
indboard16PH=indboard16(find(acqmode(indboard16)==1));


indboard17=find(boarloc==1017);
indboard17IMA=indboard17(find(acqmode(indboard17)==3));
indboard17PH=indboard17(find(acqmode(indboard17)==1));

indboard18=find(boarloc==1018);
indboard18IMA=indboard18(find( acqmode(indboard18)==3));
indboard18PH=indboard18(find(acqmode(indboard18)==1));

indboard19=find(boarloc==1019);
indboard19IMA=indboard19(find( acqmode(indboard19)==3));
indboard19PH=indboard19(find(acqmode(indboard19)==1));

t=24.*3600*(timecomp-timecomp(1));
figure
plot(t,acqmode)
ylabel('acqmode')

figure
hold on
plot(t(indboard4),packetno(indboard4))
plot(t(indboard5),packetno(indboard5))
plot(t(indboard6),packetno(indboard6))
plot(t(indboard7),packetno(indboard7))
plot(t(indboard16),packetno(indboard16))
plot(t(indboard17),packetno(indboard17))
plot(t(indboard18),packetno(indboard18))
plot(t(indboard19),packetno(indboard19))
ylabel('packetno')

figure
hold on
plot(t(indboard4),packetno(indboard4)-circshift(packetno(indboard4),1))
plot(t(indboard5),packetno(indboard5)-circshift(packetno(indboard5),1))
plot(t(indboard6),packetno(indboard6)-circshift(packetno(indboard6),1))
plot(t(indboard7),packetno(indboard7)-circshift(packetno(indboard7),1))
plot(t(indboard16),packetno(indboard16)-circshift(packetno(indboard16),1))
plot(t(indboard17),packetno(indboard17)-circshift(packetno(indboard17),1))
plot(t(indboard18),packetno(indboard18)-circshift(packetno(indboard18),1))
plot(t(indboard19),packetno(indboard19)-circshift(packetno(indboard19),1))
ylabel('packetno shift')

figure
boarlocmodif=boarloc;
for iii=1:numel(boarloc)
    if boarloc(iii)>1000
        boarlocmodif(iii)=boarloc(iii)-1008;
    end
end
hold on
plot(t(indboard4),boarlocmodif(indboard4))
plot(t(indboard5),boarlocmodif(indboard5))
plot(t(indboard6),boarlocmodif(indboard6))
plot(t(indboard7),boarlocmodif(indboard7))
plot(t(indboard16),boarlocmodif(indboard16))
plot(t(indboard17),boarlocmodif(indboard17))
plot(t(indboard18),boarlocmodif(indboard18))
plot(t(indboard19),boarlocmodif(indboard19))
ylabel('boardloc')

figure
hold on
plot(t(indboard4),stdlev(indboard4))
plot(t(indboard5),stdlev(indboard5))
plot(t(indboard6),stdlev(indboard6))
plot(t(indboard7),stdlev(indboard7))
plot(t(indboard16),stdlev(indboard16))
plot(t(indboard17),stdlev(indboard17))
plot(t(indboard18),stdlev(indboard18))
plot(t(indboard19),stdlev(indboard19))
ylabel('spatial std vs time')

figure
hold on
plot(t(indboard4),meanlev(indboard4))
plot(t(indboard5),meanlev(indboard5))
plot(t(indboard6),meanlev(indboard6))
plot(t(indboard7),meanlev(indboard7))
plot(t(indboard16),meanlev(indboard16))
plot(t(indboard17),meanlev(indboard17))
plot(t(indboard18),meanlev(indboard18))
plot(t(indboard19),meanlev(indboard19))
ylabel('spatial mean vs time')

figure
hold on
plot(t(indboard4),medianlev(indboard4))
plot(t(indboard5),medianlev(indboard5))
plot(t(indboard6),medianlev(indboard6))
plot(t(indboard7),medianlev(indboard7))
plot(t(indboard16),medianlev(indboard16))
plot(t(indboard17),medianlev(indboard17))
plot(t(indboard18),medianlev(indboard18))
plot(t(indboard19),medianlev(indboard19))
ylabel('spatial median vs time')

figure
plot(t(2:end)-t(1:end-1))
ylabel('t - tshift [s]')
xlabel('raw acquis.#')

%%%%%% IMA Stuffs
maxims=max([numel(indboard4IMA) numel(indboard5IMA) numel(indboard6IMA) numel(indboard7IMA) ...
    numel(indboard16IMA) numel(indboard17IMA) numel(indboard18IMA) numel(indboard19IMA)]);
maxpackets=max([packetno(indboard4IMA(end))-packetno(indboard4IMA(1)) ...
    packetno(indboard5IMA(end))-packetno(indboard5IMA(1)) ...
    packetno(indboard6IMA(end))-packetno(indboard6IMA(1)) ...
    packetno(indboard7IMA(end))-packetno(indboard7IMA(1)) ...
    packetno(indboard16IMA(end))-packetno(indboard16IMA(1)) ...
    packetno(indboard17IMA(end))-packetno(indboard17IMA(1)) ...
    packetno(indboard18IMA(end))-packetno(indboard18IMA(1)) ...
    packetno(indboard19IMA(end))-packetno(indboard19IMA(1)) ...
    ]);

indima=find(acqmode==3);
boarlocima=boarloc(indima);
imafB= makedoublemoboframe(packetno(indima),maxpackets,images(:,:,indima),boarlocima );


medianframe=median(imafB,3);


figure
imagesc(medianframe)
axis image
colorbar

%% fake coin?
% imafB(8,12,1)=1e5;
% imafB(9,32+11,1)=1e5;
%%%%%%Multi time resolution analysis with IMA
% For each dataset defined by a 10sec (sliding) window over the full dataset,
% for each octave (100?sec, 200?sec, 400?sec,.., up to 1sec)
%    - frames are binned in time according to octave (to do: shift the center position of each bin in an additional for loop)
%    - the 16x16 mean, median and std images at this specific octave are calculated from the binned frames and the median image is subtracted from all binned frames
%    - detect high events (any pixel higher than 3 std) in the residual subtracted binned frames
%    - detect coincidence between boards using a spatial coincidence window of a few pixels and a coincidence time window a few times the current octave.
exposuretime=1e-5*round(1e5*(1/(numel(ind4ima)/timetot)));
deuxmul=2.^(1:20);
nbstd=3;
indmax=find(deuxmul<=0.5*numel(ind4ima));
multioc=[1. deuxmul(indmax)];
octave=(exposuretime)*multioc;
nbcoinoc=zeros(1,numel(octave));
nbhighevoc=zeros(1,numel(octave));
for oc=1:numel(octave)
    imafC = imresize3(imafB,[size(imafB,1) size(imafB,2) size(imafB,3)/multioc(oc)]);
    medianframeoc=median(imafC,3);
    meanframeoc=mean(imafC,3);
    stdframeoc=std(imafC,[],3);
    highpix3dlogic=[];
    for fram=1:size(imafC,3)
        residualima=imafC(:,:,fram)-meanframeoc;
        highpix= find(residualima-(nbstd*stdframeoc)>0);
        [highpix2dy highpix2dx]= find(residualima-(nbstd*stdframeoc)>0);
        highpix3dlogic=cat(3,highpix3dlogic,(residualima>(nbstd*stdframeoc)));
    end
    %detect imaging coincidences
    cointimewindow=1;
    coinspatialwindow=1;
    shiftx=-1;
    shifty=1;
    %mobo#1
    indhighev1=find(highpix3dlogic(:,1:32,:));
    %[indhighev1y indhighev1x indhighev1z] =find(highpix3dlogic(:,1:32,:));
    %[indhighev1y indhighev1x indhighev1z]=
    % indhighev2=find(highpix3dlogic(:,33:64,:));
    disp(['Nb of high events detected at octave (' num2str(octave(oc)) 'sec) :' num2str(sum(highpix3dlogic,'all')) ])
    nbhighevoc(oc)=sum(highpix3dlogic,'all');
    
    coins=0*(1:8);nbcoins=0;
    for hh=1:numel(indhighev1)
        [yr,xr,zr]=ind2sub(size(highpix3dlogic(:,1:32,:)),indhighev1(hh));
        %prepare coord with edges
        yw0=shifty+(yr-coinspatialwindow:yr+coinspatialwindow);
        xw0=shiftx+(xr-coinspatialwindow:xr+coinspatialwindow);
        zw0=(zr-cointimewindow:zr+cointimewindow);
        yw=yw0(find((yw0>0) & (yw0<33)));
        xw=xw0(find((xw0>0) & (xw0<33)));
        zw=zw0(find((zw0>0) & (zw0<size(highpix3dlogic,3))));
        cubesum=sum(uint8(highpix3dlogic(yw,32+xw,zw)),'all');
        
        
        if cubesum>0
            indcoi  =find(highpix3dlogic(yw,32+xw,zw));
            [yrsub xrsub zrsub]= ind2sub(size(highpix3dlogic(yw,32+xw,zw)),indcoi(1));
            yr2=yrsub+yw(1)-1;
            xr2=32+xrsub+xw(1)-1;
            zr2=zrsub+zw(1)-1;
            coins=cat(1,coins, [oc yr xr zr yr2(1) xr2(1) zr2(1) 1] );
        end
    end
    
    %mobo#2
    % indhighev1=find(highpix3dlogic(:,1:32,:));
    %[indhighev1y indhighev1x indhighev1z] =find(highpix3dlogic(:,1:32,:));
    %[indhighev1y indhighev1x indhighev1z]=
    indhighev2=find(highpix3dlogic(:,33:64,:));
    % disp(['Nb of high events detected at octave (' num2str(octave(oc)) 'sec) :' num2str(sum(highpix3dlogic,'all')) ])
    %  coins=0*(1:8);nbcoins=0;
    for hh=1:numel(indhighev2)
        [yr,xr,zr]=ind2sub(size(highpix3dlogic(:,33:64,:)),indhighev2(hh));
        %prepare coord with edges
        yw0=-shifty+(yr-coinspatialwindow:yr+coinspatialwindow);
        xw0=-shiftx+(xr-coinspatialwindow:xr+coinspatialwindow);
        zw0=(zr-cointimewindow:zr+cointimewindow);
        yw=yw0(find((yw0>0) & (yw0<33)));
        xw=xw0(find((xw0>0) & (xw0<33)));
        zw=zw0(find((zw0>0) & (zw0<size(highpix3dlogic,3))));
        cubesum=sum(uint8(highpix3dlogic(yw,xw,zw)),'all');
        
        
        if cubesum>0
            indcoi  =find(highpix3dlogic(yw,xw,zw));
            [yrsub xrsub zrsub]= ind2sub(size(highpix3dlogic(yw,xw,zw)),indcoi(1));
            yr2=yrsub+yw(1)-1;
            xr2=32+xrsub+xw(1)-1;
            zr2=zrsub+zw(1)-1;
            coins=cat(1,coins, [oc yr2(1) xr2(1) zr2(1) yr xr zr 2] );
        end
    end
    
    coins=coins(2:end,:);
    nbcoinsoc=size(coins,1)-nbcoins;
    disp(['Nb of coins  detected at octave (' num2str(octave(oc)) 'sec) :' num2str(nbcoinsoc)])
    nbcoinoc(oc)=nbcoinsoc;
    
    
    if 1==0
        
        % figure std
        figure;imagesc(stdframeoc,[0 400]);colorbar;axis image
        ti=title(['std frame (imaging), exposure time[sec]:' num2str(exposuretime) ', Tot time [s]:' num2str(timetot,'%2.3g')])
        saveas(gcf,[direc   'stdframe'  '_' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.png'])
        saveas(gcf,[direc   'stdframe'  '_' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.fig'])
        
        % figure histogram pixel
        xh=2;yh=2;figure;hold on; cts=hist(squeeze(imafC(xh,yh,:)),20);hist(squeeze(imafC(xh,yh,:)),20);
        plot([meanframeoc(xh,yh) meanframeoc(xh,yh)],[0 1.2*max(cts,[],'all')],'b--' )
        plot([meanframeoc(xh,yh)+3*stdframeoc(xh,yh) meanframeoc(xh,yh)+3*stdframeoc(xh,yh)],[0 1.2*max(cts,[],'all')],'r--' )
        legend(['Pixel (' num2str(xh) ', ' num2str(yh) ')'],'mean',[num2str(nbstd) '\sigma'])
        ti=title(['Histogram pixel values (imaging), exposure time[sec]:' num2str(exposuretime) ', Tot time [s]:' num2str(timetot,'%2.3g')])
        saveas(gcf,[direc   'histpix' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.png'])
        saveas(gcf,[direc   'histpix'  char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.fig'])
        
        
        for cc=1:size(coins,1)
            figure('Position',[10 10 1000 800],'Color','w')
            subplot(2,1,1)
            hold on
            
            yr=coins(cc,3);xr=coins(cc,2);zr=coins(cc,4);
            %[yr,xr,zr]=ind2sub(size(highpix3dlogic),coins(cc,2));
            coinima=cat(2,imafC(:,1:32,zr), imafC(:,33:64,coins(cc,7)));
            imagesc(((coinima-meanframeoc-(3*stdframeoc))),[0 0.6*max((coinima-meanframeoc-(3*stdframeoc)),[],'all')]);colorbar;axis image;
            plot([32.5 32.5],[0.5 32.5],'-','Color','w')
            % [yr,xr]=ind2sub(size(residualima),highpix(cc))
            plot(yr,xr,'ro','MarkerSize',13.,'LineWidth',3)
            
            plot(coins(cc,6),coins(cc,5),'ro','MarkerSize',13.,'LineWidth',3)
            [ indhighevimy  indhighevimx] =find(highpix3dlogic(:,1:32,zr));
            for zzz=1:size(indhighevimy,1)
                plot(indhighevimx,  indhighevimy,'go','MarkerSize',16.)
            end
            [ indhighevimy2  indhighevimx2] =find(highpix3dlogic(:,33:64,coins(cc,7)));
            for zzz=1:size(indhighevimy2,1)
                plot(32+indhighevimx2,  indhighevimy2,'go','MarkerSize',16.)
            end
            tx= text(1.5,1.5,[string(datetime(capture(zr).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles'))],'Color','w');
            tx2= text(33.5,1.5,[string(datetime(capture(coins(cc,7)).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles'))],'Color','w');
            
            ti=title(['Images-mean-' num2str(nbstd) 'std, Time Resol.[sec]: ' num2str(octave(oc)) ...
                ', Coinc. time window [sec]: ' num2str((2*cointimewindow+1)*octave(oc)) ...
                ', Coinc. spatial window: ' num2str((2*coinspatialwindow+1)) 'x'  num2str((2*coinspatialwindow+1)) 'pix' ...
                ', \Deltat[sec]= ' num2str((coins(cc,7)-zr)*octave(oc))]);
            ti.FontSize=12;
            
            subplot(2,1,2)
            hold on
            yr=coins(cc,3);xr=coins(cc,2);zr=coins(cc,4);
            %[yr,xr,zr]=ind2sub(size(highpix3dlogic),coins(cc,2));
            coinima=cat(2,imafC(:,1:32,zr), imafC(:,33:64,coins(cc,7)));
            imagesc(coinima);colorbar;axis image
            plot([32.5 32.5],[0.5 32.5],'-','Color','w')
            % [yr,xr]=ind2sub(size(residualima),highpix(cc))
            plot(yr,xr,'ro','MarkerSize',13.,'LineWidth',3)
            plot(coins(cc,6),coins(cc,5),'ro','MarkerSize',13.,'LineWidth',3)
            
            [ indhighevimy  indhighevimx] =find(highpix3dlogic(:,1:32,zr));
            for zzz=1:size(indhighevimy,1)
                plot(indhighevimx,  indhighevimy,'go','MarkerSize',16.)
            end
            [ indhighevimy2  indhighevimx2] =find(highpix3dlogic(:,33:64,coins(cc,7)));
            for zzz=1:size(indhighevimy2,1)
                plot(32+indhighevimx2,  indhighevimy2,'go','MarkerSize',16.)
            end
            tx= text(1.5,1.5,[string(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles'))],'Color','w');
            tx2= text(33.5,1.5,[', \Deltat[sec]= ' num2str((coins(cc,7)-zr)*octave(oc))],'Color','w');
            
            ti=title(['Images, Time Resol.[sec]: ' num2str(octave(oc)) ...
                ', Coinc. time window [sec]: ' num2str((2*cointimewindow+1)*octave(oc)) ...
                ', Coinc. spatial window: ' num2str((2*coinspatialwindow+1)) 'x'  num2str((2*coinspatialwindow+1)) 'pix' ...
                ', \Deltat[sec]= ' num2str((coins(cc,7)-zr)*octave(oc))]);
            ti.FontSize=12;
            saveas(gcf,[direc   'ImaCoins' num2str(cc) '_' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.png'])
            saveas(gcf,[direc   'ImaCoins' num2str(cc) '_' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.fig'])
            
            
        end
        
        
    end
    %%fig ima + all coins in circles
    if 1==1
        figure('Position',[10 10 1000 800],'Color','w')
        
        hold on
        for cc=1:size(coins,1)
            yr=coins(cc,3);xr=coins(cc,2);zr=coins(cc,4);
            %[yr,xr,zr]=ind2sub(size(highpix3dlogic),coins(cc,2));
            if cc==1
                coinima=cat(2,imafC(:,1:32,zr), imafC(:,33:64,coins(cc,7)));
                imagesc(coinima);colorbar;axis image
                
                plot([32.5 32.5],[0.5 32.5],'-','Color','w')
            end
            % [yr,xr]=ind2sub(size(residualima),highpix(cc))
            plot(yr,xr,'ro','MarkerSize',13.,'LineWidth',3)
            plot(coins(cc,6),coins(cc,5),'ro','MarkerSize',13.,'LineWidth',3)
            
        end
        tx= text(1.5,1.5,[string(datetime(capture(ind4ima(1)).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles'))],'Color','w');
        % tx2= text(33.5,1.5,[', \Deltat[sec]= ' num2str((coins(cc,7)-zr)*octave(oc))],'Color','w');
        
        ti=title(['All coincidences at Time Resol.[sec]: ' num2str(octave(oc)) ...
            ', Coinc. time window [sec]: ' num2str((2*cointimewindow+1)*octave(oc)) ...
            ', Coinc. spatial window: ' num2str((2*coinspatialwindow+1)) 'x'  num2str((2*coinspatialwindow+1)) 'pix' ...
            ', Tot time [s]:' num2str(timetot,'%2.3g')]);
        ti.FontSize=12;
        saveas(gcf,[direc   'AllCoinsOcta' num2str(oc) char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.png'])
        saveas(gcf,[direc   'AllCoinsOcta' num2str(oc) char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.fig'])
    end
    
    
end
figure('Position',[10 10 1000 800],'Color','w')
subplot(2,1,1)
bar(cat(2, nbhighevoc' ))
legend('Nb of high events')
xlim([0 numel(octave)])
xticks((0:numel(octave)))
labti={''};
for io=1:numel(octave)
    labti=[labti {num2str(octave(io))}];
end
xticklabels(labti)
ti=title(['Nb of high events (>' num2str(nbstd) '\sigma) Imaging: ' num2str(octave(oc)) ...
    ', Tot time [s]:' num2str(timetot,'%2.3g')]);


subplot(2,1,2)
bar(cat(2, nbcoinoc' ))
xlabel('Time Resolution [sec]')
legend('Number of coincidences')
xlim([0 numel(octave)])
xticks((0:numel(octave)))
xticklabels(labti)
ti=title(['Nb coincidences per octave (Imaging)'  ...
    ', Coinc. time window: ' num2str((2*cointimewindow+1)) 'time res.' ...
    ', Coinc. spatial window: ' num2str((2*coinspatialwindow+1)) 'x'  num2str((2*coinspatialwindow+1)) 'pix' ...
    ', Tot time [s]:' num2str(timetot,'%2.3g')]);
saveas(gcf,[direc   'Ima' num2str(nbstd) 'stdNbsHighevCoins' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.png'])
saveas(gcf,[direc   'Ima' num2str(nbstd) 'stdNbsHighevCoins' char(datetime(capture(ind4ima(zr)).frametime_epoch,'ConvertFrom','posixtime','format','yyyyMMdd_hhmmss','TimeZone','America/Los_Angeles'))  '.fig'])


%%%%%%%%% PHDs all pix
PHDs=0;
if PHDs==1
    %%%All pixs
    szi=size(images);
    allADCpixt=reshape(images,[1 szi(1)*szi(2)*szi(3)]);
    %%%PHD
    minp=min(allADCpixt);
    maxp=max(allADCpixt);
    factbin=10;
    nbin=factbin*(maxp-minp);
    xcallpix=minp:(maxp-minp)/nbin:maxp;
    h=hist(allADCpixt,xcallpix);
    hcr=cumsum(h(end:-1:1));
    hcallpix=hcr(end:-1:1);
    
    %   ADCDACfit=plot(dactab,(countfit.p1*dactab + countfit.p2),'--','LineWidth',2.)
    
    
    figure('Position',[10 10 1400 900],'Color','w')
    hold on
    timeacq=acqint*numel(indboard4);
    plot(xcallpix,(1/timeacq)*hcallpix,'LineWidth',3)
    vecbin=minp:maxp;
    h2=hist(allADCpixt,vecbin);
    bar(vecbin,(1/timeacq)*h2)
    hold off
    set(gca,'YScale','log')
    fs=16;
    set(gca,'FontSize',fs)
    yl=ylim;xl=xlim;
    set(gca,'YLim',[(1/timeacq)*0.5 yl(2)],'XLim',[0 xl(2)])
    xlabel('pixel intensity [ADC]')
    ylabel(['Occurrences per sec' ])
    legend('All quabo pixels, occurrences per sec above threshold',['All quabo pixels, occurrences per sec, bin width: ' num2str(vecbin(2)-vecbin(1),'%i') 'ADC'])
    box on
    grid on
    ti=title(['Lick on-sky, UT: ' datestr(timecomp(1)+7./24,'yyyy-mm-dd HH:MM:SS') ', ' dataset ', durationfile [s]:' num2str(timeacq,'%4.1f') ],'FontSize',20)
    ti.FontSize=16;
    saveas(gcf,[direc   'PHDallpix' datestr(timecomp(1)+7./24,'yyyymmddHHMMSS')  '.png'])
    saveas(gcf,[direc   'PHDallpix' datestr(timecomp(1)+7./24,'yyyymmddHHMMSS')  '.fig'])
    
    %%%All pixs - median frame
    szi=size(images);
    imagesmedremoved=imafB;
    for zi=1:size(imafB,3)
        imagesmedremoved(:,:,zi)=imafB(:,:,zi)-medianframe;
    end
    
    szi=size( imagesmedremoved);
    allADCpixtmed=reshape(imagesmedremoved,[1 szi(1)*szi(2)*szi(3)]);
    %%%PHD
    minp=min(allADCpixtmed);
    maxp=max(allADCpixtmed);
    factbin=10;
    nbin=factbin*(maxp-minp);
    xcallpixmed=minp:(maxp-minp)/nbin:maxp;
    hmed=hist(allADCpixtmed,xcallpixmed);
    hcrmed=cumsum(hmed(end:-1:1));
    hcallpixmedrem=hcrmed(end:-1:1);
    
    %   ADCDACfit=plot(dactab,(countfit.p1*dactab + countfit.p2),'--','LineWidth',2.)
    
    
    figure('Position',[10 10 1400 900],'Color','w')
    hold on
    timeacq=acqint*numel(indboard4);
    plot(xcallpixmed,(1/timeacq)*hcallpixmedrem,'LineWidth',3)
    vecbin=minp:maxp;
    h2=hist(allADCpixtmed,vecbin);
    bar(vecbin,(1/timeacq)*h2)
    hold off
    set(gca,'YScale','log')
    fs=16;
    set(gca,'FontSize',fs)
    yl=ylim;xl=xlim;
    set(gca,'YLim',[(1/timeacq)*0.5 yl(2)]);%,'XLim',[0 xl(2)])
    xlabel('pixel intensity [ADC]')
    ylabel(['Occurrences per sec' ])
    legend('All quabo pixels (median subtracted), occurrences per sec above threshold',['All quabo pixels (median subtracted), occurrences per sec, bin width: ' num2str(vecbin(2)-vecbin(1),'%i') 'ADC'])
    box on
    grid on
    ti=title(['Lick on-sky, median frame removed, UT: ' datestr(timecomp(1)+7./24,'yyyy-mm-dd HH:MM:SS') ', ' dataset ', durationfile [s]:' num2str(timeacq,'%4.1f') ],'FontSize',20)
    ti.FontSize=16;
    saveas(gcf,[direc   'PHDallpixminusmed' datestr(timecomp(1)+7./24,'yyyymmddHHMMSS')  '.png'])
    saveas(gcf,[direc   'PHDallpixminusmed' datestr(timecomp(1)+7./24,'yyyymmddHHMMSS')  '.fig'])
    
end

if 1==0
    dispim=imafB;
    figure
    axis image
    for nn=1:size(dispim,3)
        imagesc(dispim(:,:,nn))
        colorbar
        pause(0.2)
    end
    
    figure
    axis image
    for nn=1:size(dispim,3)
        imagesc(dispim(:,:,nn)-medianframe,[-200 200])
        
        colorbar
        pause(0.2)
    end
end

makevideo=0;
if makevideo==1
    filename=[direc   'MovIma' datestr(timecomp(1)+7./24,'yyyymmddHHMMSS')  '.gif'];
    dispim=imafB;
    figure('Color','w','Position',[100 100 1200 800])
    
    for nn=1:size(dispim,3)
        hold on
        imagesc(flipud(dispim(:,:,nn)))
        plot([32.5 32.5],[0.5 32.5],'-k','LineWidth',3)
        axis image
        colorbar
        %pause(0.2)
        if numel(indboard4)>=nn
            title(['Lick W&E modules,  ' dataset '  ' datestr(timecomp(indboard4(nn))+7./24,'yyyy mm dd HH:MM:SS')])
        end
        frame = getframe(gcf,[100, 170, 1000, 500]);
        im = frame2im(frame); %,
        [imind,cm] = rgb2ind(im,256);
        delay=0;
        if (nn==1)
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
        end
    end
    %%video of frames - median frame
    filename=[direc   'MovImaMinusMed' datestr(timecomp(1)+7./24,'yyyymmddHHMMSS')  '.gif'];
    dispim=imafB;
    figure('Color','w','Position',[100 100 1200 800])
    
    for nn=1:size(dispim,3)
        hold on
        imagesc(flipud(dispim(:,:,nn)-medianframe))
        plot([32.5 32.5],[0.5 32.5],'-k','LineWidth',3)
        axis image
        colorbar
        %pause(0.2)
        if numel(indboard4)>=nn
            title(['Lick W&E modules, Raw Images - median(Images), ' dataset '  ' datestr(timecomp(indboard4(nn))+7./24,'yyyy mm dd HH:MM:SS')])
        end
        frame = getframe(gcf,[100, 170, 1000, 500]);
        im = frame2im(frame); %,
        [imind,cm] = rgb2ind(im,256);
        delay=0;
        if (nn==1)
            imwrite(imind,cm,filename,'gif', 'Loopcount',inf,'DelayTime',delay);%,'ScreenSize',[640 640]
        else
            imwrite(imind,cm,filename,'gif','WriteMode','append','DelayTime',delay);
        end
        
    end
    
end

% [filepath,name,ext] = fileparts(files(ii).name)
% save([direc 'Imares' name '.mat'])
% else
%     [filepath,name,ext] = fileparts(files(ii).name)
%     load([direc 'Imares' name '.mat'])
%     end
%     end
%
