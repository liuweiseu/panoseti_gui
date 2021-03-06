
%find ima mode
indimamodeall=find(cap.acq_mode~=1);
if numel(indimamodeall) >1
    imamode=cap.acq_mode(indimamodeall(1))
end
disp('****** Packet analysis **************')

ind4=find(cap.boardloc==4);
ind5=find(cap.boardloc==5);
ind6=find(cap.boardloc==6);
ind7=find(cap.boardloc==7);
ind16=find(cap.boardloc==1016);
ind17=find(cap.boardloc==1017);
ind18=find(cap.boardloc==1018);
ind19=find(cap.boardloc==1019);

ind4ima=find(cap.acq_mode(ind4)==imamode);
ind4ph=find(cap.acq_mode(ind4)==1);
ind5ima=find(cap.acq_mode(ind5)==imamode);
ind5ph=find(cap.acq_mode(ind5)==1);
ind6ima=find(cap.acq_mode(ind6)==imamode);
ind6ph=find(cap.acq_mode(ind6)==1);
ind7ima=find(cap.acq_mode(ind7)==imamode);
ind7ph=find(cap.acq_mode(ind7)==1);
ind16ima=find(cap.acq_mode(ind16)==imamode);
ind16ph=find(cap.acq_mode(ind16)==1);
ind17ima=find(cap.acq_mode(ind17)==imamode);
ind17ph=find(cap.acq_mode(ind17)==1);
ind18ima=find(cap.acq_mode(ind18)==imamode);
ind18ph=find(cap.acq_mode(ind18)==1);
ind19ima=find(cap.acq_mode(ind19)==imamode);
ind19ph=find(cap.acq_mode(ind19)==1);

  nanosec4ima=cap.nanosec(ind4ima);
  nanosec4imadiffmed=median(nanosec4ima(2:end)-nanosec4ima(1:end-1),'all');
  disp(['Median Ima#4 nanosec diff [ns]:' num2str(nanosec4imadiffmed)])
pack4ima=cap.packet_no(ind4(ind4ima));
if numel(pack4ima) ~=0
missed4ima=(pack4ima(end)-pack4ima(1)+1)-numel(pack4ima);
disp(['Missed packets board4 ima:' num2str(missed4ima) ' (' num2str(numel(pack4ima)) ' fr.)'])
disp(['Missed packets board4 ima:' num2str(100*missed4ima/(numel(pack4ima)+(missed4ima))) ' %'])

else
    disp('No board#4 ima packets')
end
pack4ph=cap.packet_no(ind4(ind4ph));
if numel(pack4ph) ~=0
    missed4ph=(pack4ph(end)-pack4ph(1)+1)-numel(pack4ph);
disp(['Missed packets board4 ph:' num2str(missed4ph) ' (' num2str(numel(pack4ph)) ' fr.)'])
else
    disp('No board#4 ph packets')
end

  nanosec5ima=cap.nanosec(ind5ima);
  nanosec5imadiffmed=median(nanosec5ima(2:end)-nanosec5ima(1:end-1),'all');
  disp(['Median Ima#5 nanosec diff [ns]:' num2str(nanosec5imadiffmed)])
pack5ima=cap.packet_no(ind5(ind5ima));
if numel(pack5ima) ~=0
missed5ima=(pack5ima(end)-pack5ima(1)+1)-numel(pack5ima);
disp(['Missed packets board5 ima:' num2str(missed5ima) ' (' num2str(numel(pack5ima)) ' fr.)'])
disp(['Missed packets board5 ima:' num2str(100*missed5ima/(numel(pack5ima)+(missed5ima))) ' %'])

else
    disp('No board#5 ima packets')
end
pack5ph=cap.packet_no(ind5(ind5ph));
if numel(pack5ph) ~=0
missed5ph=(pack5ph(end)-pack5ph(1)+1)-numel(pack5ph);
disp(['Missed packets board5 ph:' num2str(missed5ph) ' (' num2str(numel(pack5ph)) ' fr.)'])
else
    disp('No board#5 ph packets')
