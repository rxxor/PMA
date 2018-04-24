proc mixed data=localc.evista method=reml covtest noclprint;
where bonspec='OBG' and tbondgrp in (6,10);
model evissom = evissomlag detrt 
/ddfm=bw notest solution;
repeated / type=toep(2) subject=mdid;
ods output solutionF=solutionf;
run;

/************************************************************************************/
/************************************************************************************/
/************************************************************************************/
/*STEP0*/

data evista;
set localc.evista;
where bonspec='OBG' and tbondgrp in (6,10);
detrta2c=detrta2; detrta3c=detrta3;
run;

proc stdize data=evista out=tmp method=std ;
var detrta2c detrta3c;
run ;

data evista1;
  set tmp nobs=last ;
  detrta2c=detrta2c/sqrt(last-1) ;
  detrta3c=detrta3c/sqrt(last-1) ;
run ;

/************************************************************************************/
/*STEP1*/

proc iml ;
 use evista1 ;
 read all var {detrta2c detrta3c} into X ;
 close evista1 ;
 use evista1 ;
 read all var {mdid time} into Y ;
 close evista1 ; 
 call svd(P,S,Q,X) ;
 Z=P*t(Q);
 Z1=Y || Z ;
 print Q S ;
 create zmatrix from Z1 [colname={'mdid' 'time' 'z1' 'z2'}];
 append from Z1;
 close zmatrix;
quit ; 

proc sort data=evista1;
by mdid time;
run;

proc sort data=zmatrix;
by mdid time;
run;

data evista1 ;
  merge evista1 (in=in1)
        zmatrix (in=in2) ;
  by mdid time ;
  if in1 and in2 ;
run ;

proc mixed data=evista1 method=reml covtest noclprint;
model evissom = evissomlag z1-z2
/ddfm=bw notest solution outpm=pilt2p(keep=mdid time pred evissom mktnrx);
repeated /type=toep(2) subject=mdid r;
ods output solutionF=tmpfe1;
run;

proc transpose data=tmpfe1 out=tmpfe1t prefix=p ;
var estimate ;
id effect ;
run ;

/*******************************************************************/
/*STEP2*/

data locald.lag_pilt2p;
set tmpfe1;
if effect='evissomlag';
keep estimate;
run;

data evista1;
if _N_=1 then set locald.lag_pilt2p;
set evista1;
run;

data evista1;
set evista1;
evisdif=evissom-estimate*evissomlag;
run;

data evista1;
  if _n_=1 then set tmpfe1t (keep=pz1 pz2); 
  set evista1;
  varnew=detrta2c*pz1+detrta3c*pz2;
run ;

proc mixed data=evista1 method=reml covtest noclprint;
model evisdif = varnew /ddfm=bw notest solution ;
ods output solutionF=tmpfe2;
run;

proc summary data=evista;
var detrta2 detrta3;
output out=tmpstd (rename=(_freq_=nobs)) std = std_z1 std_z2;
run ;

data locald.parm_pilt2p;
  merge tmpfe1t (in=in1)
        tmpfe2 (in=in2 where=(effect='varnew') rename=(estimate=pvarnew)) 
		tmpstd (in=in3) ;
  pz1u=pz1*pvarnew/(std_z1*sqrt(nobs-1)) ;
  pz2u=pz2*pvarnew/(std_z2*sqrt(nobs-1)) ;
  keep pz1u pz2u;
run ;
