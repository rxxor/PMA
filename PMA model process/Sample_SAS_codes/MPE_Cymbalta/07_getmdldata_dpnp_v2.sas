
%include '~/SASCODES/General/control.sas' ;

* Get data set for building Cymbalta DPNP response model ;

* Universe of MDs  ;

data shankar.tmpuniv ;
  set shankar.pr23_mduniv200702_v2 ;
  if index(seg,"DPNP")>0 ;
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

* Create month list from 2005-03 to 2006-12 ;
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
  set shankar.pr2_xpo200702 ;
  format month1 yymmd7. ;
  month1=input(substr(month,1,4) || "-" || substr(month,5,2) || "-01",yymmdd10.) ;
  if month1 < mdy(3,1,2007) ;
run ;
data shankar.tmprxcymb ;
  set shankar.pr23_xpo200702 ;
  format month1 yymmd7. ;
  month1=input(substr(month,1,4) || "-" || substr(month,5,2) || "-01",yymmdd10.) ;
  if month1 < mdy(3,1,2007) ;
run ;

* Merge Rx and Activity data ;
data shankar.tmprxdetprog ;
  merge shankar.tmpmdmnth (in=in1 keep=affilid affilsrc mdid time month) 
        shankar.tmprxcymb (in=in2 keep=affilid affilsrc month1 nrxcymb trxcymb rename=(month1=month))
        shankar.tmprx (in=in3 keep=affilid affilsrc month1 nrxdpnp trxdpnp rename=(month1=month))
        shankar.pr23_allact200702_v2 (in=in4)
                                     ;
 by affilid affilsrc month ;
 if in1 ;
 %zerout ;
 
 smp1=smp ;
 det1=det ;
 
 if smp > 100 then smp=100 ;
 if det > 10 then det=10 ;
 
 if nrxdpnp=0 then nshrcymb=0 ;
 else nshrcymb=nrxcymb/nrxdpnp ;
 
 nrxcymb_adj=nrxcymb-0.5*vch ;
 if nrxcymb_adj < 0 then nrxcymb_adj=0 ;
 if nrxdpnp=0 then nshrcymb_adj=0 ;
 else nshrcymb_adj=nrxcymb_adj/nrxdpnp ;
 
run ;


* Get profile data ;
data shankar.tmprxdetprog ;
  merge shankar.tmprxdetprog (in=in1)
        shankar.tmpuniv (in=in2 keep=affilid affilsrc tdnpdec cymbdec specialty_cd seg pyrdpnp pyrdpnp1 pyrdpnp2) ;
  by affilid affilsrc ;
  if in1 and in2 ;
  prgfld=prg_dpnp ;
run ;

data shankar.pr23_dpnpmdl200702_v2 ;
  set shankar.tmprxdetprog ;
run ;

