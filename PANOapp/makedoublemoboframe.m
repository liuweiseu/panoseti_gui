function imafB= makedoublemoboframe(packetno2,maxpackets,images,boarloc )
nbim=size(images,3);
offset=0;

indboard4=find(boarloc==4);
indboard5=find(boarloc==5);
indboard6=find(boarloc==6);
indboard7=find(boarloc==7);
indboard16=find(boarloc==1016);
indboard17=find(boarloc==1017);
indboard18=find(boarloc==1018);
indboard19=find(boarloc==1019);

% for nima=2:nbim
%     
% end
imafB=zeros(32,64,maxpackets+1);
for nima=1:nbim
    %  disp(['Rotating ima ' num2str(nima) '/' num2str(nbim)])
    dispima= boarloc(nima);
    shapedima=images(:,:,nima);
%     if packetno(nima)<packetno(nima)-1
%         offset=offset+packetno2(nima-1);
%         packetno2(nima)=packetno2(nima)+offset;
%     end
    
    
    switch dispima
        %                 case 0
        %                     parentUIaxes=app.UIAxes;
        %                     imadisp=fliplr(shapedima);
        case 4
            %parentUIaxes=app.UIAxes2;
            % imadisp=fliplr(shapedima);
            xq=0;yq=0;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard4(1))+1)= shapedima;
            
        case 5
            %parentUIaxes=app.UIAxes3;
            %imadisp=flipud(fliplr((shapedima)'));
            xq=0;yq=16;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard5(1))+1)=shapedima;
        case 6
            %parentUIaxes=app.UIAxes4;
            %    imadisp=flipud(shapedima);
            xq=16;yq=16;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard6(1))+1)=shapedima;
        case 7
            %parentUIaxes=app.UIAxes5;
            %   imadisp=shapedima';
            xq=16;yq=0;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard7(1))+1)=shapedima;
        case 1016
            %parentUIaxes=app.UIAxes2;
            %    imadisp=fliplr(shapedima);
            xq=0;yq=32;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard16(1))+1)=shapedima;
        case 1017
            %parentUIaxes=app.UIAxes3;
            %   imadisp=flipud(fliplr((shapedima)'));
            xq=0;yq=48;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard17(1))+1)=shapedima;
        case 1018
            %parentUIaxes=app.UIAxes4;
            %  imadisp=flipud(shapedima);
            xq=16;yq=48;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard18(1))+1)=shapedima;
        case 1019
            %parentUIaxes=app.UIAxes5;
            % imadisp=shapedima';
            xq=16;yq=32;
            imafB(xq+(1:16),yq+(1:16),packetno2(nima)-packetno2(indboard19(1))+1)=shapedima;
    end
end