end

pack6ima=cap.packet_no(ind6(ind6ima));
if numel(pack6ima) ~=0
missed6ima=(pack6ima(end)-pack6ima(1)+1)-numel(pack6ima);
disp(['Missed packets board6 ima:' num2str(missed6ima) ' (' num2str(numel(pack6ima)) ' fr.)'])
disp(['Missed packets board6 ima:' num2str(100*missed6ima/(numel(pack6ima)+(missed6ima))) ' %'])

else
    disp('No board#6 ima packets')
end
pack6ph=cap.packet_no(ind6(ind6ph));
if numel(pack6ph) ~=0
missed6ph=(pack6ph(end)-pack6ph(1)+1)-numel(pack6ph);
disp(['Missed packets board6 ph:' num2str(missed6ph) ' (' num2str(numel(pack6ph)) ' fr.)'])

else
    disp('No board#6 ph packets')
end

pack7ima=cap.packet_no(ind7(ind7ima));
if numel(pack7ima) ~=0
missed7ima=(pack7ima(end)-pack7ima(1)+1)-numel(pack7ima);
disp(['Missed packets board7 ima:' num2str(missed7ima) ' (' num2str(numel(pack7ima)) ' fr.)'])
disp(['Missed packets board7 ima:' num2str(100*missed7ima/(numel(pack7ima)+(missed7ima))) ' %'])

else
    disp('No board#7 ima packets')
end
pack7ph=cap.packet_no(ind7(ind7ph));
if numel(pack7ph) ~=0
missed7ph=(pack7ph(end)-pack7ph(1)+1)-numel(pack7ph);
disp(['Missed packets board7 ph:' num2str(missed7ph) ' (' num2str(numel(pack7ph)) ' fr.)'])
else
    disp('No board#7 ph packets')
end


pack16ima=cap.packet_no(ind16(ind16ima));
if numel(pack16ima) ~=0
missed16ima=(pack16ima(end)-pack16ima(1)+1)-numel(pack16ima);
disp(['Missed packets board16 ima:' num2str(missed16ima) ' (' num2str(numel(pack16ima)) ' fr.)'])
disp(['Missed packets board16 ima:' num2str(100*missed16ima/(numel(pack16ima)+(missed16ima))) ' %'])
else
    disp('No board#16 ima packets')
end
pack16ph=cap.packet_no(ind16(ind16ph));
if numel(pack16ph) ~=0
missed16ph=(pack16ph(end)-pack16ph(1)+1)-numel(pack16ph);
disp(['Missed packets board16 ph:' num2str(missed16ph) ' (' num2str(numel(pack16ph)) ' fr.)'])
else
    disp('No board#16 ph packets')
end


pack17ima=cap.packet_no(ind17(ind17ima));
if numel(pack17ima) ~=0
missed17ima=(pack17ima(end)-pack17ima(1)+1)-numel(pack17ima);
disp(['Missed packets board17 ima:' num2str(missed17ima) ' (' num2str(numel(pack17ima)) ' fr.)'])
disp(['Missed packets board17 ima:' num2str(100*missed17ima/(numel(pack17ima)+(missed17ima))) ' %'])
else
    disp('No board#17 ima packets')
end
pack17ph=cap.packet_no(ind17(ind17ph));
if numel(pack17ph) ~=0
missed17ph=(pack17ph(end)-pack17ph(1)+1)-numel(pack17ph);
disp(['Missed packets board17 ph:' num2str(missed17ph) ' (' num2str(numel(pack17ph)) ' fr.)'])
else
    disp('No board#17 ph packets')
end


pack18ima=cap.packet_no(ind18(ind18ima));
if numel(pack18ima) ~=0
missed18ima=(pack18ima(end)-pack18ima(1)+1)-numel(pack18ima);
disp(['Missed packets board18 ima:' num2str(missed18ima) ' (' num2str(numel(pack18ima)) ' fr.)'])
disp(['Missed packets board18 ima:' num2str(100*missed18ima/(numel(pack18ima)+(missed18ima))) ' %'])
else
    disp('No board#18 ima packets')
