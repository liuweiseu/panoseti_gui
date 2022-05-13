function quaboconfig=changehold(hold,quaboconfig)

if (hold>=0) && (hold<=15)
[ig,indexhold1]=ismember(['HOLD1 '] ,quaboconfig);
[ig,indexhold2]=ismember(['HOLD2 '] ,quaboconfig);
 quaboconfig(indexhold1,2)={num2str(hold)};
 quaboconfig(indexhold2,2)={num2str(hold)};
       
      disp(['Sending Maroc comm...Hold[ns]: ' num2str(hold)])
      sentacqparams2board(quaboconfig)
            sendconfig2Maroc(quaboconfig)
end
end