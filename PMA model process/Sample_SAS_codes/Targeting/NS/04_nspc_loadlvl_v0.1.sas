
* Get list of terrs to be retiered in NSPC ;
rsubmit ;
data shankar.tmpreps (drop=sf) ;
  set shankar.d0710_retier_terrlist (keep=trtry_nm hc sf where=(sf="NSPC")) ;
  numreps=hc ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc ;
   merge shankar.d0710_nspc_tgtlist_0 (in=in1)
         shankar.d0710_nspc_nattier (in=in2 keep=personid tierf callgoal) ;
   by personid ;
   if in1 and in2 ;
   if tierf in (1,2,3,4) ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpnspc ; tables tierf ; run ;
endrsubmit ;

* Get historical calls ;
rsubmit ;
data shankar.tmpnspc ; 
  merge shankar.tmpnspc (in=in1)
        shankar.d070404_nsdet_q107 (in=in2 keep=personid calls_pc) ;
  by personid ;
  if in1 ;
  %zerout ;
run ;
endrsubmit ;

* Rank MDs ;
rsubmit ;
data shankar.tmpnspc1 ;
  set shankar.tmpnspc ;
  portval=0.5*tadpdec_f+0.25*tapsdec_f+0.25*tadddec_f ;
run ;
proc sort data=shankar.tmpnspc1 out=shankar.tmpnspc1 ;
by trtry_nm tierf descending portval descending tadpdec_f 
          descending tapsdec_f descending tadddec_f 
          descending calls_pc ;
run ;
data shankar.tmpnspc1 ;
  set shankar.tmpnspc1 ;
  by trtry_nm tierf descending portval descending tadpdec_f 
          descending tapsdec_f descending tadddec_f 
          descending calls_pc ;
  retain rnk ;
  if first.trtry_nm then rnk=1 ; else rnk+1 ;
run ;
endrsubmit ;

* QC ranking ;
rsubmit ;
proc summary data=shankar.tmpnspc1 nway ;
class cymbgrp zypxgrp stragrp ;
var rnk ;
output out=shankar.tmpchkrnk_nspc mean= ;
run ;
endrsubmit ;
%xlexport(shankar.tmpchkrnk_nspc,tmpchkrnk_nspc.xls) ;

* Get call capacity ;
rsubmit ;
data shankar.tmpnspc1 ;
  merge shankar.tmpnspc1 (in=in1)
        shankar.tmpreps (in=in2 keep=trtry_nm numreps) ;
  by trtry_nm ;
  if in1 and in2 ;
  terrcap=numreps*459 ;
run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmpnspc1 nway ;
class trtry_nm ;
var callgoal terrcap ;
output out=shankar.tmpnspc_cap sum(callgoal)=terrcall mean(terrcap)=terrcap ;
run ;
data shankar.tmpnspc_cap_oc ;
  set shankar.tmpnspc_cap ;
  pctcap=terrcall/terrcap ;
  if terrcall/terrcap > 1 ;
run ;
data shankar.tmpnspc_cap_uc ;
  set shankar.tmpnspc_cap ;
  pctcap=terrcall/terrcap ;
  if terrcall/terrcap <= 1 ;
run ;
endrsubmit ;

