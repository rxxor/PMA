
* Get Psych target list with national tiering ;

* Get Psych MD Universe ;
rsubmit ;
data shankar.tmpuniv ;
  set shankar.d0710_nsuniv_psych ;
run ;
%prntf(shankar.tmpuniv,10) ;
endrsubmit ;

* Get Rx/decile info ;
rsubmit ;
data shankar.tmpadp (drop=tt_: t_:) ;
  set par.rx_adp_200707 (keep=docid tt_adp22-tt_adp24 t_cymb22-t_cymb24) ;
  tadp=sum(0,of tt_adp22-tt_adp24) ;
  tcymb=sum(0,of t_cymb22-t_cymb24) ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdpn (drop=tt_:) ;
  set par.rx_dpn_200707 (keep=docid tt_dpn22-tt_dpn24) ;
  tdnp=sum(0,of tt_dpn22-tt_dpn24) ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpaps (drop=tt_: t_:) ;
  set par.rx_aps_200707 (keep=docid tt_aps22-tt_aps24 t_zypx22-t_zypx24) ;
  taps=sum(0,of tt_aps22-tt_aps24) ;
  tzypx=sum(0,of t_zypx22-t_zypx24) ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpadd (drop=tt_: t_:) ;
  set par.rx_add_200707 (keep=docid tt_add22-tt_add24 t_stra22-t_stra24) ;
  tadd=sum(0,of tt_add22-tt_add24) ;
  tstra=sum(0,of t_stra22-t_stra24) ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdecrx ;
  merge par.decile_200707 (in=in1 keep=docid dec3_adp dec3_cymb dec3_dpn dec3_aps
                                             dec3_zypx dec3_add dec3_stra)
		shankar.tmpadp (in=in2)
		shankar.tmpdpn (in=in3)
		shankar.tmpaps (in=in4)
		shankar.tmpadd (in=in5) ;
  by docid ;
  %zerout ;
  rename dec3_adp=tadpdec_f dec3_cymb=cymbdec_f dec3_dpn=tdnpdec_f
         dec3_aps=tapsdec_f dec3_zypx=zypxdec_f dec3_add=tadddec_f
		 dec3_stra=stradec_f ;
  rename tadp=tadp_f tcymb=tcymb_f tdnp=tdnp_f taps=taps_f tzypx=tzypx_f
         tadd=tadd_f tstra=tstra_f ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdecrx1 shankar.tmpnomatch ;
  merge shankar.tmpdecrx (in=in1)
        par.customer_200707 (in=in2 keep=docid prsn_id afltn_id afltn_src_id) ;
  by docid ;
  length affilid $10. affilsrc $2. ;
  affilid=afltn_id ;
  affilsrc=afltn_src_id ;
  if in1 and in2 then output shankar.tmpdecrx1 ;
  if in1 and ^in2 then output shankar.tmpnomatch ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmpdecrx1 out=shankar.tmpdecrx2 nodupkey ;
by affilid affilsrc ;
run ;
endrsubmit ;
*QC ;
rsubmit ;
proc freq data=shankar.tmpdecrx2 ; tables tadpdec_f tapsdec_f tadddec_f ; run ;
endrsubmit ;
rsubmit ;
proc means data=shankar.tmpdecrx2 sum ;
class zypxdec_f ;
var tzypx_f ;
run ;
endrsubmit ;

* Merge Rx/decile info with universe ;
rsubmit ;
data shankar.tmpuniv1 ;
  merge shankar.tmpuniv (in=in1)
        shankar.tmpdecrx2 (in=in2 drop=docid prsn_id afltn_id afltn_src_id) ;
  by affilid affilsrc ;
  if in1 ;
  %zerout ;
run ;
endrsubmit ;

