
* Combine all activity data into a single data set ;

rsubmit ;
%let thercls=23 ;
%let datestamp=200702 ;
endrsubmit ;

* Field program data ;
rsubmit ;
data tmpfieldprog ;
  set shankar.pr23_fieldprog200702 ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=tmpfieldprog out=tmpfieldprog ; by affilid affilsrc month ; run ;
proc transpose data=tmpfieldprog out=tmpfieldprog_t prefix=prg_ ;
by affilid affilsrc month ;
var numprog ;
id progtype2 ;
run ;
endrsubmit ;
* Telessession data ;
rsubmit ;
proc summary data=shankar.pr23_groupdynamic200703 (where=(confirmed="Y")) nway ;
class affilid affilsrc month ;
output out=shankar.tmpgd (rename=(_freq_=tel)) ;
run ;
endrsubmit ;
* DWA neurobio data ;
rsubmit ;
proc summary data=shankar.pr23_dwa200612 nway ;
class affilid affilsrc month ;
output out=shankar.tmpdwa (rename=(_freq_=dwa_nb)) ;
run ;
endrsubmit ;
* Rx Pad data ;
rsubmit ;
proc summary data=shankar.pr23_rxpad200612 nway ;
class affilid affilsrc month ;
output out=shankar.tmprxp (rename=(_freq_=rxp)) ;
run ;
endrsubmit ;
* Direct mail ;
rsubmit ;
proc sort data=shankar.pr23_mail200612 (keep=affilid affilsrc month 
           where=(affilid ^= " " and affilsrc ^= " " and month>0))
          out=shhome.tmpmail ;
by affilid affilsrc month ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpmail nway ;
by affilid affilsrc month ;
output out=shhome.tmpmail1 (rename=(_freq_=mail)) ;
run ;
endrsubmit ;
rsubmit ;
data shhome.tmpmail1 (drop=affilid) ;
  set shhome.tmpmail1 ;
  length affilid1 $10. ;
  affilid1=affilid ;
run ;
endrsubmit ;
* Vouchers ;
rsubmit ;
proc summary data=shankar.pr23_vch200612 nway ;
class affilid affilsrc month1 ;
var trx ;
output out=shankar.tmpvch (rename=(trx=vch)) sum= ;
run ;
endrsubmit ;
* Esamples ;
rsubmit ;
proc summary data=shankar.pr23_esamp200701 nway ;
class affilid affilsrc month type ;
var qty_ordered ;
output out=tmpesamp sum= ;
run ;
endrsubmit ;
rsubmit ;
proc transpose data=tmpesamp out=tmpesamp_t prefix=esmp_ ;
by affilid affilsrc month ;
var qty_ordered ;
id type ;
run ;
endrsubmit ;

* Combine all the data together ;
rsubmit ;
data shankar.tmpallact ;
  merge shankar.pr23_detsmp200702 (in=in1 keep=affilid affilsrc month det smp)
        shankar.pr_cial_detsmp200702 (in=in2 keep=affilid affilsrc month det smp
		          rename=(det=cialdet smp=cialsmp))
	    tmpfieldprog_t (in=in3 keep=affilid affilsrc month prg_:)
		shankar.tmpgd (in=in4 keep=affilid affilsrc month tel)
		shankar.tmpdwa (in=in5 keep=affilid affilsrc month dwa_nb)
		shankar.tmprxp (in=in6 keep=affilid affilsrc month rxp)
		shhome.tmpmail1 (in=in7 keep=affilid1 affilsrc month mail rename=(affilid1=affilid))
		shankar.tmpvch (in=in8 keep=affilid affilsrc month1 vch rename=(month1=month))
		tmpesamp_t (in=in9 keep=affilid affilsrc month esmp_:) ;
  by affilid affilsrc month ;
  %zerout ;
  flagdet=(in1=1) ;
  flagcial=(in2=1) ;
  flagprog=(in3=1) ;
  flaggd=(in4=1) ;
  flagdwa=(in5=1) ;
  flagrxp=(in6=1) ;
  flagmail=(in7=1) ;
  flagvch=(in8=1) ;
  flagesmp=(in9=1) ;
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpallact nway missing ;
class flagdet flagcial flagprog flaggd flagdwa flagrxp flagmail flagvch flagesmp ;
output out=shankar.tmpchk ;
run ;
endrsubmit ;
%xlexport(shankar.tmpchk,tmpchk.xls) ;

* Create permanent data set ;
rsubmit ;
data shankar.pr&thercls._allact&datestamp. ;
  set shankar.tmpallact ;
run ;
endrsubmit ;

* Update voucher data ;
rsubmit ;
proc summary data=shankar.pr23_vch200703 (where=(month1<mdy(3,1,2007))) nway ;
class affilid affilsrc month1 ;
var prx ;
output out=shankar.tmpvch (rename=(prx=vch)) sum= ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr&thercls._allact&datestamp._v2 ;
  merge shankar.pr&thercls._allact&datestamp. (in=in1 drop=vch)
        shankar.tmpvch (in=in2 keep=affilid affilsrc month1 vch
		                  rename=(month1=month)) ;
  by affilid affilsrc month ;
  %zerout ;
run ;
endrsubmit ;


