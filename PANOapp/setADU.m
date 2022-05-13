function answer = setADU(comm)
% J. Maire 2019-05-28
% http://www.ontrak.net/ADUSDK/Functions.html 
%
% libfunctions('AduHid')
% 
% Functions in library AduHid:
% 
% ADUCount                     OpenAduDeviceBySerialNumber  
% CloseAdu232                  OpenAduStream                
% CloseAduDevice               OpenAduStreamByProductId     
% CloseAduStream               OpenAduStreamBySerialNumber  
% GetADU                       ReadAdu232                   
% GetAduDeviceList             ReadAduDevice                
% OpenAdu232                   ReadAduStream                
% OpenAdu232ByProductId        ShowAduDeviceList            
% OpenAdu232BySerialNumber     WriteAdu232                  
% OpenAduDevice                WriteAduDevice               
% OpenAduDeviceByProductId     

% 
% Functions in library lib:
% 
% int32 ADUCount(ulong)
% voidPtr CloseAdu232(voidPtr)
% voidPtr CloseAduDevice(voidPtr)
% voidPtr CloseAduStream(voidPtr)
% s_ADU_DEVICE_IDPtr GetADU(s_ADU_DEVICE_IDPtr, uint16, ulong)
% [s_ADU_DEVICE_IDPtr, uint16Ptr, int32Ptr] GetAduDeviceList(s_ADU_DEVICE_IDPtr, uint16, ulong, uint16Ptr, int32Ptr)
% lib.pointer OpenAdu232(ulong)
% lib.pointer OpenAdu232ByProductId(int32, ulong)
% [lib.pointer, cstring] OpenAdu232BySerialNumber(cstring, ulong)
% lib.pointer OpenAduDevice(ulong)
% lib.pointer OpenAduDeviceByProductId(int32, ulong)
% [lib.pointer, cstring] OpenAduDeviceBySerialNumber(cstring, ulong)
% lib.pointer OpenAduStream(ulong)
% lib.pointer OpenAduStreamByProductId(int32, ulong)
% [lib.pointer, cstring] OpenAduStreamBySerialNumber(cstring, ulong)
% [int32, voidPtr, voidPtr, ulongPtr] ReadAdu232(voidPtr, voidPtr, ulong, ulongPtr, ulong)
% [int32, voidPtr, voidPtr, ulongPtr] ReadAduDevice(voidPtr, voidPtr, ulong, ulongPtr, ulong)
% [int32, voidPtr, voidPtr, ulongPtr] ReadAduStream(voidPtr, voidPtr, ulong, ulongPtr, ulong)
% [s_ADU_DEVICE_IDPtr, cstring] ShowAduDeviceList(s_ADU_DEVICE_IDPtr, cstring)
% [int32, voidPtr, voidPtr, ulongPtr] WriteAdu232(voidPtr, voidPtr, ulong, ulongPtr, ulong)
% [int32, voidPtr, voidPtr, ulongPtr] WriteAduDevice(voidPtr, voidPtr, ulong, ulongPtr, ulong)





loadlibrary('AduHid','AduHid.h','alias','lib')

%libfunctionsview lib
libisloaded('lib') 
res = calllib('lib','ADUCount',500)
% testpt = libpointer('int32Ptr');
% testpt2 = libpointer('voidPtr');
% struct.p1 = 4;
% calllib('lib','ShowAduDeviceList',testpt2,'test')
% 

dev = calllib('lib','OpenAduDevice',500);
sta='STA';
% int __stdcall WriteAduDevice(void * hDevice, 
% const void * lpBuffer, 
% unsigned long nNumberOfBytesToWrite, 
% unsigned long * lpNumberOfBytesWritten, 
% unsigned long iTimeout);
%sta = libpointer('voidPtr');
sta = libpointer('cstring'); sta.Value=comm 
sta2 = libpointer('voidPtr');
voidPtr1 = libpointer('voidPtr');
voidPtr2 = libpointer('voidPtr');
ushortPtr = libpointer('uint16Ptr', uint16(0));
ushortPtr2 = libpointer('uint16Ptr', uint16(0));
longPtr = libpointer('int32Ptr', uint32(0));
longPtr2 = libpointer('int32Ptr', uint32(0));
int32='0';

%[s_ADU_DEVICE_IDPtr, uint16Ptr, int32Ptr] GetAduDeviceList(s_ADU_DEVICE_IDPtr, uint16, ulong, uint16Ptr, int32Ptr)
%[sta2, ushortPtr2, longPtr2]= GetAduDeviceList(sta, 16,100, ushortPtr, longPtr)



%sta = libpointer('voidPtr',[int16('sta')]);
nNumberOfBytesToWrite = uint32(16);
lpNumberOfBytesWritten = libpointer('ulongPtr', uint32(0));

%[int32, voidPtr, voidPtr, ulongPtr] WriteAduDevice(voidPtr, voidPtr, ulong, ulongPtr, ulong)

%[int32, voidPtr1, voidPtr2, ulongPtr]
disp(['Com: ' sta.Value])
[aa, bb, cc, dd]= calllib('lib','WriteAduDevice',dev,sta,nNumberOfBytesToWrite,lpNumberOfBytesWritten,uint32(500));
%[res,st] = calllib('lib','ShowAduDeviceList')
disp(['Com: ' sta.Value])
disp(['aa:' num2str(aa) ' dd(lp):' num2str(lpNumberOfBytesWritten.Value) ])
pause(0.001)
dd2=uint16(0);
disp(['Com: ' sta.Value])
[aa2, bb2, cc2, dd2] = calllib('lib','ReadAduDevice', dev,sta,nNumberOfBytesToWrite,lpNumberOfBytesWritten,uint32(500));
disp(['Com: ' sta.Value])
disp(['aa2:' num2str(aa2) ' dd2:' num2str(dd2) ' lp:' num2str(lpNumberOfBytesWritten.Value) ]);
%unloadlibrary lib

answer=sta.Value
end