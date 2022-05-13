   

port=60001;
         nbudp=10;
         tic
         ticBytes(gcp)
         parfor ii=1:10
[packet,SOURCEHOST]  = judp('RECEIVE',port,528, 2000);
%ii
         end
         tocBytes(gcp)
           t1= toc;
           
           
    disp(['time per frame (s):' num2str( (1/nbudp)*   t1)])
      disp(['pack/s:' num2str(nbudp/t1)])
         %pano with display
        timecomp1= 737472.567814398 ;
          timecomp2 = 737472.567853785 ;
          nbframe=18;
          %time per frame:
     disp(['time per frame (s):' num2str( (1/nbframe)*   3600*24*(timecomp2- timecomp1))])
      disp(['pack/s:' num2str(1/( (1/nbframe)*   3600*24*(timecomp2- timecomp1)))])

     %pano sans display with fits save
          timecomp1= 737472.582291458 ;
            timecomp2 = 737472.582292732 ;
            nbframe=30;
         disp(['time per frame (s):' num2str( (1/nbframe)*   3600*24*(timecomp2- timecomp1))])
      disp(['pack/s:' num2str(1/( (1/nbframe)*   3600*24*(timecomp2- timecomp1)))])
