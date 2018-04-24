
%include '~/SASCODES/General/control.sas' ;

* Get data set for building Cymbalta MDD response model ;

* Universe of MDs  ;

data shankar.tmpuniv ;
  set shankar.pr23_mduniv200702 ;
  if seg in ("MDD_PCP_ADP710","MDD_PCP_ADP56","MDD_PCP_ADP34",
             "MDD_PSY_ADP710","MDD_PSY_ADP36") ;
run ;


data shankar.tmpuniv ;
  set shankar.tmpuniv ;
  by affilid affilsrc ;
  retain mdid ;
  if _n_=1 then mdid=0 ;
  mdid+1 ;
run ;

proc freq data=shankar.tmpuniv ; tables seg ; run ;

* Create all combination of MD and month ;

* Create month list from 2005-03 to 2007-02 ;
data shankar.tmpmnth ;
  format month yymmd7. ;
  do time=1 to 24 ;
    if time <= 10 then month=mdy(time+2,1,2005) ;
    else if time <= 22 then month=mdy(time-10,1,2006) ;
    else month=mdy(time-22,1,2007) ;
    output ;
  end ;
run ;

%prntf(shankar.tmpmnth) ;

proc sql ;
create table shankar.tmpmdmnth as
select a.affilid, a.affilsrc, a.mdid, b.time, b.month
from shankar.tmpuniv a, shankar.tmpmnth b ;
quit ;

* Add sas month variable to rx data ;
data shankar.tmprx ;
  set shankar.pr23_xpo200702 ;
  format month1 yymmd7. ;
  month1=input(substr(month,1,4) || "-" || substr(month,5,2) || "-01",yymmdd10.) ;
  if month1 < mdy(3,1,2007) ;
run ;


* Merge Rx and Activity data ;
data shankar.tmprxdetprog ;
  merge shankar.tmpmdmnth (in=in1 keep=affilid affilsrc mdid time month) 
        shankar.tmprx (in=in2 keep=affilid affilsrc month1 nrxcymb trxcymb
                                            nrxadp trxadp rename=(month1=month))
        shankar.pr23_allact200702 (in=in3)
                                     ;
 by affilid affilsrc month ;
 if in1 ;
 %zerout ;
 
 smp1=smp ;
 det1=det ;
 
 if smp > 100 then smp=100 ;
 if det > 10 then det=10 ;
 
 if nrxadp=0 then nshrcymb=0 ;
 else nshrcymb=nrxcymb/nrxadp ;
 
 nrxcymb_adj=nrxcymb-vch ;
 if nrxcymb_adj < 0 then nrxcymb_adj=0 ;
 if nrxadp=0 then nshrcymb_adj=0 ;
 else nshrcymb_adj=nrxcymb_adj/nrxadp ;
 
run ;

* Get weight factors for GRP split ;
proc summary data=shankar.tmprxdetprog (where=(year(month)=2006)) nway ;
class affilid affilsrc ;
var trxadp ;
output out=shankar.tmprxmd_yr sum= ;
run ;
data shankar.tmprxmd_yr ;
  merge shankar.tmprxmd_yr (in=in1)
        shankar.pr23_mduniv200702 (in=in2 keep=affilid affilsrc tadpdec) ;
  by affilid affilsrc ;
  if in1 and in2 ;
run ;
proc summary data=shankar.tmprxmd_yr nway ;
class tadpdec ;
var trxadp ;
output out=shankar.tmprxdec_yr mean= ;
run ;
proc summary data=shankar.tmprxmd_yr nway ;
var trxadp ;
output out=shankar.tmprxnat_yr mean= ;
run ;
data shankar.tmpsplit ;
  merge shankar.tmprxmd_yr (in=in1 keep=affilid affilsrc tadpdec trxadp rename=(trxadp=tadp_md))
        shankar.tmprxdec_yr (in=in2 keep=tadpdec trxadp rename=(trxadp=tadp_dec)) ;
  by tadpdec ;
  if in1 and in2 ;
run ;
data shankar.tmpsplit ;
  if _n_=1 then set shankar.tmprxnat_yr (keep=trxadp rename=(trxadp=tadp_nat)) ;
  set shankar.tmpsplit ;
  idx1=tadp_md/tadp_nat ;
  idx2=tadp_dec/tadp_nat ;
run ;

data shankar.tmprxdetprog ;
  merge shankar.tmprxdetprog (in=in1)
        shankar.tmpsplit (in=in2 keep=affilid affilsrc idx1 idx2) ;
  by affilid affilsrc ;
  if in1 and in2 ;
run ;

* Get monthly GRP data ;
data shankar.tmpgrp ;
  set shankar.pr23_grp200703 ;
  tv_grp_b=tv_grp_b*mnthfactor ;
  print_grp_b=print_grp_b*mnthfactor ;
run ;
proc summary data=shankar.tmpgrp nway ;
class month ;
var tv_grp_b print_grp_b ;
output out=shankar.tmpgrp sum= ;
run ;

data shankar.tmprxdetprog ;
  merge shankar.tmprxdetprog (in=in1)
        shankar.tmpgrp (in=in2) 
        shankar.pr23_web200702 (in=in3 rename=(visits=web)) ;
  by month ;
  if in1 ;
  %zerout ;
  tv_grp_b1=tv_grp_b*idx1 ;
  tv_grp_b2=tv_grp_b*idx2 ;
  print_grp_b1=print_grp_b*idx1 ;
  print_grp_b2=print_grp_b*idx2 ;  
  web1=web*idx1 ;
  web2=web*idx2 ;
run ;

* Get profile data ;
data shankar.tmprxdetprog ;
  merge shankar.tmprxdetprog (in=in1)
        shankar.tmpuniv (in=in2 keep=affilid affilsrc tadpdec cymbdec specgrp seg pyrmdd pyrmdd1 pyrmdd2) ;
  by affilid affilsrc ;
  if in1 and in2 ;
  if index(seg,"DPNP")>0 then prgfld=prg_dpnp ;
  else if index(seg,"MDD_PCP")>0 then prgfld=prg_pcp ;
  else if index(seg,"MDD_PSY")>0 then prgfld=prg_psyc ;
  prgnb=sum(0,prg_nuro,dwa_nb) ;
run ;

data shankar.pr23_mddmdl200702 ;
  set shankar.tmprxdetprog ;
run ;

