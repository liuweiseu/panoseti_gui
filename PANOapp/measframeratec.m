function [packet_no timenow]=measframerate(timeout)

timenow=[];packet_no=[];
    port=60001;
foundpac=1;binderror =0;
while ((foundpac ~= 528) && (foundpac ~= 0)) || (binderror == 1)
    foundpac=1;
    try
        
        [packet,SOURCEHOST]  = judp('RECEIVE',port,2048, timeout);
        
    catch ME
        packet=[];
        if (strfind(ME.message,'java.net.BindException'))
        %  updateconsoleapp(app,'No packet received.')
       % wait(1)
            binderror=1
        % [packet,SOURCEHOST]  = judp('RECEIVE',port,2048, 2000);
        else
            binderror=0;
        end
    end
    timenow=now;
    sz=size(packet);
    szp=sz(1);
    
    %     app.Lamp_2.Color='g';
    %    updateconsoleapp(app,['1 Packet of size ' num2str(sz(1)) ' bytes received!'])
    
    %% read data
    foundpac=szp;
    if szp==528 %SCIENCE
        
        %    acq_mode=typecast(uint8(packet(1)),'uint8');
        packet_no=typecast((packet(3:4)),'uint16');
        
    end
    
end
end
                  