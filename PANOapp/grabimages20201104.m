function images=grabimages(nim,mode,rec)   
if mode==1
    recorddata=1;
    recorddataudpnodisp= 0;
    recorddatafast=0;
elseif mode==2
    recorddata=0;
    recorddataudpnodisp= 1;
    recorddatafast=0;
elseif mode==3
    recorddata=0;
    recorddataudpnodisp= 0;
    recorddatafast=1;
else
    recorddata=1;
    recorddataudpnodisp= 0;
    recorddatafast=0;
end
dimima=16;
images=zeros(dimima,dimima,nim);
                
   import matlab.io.*
            utcshift=7/24;
         port=60001;
            porthost=49153;
          %  h=app.DataDirectoryEditField;
      panodatadir= [getuserdir '\panoseti\DATA\'];
            %    u = udp('127.0.0.1',4012);
            %    porthost=49153;
            %  u = udp('192.168.1.10',porthost, 'LocalPort', port,'InputBufferSize',528,'DatagramTerminateMode','on');
            %     u = udp('192.168.1.11',porthost, 'LocalPort', port,'InputBufferSize',528*8,'DatagramTerminateMode','off');
            %  py.store_sci_data_quabo_init_Matlab
            %     fopen(u)
            missedpac=0;
            dolisten=1;
             app.fitsnum=1;
             app.fitsmax=nim;
            while  (dolisten==1) && (missedpac<app.fitsmax+1)
                 
                 disp(['Taking ima#' num2str(app.fitsnum)])
                
                %   if app.fitsnum==1
                
                %                end
                %  disp(ct(end))
                %re=fread(u2);
                %disp('Awaiting packets...')
                %             updateconsoleapp(app,['Listening packets on port ' num2str(port)])
                %             drawnow
                %             try
                %                  %   [packet,SOURCEHOST]  = judp('RECEIVE',port,528, 2000);
                %                   ti=      tic;
                %                     %packet = fread(u,528,'uint8');
                %                      [packet,SOURCEHOST]  = judp('RECEIVE',port,528, 2000);
                %                        disp(['udp time:' num2str(toc(ti))])
                %                 catch
                %                   packet=[];
                %      %               updateconsoleapp(app,'No packet received.')
                %             end
               
                
                displaymean=0;%app.DisplayMEANonlyCheckBox.Value;
                if (recorddatafast==1) || (displaymean ==1)
                    if exist('u','var')
                        fclose(u)
                    end
                    if size(app.sock,1)==0
                        %           port=60000
                        %judp('SEND',port,'192.168.1.10', packet);
                        aa=py.socket.AF_INET;
                        ab=py.socket.SOCK_DGRAM;
                        sock = py.socket.socket(aa, ab);
                        
                        sock.settimeout(5)
                        
                        
                        host=py.tuple({'', uint32(60001)});
                        sock.bind(host);
                        app.sock=sock;
                        
                        
                        %       hdr=cell_fitshead_addkey(hdr0,'UTSTARTC' ,	 datestr(timenow+utc,'HH:MM:SS.FFF'), 'UT at UDP reception (computer)');
                        %       hdr=cell_fitshead_addkey(hdr,'ETSEC1' ,	ET_ticks, ' ');
                        %       hdr=cell_fitshead_addkey(hdr,'ETSEC2' ,	ET_ticks, ' ');
                        %       hdr=cell_fitshead_addkey(hdr,'ETSEC3' ,	ET_ticks, ' ');
                        %TODO: test if filename exist, then padd ['_' num2str(i)]
                        
                        %app.fhand = py.open(fullfilename, 'w')
                    end
                    %%%%%%%%%%%%%%testudp_fpga_new;packet=packet';pause(1)
                    %           drawnow
                    %   reply = app.sock.recvfrom(unit32(2048))
                    timenow=now;
                    % if app.fitsnum==1
                    filename = ['p_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS_FFF') ];
                    filesep='\';
                    fullfilename=[panodatadir filesep filename];
                    
                    
                    % tic
                    %  [chip0,chip1,chip2,chip3]=
                    
                    ti= tic;
                    try
                        if displaymean==0
                        py.store_sci_data_quabo_packet_MatlabEpyfits3s.makeim(sock,fullfilename,app.fitsmax);
                        disp(['udp py time:' num2str(toc(ti))])
                        else
                             im=py.store_sci_data_quabo_packet_MatlabEpyfits3s.makemean(sock,fullfilename,app.fitsmax);
                             im2=double(py.array.array('d',py.numpy.nditer(im)));
                             displayimageapp(app,im2);
                             
                        end
                    catch
                        packet=[];
                        updateconsoleapp(app,'No packet received.')
                    end
                    
                else
                    
                    if  recorddataudpnodisp==1 && (~exist('u','var') || strncmp(u.Status,'clo',3))
                        u = udp('192.168.1.11',porthost, 'LocalPort', port,'InputBufferSize',528*8,'DatagramTerminateMode','on');
                        
                        fopen(u)
                        app.u=u;
                    end
                    try
                        %  [packet,SOURCEHOST]  = judp('RECEIVE',port,2048, 2000);
                        if  recorddataudpnodisp==1
                            packet = uint8(fread(u,528));
                        else
                            [packet,SOURCEHOST]  = judp('RECEIVE',port,2048, 2000);
                        end
                    catch
                        packet=[];
                      %  updateconsoleapp(app,'No packet received.')
                    end
                    
                    %%%%%%%%%%%%%%testudp_fpga_new;packet=packet';pause(1)
                    %if  recorddataudpnodisp~=1
                   % drawnow
                    % end
                    
                    %char(packet')
                    
                    %packet identification
                    sz=size(packet);
                    szp=sz(1);
                    if szp>0
                   %     app.Lamp_2.Color='g';
                    %    updateconsoleapp(app,['1 Packet of size ' num2str(sz(1)) ' bytes received!'])
                        
                        %% read data
                        if szp==528 %SCIENCE
                            
                            acq_mode=typecast(uint8(packet(1)),'uint8');
                            packet_no=typecast((packet(3:4)),'uint16');
                            %ct=[ct packet_no];
                            boardloc=typecast((packet(5:6)),'uint16');
                            utc=typecast(uint8(packet(7:10)),'uint32');
                            nanosec=typecast(uint8(packet(11:14)),'uint32');
                            
                            % ET_ticks=typecast(uint8(packet(3:6)),'uint32');
                            % ET_seconds1=typecast(uint8(packet(7:10)),'uint32');
                            % ET_seconds2=typecast(uint8(packet(11:14)),'uint32');
                            % ET_seconds3=typecast(uint8(packet(15:18)),'uint32');
                            pixels=typecast((packet(17:17+2*256-1)),'uint16');
                            
                            %all values should be 12-bit
                            % in pulse height mode (trigger mode) MS bit (most significant bit) is 1
                            % for the pixel that triggered
%                             MSind=find(pixels>2^12);
%                             pixels(MSind)=pixels(MSind)-2^15;
%                             if numel(MSind)>0
%                                 %updateconsole(app,'Found triggering pixel.')
%                             end

%put data in memory for variable use
images(:,:,app.fitsnum)=reshape(pixels,[dimima,dimima])';

                            %%save data
                            
                            timenow=now;
                            
                            
                         %   h=app.SaveFITSCheckBox;
                          %  recorddata=  rec;
                            if ((recorddata==1) || (recorddataudpnodisp==1)) && (rec==1)
                             %   h=app.DataDirectoryEditField;
                             %   panodatadir=  h.Value;
                                %       hdr=cell_fitshead_addkey(hdr0,'UTSTARTC' ,	 datestr(timenow+utc,'HH:MM:SS.FFF'), 'UT at UDP reception (computer)');
                                %       hdr=cell_fitshead_addkey(hdr,'ETSEC1' ,	ET_ticks, ' ');
                                %       hdr=cell_fitshead_addkey(hdr,'ETSEC2' ,	ET_ticks, ' ');
                                %       hdr=cell_fitshead_addkey(hdr,'ETSEC3' ,	ET_ticks, ' ');
                                %TODO: test if filename exist, then padd ['_' num2str(i)]
                                
                                if app.fitsnum==1
                                    filename = ['p_d0w0m0q0_' datestr(timenow+utcshift,'yyyymmdd_HHMMSS') '_' num2str(packet_no)];
                                    filesep='\';
                                    fullfilename=[panodatadir filesep filename];
                                    app.fitscurrentname=fullfilename;
                                    
                                    %4   hdr=cell_fitshead_addkey(hdr,'SEQID' ,	seqID, 'Name of the sequence');
                                    %        hdr=cell_fitshead_addkey(hdr,'FILENAME' ,	[filename '.fits'], 'Name of the file');
                                    %        hdr=cell_fitshead_addkey(hdr,'ABORTED' ,	'F', 'Exposure was stopped before completion');
                                    
                                    %[Flag,hdr]=fitswrite_my(pixels,[fullfilename '.fits'],hdr,'int16');
                                    %  fitswrite_my(pixels',[fullfilename '.fits'],hdr,'int16');
                                    % fitswrite(pixels',[fullfilename '.fits'],hdr);
                                    
                                    app.fptr = fits.createFile([fullfilename '.fits']);
                                    
                                    fits.createImg(app.fptr,'int32',[16 16]);
                                    %fitsmode='overwrite';
                                    img=int32(reshape(pixels,[16 16]));
                                    fits.writeImg(app.fptr,img)
                                else
                                    %   app.fptr = fits.openFile([app.fitscurrentname '.fits'],'readwrite');
                                    % fitsmode='append'
                                    fits.createImg(app.fptr,'int32',[16 16]);
                                    img=int32(reshape(pixels,[16 16]));
                                    %fits.insertImage(fptr,img,'Writemode',fitsmode)
                                    fits.writeImg(app.fptr,img)
                                end
                                
                                
                                %                             h=findobj('Tag','dispacqmode');
                                %                             h.String=['Acq. mode: ' num2str(acq_mode)];
                                %                             h=findobj('Tag','disppacket_no');
                                %                             h.String=['Packet No: ' num2str(packet_no)];
                                %                             h=findobj('Tag','dispboardloc');
                                %                             h.String=['Board No: ' num2str(boardloc)];
                                %                             h=findobj('Tag','disputc');
                                %                             h.String=['UTC: ' num2str(utc)];
                                %                             h=findobj('Tag','dispnanosec');
                                %                             h.String=['Nanosec: ' num2str(nanosec)];
                                %                             h=findobj('Tag','disptime');
                                %                             timenow=[char((string(datetime('now'))))];
                                %                             h.String=timenow;
                                fits.writeKey(app.fptr,'DOMENO',0,'Dom No');
                                fits.writeKey(app.fptr,'MODULENO',0,'Module No');
                                fits.writeKey(app.fptr,'WAVELEN',0,'Waveband 0:vis 1:NIR');
                                fits.writeKey(app.fptr,'QUABO',0,'Quad board No');
                                fits.writeKey(app.fptr,'ACQMODE',acq_mode,'Acq. mode');
                                fits.writeKey(app.fptr,'PACKETNO',typecast([packet_no 0],'int32'),'Packet No');
                                fits.writeKey(app.fptr,'BOARDLOC',typecast([boardloc 0],'int32'),'aperture number (8b) concatenated with the quadrant number (2b) padded with 0s.');
                                fits.writeKey(app.fptr,'UTC',typecast([utc 0],'int64'),'Universal Time, in seconds, from the White Rabbit infrastructure');
                                fits.writeKey(app.fptr,'NANOSEC',typecast([nanosec 0],'int64'),'number of nanoseconds since the last tick of UTC');
                                fits.writeKey(app.fptr,'TIMECOMP',timenow,'int32');
%                                 if numel(MSind)>0
%                                     fits.writeKey(app.fptr,'MSIND',MSind(1),'int16');
%                                 end
                                app.fitsnum=app.fitsnum+1;
                                if app.fitsnum==app.fitsmax+1
                                    fits.closeFile(app.fptr);
                                   % app.fitsnum=1;
                                   closedfits=1
                                end
                            end
                            
                            %
                            % %draw pixels
                            % imagesc(reshape(pixels,[8,8]))
                            % drawnow
                          %  displayinfoapp(app,acq_mode,packet_no,boardloc,utc,nanosec,timenow);
%                             if  ~exist('u','var') || strncmp(u.Status,'clo',3)
%                                 displayimageapp(app,pixels);
%                             end
%                            app.Lamp_2.Color=[1.00 0.96 0.93];
                        end%SCIENCE
                        
                        
                        
                    else
                        missedpac=missedpac+1;
                        
                    end %szp>0
                    
                    
                    
                    
                end
               
                
               if  app.fitsnum==app.fitsmax+1
                      dolisten=0;
                        if exist('u','var')
                        fclose(u)
                    end
                  end
                %%be sure none changed the Listen bouton
               % drawnow;
              %  value = app.Switch.Value;
                
              %  if strncmp(value, 'On',2)
                    % h=findobj('Tag','listen');
                    %txt= h(1).String;
                    %  if strncmp(txt,'Stop',4) %txt updated just before
              %      dolisten=1;
              %  else
             %       dolisten=0;
             %       app.Lamp.Color='r';
              %      updateconsoleapp(app,['Listening packet stopped.'])
                   
              %  end
            end
            %%disp time
            % timenow=[char((string(datetime('now'))))];
            %toc
            
            %else
             if isfield(app,'fptr') && ~exist('closedfits','var')
             fits.closeFile(app.fptr);
           end