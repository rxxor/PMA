
* Create uncorrelated Z variables from x variables based on residual (gram-schmidt)
  method ;
  
* Input parameters to the macro ;
* inds - Input data set ;  
* outds - Output data set ;
* seg - Segment variable (always needed-put a dummy segment even in cases where there
                          is no segment needed) ;
* xvar - List of X variables that need to be made uncorrelated
         This needs to be specified within the %str function - see example below ;
* The output variables have the same name as input variables prefixed with res ;

* EXAMPLE:
*%getgsvar_by(inds=tmpinput,outds=tmpoutput,seg=dummy,xvar=%str(det smp prog)) ; ;
*The output variables will be stored in detres, smpres, progres ;

%macro getgsvar_by(inds=,outds=,seg=,xvar=) ;

  proc sort data=&inds. out=&outds. ; by &seg. ; run ;
  
  data &outds. ;
    set &outds. ;
	%let i=1 ;
	%let word=%scan(&xvar.,&i.,%str( )) ;
    %do %while (&word. ne ) ;
       %str(rename &word.=x&i. ;) ;
	   %let nvar=&i. ;
	   %let i=%eval(&i.+1) ;
       %let word=%scan(&xvar.,&i.,%str( )) ;
    %end ;
  run ;

  %do i=1 %to &nvar. ;
    %if &i.=1 %then
     %str(
     data &outds. ;
	    set &outds. ;
		z&i.=x&i. ;
      run ;
	     ) ;
    %else
	   %do ;
	     %let zvarlist= ;
		 %let sumlist=x&i. ;
	     %do j=1 %to %eval(&i.-1) ;
	      %let zvarlist=&zvarlist. z&j. ;
		  %let sumlist= &sumlist - (covx&i.z&j./varz&j.)*z&j. ;
	     %end ;
         %str(
         proc corr data=&outds. cov ;
         by &seg. ;
         var x&i. ;
	     with &zvarlist. ;
	     ods output cov=tmpcov&i. ;
	     run ; 
         proc transpose data=tmpcov&i. out=ttmpcov&i. prefix=covx&i. ;
		 by &seg. ;
		 var x&i. ;
		 id variable ;
		 run ;
		 data &outds. ;
		   merge &outds. (in=in1)
		         ttmpcov&i. (in=in2) ;
		   by &seg. ;
		   if in1 and in2 ;
		   z&i.=&sumlist. ;
		 run ;
          ) ;
       %end ;
	%str(
	proc summary data=&outds. nway ;
	class &seg. ;
	var z&i. ;
	output out=tmpvar&i. var=varz&i. ;
	run ;
	data &outds. ;
	  merge &outds. (in=in1)
	        tmpvar&i. (in=in2) ;
	  by &seg. ;
	  if in1 and in2 ;
	run ;
	 ) ;
  %end ;

  data &outds. (drop=_type_ _freq_ _name_) ;
    set &outds. ;
	%let i=1 ;
	%let word=%scan(&xvar.,&i,%str( )) ;
    %do %while (&word. ne ) ;
       %str(rename x&i.=&word. ;
            rename z&i.=&word.res ; ) ;
	   %let i=%eval(&i.+1) ;
       %let word=%scan(&xvar.,&i,%str( )) ;
    %end ;
  run ;

%mend getgsvar_by ;
