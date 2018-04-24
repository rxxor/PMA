
* Get territory to physician list for nspc ;

rsubmit ;
data shankar.tmpreps (drop=sf) ;
  set shankar.d0710_retier_terrlist (keep=trtry_nm hc sf where=(sf="NSPC")) ;
  numreps=hc ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc ;
  merge shankar.d0710_nspc_tgtlist_0 (in=in1) 
        shankar.d0710_nspc_nattier (in=in2 keep=personid tierf)
        shankar.d071007_nspc_loadlvl_2 (in=in3 keep=personid tiern) ;
  by personid ;
  if in1 and in2 and in3 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc ;
  set shankar.tmpnspc ;
  keep personid affilid affilsrc imsspec llyspec tierf tiern tier_nspc tier_nsab tier_cmhc
       nspc_adp nspc_aps nspc_add
       cymbgrp dpnpgrp zypxgrp stragrp 
	   tadpdec_f tdnpdec_f tapsdec_f tadddec_f
	   cymbdec_f zypxdec_f stradec_f ;
run ;
endrsubmit ;

* Get profile info ;
rsubmit ;
proc sort data=shankar.d0710_nsuniv_algnods (where=(sf in ("NSPC")))
          out=shankar.tmpmd_nspc nodupkey ;
by personid trtry_nm ;
run ;
data shankar.tmpmd_nspc ;
  merge shankar.tmpmd_nspc (in=in1)
        shankar.tmpreps (in=in2 keep=trtry_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
  keep personid trtry_nm frst_nm mdl_nm lst_nm addr1 addr2 city state zip ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpmd_nspc,10) ;
endrsubmit ;

* Get hierarchy info ;
rsubmit ;
proc sort data=shankar.d071004_terrhier_algn_ods (where=(index(dvsn_nm,"NEURO")>0))
          out=shankar.tmphier nodupkey ;
by trtry_nm ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpmd_nspc ;
  merge shankar.tmpmd_nspc (in=in1)
        shankar.tmphier (in=in2 keep=trtry_nm dstrct_nm area_nm rgn_nm) ;
  by trtry_nm ;
  if in1 and in2 ;
run ;
endrsubmit ;

* Flag MDs included in capacity calculation ;
rsubmit ;
data shankar.tmpmd_nspc ;
  merge shankar.tmpmd_nspc (in=in1)
        shankar.d0710_nsuniv_nspc (in=in2 keep=personid trtry_nm) ;
  by personid trtry_nm ;
  if in1 ;
  if in2 then incap=1 ; else incap=0 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc1 shankar.tmpnomatch_nspc ;
  merge shankar.tmpmd_nspc (in=in1)
        shankar.tmpnspc (in=in2) ;
  by personid ;
  if in1 and in2 then output shankar.tmpnspc1 ;
  if in2 and ^in1 then output shankar.tmpnomatch_nspc ;
run ;
endrsubmit ;

* Get historical calls/details ;
/*
rsubmit ;
data shankar.tmpnspc1 ;
  merge shankar.tmpnspc1 (in=in1)
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
data shankar.tmpnspc2 ;
  retain terr_name 
         dist_name area_name reg_name
		 personid affilid affilsrc frst_nm mdl_nm lst_nm llyspec imsspec addr1 addr2 city state zip
		 tierf tiern tier_nspc tier_nsab tier_cmhc
         nspc_adp nspc_aps nspc_add
         cymbgrp dpnpgrp zypxgrp stragrp
         tadpdec_f tdnpdec_f tapsdec_f tadddec_f
         cymbdec_f zypxdec_f stradec_f
          incap ; 
  set shankar.tmpnspc1 (rename=(trtry_nm=terr_name dstrct_nm=dist_name area_nm=area_name
                           rgn_nm=reg_name)) ;
  keep   terr_name 
         dist_name area_name reg_name
		 personid affilid affilsrc frst_nm mdl_nm lst_nm llyspec imsspec addr1 addr2 city state zip
		 tierf tiern tier_nspc tier_nsab tier_cmhc
         nspc_adp nspc_aps nspc_add
         cymbgrp dpnpgrp zypxgrp stragrp
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
data shankar.tmpnspc2 ;
  merge shankar.tmpnspc2 (in=in1)
        shankar.tmpamaoptout (in=in2 keep=personid) ;
  by personid ;
  if in1 ;
  if in2 then amaoptout=1 ; else amaoptout=0 ;
run ;
endrsubmit ;

rsubmit ;
proc sort data=shankar.tmpnspc2 out=shankar.tmpnspc2 ;
by reg_name area_name dist_name terr_name tiern tierf ;
run ;
endrsubmit ;

rsubmit ;
data shankar.d071007_ttplist_nspc_2 ;
  set shankar.tmpnspc2 ;
  if tier_nspc="7" then tier_nspc=" " ;
  if tier_cmhc="7" then tier_cmhc=" " ;
  if tier_nsab="7" then tier_nsab=" " ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.d071007_ttplist_nspc_1,10) ;
endrsubmit ;

* Export to excel ;
rsubmit ;
data nspc ;
  set shankar.d071007_ttplist_nspc_2  ;
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
%xlexport(workrem.nspc,nspc.xls) ;

* Summarize national and terr capacity at territory level ;
rsubmit ;
data shankar.tmpcap ;
  merge shankar.d071007_ttplist_nspc_2 (in=in1)
        shankar.tmpreps (in=in2 keep=trtry_nm hc rename=(trtry_nm=terr_name)) ;
  by terr_name ;
  if in1 and in2 ;
  if incap=1 ;
  r1=(tierf=1) ; r2=(tierf=2) ; r3=(tierf=3) ; r4=(tierf=4) ;
  t1=(tiern=1) ; t2=(tiern=2) ; t3=(tiern=3) ; t4=(tiern=4) ;
run ;
proc summary data=shankar.tmpcap nway ;
class terr_name dist_name area_name reg_name hc ;
var r1 r2 r3 r4 t1 t2 t3 t4 ;
output out=tmpcap1 sum= ;
run ; 
endrsubmit ;
%xlexport(workrem.tmpcap1,tmpcap1.xls) ;

