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



