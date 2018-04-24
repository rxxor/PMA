
%include '~/SASCODES/General/control.sas' ;

* Get Details and Sample data for Cymbalta ;

%let thercls=23 ;
%let datestamp=200702 ;

* Detail product codes ;
%let prddet='203982','203989','204327' ;
 
 * Sample product codes ;
 %let prdsmp='61127','61132'  ;

* Get Detail data ;
data shankar.tmpdet ;
  set md.raw_details_2005q1
      md.raw_details_2005q2
      md.raw_details_2005q3
      md.raw_details_2005q4 
      md.raw_details_2006q1
      md.raw_details_2006q2
      md.raw_details_2006q3
      md.raw_details_2006q4 
      md.raw_details_2007q1;
  format month yymmd7. ;
  if calltype in ('DO','DS','LD','LL') and 
  prodgrp in (&prddet.) ;
  month=mdy(month(eventdate),1,year(eventdate)) ;
  if month >= mdy(3,1,2005) and month <= mdy(2,1,2007) ;
run ;

proc summary data=shankar.tmpdet nway ;
class prodgrp month ;
output out=shankar.tmpdetgrp ;
run ;

* Get Sample data ;
data shankar.tmpsmp ;
  set md.raw_samples_2005q1_new
      md.raw_samples_2005q2_new
      md.raw_samples_2005q3_new
      md.raw_samples_2005q4_new 
      md.raw_samples_2006q1_new
      md.raw_samples_2006q2_new
      md.raw_samples_2006q3_new 
      md.raw_samples_2006q4_new 
      md.raw_samples_2007q1_new
      ;
  format month yymmd7. ;
  if pharmprd in (&prdsmp.) ;
  month=mdy(month(eventdate),1,year(eventdate)) ;
  if month >= mdy(3,1,2005) and month <= mdy(2,1,2007) ;
run ;

proc summary data=shankar.tmpsmp nway ;
class pharmprd month ;
var tot_samples ;
output out=shankar.tmpsmpgrp sum= ;
run ;
  
* Aggregate to personid-month level ;
proc summary data=shankar.tmpdet nway ;
class personid month ;
output out=shankar.tmpdet1 (rename=(_freq_=det)) ;
run ;
proc summary data=shankar.tmpsmp nway ;
class personid month ;
var tot_samples ;
output out=shankar.tmpsmp1 (rename=(tot_samples=smp)) sum= ;
run ;

* Merge detail and sample data ;
data shankar.tmpdetsmp ;
  merge shankar.tmpdet1 (in=in1 keep=personid month det)
        shankar.tmpsmp1 (in=in2 keep=personid month smp) ;
  by personid month ;
  %zerout ;
run ;


/* Create data set with unique personid-affilid-affilsrc combinations */
proc sort data=md.bridge_file (where=(affilid ^= " " and affilsrc ^= " ")) 
          out=shankar.tmpbridge nodupkey ; 
by personid affilid affilsrc ; 
run ;
proc sort data=shankar.tmpbridge nodupkey ; 
by personid ; 
run ;

* Get affilid-affilsrc ;
data shankar.tmpdetsmp ;
  merge shankar.tmpdetsmp (in=in1)
        shankar.tmpbridge (in=in2 keep=affilid affilsrc personid) ;
  by personid ;
  if in1  ;
  if ^in2 then
     do ;
       affilid="0000000000" ; affilsrc="00" ;
     end ;
run ;

* Aggregate to affilid-affilsrc-month level ;
proc summary data=shankar.tmpdetsmp nway ;
class affilid affilsrc month ;
var det smp ;
output out=shankar.tmpdetsmp1 sum= ;
run ;

data shankar.pr&thercls._detsmp&datestamp. ;
  set shankar.tmpdetsmp1 ;
run ;


  
