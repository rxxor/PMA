
* Get MDs in ADP psych/PCP quota pool for Q2'07 ;
rsubmit ;
proc freq data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="23")) ;
tables respcd ;
run ;
endrsubmit ;

* Psych quota pool MDs ;
rsubmit ;
proc sort data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="23" and 
                            respcd in ("DI","DN")))
		  out=shankar.tmpqta_psy nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.ttp_specrules_cq3_fq4_07 ; tables psych_adp*psychd_adp / missing ; run ;
endrsubmit ;
rsubmit ;
data shankar.tmpqta_psy ;
  merge shankar.tmpqta_psy (in=in1)
        shankar.ttp_specrules_cq3_fq4_07 (in=in2 keep=specialty_cd psych_adp) ;
  by specialty_cd ;
  if in1 ;
  if psych_adp="I" ;
run ;
endrsubmit ;

* PCP quota pool MDs;
rsubmit ;
proc sort data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="23" and 
                            respcd in ("DA")))
		  out=shankar.tmpqta_nspc nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpqta_nspc ;
  merge shankar.tmpqta_nspc (in=in1)
        shankar.ttp_specrules_cq3_fq4_07 (in=in2 keep=specialty_cd nspc_adp) ;
  by specialty_cd ;
  if in1 ;
  if nspc_adp ^= "E" ;
run ;
endrsubmit ;

* Get MDs in DPNP quota pool for Q2'07 ;
rsubmit ;
proc summary data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="2")) nway ;
class respcd specialty_cd ;
output out=tmpspecchk ;
run ;
endrsubmit ;
%xlexport(workrem.tmpspecchk,tmpspecchk.xls) ;

rsubmit ;
proc sort data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="2" and 
                            respcd in ("DI","DL")))
		  out=shankar.tmpqta_psydpnp nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.ttp_specrules_cq3_fq4_07 ; tables psych_dpnp*dpnp_focus / missing ; run ;
endrsubmit ;
* Get TTP spec rules for CQ3-07 ;
rsubmit ;
data shankar.tmpqta_psydpnp ;
  merge shankar.tmpqta_psydpnp (in=in1)
        shankar.ttp_specrules_cq3_fq4_07 (in=in2 keep=specialty_cd dpnp_focus) ;
  by specialty_cd ;
  if in1 ;
  if dpnp_focus="I" ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpqta_psydpnp ; tables specialty_cd ; run ;
endrsubmit ;

* Get MDs in Endo quota pool for Q2'07 ;
rsubmit ;
proc sort data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="2" and 
                            respcd in ("EI")))
		  out=shankar.tmpqta_endodpnp nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
* Get TTP spec rules for CQ3-07 ;
rsubmit ;
data shankar.tmpqta_endodpnp ;
  merge shankar.tmpqta_endodpnp (in=in1)
        shankar.ttp_specrules_cq3_fq4_07 (in=in2 keep=specialty_cd diabf_dpnp) ;
  by specialty_cd ;
  if in1 ;
  if diabf_dpnp="I" ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpqta_endodpnp ; tables specialty_cd ; run ;
endrsubmit ;

* Get Rheums in ADP PCP quota pool ;
rsubmit ;
proc sort data=qta.ttp_profile_07q2 (where=(therapeuticclass_cd="23" and 
                            specialty_cd in ("RHU")))
		   out=shankar.tmpqta_rhudpnp nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpqta_rhudpnp ; tables respcd ; run ;
endrsubmit ;

* Get Apr07 Laptop tier for Psych, NSPC ;
rsubmit ;
%macro laptier(sf,dt) ;
proc sort data=md.laptop_pull_&sf._&dt. (where=(tier in ("1","2","3","4"))) 
                    out=shankar.tmp&sf. nodupkey ;
by affilid affilsrc tier ;
run ;

proc sort data=shankar.tmp&sf. (keep=affilid affilsrc tier) nodupkey ; 
by affilid affilsrc ; run ;

proc freq data=shankar.tmp&sf. ; tables tier ; run ;

%mend laptier ;
endrsubmit ;

rsubmit ;
%laptier(psych,20070402) ;
%laptier(nspc,20070402) ;
endrsubmit ;

* Get details in the 6 month period (Nov06-Apr07) for Cymbalta ;
rsubmit ;
data shankar.tmpdet ;
  set md.raw_details_2006q4 
      md.raw_details_2007q1
	  md.raw_details_2007q2 ;
  if prodgrp in ("203982","203989","204327") and calltype in ("DO","DS","LD","LL") ;
  if eventdate >= mdy(11,1,2006) and eventdate < mdy(5,1,2007) ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpdet nway ;
class personid ;
output out=shankar.tmpdet1 (rename=(_freq_=det)) ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=md.bridge_file (where=(affilid ^= " " and affilsrc ^= " "))
          out=shankar.tmpbridge nodupkey ;
by personid ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdet1 ;
  merge shankar.tmpdet1 (in=in1)
        shankar.tmpbridge (in=in2 keep=personid affilid affilsrc) ;
  by personid ;
  if in1 and in2 ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpdet1 nway ;