end
pack18ph=cap.packet_no(ind18(ind18ph));
if numel(pack18ph) ~=0
missed18ph=(pack18ph(end)-pack18ph(1)+1)-numel(pack18ph);
disp(['Missed packets board18 ph:' num2str(missed18ph) ' (' num2str(numel(pack18ph)) ' fr.)'])
else
    disp('No board#18 ph packets')
end

pack19ima=cap.packet_no(ind19(ind19ima));
if numel(pack19ima) ~=0
missed19ima=(pack19ima(end)-pack19ima(1)+1)-numel(pack19ima);
disp(['Missed packets board19 ima:' num2str(missed19ima) ' (' num2str(numel(pack19ima)) ' fr.)'])
disp(['Missed packets board19 ima:' num2str(100*missed19ima/(numel(pack19ima)+(missed19ima))) ' %'])
else
    disp('No board#19 ima packets')
end
pack19ph=cap.packet_no(ind19(ind19ph));
if numel(pack19ph) ~=0
missed19ph=(pack19ph(end)-pack19ph(1)+1)-numel(pack19ph);
disp(['Missed packets board19 ph:' num2str(missed19ph) ' (' num2str(numel(pack19ph)) ' fr.)'])
else
    disp('No board#19 ph packets')
end

disp(['Total pack:' num2str(size(cap.boardloc,2))])

ti=datetime(capture(1).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles');
tf=datetime(capture(end).frametime_epoch,'ConvertFrom','posixtime','format','yyyy/MM/dd hh:mm:ss.SSSSSS','TimeZone','America/Los_Angeles');
timetot=etime(datevec(tf),datevec(ti));
disp(['Tot time [s]:' num2str(timetot)])
disp(['frame rate [fr/s]:' num2str(size(cap.boardloc,2)/timetot)])


%%(to do take exact first and last fr time rather than timetot:)
disp(['Ima4 rate [fr/s]:' num2str(numel(ind4ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind4ima)/timetot)))])
disp(['Ima5 rate [fr/s]:' num2str(numel(ind5ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind5ima)/timetot)))])
disp(['Ima6 rate [fr/s]:' num2str(numel(ind6ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind6ima)/timetot)))])
disp(['Ima7 rate [fr/s]:' num2str(numel(ind7ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind7ima)/timetot)))])
disp(['Ima16 rate [fr/s]:' num2str(numel(ind16ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind16ima)/timetot)))])
disp(['Ima17 rate [fr/s]:' num2str(numel(ind17ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind17ima)/timetot)))])
disp(['Ima18 rate [fr/s]:' num2str(numel(ind18ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind18ima)/timetot)))])
disp(['Ima19 rate [fr/s]:' num2str(numel(ind19ima)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind19ima)/timetot)))])

disp(['ph4 rate [fr/s]:' num2str(numel(ind4ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind4ph)/timetot)))])
disp(['ph5 rate [fr/s]:' num2str(numel(ind5ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind5ph)/timetot)))])
disp(['ph6 rate [fr/s]:' num2str(numel(ind6ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind6ph)/timetot)))])
disp(['ph7 rate [fr/s]:' num2str(numel(ind7ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind7ph)/timetot)))])
disp(['ph16 rate [fr/s]:' num2str(numel(ind16ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind16ph)/timetot)))])
disp(['ph17 rate [fr/s]:' num2str(numel(ind17ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind17ph)/timetot)))])
disp(['ph18 rate [fr/s]:' num2str(numel(ind18ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind18ph)/timetot)))])
disp(['ph19 rate [fr/s]:' num2str(numel(ind19ph)/timetot) ' Expos. time[ms]:' num2str(1000*(1/(numel(ind19ph)/timetot)))])


