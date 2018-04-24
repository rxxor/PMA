
* Get brand program data for 2005 ;
rsubmit ;
%prntf(md.dtp_groupdynamic_200601,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_groupdynamic_200601 ; tables brand ; run ;
proc freq data=md.dtp_groupdynamic_200601 
        (where=(substr(intervention_id,1,5) in ("GLICY","GLICD"))) ; tables brand ; run ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_groupdynamic_200601 (where=(brand="CYMBALTA")); 
tables confirmed*month intervention_desc intervention_topic / list missing ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmpgd_2005 ;
  set md.dtp_groupdynamic_200601 (where=(brand="CYMBALTA"));
  format date1 mmddyy10. ;
  keep menum affilsrc date1 month brand intervention_type intervention_desc intervention_topic
       targeted confirmed ;
  rename menum=affilid intervention_type=tactic_type intervention_desc=wavename intervention_topic=campname ;
  if menum ^= " " ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmpgd_2005 ; tables confirmed ; run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmpgd_2005,10) ;
endrsubmit ;

* Get brand program data for Jan-Mar'06 ;
rsubmit ;
%prntf(aw.dtp_200603,10) ;
endrsubmit ;
rsubmit ;
data chk ;
  set aw.dtp_200603 ;
  if vendor="GroupDynamics" ;
run ;
%prntf(chk,10) ;
endrsubmit ;
rsubmit ;
proc freq data=aw.dtp_200603 ; tables vendor ; run ;
proc freq data=aw.dtp_200603 (where=(vendor="GroupDynamics")) ; tables brand ; run ;
proc freq data=aw.dtp_200603 (where=(vendor="GroupDynamics" and
          substr(wave_id,1,5) in ("GLICY","GLICD"))) ; tables brand ; run ;
endrsubmit ;
rsubmit ;
proc freq data=aw.dtp_200603 (where=(substr(wave_id,1,5) in ("GLICY","GLICD"))) ;
tables vendor*tactic_type  / list missing  ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpgd_200603 ;
  set aw.dtp_200603 (where=(substr(wave_id,1,5) in ("GLICY","GLICD")
                                    and vendor="GroupDynamics")) ;
  keep affilid affilsrc event_date month tactic_type brand wave_name campaign_name 
       targeted confirmed ;
  rename event_date=date1 wave_name=wavename campaign_name=campname ;
  if affilid ^= " " ;
run ;
endrsubmit ;

* Get brand program data for Apr-Sep'06 ;
rsubmit ;
%prntf(md.dtp_groupdynamic_200609,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_groupdynamic_200609 ; tables brand_name ; run ;
proc freq data=md.dtp_groupdynamic_200609 
                (where=(substr(wave_id,1,5) in ("GLICY","GLICD"))); tables brand_name ; run ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_groupdynamic_200609 (where=(substr(wave_id,1,5) in ("GLICY","GLICD") and
                 confirmed="Y")) ;
tables month ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpgd_200609 ;
  set md.dtp_groupdynamic_200609 (where=(substr(wave_id,1,5) in ("GLICY","GLICD"))) ;
  keep affil_id affil_src event_date month tactic_type brand_name wave_name
       campaign_name targeted confirmed ;
  rename affil_id=affilid affil_src=affilsrc event_date=date1 brand_name=brand
         wave_name=wavename campaign_name=campname ;
  if affil_id ^= " " ;
run ;
endrsubmit ;

rsubmit ;
%prntf(md.dtp_groupdynamic_200703,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_groupdynamic_200703 ; tables brand_name ; run ;
proc freq data=md.dtp_groupdynamic_200703 
                (where=(substr(wave_id,1,5) in ("GLICY","GLICD"))); tables brand_name ; run ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_groupdynamic_200703 (where=(substr(wave_id,1,5) in ("GLICY","GLICD") and
                 confirmed="Y")) ;
tables month ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpgd_200703 ;
  set md.dtp_groupdynamic_200703 (where=(substr(wave_id,1,5) in ("GLICY","GLICD"))) ;
  keep affil_id affil_src event_date month tactic_type brand_name wave_name
       campaign_name targeted confirmed ;
  rename affil_id=affilid affil_src=affilsrc event_date=date1 brand_name=brand
         wave_name=wavename campaign_name=campname ;
  if affil_id ^= " " ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpgd_2005 ;
  set shankar.tmpgd_2005 ;
  length brand1 $100. wavename1 $200. campname1 $200. ;
  brand1=brand ;
  wavename1=wavename ;
  campname1=campname ;
run ;
data shankar.tmpgd_200603 ;
  set shankar.tmpgd_200603 ;
  length brand1 $100. wavename1 $200. campname1 $200. ;
  brand1=brand ;
  wavename1=wavename ;
  campname1=campname ;
run ;
data shankar.tmpgd_200609 ;
  set shankar.tmpgd_200609 ;
  length brand1 $100. wavename1 $200. campname1 $200. ;
  brand1=brand ;
  wavename1=wavename ;
  campname1=campname ;
run ;
data shankar.tmpgd_200703 ;
  set shankar.tmpgd_200703 ;
  length brand1 $100. wavename1 $200. campname1 $200. ;
  brand1=brand ;
  wavename1=wavename ;
  campname1=campname ;
run ;
data shankar.tmpgd ;
  set shankar.tmpgd_2005
      shankar.tmpgd_200603
	  shankar.tmpgd_200609
      shankar.tmpgd_200703 ;
run ;
endrsubmit ;

* Get correct affilsrc ;

rsubmit ;
proc sort data=tracker.dec200702m12 (keep=affilid affilsrc) 
          out=shankar.tmpaffilsrc nodupkey ;
by affilid ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpgd1 ;
  merge shankar.tmpgd (in=in1 rename=(affilsrc=affilsrc1))
        shankar.tmpaffilsrc (in=in2 keep=affilid affilsrc rename=(affilsrc=affilsrc2)) ;
  by affilid ;
  if in1 ;
  if affilsrc1 in ("01","02","06","07") then affilsrc=affilsrc1 ;
  else if affilsrc1 in ("1","2","6","7") then affilsrc="0" || affilsrc1 ;
  else affilsrc=affilsrc2 ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.tmpgd1 ; tables affilsrc*affilsrc1*affilsrc2 / list missing ; run ;
endrsubmit ;


rsubmit ;
data shankar.pr23_groupdynamic200703 ;
  set shankar.tmpgd1 ;
run ;
endrsubmit ;

rsubmit ;
proc freq data=shankar.pr23_groupdynamic200703  ; tables month brand1 wavename1 campname1 ; run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.pr23_groupdynamic200703  (where=(confirmed="Y")) ; tables month brand1 wavename1 campname1 ; run ;
endrsubmit ;