class affilid affilsrc ;
var det ;
output out=shankar.tmpdet2 sum= ;
run ;
endrsubmit ;

* Create the universe of MDs ;
rsubmit ;
data shankar.tmpmduniv ;
  merge shankar.tmpqta_psy (in=in1 keep=affilid affilsrc specialty_cd)
        shankar.tmpqta_nspc (in=in2 keep=affilid affilsrc specialty_cd)
		shankar.tmpqta_psydpnp (in=in3 keep=affilid affilsrc specialty_cd)
		shankar.tmpqta_endodpnp (in=in4 keep=affilid affilsrc specialty_cd) ;
  by affilid affilsrc specialty_cd ;
  if in1=1 then qta_psy=1 ; else qta_psy=0 ;
  if in2=1 then qta_nspc=1 ; else qta_nspc=0 ;
  if in3=1 then qta_psydpnp=1 ; else qta_psydpnp=0 ;
  if in4=1 then qta_endodpnp=1 ; else qta_endodpnp=0 ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmpmduniv out=shankar.tmpmduniv nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpmduniv ; 
tables qta_psy*qta_nspc*qta_psydpnp*qta_endodpnp / list missing ;
run ;
endrsubmit ;

* Get MD info - Decile, Laptop tier, Rhuem flag, 6 month cymb details ;
rsubmit ;
data shankar.tmpmduniv1 ;
  merge shankar.tmpmduniv (in=in1)
        tracker.dec200703m12 (in=in2 keep=affilid affilsrc tadpdec tdnpdec cymbdec)
		shankar.tmppsych (in=in3 keep=affilid affilsrc tier rename=(tier=tier_psych))
		shankar.tmpnspc (in=in4 keep=affilid affilsrc tier rename=(tier=tier_nspc))
		shankar.tmpqta_rhudpnp (in=in5 keep=affilid affilsrc)
		shankar.tmpdet2 (in=in6 keep=affilid affilsrc det rename=(det=det0704m6)) ;
  by affilid affilsrc ;
  if in1 ;
  %zerout ;
  if in5 then rhuflag=1 ; else rhuflag=0 ;
run ;
endrsubmit ;

* Define MDD vs DPNP targets ;
rsubmit ;
proc format;
  value $spec
 	"CN","MN","N","NP","NA","NPR","NS","NCC","NSP","PYN" = "NEU"		/*NEUs*/
	"AN","APM","CCA" = "ANE"                   /* Anesthesiology*/
	"MPM","PM","PMD","PMP","PMR","SCI" = "PAI"		/*Pain*/
	"POD" = "POD" /* Pods*/
	"RHU" = "RHU" /*Rheums*/
	other = "OTH"
  ;
run;
endrsubmit ;
rsubmit ;
data shankar.tmpmduniv2 ;
  set shankar.tmpmduniv1 ;
  length tgt $20. ;
  if affilsrc="90" then delete ;
  if qta_psydpnp=1 and (tier_psych in ("1","2","3","4") or
                        tier_nspc in ("1","2","3","4") or
						det0704m6 >= 3) then tgt="DPNP_NS" ;
  else if qta_endodpnp=1 and tdnpdec>=3 then tgt="DPNP_ENDO" ;
  else if rhuflag=1 and (tadpdec>=3 or tdnpdec>=3) then tgt="DPNP_RHU" ;
  else if qta_nspc=1 and tier_nspc in ("1","2","3","4") and tadpdec < 3 and
          tdnpdec>=7 then tgt="DPNP_PC" ;
  else if qta_psy=1 and tadpdec>=3 then tgt="PSY" ;
  else if qta_nspc=1 and tadpdec>=3 then tgt="PCP" ;
  else tgt="NonTarget" ;
run ;
endrsubmit ; 
rsubmit ;
proc freq data=shankar.tmpmduniv2 ; tables tgt ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmpmduniv3 ;
  set shankar.tmpmduniv2 ;
  length tgt1 $20. ;
  if tgt="DPNP_NS" then tgt1="DPNP_NS_" || trim(put(specialty_cd,$spec.)) ;
  else tgt1=tgt ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpmduniv3 ; tables tgt1 ; run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_mduniv200702_v2 ;
  set shankar.tmpmduniv3 ;
run ;
endrsubmit ;

*--------------Create some summaries---------------------;
rsubmit ;
proc summary data=shankar.pr23_mduniv200702_v2 nway ;
class tgt1 ;
output out=tmpsum1 ;
run ;
endrsubmit ;
%xlexport(workrem.tmpsum1,tmpsum1.xls) ;
rsubmit ;
data chk_dpnp_ns ;
  set shankar.pr23_mduniv200702_v2 ;
  if tier_psych in ("1","2","3","4") or tier_nspc in ("1","2","3","4") then tierflag=1 ;
  else tierflag=0 ;
  if det0704m6 >= 3 then detflag=1 ; else detflag=0 ;
  if index(tgt1,"DPNP_NS")>0 ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=chk_dpnp_ns nway ;
class tgt1 tierflag detflag ;
output out=tmpsum2 ;
run ;
endrsubmit ;
%xlexport(workrem.tmpsum2,tmpsum2.xls) ;