%%%test transition:
testtransition=0;
if testtransition==1
indB4=find(cap2.boardloc==4);
indB5=find(cap2.boardloc==5);
indB6=find(cap2.boardloc==6);
indB7=find(cap2.boardloc==7);
indB16=find(cap2.boardloc==1016);
indB17=find(cap2.boardloc==1017);
indB18=find(cap2.boardloc==1018);
indB19=find(cap2.boardloc==1019);

indB4ima=find(cap2.acq_mode(indB4)==3);
indB4ph=find(cap2.acq_mode(indB4)==1);
indB5ima=find(cap2.acq_mode(indB5)==3);
indB5ph=find(cap2.acq_mode(indB5)==1);
indB6ima=find(cap2.acq_mode(indB6)==3);
indB6ph=find(cap2.acq_mode(indB6)==1);
indB7ima=find(cap2.acq_mode(indB7)==3);
indB7ph=find(cap2.acq_mode(indB7)==1);
indB16ima=find(cap2.acq_mode(indB16)==3);
indB16ph=find(cap2.acq_mode(indB16)==1);
indB17ima=find(cap2.acq_mode(indB17)==3);
indB17ph=find(cap2.acq_mode(indB17)==1);
indB18ima=find(cap2.acq_mode(indB18)==3);
indB18ph=find(cap2.acq_mode(indB18)==1);
indB19ima=find(cap2.acq_mode(indB19)==3);
indB19ph=find(cap2.acq_mode(indB19)==1);

packB4ima=cap2.packet_no(indB4(indB4ima));
missed4ima=(packB4ima(end)-packB4ima(1)+1)-numel(packB4ima);
disp(['Missed packBets board4 ima:' num2str(missed4ima) ' (' num2str(numel(packB4ima)) ' fr.)'])
packB4ph=cap2.packet_no(indB4(indB4ph));
missed4ph=(packB4ph(end)-packB4ph(1)+1)-numel(packB4ph);
disp(['Missed packBets board4 ph:' num2str(missed4ph) ' (' num2str(numel(packB4ph)) ' fr.)'])

packB5ima=cap2.packet_no(indB5(indB5ima));
missed5ima=(packB5ima(end)-packB5ima(1)+1)-numel(packB5ima);
disp(['Missed packBets board5 ima:' num2str(missed5ima) ' (' num2str(numel(packB5ima)) ' fr.)'])
packB5ph=cap2.packet_no(indB5(indB5ph));
missed5ph=(packB5ph(end)-packB5ph(1)+1)-numel(packB5ph);
disp(['Missed packBets board5 ph:' num2str(missed5ph) ' (' num2str(numel(packB5ph)) ' fr.)'])

packB6ima=cap2.packet_no(indB6(indB6ima));
missed6ima=(packB6ima(end)-packB6ima(1)+1)-numel(packB6ima);
disp(['Missed packBets board6 ima:' num2str(missed6ima) ' (' num2str(numel(packB6ima)) ' fr.)'])
packB6ph=cap2.packet_no(indB6(indB6ph));
missed6ph=(packB6ph(end)-packB6ph(1)+1)-numel(packB6ph);
disp(['Missed packBets board6 ph:' num2str(missed6ph) ' (' num2str(numel(packB6ph)) ' fr.)'])

packB7ima=cap2.packet_no(indB7(indB7ima));
missed7ima=(packB7ima(end)-packB7ima(1)+1)-numel(packB7ima);
disp(['Missed packBets board7 ima:' num2str(missed7ima) ' (' num2str(numel(packB7ima)) ' fr.)'])
packB7ph=cap2.packet_no(indB7(indB7ph));
missed7ph=(packB7ph(end)-packB7ph(1)+1)-numel(packB7ph);
disp(['Missed packBets board7 ph:' num2str(missed7ph) ' (' num2str(numel(packB7ph)) ' fr.)'])



