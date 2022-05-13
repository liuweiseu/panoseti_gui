function panocap(filesize, nbfiles, packetsperfile, datadir, prefix, capture_filter_str)
%eval(['[status cmdout]=system(''C:\PROGRA~1\Wireshark\tshark -D '')'])
eval(['[status cmdout]=system(''tshark -D '')'])

interface=3;
% -a 
% filesize:value
% Stop writing to a capture file after it reaches a size of value kilobytes (where a kilobyte is 1000 bytes, not 1024 bytes). If this option is used together with the -b option, Wireshark will stop writing to the current capture file and switch to the next one if filesize is reached.
% files:value
% Stop writing to capture files after value number of files were written.
% packets:value
% Stop writing to a capture file after value number of packets were written.

%-b
% filesize:value
% Stop writing to a capture file after it reaches a size of value kilobytes (where a kilobyte is 1000 bytes, not 1024 bytes). If this option is used together with the -b option, Wireshark will stop writing to the current capture file and switch to the next one if filesize is reached.
% files:value
% Stop writing to capture files after value number of files were written.
% packets:value
% Stop writing to a capture file after value number of packets were written.
% filesize=50000;
% nbfiles=10;
% packetsperfile=10;
%  datadir=[getuserdir filesep 'panoseti' filesep 'DATA' filesep '20200618' filesep]; 
%  prefix='p' ;
%  capture_filter_str='';
  fprintf(['Started capturing from network interface #' int2str(interface) ':\n']);
 eval(['status=system(''sudo tshark -i ' int2str(interface) ...
     ' -a filesize:' int2str(filesize) ' -a files:' int2str(nbfiles) ...
     ' -b packets:'  int2str(packetsperfile) ...
     ' -w ' datadir prefix '.pcapng' ' ' capture_filter_str ''');'])
assert(~status,'Capture using Tshark did not run well. Please make sure your inputs were correct.')
 


