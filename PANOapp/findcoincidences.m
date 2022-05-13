function [coincidence4 nbcoin nanodiff] = findcoincidences(...
    windowtimecomp,coincidencetime,timecomp4,nanosec4,...
     timecomp5,nanosec5,timecomp6,nanosec6,timecomp7,nanosec7,...
     timecomp3248,nanosec3248, timecomp3249,nanosec3249, ...
     timecomp3250,nanosec3250, timecomp3251,nanosec3251 )
nbcoin=0;
coincidence4 = {};nanodiff=[];
    for fra=1:numel(timecomp4)
        %find frames on other quabos inside an interval windowtimecomp sec
        indsamesec45=find(abs(timecomp4(fra)-timecomp5)<windowtimecomp);
        indsamesec46=find(abs(timecomp4(fra)-timecomp6)<windowtimecomp);
        indsamesec47=find(abs(timecomp4(fra)-timecomp7)<windowtimecomp);
        indsamesec43248=find(abs(timecomp4(fra)-timecomp3248)<windowtimecomp);
        indsamesec43249=find(abs(timecomp4(fra)-timecomp3249)<windowtimecomp);
        indsamesec43250=find(abs(timecomp4(fra)-timecomp3250)<windowtimecomp);
        indsamesec43251=find(abs(timecomp4(fra)-timecomp3251)<windowtimecomp);
        
        %find coincidences inside that first window
        indsamenano45=find(abs(nanosec4(fra)-nanosec5(indsamesec45))<coincidencetime);
        indsamenano46=find(abs(nanosec4(fra)-nanosec6(indsamesec46))<coincidencetime);
        indsamenano47=find(abs(nanosec4(fra)-nanosec7(indsamesec47))<coincidencetime);
        indsamenano43248=find(abs(nanosec4(fra)-nanosec3248(indsamesec43248))<coincidencetime);
        indsamenano43249=find(abs(nanosec4(fra)-nanosec3249(indsamesec43249))<coincidencetime);
        indsamenano43250=find(abs(nanosec4(fra)-nanosec3250(indsamesec43250))<coincidencetime);
        indsamenano43251=find(abs(nanosec4(fra)-nanosec3251(indsamesec43251))<coincidencetime);
        
        if numel(indsamenano45)>0 ...
                || numel(indsamenano46)>0 ...
                || numel(indsamenano47)>0 ...
                || numel(indsamenano43248)>0 ...
                || numel(indsamenano43249)>0 ...
                || numel(indsamenano43250)>0 ...
                || numel(indsamenano43251)>0
            
            coincidence4 = [coincidence4; {fra} ...
                {indsamesec45(indsamenano45)} ...
                {indsamesec46(indsamenano46)} ...
                {indsamesec47(indsamenano47)} ...
                {indsamesec43248(indsamenano43248)} ...
                {indsamesec43249(indsamenano43249)} ...
                {indsamesec43250(indsamenano43250)} ...
                {indsamesec43251(indsamenano43251)} ...
                ];
            nbcoin=nbcoin+1;
        end     
    end
  
    
    %%look at coincidences:
    for cc=1:nbcoin
        %take non-empty cells for each coin:
     % indnn = find(~isempty(nanosec4(cell2mat(coincidence4(cc,2:end)))));
     % for nn=1:numel(indnn)
     if ~isempty(coincidence4(cc,2))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec5(cell2mat(coincidence4(cc,2)))];
     end
     if ~isempty(coincidence4(cc,3))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec6(cell2mat(coincidence4(cc,3)))];
     end
     if ~isempty(coincidence4(cc,4))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec7(cell2mat(coincidence4(cc,4)))];
     end
     if ~isempty(coincidence4(cc,5))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec3248(cell2mat(coincidence4(cc,5)))];
     end 
          if ~isempty(coincidence4(cc,6))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec3249(cell2mat(coincidence4(cc,6)))];
          end    
          if ~isempty(coincidence4(cc,7))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec3250(cell2mat(coincidence4(cc,7)))];
          end    
          if ~isempty(coincidence4(cc,8))
       nanodiff=[nanodiff ...
           nanosec4(cell2mat(coincidence4(cc,1)))-nanosec3251(cell2mat(coincidence4(cc,8)))];
          end
     
    end
    