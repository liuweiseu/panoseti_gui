 %set masks MASKOR1_
    mask=0;
    if mask==0
        for pp=0:63
            [ig,indexmask]=ismember(['MASKOR1_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
        end
    else
        indcols=1
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
        
            %marocmap(32,1,:)
        [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
        quad=1; 
        quaboconfig(indexmask,quad+1)={['0']};
        [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
        quaboconfig(indexmask2,quad+1)={['0']};
%         [ig,indexmask]=ismember(['MASKOR1_53'] ,quaboconfig);
%       quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_53'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
                
%                         quaboconfig(indexmask,quad+1+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1+1)={['0']};
%                 [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
    end
    