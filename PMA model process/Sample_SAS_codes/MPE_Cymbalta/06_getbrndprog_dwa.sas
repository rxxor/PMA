
* Get DWA programs ;
rsubmit ;
%prntf(md.dtp_dwa_200612,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_dwa_200612 ; tables name*month name*title / list ; run ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_dwa_200612 (where=(affilid ^= " ")) ; tables name*month / list ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmpdwa ;
  set md.dtp_dwa_200612 ;
  keep affilid affilsrc name eventdate title month ;
  rename name=brand title=wavename ;
  if index(name,"Cymbalta")>0 and affilid ^= " " ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_dwa200612 ;
  set shankar.tmpdwa ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.pr23_dwa200612 ; tables wavename month ; run ;
endrsubmit ;
