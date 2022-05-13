function quaboconfig=changemask(maskmode,maskallexceptedcoor,quaboconfig)
%%% maskallexceptedcoor is dim [nbpix quad] ; attention quad starts at 1
%%% nbpix starts at 1 (whereas Maroc starts at 0)
indcol=1:4;
    %mask=1;
    if maskmode==0
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
            [ig,indexmask]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
        end
           disp(['Unmasking all pix....' ])
    else
       % indcols=1
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['1']};
            [ig,indexmask2]=ismember(['MASKOR2_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask2,indcol+1)={['1']};
        end
%         [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
%         quad=1; 
%         quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
      for pixi=1: size( maskallexceptedcoor,1)
            %marocmap(32,1,:)
        [ig,indexmask]=ismember(['MASKOR1_' num2str(maskallexceptedcoor(pixi,1)-1)] ,quaboconfig);
        quad=maskallexceptedcoor(pixi,2); 
        quaboconfig(indexmask,quad+1)={['0']};
        [ig,indexmask2]=ismember(['MASKOR2_'  num2str(maskallexceptedcoor(pixi,1)-1)] ,quaboconfig);
        quaboconfig(indexmask2,quad+1)={['0']};
      end
%         [ig,indexmask]=ismember(['MASKOR1_53'] ,quaboconfig);
%       quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_53'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
                
%                         quaboconfig(indexmask,quad+1+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1+1)={['0']};
%                 [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
      disp(['masking all pixels excepted some pix...'])
    end
   

            sendconfig2Maroc(quaboconfig)