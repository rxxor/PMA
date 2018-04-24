
* Get e-sample data ;

%let datadir=Y:\Model\MP & E\00_Data\esample_2006\Eli Lilly Monthly Reports 2006-2007 ;
libname wrkbk excel "&datadir.\Jan 2006\Cymbalta MDD Monthly Order Report Jan 2006.xls" ;
data jan06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Jan 2006\Cymbalta DPNP Monthly Order Report Jan 2006.xls" ;
data jan06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Feb 2006\Cymbalta MDD Orders Data Feed Report Feb 2006.xls" ;
data feb06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Feb 2006\Cymbalta DPNP Orders Data Feed Report Feb 2006.xls" ;
data feb06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Mar 2006\Cymbalta MDD Monthly Order Data Feed report March 2006.xls" ;
data mar06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Mar 2006\Cymbalta DPNP Monthly Order Data Feed Report March 2006.xls" ;
data mar06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\April 2006\Cymbalta MDD Order Data Feed Report April 2006.xls" ;
data apr06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\April 2006\Cymbalta DPNP Order Data Feed Report April 2006.xls" ;
data apr06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\May 2006\Cymbalta MDD Monthly Order Data Feed Report May 2006.xls" ;
data may06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\May 2006\Cymbalta DPNP Monthly Order Data Feed report May 2006.xls" ;
data may06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\June 2006\Cymbalta MDD Monthly Date Feed Report June 2006.xls" ;
data jun06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\June 2006\Cymbalta DPNP Monthly Data Feed Report June 2006.xls" ;
data jun06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\July 2006\Cymbalta MDD Monthly Data Feed report July 2006.xls" ;
data jul06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\July 2006\Cymbalta DPNP Monthly Data Feed Report July 2006.xls" ;
data jul06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\August 2006\Cymbalta MDD Monthly Data Feed Report Aug 2006.xls" ;
data aug06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\August 2006\Cymbalta DPNP Monthly Data Feed Report Aug 2006.xls" ;
data aug06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Sept 2006\Cymbalta MDD Monthly Order Report Sept 2006.xls" ;
data sep06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Sept 2006\Cymbalta DPNP Monthly Order Report Sept 2006.xls" ;
data sep06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Oct 2006\Cymbalta MDD Order report Oct 2006 .xls" ;
data oct06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Oct 2006\Cymbalta DPNP Order Report Oct 2006.xls" ;
data oct06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Nov 2006\Cymbalta MDD Monthly Data feed Report Nov 2006.xls" ;
data nov06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Nov 2006\Cymbalta DPNP Data Feed report Nov 2006.xls" ;
data nov06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Dec 2006\Cymbalta MDD Monthly Order Data feed Report Dec 2006.xls" ;
data dec06_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Dec 2006\Cymbalta DPNP Monthly Order Data feed Report Dec 2006.xls" ;
data dec06_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

libname wrkbk excel "&datadir.\Jan 2007\Cymbalta MDD Order Report Jan 2007.xls" ;
data jan07_mdd ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="MDD" ;
run ;
libname wrkbk clear ;
libname wrkbk excel "&datadir.\Jan 2007\Cymbalta DPNP Order Report Jan 2007.xls" ;
data jan07_dpnp ;
  set wrkbk.esmpdata ;
  length type $4. ;
  type="DPNP" ;
run ;
libname wrkbk clear ;

data esmp ;
  set jan06_mdd jan06_dpnp feb06_mdd feb06_dpnp mar06_mdd mar06_dpnp
      apr06_mdd (rename=(channel_id=channel_code))
      apr06_dpnp (rename=(channel_id=channel_code))
      may06_mdd (rename=(qty=qty_ordered order_number=ordernumber)) 
      may06_dpnp (rename=(qty=qty_ordered order_number=ordernumber))
      jun06_mdd (rename=(qty=qty_ordered order_number=ordernumber last_=last))
      jun06_dpnp (rename=(qty=qty_ordered order_number=ordernumber name=first))
	  jul06_mdd (rename=(qty=qty_ordered order_number=ordernumber))
      jul06_dpnp (rename=(qty=qty_ordered order_number=ordernumber))
      aug06_mdd aug06_dpnp sep06_mdd sep06_dpnp
	  oct06_mdd oct06_dpnp nov06_mdd nov06_dpnp dec06_mdd dec06_dpnp 
	  jan07_mdd jan07_dpnp ;
run ;

data shankar.tmpesmp ;
  set esmp ;
run ;

* Get affilid affilsrc for DEA numbers ;
rsubmit ;
proc sort data=aw.customer (keep=afltn_id afltn_src_id dea_nbr 
                      where=(dea_nbr ^= " " and afltn_id ^= " "))
          out=shankar.tmpmd nodupkey ;
by dea_nbr ;
run ;
endrsubmit ;

rsubmit ;
data shankar.tmpesmp1 ;
  set shankar.tmpesmp ;
  length dea_nbr $20. ;
  dea_nbr=dea ;
run ;
endrsubmit ;
rsubmit ;
data shankar.tmpesmp1 ;
  merge shankar.tmpesmp1 (in=in1)
        shankar.tmpmd (in=in2) ;
  by dea_nbr ;
  if in1 ;
run ;
endrsubmit ;

rsubmit ;
data shankar.pr23_esamp200701 ;
  set shankar.tmpesmp1 (drop=affilid) ;
  rename afltn_id=affilid afltn_src_id=affilsrc ;
  format month yymmd7. ;
  month=mdy(month(order_date),1,year(order_date)) ;
  if afltn_id ^= " " ;
run ;
endrsubmit ;
rsubmit ;
%prntf(shankar.pr23_esamp200701,10) ;
endrsubmit ;
