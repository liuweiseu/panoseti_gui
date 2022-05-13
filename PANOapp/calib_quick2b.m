close all
cpsref=1e2;

calib=0
if calib==1
IP='192.168.0.4'
startqN
[S0dacQ0ref S0dacQ1ref S0dacQ2ref S0dacQ3ref]=findDACref(cpsref,IP)
pauseboard

IP='192.168.0.5'
startqN
[S1dacQ0ref S1dacQ1ref S1dacQ2ref S1dacQ3ref]=findDACref(cpsref,IP)
pauseboard

IP='192.168.0.6'
startqN
[S2dacQ0ref S2dacQ1ref S2dacQ2ref S2dacQ3ref]=findDACref(cpsref,IP)
pauseboard

IP='192.168.0.7'
startqN
[S3dacQ0ref S3dacQ1ref S3dacQ2ref S3dacQ3ref]=findDACref(cpsref,IP)
pauseboard
save('testquickcalibb.mat')
end

load('testquickcalibb.mat')
    
IP='192.168.0.4'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(S0dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(S0dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(S0dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(S0dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
IP='192.168.0.5'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(S1dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(S1dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(S1dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(S1dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
   IP='192.168.0.6'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(S2dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(S2dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(S2dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(S2dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
       IP='192.168.0.7'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(S3dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(S3dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(S3dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(S3dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig) 
        