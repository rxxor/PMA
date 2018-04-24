
* Get direct mail data ;

* 2005 data ;
rsubmit ;
%prntf(md.mail_allbrand_200504b,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.mail_allbrand_200504b ; tables brand ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmpdm_200504 (drop=date) ;
  set md.mail_allbrand_200504b (keep=menum date month brand 
                                wavename campname targeted confirmed where=(brand="CYMBALTA")) ;
  format date1 yymmdd10. ;
  date1=datepart(date) ;
run ;
endrsubmit ;

rsubmit ;
%prntf(md.mail_allbrand_200506,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.mail_allbrand_200506 ; tables brand ; run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdm_200506 ;
  set md.mail_allbrand_200506 (keep=menum date1 month brand 
                                wavename campname targeted confirmed where=(brand="CYMBALTA")) ;
run ;
endrsubmit ;

rsubmit ;
%prntf(md.mail_allbrand_200509,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.mail_allbrand_200509 ; tables brand ; run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdm_200509 ;
  set md.mail_allbrand_200509 (keep=menum date1 month brand 
                                wavename campname targeted confirmed where=(brand="CYMBALTA")) ;
run ;
endrsubmit ;

rsubmit ;
%prntf(md.dtp_mail_200512,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_mail_200512 ; tables brand ; run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdm_200512 ;
  set md.dtp_mail_200512 (keep=menum date1 month brand 
                                intervention_desc intervention_topic
                                targeted confirmed where=(brand="CYMBALTA")) ;
  format date1 yymmdd10. month yymmd7. ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpdm_200512,10) ;
endrsubmit ;

* Stack all 2005 data ;
rsubmit ;
data shankar.tmpdm_2005 ;
  set shankar.tmpdm_200504 
      shankar.tmpdm_200506 
	  shankar.tmpdm_200509 
	  shankar.tmpdm_200512 (rename=(intervention_desc=wavename intervention_topic=campname))
	           ;
run ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmpdm_2005 out=shankar.tmpdm_2005 ;
by menum wavename month descending confirmed ;
run ;
proc sort data=shankar.tmpdm_2005 out=shankar.tmpdm_2005 nodupkey ;
by menum wavename month ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpdm_2005,10) ;
endrsubmit ;

* Get 2006 Jan-Mar data ;
rsubmit ;
proc freq data=aw.dtp_200603 (where=(tactic_type="DM")) ; tables brand ; run ;
endrsubmit ;
rsubmit ;
%prntf(aw.dtp_200603,10) ;
endrsubmit ;
rsubmit ;
data shankar.tmpdm_200603 ;
  set aw.dtp_200603 (where=(tactic_type="DM" and brand="CYMBALTA" and 
                             month < mdy(4,1,2006))) ;
  keep affilid affilsrc event_date month brand wave_name campaign_name targeted confirmed ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpdm_200603,10) ;
endrsubmit ;

* Get MMS data starting April 2006 ;
rsubmit ;
%prntf(md.mms_data_200703,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.mms_data_200703 (where=(tactic_type="DM")) ; tables brand_name ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmpdm_200702 (drop=tactic_type) ;
  set md.mms_data_200703 (keep=affil_id affil_src event_date month brand_name
                            wave_name campaign_name targeted confirmed tactic_type
                            where=(tactic_type="DM" and brand_name="CYMBALTA"
                                and month < mdy(3,1,2007))) ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpdm_200702 ;
  set shankar.tmpdm_200702 ;
  format date1 yymmdd10. ;
  date1=datepart(event_date) ;
  drop event_date ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpdm_2006 ;
  set shankar.tmpdm_200603 (rename=(event_date=date1 wave_name=wavename campaign_name=campname))
      shankar.tmpdm_200702 (rename=(affil_id=affilid affil_src=affilsrc
                       wave_name=wavename campaign_name=campname brand_name=brand)) ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpdm_2006,10) ;
endrsubmit ;
rsubmit ;
proc sort data=shankar.tmpdm_2006 out=shankar.tmpdm_2006 ;
by affilid affilsrc month wavename descending confirmed ;
run ;
proc sort data=shankar.tmpdm_2006 out=shankar.tmpdm_2006 nodupkey ;
by affilid affilsrc month wavename ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpdm  ;
  set shankar.tmpdm_2005 (rename=(menum=affilid))
      shankar.tmpdm_2006 ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpdm,10) ;
endrsubmit ;

* Get affilsrc ;
rsubmit ;
proc sort data=tracker.dec200702m12 (keep=affilid affilsrc) out=shankar.tmpaffsrc  ;
by affilid affilsrc ;
run ;
proc sort data=shankar.tmpaffsrc out=shankar.tmpaffsrc nodupkey ;
by affilid ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpdm1 ;
  merge shankar.tmpdm (in=in1)
        shankar.tmpaffsrc (in=in2 rename=(affilsrc=affilsrc1)) ;
  by affilid ;
  if in1 and in2 ;
  if affilsrc=" " then affilsrc=affilsrc1 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_mail200612 ;
  set shankar.tmpdm1 ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.pr23_mail200612 ; tables month ; run ;
endrsubmit ;



