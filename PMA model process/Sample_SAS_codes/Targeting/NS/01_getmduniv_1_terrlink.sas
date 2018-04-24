
%include '~/SASCODES/General/control.sas' ;

* Extract alignment from Alignment ODS database that is a day lagged from CDM input ;

PROC SQL;
   CONNECT TO ORACLE (user=&usrid. password=&passwd. schema=ads_owner PATH="PRD287");
   CREATE TABLE  shankar.tmpcdm AS 
   SELECT * 
   FROM CONNECTION TO ORACLE
   ( SELECT pds_cstmr_srs.cstmr_srs_cust_id, 
            pds_cstmr_srs.cust_typ_cd,
            pds_cstmr_srs.cstmr_srs_strt_dt, 
            pds_cstmr_srs.cstmr_srs_end_dt,
            pds_cstmr_srs.ads_sfa_id, 
            pds_cstmr_srs.party_id
  FROM ads_owner.pds_cstmr_srs
  WHERE to_char(pds_cstmr_srs.cstmr_srs_end_dt,'YYYY') = (9999) and
        pds_cstmr_srs.cust_typ_cd='P'
          );
   DISCONNECT FROM ORACLE;
   QUIT;
RUN;

* Get hierarchy from Alignment ODS ;

data shankar.tmphier ;
  set shankar.d071004_terrhier_algn_ods ;
  keep trtry_srs_id trtry_sls_force_cd trtry_nm ;
  rename trtry_srs_id=ads_sfa_id ;
  if trtry_sls_force_cd in ("DA","DB","DC","DD","DI","DJ","DK","DL","EU","DN","DO","DP") ;
run ;  


* Psych Ofc and NSPC MD universe ;
data shankar.tmpuniv shankar.tmpunmatch ;
  merge shankar.tmpcdm (in=in1)
        shankar.tmphier (in=in2) ;
  by ads_sfa_id ;
  length sf $10. ;
  if trtry_sls_force_cd in ("DA","DB","DC","DD") then sf="NSPC" ;
  else if trtry_sls_force_cd in ("DI","DJ","DK") then sf="PSYCH" ;
  else if trtry_sls_force_cd in ("DL","EU") then sf="DPNP" ;
  else if trtry_sls_force_cd in ("DN","DO","DP") then sf="PSYCH-D" ;
  if in1 and in2 then output shankar.tmpuniv ;
  if in2 and ^in1 then output shankar.tmpunmatch ;
run ;


data shankar.d0710_psych_nspc_algnods ;
  set shankar.tmpuniv ;
run ;

* Get MD universe from CRD data service ;
data tmpmd ;
  set shankar.d0710_crdhcp ;
  length personid $11. affilid $10. affilsrc $2. ;
  if prsn_id ^= " " ;
  personid=prsn_id ;
  affilid=afltn_id ;
  affilsrc=afltn_src_id ;
  rename ims_mjr_spclty_cd=imsspec ly_mjr_spclty_cd=llyspec
         ln_1_adrs_txt=addr1 ln_2_adrs_txt=addr2 city_nm=city st_nm=state pstl_cd=zip 
         prmry_adrs_flg=prmryflg ;
  if prmry_adrs_flg="1" ;
run ;
proc sort data=tmpmd out=tmpmd nodupkey ; by personid ; run ;

data shankar.tmpuniv shankar.tmpunmatch ;
  merge shankar.d0710_psych_nspc_algnods (in=in1 keep=cstmr_srs_cust_id ads_sfa_id trtry_sls_force_cd trtry_nm sf 
                                            rename=(cstmr_srs_cust_id=personid))
        tmpmd (in=in2) ;
  by personid ;
  if in1 and in2 then output shankar.tmpuniv ;
  if in1 and ^in2 then output shankar.tmpunmatch ;
run ;

data shankar.d0710_nsuniv_algnods ;
  set shankar.tmpuniv ;
run ;