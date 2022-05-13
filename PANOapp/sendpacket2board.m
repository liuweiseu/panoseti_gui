 function answ = sendpacket2board(packet,IP, readback)
            %packet identification
            sz=size(packet);
            szp=sz(1);
            
            %% read data
          %  if szp==64 %SCIENCE
                
               % if size(app.sock,1)==0
                    port=60000;
                    %judp('SEND',port,'192.168.1.10', packet);
                    aa=py.socket.AF_INET;
                    ab=py.socket.SOCK_DGRAM;
                    sock = py.socket.socket(aa, ab);
                    
                    sock.settimeout(5)
                    
                    
                    host=py.tuple({'', uint32(60000)});
                    sock.bind(host);
           %     end
                zzb=py.bytes(packet);
                
                dest3=py.tuple({IP, uint32(60000)});
                sock.sendto(zzb,dest3);
                if exist('readback','var') && (readback==1)
                disp('receiving resp')
               reply=sock.recvfrom(uint16(1024));
                     answ=reply(1)
                else
                    answ=[];
                end
               %answ=[];
          %  end
            
       
    end