*----------------Terrs over the capacity----------------------;
rsubmit ;
proc univariate data=shankar.tmpnspc_cap_oc ;
var pctcap ;
id trtry_nm ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc1_oc ;
  merge shankar.tmpnspc1 (in=in1)
        shankar.tmpnspc_cap_oc (in=in2 keep=trtry_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_oc ;
  set shankar.tmpnspc1_oc (keep=trtry_nm personid stragrp tierf rnk terrcap) ;
  buck=1 ; output ;
  buck=2 ; output ;
  buck=3 ; output ;
run ;
data shankar.tmpnspc2_oc ;
  set shankar.tmpnspc2_oc ;
  if tierf=2 and buck > 2 then delete ;
  if tierf=3 and buck > 1 then delete ;
  if tierf=4 and buck > 1 then delete ;
  if buck=1 or index(stragrp,"PED")>0 then buck1=1 ; else buck1=0 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_oc ;
  set shankar.tmpnspc2_oc ;
  if buck < 3 then calls=3 ;
  else calls=6 ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmpnspc2_oc out=shankar.tmpnspc2_oc ;
by trtry_nm descending buck1 buck rnk ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_oc ;
  set shankar.tmpnspc2_oc ;
  by trtry_nm descending buck1 buck rnk ;
  retain totcalls ;
  if first.trtry_nm then totcalls=calls ;
  else totcalls+calls ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_oc ;
  set shankar.tmpnspc2_oc ;
  by trtry_nm descending buck1 buck rnk ;
  if buck1=0 and totcalls > terrcap then delete ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpnspc2_oc nway ;
class trtry_nm personid tierf terrcap ;
var calls ;
output out=shankar.tmpnspc3_oc sum= ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.tmpnspc3_oc ; tables tierf*calls ; run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmpnspc3_oc nway ;
class trtry_nm ;
var calls terrcap ;
output out=shankar.tmpnspc3_oc_cap sum(calls)=terrcall mean(terrcap)=terrcap ;
run ;
data shankar.tmpnspc3_oc_cap ;
  set shankar.tmpnspc3_oc_cap ;
  pctcap=terrcall/terrcap ;
run ;
endrsubmit ;
rsubmit ;
proc univariate data=shankar.tmpnspc3_oc_cap ;
var pctcap ;
id trtry_nm ;
run ;
endrsubmit ;

*----------------Terrs under the capacity----------------------;
rsubmit ;
proc univariate data=shankar.tmpnspc_cap_uc ;
var pctcap ;
id trtry_nm ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc1_uc ;
  merge shankar.tmpnspc1 (in=in1)
        shankar.tmpnspc_cap_uc (in=in2 keep=trtry_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_uc ;
  set shankar.tmpnspc1_uc (keep=trtry_nm personid stragrp tierf rnk terrcap) ;
  buck=1 ; output ;
  buck=2 ; output ;
  buck=3 ; output ;
run ;
data shankar.tmpnspc2_uc ;
  set shankar.tmpnspc2_uc ;
  if index(stragrp,"PED")>0 and buck > 1 then delete ;
  if tierf=1 and buck <= 3 then buck1=1 ; 
  else if tierf=2 and buck <= 2 then buck1=1 ;
  else if tierf=3 and buck <= 1 then buck1=1 ;
  else if tierf=4 and buck = 1 then buck1=1 ;
  else buck1=0 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_uc ;
  set shankar.tmpnspc2_uc ;
  if buck < 3 then calls=3 ;
  else calls=6 ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmpnspc2_uc out=shankar.tmpnspc2_uc ;
by trtry_nm descending buck1 buck rnk ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_uc ;
  set shankar.tmpnspc2_uc ;
  by trtry_nm descending buck1 buck rnk ;
  retain totcalls ;
  if first.trtry_nm then totcalls=calls ;
  else totcalls+calls ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpnspc2_uc ;
  set shankar.tmpnspc2_uc ;
  by trtry_nm descending buck1 buck rnk ;
  if buck1=0 and totcalls > terrcap then delete ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpnspc2_uc nway ;
class trtry_nm personid tierf terrcap ;
var calls ;
output out=shankar.tmpnspc3_uc sum= ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.tmpnspc3_uc ; tables tierf*calls ; run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmpnspc3_uc nway ;
class trtry_nm ;
var calls terrcap ;
output out=shankar.tmpnspc3_uc_cap sum(calls)=terrcall mean(terrcap)=terrcap ;
run ;
data shankar.tmpnspc3_uc_cap ;
  set shankar.tmpnspc3_uc_cap ;
  pctcap=terrcall/terrcap ;
run ;
proc univariate data=shankar.tmpnspc3_uc_cap ;
var pctcap ;
id trtry_nm ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc_newcalls ;
  set shankar.tmpnspc3_oc (keep=personid trtry_nm tierf calls)
      shankar.tmpnspc3_uc (keep=personid trtry_nm tierf calls);
  rename calls=calls_n ;
  if calls=12 then tiern=1 ;
  else if calls=6 then tiern=2 ;
  else if calls=3 and tierf <= 3 then tiern=3 ;
  else if calls=3 and tierf = 4 then tiern=4 ;
run ;
endrsubmit ;


rsubmit ;
data shankar.d071007_nspc_loadlvl_2 ;
  set shankar.tmpnspc_newcalls ;
  keep personid trtry_nm calls_n tiern ;
run ;
endrsubmit ;

