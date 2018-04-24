
rsubmit ;
%prntf(shankar.d0710_nsuniv_algnods,10) ;
endrsubmit ;

* Get MDs in NSPC, Psych, Psych-D terrs ;
rsubmit ;
proc sort data=shankar.d0710_nsuniv_algnods (where=(sf in ("NSPC","PSYCH","PSYCH-D")))
          out=shankar.tmp nodupkey ;
by personid ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmp ; tables sf ; run ;
endrsubmit ;

* Check overlap of DPNP MDs with Psych-D MDs ;
rsubmit ;
proc sort data=shankar.d0710_nsuniv_algnods (where=(sf in ("DPNP")))
          out=chk nodupkey ;
by personid ;
run ;
data chk1 ;
  merge chk (in=in1)
        shankar.tmp (in=in2 where=(sf="PSYCH-D")) ;
  by personid ;
  if in1 and in2 ;
run ;
endrsubmit ;

* Get latest laptop tiers ;
rsubmit ;
%macro laptier(sf,dt) ;

proc sort data=md.laptop_pull_&sf._&dt. (where=(tier ^= " ")) out=shankar.tmp&sf. nodupkey ;
by personid tier ;
run ;

proc sort data=shankar.tmp&sf. (keep=personid terrname tier) nodupkey ; 
by personid ; run ;

proc freq data=shankar.tmp&sf. ; tables tier ; run ;

%mend laptier ;
endrsubmit ;

rsubmit ;
%laptier(nspc,20070905) ;
%laptier(psych,20070905) ;
%laptier(nsabso,20070905) ;
%laptier(cmhc,20070905) ;
endrsubmit ;

rsubmit ;
data shankar.tmpuniv ;
  merge shankar.tmp (in=in1 keep=personid affilid affilsrc sf trtry_nm imsspec llyspec)
        shankar.tmppsych (in=in2 keep=personid tier rename=(tier=tier_psych))
		shankar.tmpnspc (in=in3 keep=personid tier rename=(tier=tier_nspc))
        shankar.tmpnsabso (in=in4 keep=personid tier rename=(tier=tier_nsab))
        shankar.tmpcmhc (in=in5 keep=personid tier rename=(tier=tier_cmhc)) ;
  by personid ;
  if in1 ;
  if ^in2 then tier_psych="7" ;
  if ^in3 then tier_nspc="7" ;
  if ^in4 then tier_nsab="7" ;
  if ^in5 then tier_cmhc="7" ;
  if tier_nsab in ("1","2","3") or tier_cmhc in ("1","2","3") then 
    acctflag=1 ; 
  else 
    acctflag=0 ;
  if tier_nspc in ("1","2","3","4") then nspcflag_c=1 ;
    else nspcflag_c=0 ;
  if tier_psych in ("1","2","3","4") then psychflag_c=1 ;
    else psychflag_c=0 ;
run ;
endrsubmit ;

* Get TTP specialty rules for CQ4-07/FQ1-08 ;
rsubmit ;
data shankar.tmpttp ;
  set shankar.ttp_specrules_cq4_fq1_07 ;
  length llyspec $100. ;
  llyspec=lilly_spec ;
run ;
endrsubmit ;

* NSPC Univ ;
rsubmit ;
data shankar.tmpuniv_nspc ;
  merge shankar.tmpuniv (in=in1 where=(sf="NSPC")) 
        shankar.tmpttp (in=in2 keep=llyspec nspc_adp nspc_aps nspc_add) ;
  by llyspec ;
  if in1 ;
  if nspc_adp ^= "I" and nspc_aps ^="I" and nspc_add ^= "I" then delete ;
run ;
endrsubmit ;

* Psych Univ ;
rsubmit ;
data shankar.tmpuniv_psych ;
  merge shankar.tmpuniv (in=in1 where=(sf in ("PSYCH","PSYCH-D")))
        shankar.tmpttp (in=in2 keep=llyspec psych_adp psych_aps psych_add psych_dpnp) ;
  by llyspec ;
  if in1 ;
  if psych_adp ^= "I" and psych_aps ^= "I" and psych_add ^= "I" and psych_dpnp ^= "I"
    then delete ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpuniv_psych1 ;
  set shankar.tmpuniv_psych ;
  if index(trtry_nm,"NASHVILLE EAST PSYCH-D")>0 then trtry_nm="NASHVILLE PSYCH-D" ;
run ;
proc sort data=shankar.tmpuniv_psych1 out=shankar.tmpuniv_psych1 nodupkey ;
by personid ;
run ;
endrsubmit ;

* Create permanent datasets ;
rsubmit ;
data shankar.d0710_nsuniv_psych ;
  set shankar.tmpuniv_psych1 ;
run ;
data shankar.d0710_nsuniv_nspc ;
  set shankar.tmpuniv_nspc ;
run ;
endrsubmit ;
       
