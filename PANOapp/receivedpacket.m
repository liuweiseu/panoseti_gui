    function receivedpacket(src,evt,app)
       utcshift=7/24;
        import matlab.io.*
          if app.fitsnum==1
                                  tic
                              end
             %   try
                 %   [packet,SOURCEHOST]  = judp('RECEIVE',port,528, 2000);
                    packet = fread(src,528,'uint8');
            %    catch
             %       packet=[];
     %               updateconsoleapp(app,'No packet received.')
             %   end
                %%%%%%%%%%%%%%testudp_fpga_new;packet=packet';pause(1)
     %           drawnow
                
                %char(packet')
                
                %packet identification
                szp=size(packet,1);
                %szp=sz(1);
        %       if szp>0
  %                  app.Lamp_2.Color='g';
   %                 updateconsoleapp(app,['1 Packet of size ' num2str(sz(1)) ' bytes received!'])
                    
                    %% read data
                    if szp==528  %SCIENCE
                 %    parfor ipa=1:1
                        acq_mode=typecast(uint8(packet(1)),'uint8');
                        packet_no=typecast(uint8(packet(3:4)),'uint16');
                        %ct=[ct packet_no];
                        boardloc=typecast(uint8(packet(5:6)),'uint16');
                        utc=typecast(uint8(packet(7:10)),'uint32');
                        nanosec=typecast(uint8(packet(11:14)),'uint32');
                        
                        % ET_ticks=typecast(uint8(packet(3:6)),'uint32');
                        % ET_seconds1=typecast(uint8(packet(7:10)),'uint32');
                        % ET_seconds2=typecast(uint8(packet(11:14)),'uint32');
                        % ET_seconds3=typecast(uint8(packet(15:18)),'uint32');
                        pixels=typecast(uint8(packet(17:17+2*256-1)),'uint16');
                      %  pixels=typecast(uint8(packet(17:end)),'uint16');
                        
                        %all values should be 12-bit
                        % in pulse height mode (trigger mode) MS bit (most significant bit) is 1
                        % for the pixel that triggered
%                         MSind=find(pixels>2^12);
%                         pixels(MSind)=pixels(MSind)-2^15;
%                         if numel(MSind)>0
%                             %updateconsole(app,'Found triggering pixel.')
%                         end
%                         %%save data
                        
                        timenow=now;
                        
                        
                      %  h=app.SaveFITSCheckBox;
                       % recorddata=  h.Value;
                       recorddata=app.SaveFITSCheckBox.Value;
                        if recorddata==1
            %                 if 1==0
                            h=app.DataDirectoryEditField;
                            panodatadir=  h.Value;
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
                            fits.writeKey(app.fptr,'DOMENO',0,'Dome No');
                            fits.writeKey(app.fptr,'MODULENO',0,'Module No');
                            fits.writeKey(app.fptr,'WAVELEN',0,'Waveband 0:vis 1:NIR');
                            fits.writeKey(app.fptr,'QUABO',0,'Quad board No');
                            fits.writeKey(app.fptr,'ACQMODE',acq_mode,'Acq. mode');
%                             fits.writeKey(app.fptr,'PACKETNO',typecast([packet_no 0],'int32'),'Packet No');
%                             fits.writeKey(app.fptr,'BOARDLOC',typecast([boardloc 0],'int32'),'aperture number (8b) concatenated with the quadrant number (2b) padded with 0s.');
%                             fits.writeKey(app.fptr,'UTC',typecast([utc 0],'int64'),'Universal Time, in seconds, from the White Rabbit infrastructure');
%                             fits.writeKey(app.fptr,'NANOSEC',typecast([nanosec 0],'int64'),'number of nanoseconds since the last tick of UTC');
%                                 fits.writeKey(app.fptr,'PACKETNO',packet_no,'Packet No');
%                             fits.writeKey(app.fptr,'BOARDLOC',boardloc,'aperture number (8b) concatenated with the quadrant number (2b) padded with 0s.');
%                             fits.writeKey(app.fptr,'UTC',utc,'Universal Time, in seconds, from the White Rabbit infrastructure');
%                             fits.writeKey(app.fptr,'NANOSEC',nanosec,'number of nanoseconds since the last tick of UTC');
%                        
                            
                            fits.writeKey(app.fptr,'TIMECOMP',timenow,'int32');
%                             if numel(MSind)>0
%                                 fits.writeKey(app.fptr,'MSIND',MSind(1),'int16');
%                             end
             %                 end
                             
                            
                             app.fitsnum=app.fitsnum+1;
                            if app.fitsnum==app.fitsmax+1
                                fits.closeFile(app.fptr);
                                app.fitsnum=1;
                               t1= toc
                               disp(['time per frame (s):' num2str( (1/app.fitsmax)*   t1)])
                         disp(['pack/s:' num2str(app.fitsmax/t1)])

                            end
                             
                        end
             %     end
                        
                        %
                        % %draw pixels
                        % imagesc(reshape(pixels,[8,8]))
                        % drawnow
         %               displayinfoapp(app,acq_mode,packet_no,boardloc,utc,nanosec,timenow);
         %               displayimageapp(app,pixels);
         %               app.Lamp_2.Color=[1.00 0.96 0.93];
                    end%SCIENCE
                end
            