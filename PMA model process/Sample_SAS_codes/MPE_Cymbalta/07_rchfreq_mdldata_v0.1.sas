
* Reach/Frequency Summary from modeling data set ;

* Get estimate by qtr and year ;

rsubmit ;
options mprint=on ;
endrsubmit ;

rsubmit ;
%let inds=shankar.pr23_mddmdl200702_v2 ;
%let varlist=nrxcymb trxcymb nrxadp trxadp
             det smp prgfld prgnb prg_lead tel mail rxp vch esmp_mdd esmp_dpnp
             tv_grp_b2 print_grp_b2 ;
endrsubmit ;

rsubmit ;
%macro rpttxt(varlist,inpstr,symb) ;
   %local i finstr word ;
   %let i=1 ;
   %let word=%scan(&varlist.,&i,%str( )) ;
   %do %while (&word. ne ) ;
     %let finstr=%sysfunc(tranwrd(&inpstr.,&symb.,&word.)) ;
     %str(&finstr.) 
      %let i=%eval(&i.+1) ;
     %let word=%scan(&varlist.,&i,%str( )) ;
   %end ;
%mend rpttxt ;
endrsubmit ;

rsubmit ;
proc freq data=&inds. ; tables seg ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmp ;
  set &inds. ;
  if month >= mdy(4,1,2005) ;
  if month <= mdy(6,1,2005) then qtr=1 ;
  else if month <= mdy(9,1,2005) then qtr=2 ;
  else if month <= mdy(12,1,2005) then qtr=3 ;
  else if month <= mdy(3,1,2006) then qtr=4 ;
  else if month <= mdy(6,1,2006) then qtr=5 ;
  else if month <= mdy(9,1,2006) then qtr=6 ;
  else if month <= mdy(12,1,2006) then qtr=7 ;
  else qtr=8 ;
  seg1=compress(seg," ") || compress(pyrmdd2," ") ;
run ;
endrsubmit ;

rsubmit ;
* Summarize by qtr ;
proc summary data=shankar.tmp nway ;
class affilid affilsrc seg1 qtr ;
var &varlist. ;
output out=shankar.tmpqtr (drop=_freq_) sum= ;
run ;
endrsubmit ;
rsubmit ;
* Summarize for a year ;
proc summary data=shankar.tmp (where=(month>=mdy(3,1,2006) and month<=mdy(2,1,2007))) nway ;
class affilid affilsrc seg1 ;
var &varlist. ;
output out=shankar.tmpyr (drop=_freq_) sum= ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpqtryr ;
  set shankar.tmpqtr (in=in1)
      shankar.tmpyr (in=in2) ;
  if in2=1 then qtr=0 ;
run ;
data shankar.tmpqtryr ;
  set shankar.tmpqtryr ;
  * Create reach variables ;
  %rpttxt(&varlist.,%str(?_r=(?>0) ;),?)
run ;
endrsubmit ;

rsubmit ;
proc summary data=shankar.tmpqtryr nway ;
class qtr seg1 ;
var _numeric_ ;
output out=tmpqtryr_sum (rename=(_freq_=mdcount)) sum= ;
run ;
endrsubmit ;
%xlexport(workrem.tmpqtryr_sum,tmpqtryrsum.xls) ;

