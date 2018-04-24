
rsubmit ;
data shankar.tmpcollin ;
  set shankar.pr23_cymbmdl200607 ;
  keep affilid affilsrc time specgrp1 decgrp det_3rt smp_3rt ;
  if specgrp1="PSY" and decgrp=6 ;
run ;
endrsubmit ;

* Explore residual method ;

* Standardize detail and sample variables ;
rsubmit ;
proc stdize data=shankar.tmpcollin out=shankar.tmpcollin1 method=std ;
var det_3rt smp_3rt ;
run ;
endrsubmit ;

*QC ;
rsubmit ;
proc means data=shankar.tmpcollin1 mean std ; 
var det_3rt smp_3rt ;
run ;
endrsubmit ;

* Add a dummy segment ;
rsubmit ;
data shankar.tmpcollin1 ;
  set shankar.tmpcollin1 ;
  segment='ALL' ;
run ;
endrsubmit ;

* Create residual smp_3rt variable ;
rsubmit ;
%getresyvar(inds=shankar.tmpcollin1,outds=shankar.tmpres,xvar=det_3rt,
             yvar=smp_3rt,yvarres=smpres_3rt,seg=segment) ;
endrsubmit ;

*QC ;
rsubmit ;
proc corr data=shankar.tmpres ;
var det_3rt smp_3rt smpres_3rt;
ods output pearsoncorr=shhome.tmpcorrres ;
run ;
endrsubmit ;
%xlexport(shhome.tmpcorrres,tmpcorrres.xls) ;

* Scatter plot of original predictors ;
rsubmit ;
proc gplot data=shankar.tmpcollin1 ;
  plot smp_3rt*det_3rt ;
  plot2 smp_3rt*det_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
quit ;
endrsubmit ;

* Scatter plot of pseudo-predictors ;
rsubmit ;
proc gplot data=shankar.tmpres ;
  plot smpres_3rt*det_3rt ;
  plot2 smpres_3rt*det_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
endrsubmit ;

* Comparison of pseudo-predictors with original predictors ;
rsubmit ;
proc gplot data=shankar.tmpres ;
  plot det_3rt*det_3rt ;
  plot2 det_3rt*det_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
quit ;
endrsubmit ;

rsubmit ;
proc gplot data=shankar.tmpres ;
  plot smpres_3rt*smp_3rt ;
  plot2 smp_3rt*smp_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
quit ;
endrsubmit ;

rsubmit ;
proc greplay igout=work.gseg tc=sashelp.templt
             template=h2 nofs;
   treplay 1:gplot1 2:gplot2 ;
run;
quit;
endrsubmit ;

* Explore SVD method ;

rsubmit ;
%getzvar_by(shankar.tmpcollin1,shankar.tmpsvd,segment,det_3rt smp_3rt) ;
endrsubmit ;

*QC ;
rsubmit ;
proc corr data=shankar.tmpsvd ;
var det_3rt smp_3rt det_3rt2 smp_3rt2 ;
ods output pearsoncorr=shhome.tmpcorrz ;
run ;
endrsubmit ;
%xlexport(shhome.tmpcorrz,tmpcorrz.xls) ;

* Scatter plot of original predictors ;
rsubmit ;
proc gplot data=shankar.tmpsvd ;
  plot smp_3rt*det_3rt ;
  plot2 smp_3rt*det_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
quit ;
endrsubmit ;

* Scatter plot of pseudo-predictors ;
rsubmit ;
proc gplot data=shankar.tmpsvd ;
  plot smp_3rt2*det_3rt2 ;
  plot2 smp_3rt2*det_3rt2 ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
endrsubmit ;

* Comparison of pseudo-predictors with original predictors ;
rsubmit ;
proc gplot data=shankar.tmpsvd ;
  plot det_3rt2*det_3rt ;
  plot2 det_3rt*det_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
quit ;
endrsubmit ;

rsubmit ;
proc gplot data=shankar.tmpsvd ;
  plot smp_3rt2*smp_3rt ;
  plot2 smp_3rt*smp_3rt ;
  symbol v=star color=blue ;
  symbol2 v=none i=r color=red ;
run ;
quit ;
endrsubmit ;


