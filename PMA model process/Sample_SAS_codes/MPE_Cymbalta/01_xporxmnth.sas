
%include '~/SASCODES/General/control.sas' ;

%macro trx_year(tbl_month=, stmonth=, endmonth=, theracd=);
PROC SQL;
   CONNECT TO ORACLE (user=&gmuserid. password=&gmpasswd. PATH="prd_87");
   CREATE TABLE  shankar.tmpxpo AS 
   SELECT * 
   FROM CONNECTION TO ORACLE
   ( SELECT IMS_AFFILIATION_ID                 affilid
           ,IMS_AFFILIATION_SOURCE_ID          affilsrc
           ,IMS_PRODUCT_ID                     prod 
           ,sum(NEW_RX)				 nrx
	   ,sum(TOTAL_RX)			 trx	
	   ,IMS_THERAPEUTIC_CLASS_ID		 mkt
	   ,to_char(RX_FILLED_DATE,'YYYYMM')   month
     FROM IMS_XPONENT_RX_&TBL_MONTH
     WHERE IMS_THERAPEUTIC_CLASS_ID in (&theracd) 
	   and TO_CHAR(RX_FILLED_DATE, 'YYYYMM') >= (&stmonth)
           and TO_CHAR(RX_FILLED_DATE, 'YYYYMM') <= (&endmonth)
	   AND TOTAL_RX > 0  
     GROUP BY 
       IMS_AFFILIATION_ID
      ,IMS_AFFILIATION_SOURCE_ID	   
      ,IMS_THERAPEUTIC_CLASS_ID
      ,IMS_PRODUCT_ID
      ,to_char(RX_FILLED_DATE,'YYYYMM')   
     ORDER BY 
       IMS_AFFILIATION_ID
      ,IMS_AFFILIATION_SOURCE_ID
      ,IMS_THERAPEUTIC_CLASS_ID
      ,IMS_PRODUCT_ID 	
      ,to_char(RX_FILLED_DATE,'YYYYMM')  
    );
   DISCONNECT FROM ORACLE;
   QUIT;
RUN;
%mend trx_year;

%trx_year(tbl_month=200702, stmonth=200503, endmonth=200702, theracd = 23);

data shankar.tmpprd1 ;
  set shankar.tmpxpo ;
  if prod=30 ;
run ;

proc summary data=shankar.tmpxpo (where=(prod in (30,5,25,28))) nway ;
class affilid affilsrc month ;
var nrx trx ;
output out=shankar.tmpsubmkt1 sum= ;
run ;

proc summary data=shankar.tmpxpo nway ;
class affilid affilsrc month ;
var nrx trx ;
output out=shankar.tmpmkt1 sum= ;
run ;

data shankar.pr23_xpo200702 ;
  merge shankar.tmpprd1 (in=in1 keep=affilid affilsrc month nrx trx rename=(nrx=nrxcymb trx=trxcymb))
        shankar.tmpsubmkt1 (in=in2 keep=affilid affilsrc month nrx trx rename=(nrx=nrxsubmkt trx=trxsubmkt))
        shankar.tmpmkt1 (in=in3 keep=affilid affilsrc month nrx trx rename=(nrx=nrxadp trx=trxadp)) ;
  by affilid affilsrc month ;
  %zerout ;
run ;

* QC ;
proc summary data=shankar.pr23_xpo200702 nway missing ;
class month ;
var _numeric_ ;
output out=shankar.tmprxsumm_23 sum= ;
run ;