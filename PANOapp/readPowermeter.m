function C=readPowermeter
% {'12'} num acq   {' 5/28/2019'}    {' 14:03:29'}    {'4.6132E-11'} Watt
T = readtable('C:\Users\jerome\Documents\panoseti\DATA\Powermeter\sample2.csv',...
    'Delimiter',',','ReadVariableNames',false);

str=cell2mat(T.Var1(numel(T)));
C=strsplit(str,';');

end