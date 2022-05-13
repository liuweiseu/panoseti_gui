function quaboconfig=changestim(stimon,stimlevel,stimrate,maskmode,maskallexceptedcoor,quaboconfig)
%%% maskallexceptedcoor is dim [nbpix quad] ; attention quad starts at 1
%%% nbpix starts at 1 (whereas Maroc starts at 0)
%% maskmode=0: no stim; maskmode=1: some stimmed pixels; maskmode=2 all pix are stimmed 

%   stimon=1;stimlevel=200;stimrate=2;maskmode=1;maskallexceptedcoor=[2 2];
%   quaboconfig=changestim(stimon,stimlevel,stimrate,maskmode,maskallexceptedcoor,quaboconfig)


% STIMON =0
% STIM_LEVEL =32   *0 to 255
% STIM_RATE =2
indcol=1:4;
            [ig,indexmask]=ismember(['STIMON '] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={[num2str(stimon)]};
  [ig,indexmask]=ismember(['STIM_LEVEL '] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={[num2str(stimlevel)]};
              [ig,indexmask]=ismember(['STIM_RATE '] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={[num2str(stimrate)]};


    %mask=1;
    if maskmode==0
        for pp=0:63
            [ig,indexmask]=ismember(['CTEST_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
        end
           disp(['Unstimming all pixels....' ])
    elseif maskmode==2
        for pp=0:63
                [ig,indexmask]=ismember(['CTEST_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['1']};
        end
           disp(['Stimming all pixels....' ])
   
    else
       % indcols=1
        for pp=0:63
            [ig,indexmask]=ismember(['CTEST_' num2str(pp)] ,quaboconfig);
            quaboconfig(indexmask,indcol+1)={['0']};
        end
%         [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
%         quad=1; 
%         quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
      for pixi=1: size( maskallexceptedcoor,1)
            %marocmap(32,1,:)
        [ig,indexmask]=ismember(['CTEST_' num2str(maskallexceptedcoor(pixi,1)-1)] ,quaboconfig);
        quad=maskallexceptedcoor(pixi,2); 
        quaboconfig(indexmask,quad+1)={['1']};
      
      end
%         [ig,indexmask]=ismember(['MASKOR1_53'] ,quaboconfig);
%       quaboconfig(indexmask,quad+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_53'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1)={['0']};
                
%                         quaboconfig(indexmask,quad+1+1)={['0']};
%         [ig,indexmask2]=ismember(['MASKOR2_63'] ,quaboconfig);
%         quaboconfig(indexmask2,quad+1+1)={['0']};
%                 [ig,indexmask]=ismember(['MASKOR1_63'] ,quaboconfig);
      disp(['Stimming requested pixels ...'])
    end
   
    sentacqparams2board(quaboconfig)
          %  sendconfig2Maroc(quaboconfig)