rsubmit ;
proc freq data=chk_dpnp_ns (where=(tierflag=1)) ;
tables tier_psych*tier_nspc / missing ;
run ;
endrsubmit ;
*----------------------------------------------------------- ;

*--------------Add additional fields---------------------------;

rsubmit ;
data shankar.tmpuniv ; 
  set shankar.pr23_mduniv200702_v2 ;
  length seg $30. ;
  if tgt1="PCP" then 
    do ;
	  if tadpdec>=7 then seg="PCP_710" ;
	  else if tadpdec>=5 then seg="PCP_56" ;
	  else if tadpdec>=3 then seg="PCP_34" ;
	  else seg="PCP_OT" ;
	end ;
  else if tgt1="PSY" then
    do ;
	  if tadpdec>=7 then seg="PSY_710" ;
	  else if tadpdec>=3 then seg="PSY_36" ;
	  else seg="PSY_OT" ;
	end ;
  else if tgt1="DPNP_NS_NEU" then
    do ;
	  if tdnpdec>=7 then seg="DPNP_NS_NEU_710" ;
	  else seg="DPNP_NS_NEU_OT" ;
	end ;
  else
    seg=tgt1 ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpuniv ; tables tgt1*seg / list ; run ;
endrsubmit ;

* Get payer index ;
* Get payer index ;
rsubmit ;
data shankar.tmpmduniv1 ;
   merge shankar.tmpuniv (in=in1)
         shankar.pr23_pyrindex200702 (in=in2) ;
   by affilid affilsrc ;
   if in1 ;
   %zerout ;
run ;
endrsubmit ;

* Create payer index buckets ;
rsubmit ;
proc summary data=shankar.tmpmduniv1 (where=(tadpdec>=3)) ;
var pyrmdd ;
output out=shankar.tmpq_mdd q1=pyrmdd_q1 median=pyrmdd_q2 q3=pyrmdd_q3 ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpmduniv1  (where=(index(seg,"DPNP")>0)) ;
var pyrdpnp ;
output out=shankar.tmpq_dpnp q1=pyrdpnp_q1 median=pyrdpnp_q2 q3=pyrdpnp_q3 ;
run ;
endrsubmit ;
rsubmit ;
proc univariate data=shankar.tmpmduniv1  (where=(tadpdec>=3)) ;
var pyrmdd ;
output out=shankar.tmpp_mdd pctlpts=33 67 pctlpre=pyrmdd_ pctlname=p33 p67  ;
run ;
endrsubmit ;
rsubmit ;
proc univariate data=shankar.tmpmduniv1  (where=(index(seg,"DPNP")>0)) ;
var pyrdpnp ;
output out=shankar.tmpp_dpnp pctlpts=33 67 pctlpre=pyrdpnp_ pctlname=p33 p67 ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpmduniv1 (drop=pyrmdd_q1 pyrmdd_q2 pyrmdd_q3) ;
  if _n_=1 then set shankar.tmpq_mdd (keep=pyrmdd_q1 pyrmdd_q2 pyrmdd_q3) ;
  set shankar.tmpmduniv1 ;
  if pyrmdd > pyrmdd_q3 then pyrmdd1="Q4" ;
  else if pyrmdd > pyrmdd_q2 then pyrmdd1="Q3" ;
  else if pyrmdd > pyrmdd_q1 then pyrmdd1="Q2" ;
  else pyrmdd1="Q1" ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpmduniv2 (drop=pyrdpnp_q1 pyrdpnp_q2 pyrdpnp_q3) ;
  if _n_=1 then set shankar.tmpq_dpnp(keep=pyrdpnp_q1 pyrdpnp_q2 pyrdpnp_q3) ;
  set shankar.tmpmduniv1 ;
  if pyrdpnp > pyrdpnp_q3 then pyrdpnp1="Q4" ;
  else if pyrdpnp > pyrdpnp_q2 then pyrdpnp1="Q3" ;
  else if pyrdpnp > pyrdpnp_q1 then pyrdpnp1="Q2" ;
  else pyrdpnp1="Q1" ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpmduniv2 (drop=pyrmdd_p33 pyrmdd_p67) ;
  if _n_=1 then set shankar.tmpp_mdd (keep=pyrmdd_p33 pyrmdd_p67) ;
  set shankar.tmpmduniv2 ;
  if pyrmdd > pyrmdd_p67 then pyrmdd2="Q3" ;
  else if pyrmdd > pyrmdd_p33 then pyrmdd2="Q2" ;
  else pyrmdd2="Q1" ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpmduniv2 (drop=pyrdpnp_p33 pyrdpnp_p67) ;
  if _n_=1 then set shankar.tmpp_dpnp(keep=pyrdpnp_p33 pyrdpnp_p67) ;
  set shankar.tmpmduniv2 ;
  if pyrdpnp > pyrdpnp_p67 then pyrdpnp2="Q3" ;
  else if pyrdpnp > pyrdpnp_p33 then pyrdpnp2="Q2" ;
  else pyrdpnp2="Q1" ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_mduniv200702_v2 ;
  set shankar.tmpmduniv2 ;
run ;
endrsubmit ;
