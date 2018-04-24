
* Get list of terrs to be retiered in NSPC ;
rsubmit ;
data shankar.tmpreps (drop=sf) ;
  set shankar.d0710_retier_terrlist (keep=trtry_nm hc sf where=(sf in ("PSYCH","PSYCH-D"))) ;
  numreps=hc ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych ;
  merge shankar.d0710_psych_tgtlist_0 (in=in1)
        shankar.d0710_psych_nattier (in=in2 keep=personid tierf callgoal) ;
  by personid ;
  if in1 and in2 ;
  if tierf in (1,2,3,4) ;
  if dpnpgrp1="DPNP_FOCUS" then delete ;
run ;
endrsubmit ;

* Get historical calls ;
rsubmit ;
data shankar.tmppsych ; 
  merge shankar.tmppsych (in=in1)
        shankar.d070404_nsdet_q107 (in=in2 keep=personid calls_ns calls_ac) ;
  by personid ;
  if in1 ;
  %zerout ;
run ;
endrsubmit ;

* Rank MDs ;
rsubmit ;
data shankar.tmppsych1 ;
  set shankar.tmppsych ;
  portval=0.45*tadpdec_f+0.35*tapsdec_f+0.2*tadddec_f ;
run ;
proc sort data=shankar.tmppsych1 out=shankar.tmppsych1 ;
by trtry_nm tierf descending portval descending tadpdec_f 
          descending tapsdec_f descending tadddec_f 
          descending calls_ns descending calls_ac ;
run ;
data shankar.tmppsych1 ;
  set shankar.tmppsych1 ;
  by trtry_nm tierf descending portval descending tadpdec_f 
          descending tapsdec_f descending tadddec_f 
          descending calls_ns descending calls_ac ;
  retain rnk ;
  if first.trtry_nm then rnk=1 ; else rnk+1 ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.tmppsych1 ; tables portval ; run ;
endrsubmit ;

* QC ranking ;
rsubmit ;
proc summary data=shankar.tmppsych1 nway ;
class cymbgrp zypxgrp stragrp ;
var rnk ;
output out=shankar.tmpchkrnk_psych mean= ;
run ;
endrsubmit ;
%xlexport(shankar.tmpchkrnk_psych,tmpchkrnk_psych.xls) ;

* Get call capacity ;
rsubmit ;
data shankar.tmppsych1 ;
  merge shankar.tmppsych1 (in=in1)
        shankar.tmpreps (in=in2 keep=trtry_nm numreps) ;
  by trtry_nm ;
  if in1 and in2 ;
  terrcap=numreps*408 ;
run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmppsych1 nway ;
class trtry_nm ;
var callgoal terrcap ;
output out=shankar.tmppsych_cap sum(callgoal)=terrcall mean(terrcap)=terrcap ;
run ;
data shankar.tmppsych_cap_oc ;
  set shankar.tmppsych_cap ;
  pctcap=terrcall/terrcap ;
  if terrcall/terrcap > 1 ;
run ;
data shankar.tmppsych_cap_uc ;
  set shankar.tmppsych_cap ;
  pctcap=terrcall/terrcap ;
  if terrcall/terrcap <= 1 ;
