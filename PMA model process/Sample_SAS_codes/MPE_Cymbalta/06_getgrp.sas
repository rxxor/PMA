
libname wrkbk 'D:\TempFolder\Temp\Cymbalta\00_Data\070413_cymb_dtc.xls' ;

data grpdata ;
  set wrkbk.grpdata ;
run ;

data shankar.pr23_grp200703 ;
  set grpdata ;
run ;

libname wrkbk clear ;

rsubmit ;
%prntf(shankar.pr23_grp200612) ;
endrsubmit ;

libname wrkbk 'D:\TempFolder\Temp\Cymbalta\00_Data\070503_cymb_web.xls' ;

data webdata ;
 set wrkbk.webdata ;
run ;

data shankar.pr23_web200702 ;
  set webdata ;
run ;

libname wrkbk clear ;

rsubmit ;
%prntf(shankar.pr23_web200702) ;
endrsubmit ;
