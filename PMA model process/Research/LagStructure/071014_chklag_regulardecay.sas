
/* Test PIL lag versus Regular Lag */

*-----------PIL Lag test----------------------------;

* Extract a subgroup of MDs ;


* Use this step for MDD ;
rsubmit ;
%let mdl=_mdd_reg ;
endrsubmit ;
%let mdl=_mdd_reg ;

rsubmit ;
data shankar.tmpchkpil ;
  set shankar.pr23_cymbmdl200607 ;
  if specgrp1='PSY' and decgrp=10 and time >= 8 ;
run ;
endrsubmit ;
* End the step of using for MDD  ;

* Use this step for DPNP ;
rsubmit ;
%let mdl=_dpnp_reg ;
endrsubmit ;
%let mdl=_dpnp_reg ;

rsubmit ;
data shankar.tmpchkpil ;
  set shankar.pr23_cymbdpnpmdl200607 ;
  if seg="NUP10" and time >= 8 ;
run ;
endrsubmit ;
* End the step of using for DPNP  ;

rsubmit ;
proc sort data=shankar.tmpchkpil
          out=shankar.tmpmdl ;
by decgrp specgrp1 mdid time ;
run ;
endrsubmit ;

* Get the sample residual variable ;
rsubmit ;
%getgsvar_by(inds=shankar.tmpmdl,outds=shankar.tmpres,seg=decgrp,
     xvar=%str(det_3rt smp_3rt)) ;
endrsubmit ;

*QC ;
rsubmit ;
proc corr data=shankar.tmpres ;
var det_3rt smp_3rt det_3rtres smp_3rtres ;
run ;
endrsubmit ;
 
* Run mixed model on Z variables ;
rsubmit ;
proc sort data=shankar.tmpres ; by decgrp specgrp1 mdid time ; run ;
proc mixed data=shankar.tmpres method=ml covtest ;
by decgrp specgrp1 ;
model nshrcymb=nshrcymblag det_3rtres smp_3rtres / solution ddfm=bw ;
repeated / type=toep(2) subject=mdid ;
ods output solutionF=shhome.tmpfe
           covparms=shhome.tmpcov1
           fitstatistics=shhome.tmpfit ;
run ;
endrsubmit ;

rsubmit ;
proc transpose data=shhome.tmpfe out=shhome.tmpfe1 prefix=p ;
by decgrp specgrp1 ;
var estimate ;
id effect ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpres ;
  merge shankar.tmpres (in=in1)
        shhome.tmpfe1 (in=in2) ;
  by decgrp specgrp1 ;
  nshrnew=nshrcymb-pintercept-pnshrcymblag*nshrcymblag ;
  varnew=pdet_3rtres*det_3rt+psmp_3rtres*smp_3rt ;  
run ;
proc sort data=shankar.tmpres ; by decgrp specgrp1 mdid time ;
endrsubmit ;

*Recalibration with toep(2) ;
rsubmit ;
proc mixed data=shankar.tmpres method=ml ;
by decgrp specgrp1 ;
model nshrnew=varnew / solution ddfm=bw noint ;
repeated / type=toep(2) subject=mdid ;
ods output solutionF=shhome.tmpfe2 
           covparms=shhome.tmpcovp2 ;
run ;
endrsubmit ;

* Recalibration without toep(2) ;
rsubmit ;
proc mixed data=shankar.tmpres method=ml ;
by decgrp specgrp1 ;
model nshrnew=varnew / solution ddfm=bw noint ;
ods output solutionF=shhome.tmpfe3 ;
run ;
endrsubmit ;

                    
* Unstandardize the coefficients ;
rsubmit ;
data shhome.tmpfe_f&mdl. ;
  merge shhome.tmpfe1 (in=in1)
        shhome.tmpfe2 (in=in2 keep=decgrp specgrp1 estimate
                               rename=(estimate=pvarnew_t))
        shhome.tmpfe3 (in=in3 keep=decgrp specgrp1 estimate
                              rename=(estimate=pvarnew_d)) ;
  by decgrp specgrp1 ;
  if in1 and in2 and in3  ;

run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmpmdl nway ;
class decgrp specgrp1 ;
var nrxcymb trxcymb nrxadp trxadp ;
output out=shhome.tmprx sum= ;
run ;
endrsubmit ;

%xlexport(shhome.tmpfe_f&mdl.,tmpfe&mdl..xls) ;
%xlexport(shhome.tmpcov1,tmpcovp1.xls) ;
%xlexport(shhome.tmpcovp2,tmpcovp2.xls) ;
%xlexport(shhome.tmprx,tmprx.xls) ;

