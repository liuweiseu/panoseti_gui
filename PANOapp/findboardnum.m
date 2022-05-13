function boardnum=findboardnum(IP)

posdot=strfind(IP,'.');

boardnum=256*str2num(IP(posdot(2)+1:posdot(3)-1)) + str2num(IP(posdot(3)+1:end)) ;

end