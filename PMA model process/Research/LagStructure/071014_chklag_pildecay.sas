
/* Test PIL lag versus Regular Lag */

*-----------PIL Lag test----------------------------;

* Extract a subgroup of MDs ;

* Do this step for MDD ;
rsubmit ;
%let mdl=_mdd_pil ;
endrsubmit ;
%let mdl=_mdd_pil ;

rsubmit ;
data shankar.tmpchkpil ;
  set shankar.pr23_cymbmdl200607 ;
  if specgrp1='PSY' and decgrp=10 and time >= 8 ;
run ;
endrsubmit ;
* End do this step for MDD ;

* Do this step for DPNP ;
rsubmit ;
%let mdl=_dpnp_pil ;
endrsubmit ;
%let mdl=_dpnp_pil ;

rsubmit ;
data shankar.tmpchkpil ;
  set shankar.pr23_cymbdpnpmdl200607 ;
  if seg="NUP10" and time >= 8 ;
run ;
endrsubmit ;
* End do this step for DPNP ;

* Standardize the variables of interest by segment ;
rsubmit ;
proc sort data=shankar.tmpchkpil
          out=shankar.tmpmdl ;
by decgrp specgrp1 mdid time ;
run ;
endrsubmit ;

* Get std dev of independent variables ;
rsubmit ;
proc summary data=shankar.tmpmdl nway ;
class decgrp specgrp1 ;
var detpil2 detpil3 smppil2 smppil3 ;
output out=shankar.tmpstd std(detpil2 detpil3 smppil2 smppil3)=
                detpil2_std detpil3_std smppil2_std smppil3_std ;
run ;    
endrsubmit ;

rsubmit ;
proc stdize data=shankar.tmpmdl out=shankar.tmpmdl method=std ;
by decgrp specgrp1 ;
var detpil2 detpil3 smppil2 smppil3 ;
run ;
endrsubmit ;

* Get the Z matrix for the above variables ;
rsubmit ;
%getzvar_by(inds=shankar.tmpmdl,outds=shankar.tmpz,byvar=decgrp,
      pcvar=%str(detpil2 detpil3 smppil2 smppil3)) ;
endrsubmit ;

*QC ;
rsubmit ;
proc corr data=shankar.tmpz ;
var detpil2 detpil3 smppil2 smppil3 detpil22 detpil32 smppil22 smppil32 ;
run ;
endrsubmit ;
 
* Run mixed model on Z variables ;
rsubmit ;
proc sort data=shankar.tmpz ; by decgrp specgrp1 mdid time ; run ;
proc mixed data=shankar.tmpz method=ml covtest ;
by decgrp specgrp1 ;
model nshrcymb=nshrcymblag detpil22 detpil32 smppil22 smppil32 / solution ddfm=bw ;
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
data shankar.tmpz ;
  merge shankar.tmpz (in=in1)
        shhome.tmpfe1 (in=in2) ;
  by decgrp specgrp1 ;
  nshrnew=nshrcymb-pintercept-pnshrcymblag*nshrcymblag ;
  varnew=pdetpil22*detpil2+pdetpil32*detpil3+
         psmppil22*smppil2+psmppil32*smppil3 ;  
run ;
proc sort data=shankar.tmpz ; by decgrp specgrp1 mdid time ;
endrsubmit ;

*Recalibration with toep(2) ;
rsubmit ;
ods trace on / listing ;
proc mixed data=shankar.tmpz method=ml ;
by decgrp specgrp1 ;
model nshrnew=varnew / solution ddfm=bw noint ;
repeated / type=toep(2) subject=mdid ;
ods output solutionF=shhome.tmpfe2 
           covparms=shhome.tmpcovp2 ;
run ;
ods trace off ;
endrsubmit ;

* Recalibration without toep(2) ;
rsubmit ;
proc mixed data=shankar.tmpz method=ml ;
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
                              rename=(estimate=pvarnew_d))
        shankar.tmpstd (in=in4) ;
  by decgrp specgrp1 ;
  if in1 and in2 and in3 and in4 ;

  pdetpil2_t=pdetpil22*pvarnew_t/detpil2_std ;
  pdetpil3_t=pdetpil32*pvarnew_t/detpil3_std ;
  psmppil2_t=psmppil22*pvarnew_t/smppil2_std ;
  psmppil3_t=psmppil32*pvarnew_t/smppil3_std ;

  pdetpil2_d=pdetpil22*pvarnew_d/detpil2_std ;
  pdetpil3_d=pdetpil32*pvarnew_d/detpil3_std ;
  psmppil2_d=psmppil22*pvarnew_d/smppil2_std ;
  psmppil3_d=psmppil32*pvarnew_d/smppil3_std ;

run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmpmdl nway ;
class decgrp specgrp1 ;
var nrxcymb trxcymb nrxadp trxadp nrxdpnp trxdpnp;
output out=shhome.tmprx sum= ;
run ;
endrsubmit ;

%xlexport(shhome.tmpfe_f&mdl.,tmpfe&mdl..xls) ;
%xlexport(shhome.tmpcov1,tmpcovp1.xls) ;
%xlexport(shhome.tmpcovp2,tmpcovp2.xls) ;
%xlexport(shhome.tmprx,tmprx.xls) ;

