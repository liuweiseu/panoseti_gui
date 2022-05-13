close all
cpsref=1e2;
calib=1
if calib==1
IP='192.168.3.248'
startqN
[M0dacQ0ref M0dacQ1ref M0dacQ2ref M0dacQ3ref]=findDACref(cpsref,IP)
pauseboard

IP='192.168.3.249'
startqN
[M1dacQ0ref M1dacQ1ref M1dacQ2ref M1dacQ3ref]=findDACref(cpsref,IP)
pauseboard

IP='192.168.3.250'
startqN
[M2dacQ0ref M2dacQ1ref M2dacQ2ref M2dacQ3ref]=findDACref(cpsref,IP)
pauseboard

IP='192.168.3.251'
startqN
[M3dacQ0ref M3dacQ1ref M3dacQ2ref M3dacQ3ref]=findDACref(cpsref,IP)
pauseboard

save('testquickcalib2.mat')
end

load('testquickcalib2.mat')
IP='192.168.3.248'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(M0dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(M0dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(M0dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(M0dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
IP='192.168.3.249'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(M1dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(M1dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(M1dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(M1dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
   IP='192.168.3.250'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(M2dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(M2dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(M2dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(M2dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
 IP='192.168.3.251'
startqN
  quaboconfig(indexdac,1+1)={['0x' dec2hex(M3dacQ0ref)]};
  quaboconfig(indexdac,2+1)={['0x' dec2hex(M3dacQ1ref)]};
  quaboconfig(indexdac,3+1)={['0x' dec2hex(M3dacQ2ref)]};
  quaboconfig(indexdac,4+1)={['0x' dec2hex(M3dacQ3ref)]};
        disp(['Sending final calib Maroc comm...'  ])
        sendconfig2Maroc(quaboconfig)
        