* Define brand specific segments ;
rsubmit ;
data shankar.tmpuniv2 ;
  set shankar.tmpuniv1 ;
  length cymbgrp $30. dpnpgrp $30. zypxgrp $30. stragrp $30. npagrp $30.
         dpnpgrp1 $30. ;

  * Define Cymbalta Target Groups ;
  if psych_adp="I" then
    do ;
      if tadpdec_f >= 7 then cymbgrp="ADP710" ;
      else if tadpdec_f >= 3 then cymbgrp="ADP36" ;
      else cymbgrp="NonTarget" ;
    end ;
  else
    cymbgrp="NonTarget" ;
  if tier_psych ^in ("1","2","3","4") and acctflag=1 then cymbgrp="NonTarget" ;
  
  * Define DPNP Target Groups ;
  if psych_dpnp = "I" then
     do ;
       if llyspec in ("CN","MN","N","NPR","NS","PYN") then 
          do ;
		    if tdnpdec_f >= 3 then dpnpgrp="NEU-3-10" ;
			else dpnpgrp="NEU-0-2" ;
		  end ;
	   else if llyspec in ("POD") then
          do ;
		    if tdnpdec_f >= 3 then dpnpgrp="POD-3-10" ;
			else dpnpgrp="POD-0-2" ;
		  end ;
	   else
	      do ;
		    if tdnpdec_f >= 3 then dpnpgrp="PAI-3-10" ;
			else dpnpgrp="PAI-0-2" ;
		  end ;
	 end ;
  else
     dpnpgrp="NonTarget" ;
  if tier_psych ^in ("1","2","3","4") then dpnpgrp="NonTarget" ;         

  if psych_dpnp="I" and tier_psych in ("1","2","3","4") then dpnpgrp1="DPNP" ;
  else dpnpgrp1="NonTarget" ;

  * Define Zyprexa Target Groups ;
  if psych_aps="I" then
    do ;
	  if tapsdec_f>=7 and zypxdec_f >= 1 then zypxgrp="APS710_ZYP110" ;
	  else if tapsdec_f>=3 and zypxdec_f >= 1 then zypxgrp="APS36_ZYP110" ;
	  else if tapsdec_f in (1,2) and zypxdec_f >= 2 then zypxgrp="APS12_ZYP210" ;
	  else zypxgrp="NonTarget" ;
	end ;
  else
    zypxgrp="NonTarget" ;
  if tier_psych ^in ("1","2","3","4") and acctflag=1 then zypxgrp="NonTarget" ;

  * Define Strattera Target Groups ;
  if psych_add="I" then
    do ;
      if tadddec_f>=7 then stragrp="ADD710" ;
      else if tadddec_f>=3 then stragrp="ADD36" ;
	  else stragrp="NonTarget" ;
    end ;
  else
    stragrp="NonTarget" ;
  if tier_psych ^in ("1","2","3","4") and acctflag=1 then stragrp="NonTarget" ;  
  
  if llyspec in ("NRP","PHA") and psychflag_c=0 then
     do ;
       cymbgrp="NonTarget" ;
       dpnpgrp="NonTarget" ;
       zypxgrp="NonTarget" ;
       stragrp="NonTarget" ;
     end ;
     
  if llyspec in ("NRP","PHA") and psychflag_c=1 then
    do ;
      if tadpdec_f=0 and tdnpdec_f=0 and tapsdec_f=0 and tadddec_f=0 then npagrp="NPPA_T4" ;
      else npagrp="NonTarget" ;
    end ;  
  else npagrp="NonTarget" ;  

  *Define DPNP focus MDs that are DPNP only MDs ;
  if dpnpgrp1="DPNP" and zypxgrp="NonTarget" and stragrp="NonTarget" and sf="PSYCH-D"
    then dpnpgrp1="DPNP_FOCUS" ;
run ;
endrsubmit ;

* Create permanent dataset ;
rsubmit ;
data shankar.d0710_psych_tgtlist_0 ;
  set shankar.tmpuniv2 ;
run ;
endrsubmit ;

* Check groupings with 0703 groupings ;
rsubmit ;
data qc ;
  merge shankar.d0703_psych_tgtlist_0 (in=in1 rename=(cymbgrp=cymbgrp0 zypxgrp=zypxgrp0
                                                       stragrp=stragrp0))
        shankar.d0710_psych_tgtlist_0 (in=in2) ;
  by personid ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=qc ; tables cymbgrp*cymbgrp0 zypxgrp*zypxgrp0 stragrp*stragrp0 
                     / missing ; run ;
endrsubmit ;