run ;
endrsubmit ;
%xlexport(shankar.tmppsych_cap,psych_cap.xls) ;
*----------------Terrs over the capacity----------------------;
rsubmit ;
proc univariate data=shankar.tmppsych_cap_oc ;
var pctcap ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych1_oc ;
  merge shankar.tmppsych1 (in=in1)
        shankar.tmppsych_cap_oc (in=in2 keep=trtry_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_oc ;
  set shankar.tmppsych1_oc (keep=trtry_nm personid tierf rnk terrcap) ;
  buck=1 ; output ;
  buck=2 ; output ;
  buck=3 ; output ;
  buck=4 ; output ;
run ;
data shankar.tmppsych2_oc ;
  set shankar.tmppsych2_oc ;
  if tierf=2 and buck > 3 then delete ;
  if tierf=3 and buck > 2 then delete ;
  if tierf=4 and buck > 1 then delete ;
  if buck=1 or tierf=3 then buck1=1 ; else buck1=0 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_oc ;
  set shankar.tmppsych2_oc ;
  calls=3 ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmppsych2_oc out=shankar.tmppsych2_oc ;
by trtry_nm descending buck1 buck rnk ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_oc ;
  set shankar.tmppsych2_oc ;
  by trtry_nm descending buck1 buck rnk ;
  retain totcalls ;
  if first.trtry_nm then totcalls=calls ;
  else totcalls+calls ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_oc ;
  set shankar.tmppsych2_oc ;
  if buck1=0 and totcalls > terrcap then delete ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmppsych2_oc nway ;
class trtry_nm personid tierf terrcap ;
var calls ;
output out=shankar.tmppsych3_oc sum= ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.tmppsych3_oc ; tables tierf*calls ; run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmppsych3_oc nway ;
class trtry_nm ;
var calls terrcap ;
output out=shankar.tmppsych3_oc_cap sum(calls)=terrcall mean(terrcap)=terrcap ;
run ;
data shankar.tmppsych3_oc_cap ;
  set shankar.tmppsych3_oc_cap ;
  pctcap=terrcall/terrcap ;
run ;
proc univariate data=shankar.tmppsych3_oc_cap ;
var pctcap ;
id trtry_nm ;
run ;
endrsubmit ;

*----------------Terrs under the capacity----------------------;
rsubmit ;
proc univariate data=shankar.tmppsych_cap_uc ;
var pctcap ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych1_uc ;
  merge shankar.tmppsych1 (in=in1)
        shankar.tmppsych_cap_uc (in=in2 keep=trtry_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_uc ;
  set shankar.tmppsych1_uc (keep=trtry_nm personid tierf rnk terrcap) ;
  buck=1 ; output ;
  buck=2 ; output ;
  buck=3 ; output ;
  buck=4 ; output ;
run ;
data shankar.tmppsych2_uc ;
  set shankar.tmppsych2_uc ;
  if tierf=3 and buck > 2 then delete ;
  if tierf=1 and buck <= 4 then buck1=1 ; 
  else if tierf=2 and buck <= 3 then buck1=1 ;
  else if tierf=3 then buck1=1 ;
  else if tierf=4 and buck = 1 then buck1=1 ;
  else buck1=0 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_uc ;
  set shankar.tmppsych2_uc ;
  calls=3 ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmppsych2_uc out=shankar.tmppsych2_uc ;
by trtry_nm descending buck1 buck rnk ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_uc ;
  set shankar.tmppsych2_uc ;
  by trtry_nm descending buck1 buck rnk ;
  retain totcalls ;
  if first.trtry_nm then totcalls=calls ;
  else totcalls+calls ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych2_uc ;
  set shankar.tmppsych2_uc ;
  by trtry_nm descending buck1 buck rnk ;
  if buck1=0 and totcalls > terrcap then delete ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmppsych2_uc nway ;
class trtry_nm personid tierf terrcap ;
var calls ;
output out=shankar.tmppsych3_uc sum= ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.tmppsych3_uc ; tables tierf*calls ; run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmppsych3_uc nway ;
class trtry_nm ;
var calls terrcap ;
output out=shankar.tmppsych3_uc_cap sum(calls)=terrcall mean(terrcap)=terrcap ;
run ;
data shankar.tmppsych3_uc_cap ;
  set shankar.tmppsych3_uc_cap ;
  pctcap=terrcall/terrcap ;
run ;
proc univariate data=shankar.tmppsych3_uc_cap ;
var pctcap ;
id trtry_nm ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych_newcalls ;
  set shankar.tmppsych3_oc (keep=personid trtry_nm calls rename=(calls=calls_n1))
      shankar.tmppsych3_uc (keep=personid trtry_nm calls rename=(calls=calls_n1));
  if calls_n1=12 then tiern1=1 ;
  else if calls_n1=9 then tiern1=2 ;
  else if calls_n1=6 then tiern1=3 ;
  else if calls_n1=3 then tiern1=4 ;
  else tiern1=5 ;
run ;
endrsubmit ;

* Add back the DPNP focus targets at tier 3 with call goal 0 ;
rsubmit ;
data shankar.tmpdpnpfocus ;
  merge shankar.d0710_psych_tgtlist_0 (in=in1 keep=personid trtry_nm dpnpgrp1)
        shankar.d0710_retier_terrlist (in=in2 keep=trtry_nm sf 
		                             where=(sf in ("PSYCH","PSYCH-D"))) ;
  by trtry_nm ;
  if in1 and in2 and dpnpgrp1="DPNP_FOCUS" ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmppsych_newcalls1 ;
  set shankar.tmppsych_newcalls (in=in1 keep=personid calls_n1 tiern1)
      shankar.tmpdpnpfocus (in=in2 keep=personid) ;
  by personid ;
  if in2=1 then
    do ;
	  calls_n1=0 ; tiern1=3 ;
	end ;
run ;
endrsubmit ;

*--- Create permanent data set with terr level retiering--------;
rsubmit ;
data shankar.d071007_psych_loadlvl_2 ;
  set shankar.tmppsych_newcalls1 ;
  keep personid calls_n1 tiern1  ;
run ;
endrsubmit ;

