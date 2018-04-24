
libname wrkbk1 excel 'Y:\Model\MP & E\00_Data\PRx data\Voucher Data by Product Report 2007-Q1.xls' ;

data vchdata1 ;
  set wrkbk1.cymb_prx ;
run ;

libname wrkbk1 clear ;

data shankar.tmpvch ;
 set vchdata1 ;
 length dea_nbr $20. ;
 rename prescriber_me=affilid ;
 dea_nbr=prescriber_dea ;
run ;

rsubmit ;
proc sort data=aw.customer (keep=afltn_id afltn_src_id dea_nbr
                                       where=(dea_nbr ^= " " and afltn_id ^= " "))
          out=shankar.tmpmd nodupkey ;
by dea_nbr afltn_id ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpmd ;
   set shankar.tmpmd ;
   length affilid $10. ;
   affilid=left(afltn_id) ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpvch1 shankar.tmpunmatch ;
  merge shankar.tmpvch (in=in1)
        shankar.tmpmd (in=in2 rename=(afltn_src_id=affilsrc)) ;
  by dea_nbr affilid ;
  if in1 and in2 then output shankar.tmpvch1 ;
  if in1 and ^in2 then output shankar.tmpunmatch ;
run ;
endrsubmit ;

rsubmit ;
proc sort data=shankar.tmpmd out=shankar.tmpmd1 nodupkey ;
by dea_nbr ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpvch2 shankar.tmpunmatch2 ;
  merge shankar.tmpunmatch (in=in1 drop=affilid affilsrc) 
        shankar.tmpmd1 (in=in2 rename=(afltn_src_id=affilsrc)) ;
  by dea_nbr ;
  if in1 and in2 then output shankar.tmpvch2 ;
  if in1 and ^in2 then output shankar.tmpunmatch2 ;
run ;
endrsubmit ;

rsubmit ;
proc sort data=shankar.tmpmd out=shankar.tmpmd2 nodupkey ;
by afltn_id ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpvch3 shankar.tmpunmatch3 ;
  merge shankar.tmpunmatch2 (in=in1 drop=affilsrc) 
        shankar.tmpmd2 (in=in2 rename=(afltn_src_id=affilsrc)) ;
  by affilid ;
  if in1 and in2 then output shankar.tmpvch3 ;
  if in1 and ^in2 then output shankar.tmpunmatch3 ;
run ;
endrsubmit ;

rsubmit ;
%prntf(shankar.tmpunmatch3,100) ;
endrsubmit ;

  
rsubmit ;
data shankar.tmpvch4 ;
  set shankar.tmpvch1
      shankar.tmpvch2 ;
run ;
endrsubmit ;

rsubmit ;
%prntf(shankar.tmpvch4,10) ;
endrsubmit ;

rsubmit ;
data shankar.tmpvch4 ;
  set shankar.tmpvch4 ;
  format month1 yymmd7. ;
  month1=input(year || "-" || month || "-01",yymmdd10.)  ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_vch200703 ;
  set shankar.pr23_vch200612 (keep=affilid affilsrc month1 trx)
      shankar.tmpvch4 (keep=affilid affilsrc month1 trx) ;
  rename trx=prx ;
run ;
endrsubmit ;

rsubmit ;
proc means data=shankar.pr23_vch200703 sum ; class month1 ; var prx ; run ;
endrsubmit ;

