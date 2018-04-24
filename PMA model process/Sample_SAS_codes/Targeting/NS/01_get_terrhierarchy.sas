
* Get terr hierarchy from alignment ODS ;

rsubmit ;
data shankar.d071004_terrhier_algn_ods ;
  set algn_ods.pds_trtry_hrchy ;
  if year(datepart(trtry_hrchy_end_dt))=9999 ;
run ;
endrsubmit ;

* Explore ;
rsubmit ;
proc freq data=shankar.d071004_terrhier_algn_ods (where=(index(dvsn_nm,"NEURO")>0)) ;
tables trtry_sls_force_cd / list ;
run ;
endrsubmit ;
