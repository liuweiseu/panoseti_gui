function utc=getutcdelay(obs)
%dst=str2num(readconfig('dst')); %0 for winter, 1for summer...should be automated
if obs=='LICK'
    utc=hours(tzoffset(datetime('today','TimeZone','America/Los_Angeles'))) ;%-8.+dst;
end