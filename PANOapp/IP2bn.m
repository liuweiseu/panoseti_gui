function bn=IP2bn(IP)
IPsplit=strsplit(IP,'.');
bn=256*str2num(cell2mat(IPsplit(3)))+str2num(cell2mat(IPsplit(4)));

end
