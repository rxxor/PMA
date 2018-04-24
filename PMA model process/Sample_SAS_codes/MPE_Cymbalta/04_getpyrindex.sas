
* Get Payer Index ;

* MDD ;
rsubmit;
data shankar.tmpcymb ;
  set salam.adp_paymain_200702m3 ;
  availrx=adp_rx * p_cymb_mkt_t2csh;
  totrx=adp_rx - (adp_rx * p_cymb_mkt_nodata);
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpcymb nway ;
class affilid affilsrc ;
var availrx totrx  ;
output out=shankar.tmpcymb1 sum= ;
run ; 
endrsubmit ;
rsubmit ;
data shankar.tmpcymb1 ;
  set shankar.tmpcymb1 ;
  if totrx>0 then pyrindex_mdd=availrx/totrx ;
  else pyrindex_mdd=0 ;
run ;
endrsubmit ;

* DPNP ;
rsubmit;
data shankar.tmpcymb_d ;
  set salam.dnp_paymain_200702m3 ;
  availrx=adp_rx * p_cymb_mkt_t2csh;
  totrx=adp_rx - (adp_rx * p_cymb_mkt_nodata);
run ;
endrsubmit ;
rsubmit ;
proc summary data=shankar.tmpcymb_d nway ;
class affilid affilsrc ;
var availrx totrx  ;
output out=shankar.tmpcymb1_d sum= ;
run ; 
endrsubmit ;
rsubmit ;
data shankar.tmpcymb1_d ;
  set shankar.tmpcymb1_d ;
  if totrx>0 then pyrindex_dpnp=availrx/totrx ;
  else pyrindex_dpnp=0 ;
run ;
endrsubmit ;