packB16ima=cap2.packet_no(indB16(indB16ima));
missed16ima=(packB16ima(end)-packB16ima(1)+1)-numel(packB16ima);
disp(['Missed packBets board16 ima:' num2str(missed16ima) ' (' num2str(numel(packB16ima)) ' fr.)'])
packB16ph=cap2.packet_no(indB16(indB16ph));
missed16ph=(packB16ph(end)-packB16ph(1)+1)-numel(packB16ph);
disp(['Missed packBets board16 ph:' num2str(missed16ph) ' (' num2str(numel(packB16ph)) ' fr.)'])

packB17ima=cap2.packet_no(indB17(indB17ima));
missed17ima=(packB17ima(end)-packB17ima(1)+1)-numel(packB17ima);
disp(['Missed packBets board17 ima:' num2str(missed17ima) ' (' num2str(numel(packB17ima)) ' fr.)'])
packB17ph=cap2.packet_no(indB17(indB17ph));
missed17ph=(packB17ph(end)-packB17ph(1)+1)-numel(packB17ph);
disp(['Missed packBets board17 ph:' num2str(missed17ph) ' (' num2str(numel(packB17ph)) ' fr.)'])

packB18ima=cap2.packet_no(indB18(indB18ima));
missed18ima=(packB18ima(end)-packB18ima(1)+1)-numel(packB18ima);
disp(['Missed packBets board18 ima:' num2str(missed18ima) ' (' num2str(numel(packB18ima)) ' fr.)'])
packB18ph=cap2.packet_no(indB18(indB18ph));
missed18ph=(packB18ph(end)-packB18ph(1)+1)-numel(packB18ph);
disp(['Missed packBets board18 ph:' num2str(missed18ph) ' (' num2str(numel(packB18ph)) ' fr.)'])


packB19ima=cap2.packet_no(indB19(indB19ima));
missed19ima=(packB19ima(end)-packB19ima(1)+1)-numel(packB19ima);
disp(['Missed packBets board19 ima:' num2str(missed19ima) ' (' num2str(numel(packB19ima)) ' fr.)'])
packB19ph=cap2.packet_no(indB19(indB19ph));
missed19ph=(packB19ph(end)-packB19ph(1)+1)-numel(packB19ph);
disp(['Missed packBets board19 ph:' num2str(missed19ph) ' (' num2str(numel(packB19ph)) ' fr.)'])

disp('*** Transition ***')
disp(['missed transition pack Ima 4:' num2str(packB4ima(1) - pack4ima(end) -1)])
disp(['missed transition pack Ima 5:' num2str(packB5ima(1) - pack5ima(end) -1)])
disp(['missed transition pack Ima 6:' num2str(packB6ima(1) - pack6ima(end) -1)])
disp(['missed transition pack Ima 7:' num2str(packB7ima(1) - pack7ima(end) -1)])
disp(['missed transition pack Ima 16:' num2str(packB16ima(1) - pack16ima(end) -1)])
disp(['missed transition pack Ima 17:' num2str(packB17ima(1) - pack17ima(end) -1)])
disp(['missed transition pack Ima 18:' num2str(packB18ima(1) - pack18ima(end) -1)])
disp(['missed transition pack Ima 19:' num2str(packB19ima(1) - pack19ima(end) -1)])
disp(['missed transition pack ph 4:' num2str(packB4ph(1) - pack4ph(end) -1)])
disp(['missed transition pack ph 5:' num2str(packB5ph(1) - pack5ph(end) -1)])
disp(['missed transition pack ph 6:' num2str(packB6ph(1) - pack6ph(end) -1)])
disp(['missed transition pack ph 7:' num2str(packB7ph(1) - pack7ph(end) -1)])
disp(['missed transition pack ph 16:' num2str(packB16ph(1) - pack16ph(end) -1)])
disp(['missed transition pack ph 17:' num2str(packB17ph(1) - pack17ph(end) -1)])
disp(['missed pack ph 18:' num2str(packB18ph(1) - pack18ph(end) -1)])
disp(['missed pack ph 19:' num2str(packB19ph(1) - pack19ph(end) -1)])
end