
* Get national tiering ;
rsubmit ;
data shankar.tmppsych ;
  set shankar.d0710_psych_tgtlist_0 ;

  * # brands for which MD is target ;
  numtar=(cymbgrp ^= "NonTarget")+(dpnpgrp ^= "NonTarget")+
          (zypxgrp ^= "NonTarget")+(stragrp ^= "NonTarget") ;

  * Define tiers ;

  if psychflag_c=1 or zypxgrp='APS12_ZYP210' then
    do ;
     if cymbgrp="ADP710" or zypxgrp="APS710_ZYP110" then tierf=1 ;
     else if cymbgrp="ADP36" or zypxgrp="APS36_ZYP110" then tierf=2 ;
     else if dpnpgrp1 ^= "NonTarget" then tierf=3 ;
     else tierf=4 ;
	end ;
  else
     tierf=5 ;

  if tierf=1 then callgoal=12 ;
  else if tierf=2 then callgoal=9 ;
  else if tierf=3 then callgoal=6 ;
  else if tierf=4 then callgoal=3 ;
  else callgoal=0 ;

run ;
endrsubmit ;
rsubmit ;
data shankar.d0710_psych_nattier ;
  set shankar.tmppsych ;
  keep personid trtry_nm sf tierf callgoal ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.d0710_psych_nattier ; tables tierf*callgoal / list ; run ;
endrsubmit ;

* Chk with 0703 tier ;
rsubmit ;
data chkpsych ;
  merge shankar.d0710_psych_nattier (in=in1 keep=personid tierf rename=(tierf=t710))
        shankar.d0703_psych_nattier_adj (in=in2 keep=personid tierf1 rename=(tierf1=t703)) ;
  by personid ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=chkpsych ; tables t710*t703 / missing ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmpnspc ;
  set shankar.d0710_nspc_tgtlist_0 ;

  * # brands for which MD is target ;
  numtar=(cymbgrp ^= "NonTarget")+(dpnpgrp ^= "NonTarget")+
          (zypxgrp ^= "NonTarget")+(stragrp ^= "NonTarget") ;

  if nspcflag_c=1 then
     do ;
       if cymbgrp="ADP710" then tierf=1 ;
       else if cymbgrp="ADP56" then tierf=2 ;
       else if stragrp ^= "NonTarget" then tierf=3 ;
       else tierf=4 ;

       if zypxgrp = "APS310_ZYP610" then tierf=1 ;
       if stragrp = "ADD710_PCP" and tierf > 2 then tierf=2 ;
     end ;
   else
     tierf=5 ;

   if tierf=1 then callgoal=12 ;
   else if tierf=2 then callgoal=6 ;
   else if tierf=3 then callgoal=3 ;
   else if tierf=4 then callgoal=3 ;
   else callgoal=0 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.d0710_nspc_nattier ;
  set shankar.tmpnspc ;
  keep personid trtry_nm tierf callgoal ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.d0710_nspc_nattier ; tables tierf*callgoal / list ; run ;
endrsubmit ;

* Chk with 0703 tier ;
rsubmit ;
data chknspc ;
  merge shankar.d0710_nspc_nattier (in=in1 keep=personid tierf rename=(tierf=t710))
        shankar.d0703_nspc_nattier (in=in2 keep=personid tierf rename=(tierf=t703)) ;
  by personid ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=chknspc ; tables t710*t703 / missing ; run ;
endrsubmit ;
