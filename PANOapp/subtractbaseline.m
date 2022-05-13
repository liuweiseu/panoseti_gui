function subtractbaseline(quaboconfig)    

panobasedir=[getuserdir filesep 'panoseti' filesep 'baselines' filesep];
            if ~exist(panobasedir,'dir')
                mkdir(panobasedir)
            end
            packet=int8(zeros(64,1));
        packet(1)=int8(7);
        
        
        
  [ia,index]=ismember('IP',quaboconfig);
  IP=(quaboconfig(index,3));

        
     answ=   sendpacket2board(packet,IP,0);
        %recup baseline
         try
             [packet,SOURCEHOST] = judp('RECEIVE',60000,1064,4000);
               pixels=typecast((packet(5:5+2*256-1)),'uint16');
         %save baseline
            import matlab.io.*
            utcshift=7/24;
               timenow=now;
         filename = ['b_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS') ];
         fullfilename=[ panobasedir filename];

                                
                                fptr = fits.createFile([fullfilename '.fits']);
                                
                                fits.createImg(fptr,'int32',[16 16]);
                                %fitsmode='overwrite';
                                img=int32(reshape(pixels,[16 16]));
                            fits.writeImg(fptr,img)
                                fits.closeFile(fptr);
         
         catch
         packet=[];
                  
         end
end   