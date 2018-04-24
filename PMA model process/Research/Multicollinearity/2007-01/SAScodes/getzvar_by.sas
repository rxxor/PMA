
/*
 Z matrix creation with by variables ;
 inds - Input dataset ;
 outds - Output dataset ;
 byvar - By group variables ;
 pcvar - Variables for which Z matrix needs to be created ;
 z variables are stored under the name of pcvar2 ;

 Example: 
 %getvar_by(inds=tempin,outds=tempout,byvar=segment,pcvar=%str(det smp)) ;
   In this example Z variables are constructed for each segment 
   using the variables det and smp in tempin
   and stored as det2, smp2 in tempout 
 */ 

%macro getzvar_by(inds,outds,byvar,pcvar) ;

proc sort data=&inds. ; by &byvar. ; run ;
proc princomp data=&inds. out=testpc std ;
by &byvar. ;
var &pcvar. ;
run ;
proc princomp data=&inds. outstat=pcstat  ;
by &byvar. ;
var &pcvar. ;
run ;
data pcstat1 ;
  set pcstat ;
  if _type_='SCORE' ;
  drop _type_ ;
run ;
proc sort data=pcstat1 ; by &byvar. ; run ;
proc transpose data=pcstat1 out=pcstat2 ;
by &byvar. ;
run ;
data pcstat2 ;
  set pcstat2 ;
  _type_='SCORE' ;
run ;
proc sort data=testpc ; by &byvar. ; run ;
proc score data=testpc score=pcstat2 out=&outds. ;
by &byvar. ;
run ;

%mend getzvar_by ;
