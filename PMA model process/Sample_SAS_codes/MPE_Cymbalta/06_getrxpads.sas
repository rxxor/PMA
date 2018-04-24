

* Get Rx pad data for 2005 ;
rsubmit ;
%prntf(md.dtp_scriptpads_200512,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_scriptpads_200512 ; 
tables brand intervention_type intervention_desc targeted confirmed / missing ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmprxpad_2005 ;
  set md.dtp_scriptpads_200512 (keep=affilid brand intervention_type
                                     channel_notes date1 where=(brand="CYMBALTA")) ;
  format month yymmd7. ;
  month=mdy(month(date1),1,year(date1)) ;
run ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmprxpad_2005 ; tables month ; run ;
endrsubmit ;

* Get Rx pad data for Jan-Mar'06 ;
rsubmit ;
%prntf(aw.dtp_200603,10) ;
endrsubmit ;
rsubmit ;
proc freq data=aw.dtp_200603 (where=(index(tactic_type,"MEDI")>0)); 
tables vendor*tactic_type*brand brand / list missing ; run ;
endrsubmit ;

rsubmit ;
data shankar.tmprxpad_200603 ;
  set aw.dtp_200603 (where=(index(tactic_type,"MEDI")>0 and brand="CYMBALTA"));
  if confirmed="Y" ; 
run ;
%prntf(shankar.tmprxpad_200603,10) ;
endrsubmit ;
rsubmit ;
data shankar.tmprxpad_200603 ;
  set shankar.tmprxpad_200603 ;
  keep affilid brand tactic_type wave_name notes event_date month ;
  if month < mdy(4,1,2006) ;
run ;
endrsubmit ;

* Get Rx pad data for Apr-Dec'06 for MPI ;
rsubmit ;
%prntf(md.dtp_mpi_200612,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_mpi_200612 ; tables brand_name ; run ;
endrsubmit ;
rsubmit ;
data shankar.tmprxpad_200612_mpi ;
  set md.dtp_mpi_200612 (where=(brand_name="CYMBALTA")) ;
  if confirmed="Y" ;
run ;
endrsubmit ; 

* Get Rx pad data for Apr-Dec'06 for TripleL ;
rsubmit ;
%prntf(md.dtp_triplei_200611,10) ;
endrsubmit ;
rsubmit ;
proc freq data=md.dtp_triplei_200611 ; tables brand_name*month / list ; run ;
endrsubmit ;
rsubmit ;
data shankar.tmprxpad_200612_triplei ;
  set md.dtp_triplei_200611 (where=(brand_name="CYMBALTA")) ;
  keep affil_id brand_name tactic_type wave_name notes event_date month ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmprxpad ;
  set shankar.tmprxpad_2005(keep=affilid brand intervention_type
                                     channel_notes date1 month
							  rename=(brand=brand_name intervention_type=tactic_type
							          channel_notes=notes date1=event_date))
      shankar.tmprxpad_200603 (keep=affilid brand tactic_type wave_name notes event_date month
                                rename=(brand=brand_name))
	  shankar.tmprxpad_200612_mpi (keep=affil_id brand_name tactic_type
	                         wave_name notes event_date month rename=(affil_id=affilid))
	  shankar.tmprxpad_200612_triplei (keep=affil_id brand_name tactic_type 
                          wave_name notes event_date month rename=(affil_id=affilid))  ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.tmprxpad,10) ;
endrsubmit ;
rsubmit ;
proc freq data=shankar.tmprxpad; tables month tactic_type wave_name ; run ;
endrsubmit ;

* Nodup by affilid wave_name month ;
rsubmit ;
proc sort data=shankar.tmprxpad out=shankar.tmprxpad nodupkey ;
by affilid wave_name month ;
run ;
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
data shankar.tmprxpad1 ;
  merge shankar.tmprxpad (in=in1)
        shankar.tmpaffsrc (in=in2) ;
  by affilid ;
  if in1 and in2 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_rxpad200612 ;
  set shankar.tmprxpad1 ;
run ;
endrsubmit ;

