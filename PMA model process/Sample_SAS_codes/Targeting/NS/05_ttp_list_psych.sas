
* Get territory to physician list for psych ;

rsubmit ;
data shankar.tmpreps (drop=sf) ;
  set shankar.d0710_retier_terrlist (keep=trtry_nm hc sf where=(sf in ("PSYCH","PSYCH-D"))) ;
  numreps=hc ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych ;
  merge shankar.d0710_psych_tgtlist_0 (in=in1) 
        shankar.d0710_psych_nattier (in=in2 keep=personid tierf)
        shankar.d071007_psych_loadlvl_2 (in=in3 keep=personid tiern1 rename=(tiern1=tiern)) ;
  by personid ;
  if in1 and in2 and in3 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych ;
  set shankar.tmppsych ;
  keep personid affilid affilsrc imsspec llyspec tierf tiern tier_psych tier_nsab tier_cmhc
       psych_adp psych_dpnp psych_aps psych_add
       cymbgrp dpnpgrp dpnpgrp1 zypxgrp stragrp 
	   tadpdec_f tdnpdec_f tapsdec_f tadddec_f
	   cymbdec_f zypxdec_f stradec_f ;
run ;
endrsubmit ;

* Get profile info ;
rsubmit ;
proc sort data=shankar.d0710_nsuniv_algnods (where=(sf in ("PSYCH","PSYCH-D")))
          out=shankar.tmpmd_psych nodupkey ;
by personid trtry_nm ;
run ;
data shankar.tmpmd_psych ;
  merge shankar.tmpmd_psych (in=in1)
        shankar.tmpreps (in=in2 keep=trtry_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
  keep personid trtry_nm sf frst_nm mdl_nm lst_nm addr1 addr2 city state zip ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpmd_psych,10) ;
endrsubmit ;

* Get hierarchy info ;
rsubmit ;
proc sort data=shankar.d071004_terrhier_algn_ods (where=(index(dvsn_nm,"NEURO")>0))
          out=shankar.tmphier nodupkey ;
by trtry_nm ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpmd_psych ;
  merge shankar.tmpmd_psych (in=in1)
        shankar.tmphier (in=in2 keep=trtry_nm dstrct_nm area_nm rgn_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
run ;
endrsubmit ;

* Flag MDs included in capacity calculation ;
rsubmit ;
data shankar.tmpmd_psych ;
  merge shankar.tmpmd_psych (in=in1)
        shankar.d0710_nsuniv_psych (in=in2 keep=personid trtry_nm) ;
  by personid trtry_nm ;
  if in1 ;
  if in2 then incap=1 ; else incap=0 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych1 shankar.tmpnomatch_psych ;
  merge shankar.tmpmd_psych (in=in1)
        shankar.tmppsych (in=in2) ;
  by personid ;
  if dpnpgrp1="DPNP_FOCUS" then incap=0 ;
  if in1 and in2 then output shankar.tmppsych1 ;
  if in2 and ^in1 then output shankar.tmpnomatch_psych ;
run ;
endrsubmit ;

* Get historical calls/details ;
/*
rsubmit ;
data shankar.tmppsych1 ;
  merge shankar.tmppsych1 (in=in1)
        shankar.d070404_nsdet_q107 (in=in2 keep=personid calls_pc calls_nq
                                   det_cymbpc det_zypxpc det_strapc
                                   det_cymbnq) ;
  by personid ;
  if in1 ;
  %zerout ;
run ;
endrsubmit ;
*/


rsubmit ;
data shankar.tmppsych2 ;
  retain sf terr_name 
         dist_name area_name reg_name
		 personid affilid affilsrc frst_nm mdl_nm lst_nm llyspec imsspec addr1 addr2 city state zip
		 tierf tiern tier_psych tier_nsab tier_cmhc
         psych_adp psych_dpnp psych_aps psych_add
         cymbgrp dpnpgrp dpnpgrp1 zypxgrp stragrp
         tadpdec_f tdnpdec_f tapsdec_f tadddec_f
         cymbdec_f zypxdec_f stradec_f
          incap ; 
  set shankar.tmppsych1 (rename=(trtry_nm=terr_name dstrct_nm=dist_name area_nm=area_name
                           rgn_nm=reg_name)) ;
  keep   sf terr_name 
         dist_name area_name reg_name
		 personid affilid affilsrc frst_nm mdl_nm lst_nm llyspec imsspec addr1 addr2 city state zip
		 tierf tiern tier_psych tier_nsab tier_cmhc
         psych_adp psych_dpnp psych_aps psych_add
         cymbgrp dpnpgrp dpnpgrp1 zypxgrp stragrp
         tadpdec_f tdnpdec_f tapsdec_f tadddec_f
         cymbdec_f zypxdec_f stradec_f
          incap ; 
run ;
endrsubmit ;

rsubmit ;
proc sort data=par.customer_200708 (keep=prsn_id ama_opt_out_typ_cd 
                                    where=(ama_opt_out_typ_cd="01")) 
          out=shankar.tmpamaoptout nodupkey ;
by prsn_id ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpamaoptout ;
  set shankar.tmpamaoptout ;
  length personid $11. ;
  rename ama_opt_out_typ_cd=ama_optout ;
  personid=prsn_id ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmppsych2 ;
  merge shankar.tmppsych2 (in=in1)
        shankar.tmpamaoptout (in=in2 keep=personid) ;
  by personid ;
  if in1 ;
  if in2 then amaoptout=1 ; else amaoptout=0 ;
run ;
endrsubmit ;

rsubmit ;
proc sort data=shankar.tmppsych2 out=shankar.tmppsych2 ;
by reg_name area_name dist_name terr_name tiern tierf ;
run ;
endrsubmit ;

rsubmit ;
data shankar.d071007_ttplist_psych_2 ;
  set shankar.tmppsych2 ;
  if tier_psych="7" then tier_psych=" " ;
  if tier_cmhc="7" then tier_cmhc=" " ;
  if tier_nsab="7" then tier_nsab=" " ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.d071007_ttplist_psych_1,10) ;
endrsubmit ;

* Export to excel ;
rsubmit ;
data psych ;
  set shankar.d071007_ttplist_psych_2  ;
  if amaoptout=1 then 
    do ;
	  cymbdec_f=. ;
	  zypxdec_f=. ;
	  stradec_f=. ;
	  cymbgrp=" " ;
	  dpnpgrp=" " ;
      zypxgrp=" " ;
	  stragrp=" " ;
	end ;    
run ;
endrsubmit ;
%xlexport(workrem.psych,psych.xls) ;

* Summarize national and terr capacity at territory level ;
rsubmit ;
data shankar.tmpcap ;
  merge shankar.d071007_ttplist_psych_2 (in=in1)
        shankar.tmpreps (in=in2 keep=trtry_nm hc rename=(trtry_nm=terr_name)) ;
  by terr_name ;
  if in1 and in2 ;
  r1=(tierf=1)*incap ; r2=(tierf=2)*incap ; r3=(tierf=3)*incap ; r4=(tierf=4)*incap ;
  t1=(tiern=1)*incap ; t2=(tiern=2)*incap ; t3=(tiern=3)*incap ; t4=(tiern=4)*incap ;
  fcs=(dpnpgrp1="DPNP_FOCUS") ;
run ;
proc summary data=shankar.tmpcap nway ;
class terr_name dist_name area_name reg_name hc ;
var r1 r2 r3 r4 t1 t2 t3 t4 fcs ;
output out=tmpcap1 sum= ;
run ; 
endrsubmit ;
%xlexport(workrem.tmpcap1,tmpcap1.xls) ;

