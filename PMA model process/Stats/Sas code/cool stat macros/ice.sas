 /****************************************************************/
 /*          S A S   S A M P L E   L I B R A R Y                 */
 /*                                                              */
 /*    NAME: ICE                                                 */
 /*   TITLE: MACRO TO COMPUTE NONPARMETRIC SURVIVAL CURVES FOR   */
 /*          INTERVAL CENSORED DATA                              */
 /* PRODUCT: IML                                                 */
 /*  SYSTEM: ALL                                                 */
 /*    KEYS:                                                     */
 /*   PROCS: IML                                                 */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT:                             UPDATE:   13Jul93       */
 /*     REF:                                                     */
 /*    MISC:                                                     */
 /*                                                              */
 /****************************************************************/


 /*******************************************************************

The %ICE macro computes nonparametric survival curves from interval
censored data. Confidence intervals for the survival curves are
also calculated.

The data for the ith subject consist of an interval of the form
[L_i,R_i]. You have to prepare your data such that 1) L_i=0 for a left
censored time, 2) for a right censored time R_i is augmented to an
arbitrary fixed value (beyond the last examination time), and 3) L_i=R_i
for an exact survival time.

Under the survival curve G, the likelihood for the ith observation is

          G(L_i-) - G(R_i+)

Let [q_1,p_1],[q_2,p_2], ...,[q_m,p_m] be the set of disjoint intervals
whose left and right end points lie in the set {L_i; 1<=i<=N} and
{R_i:1<=i<=N} respectively, and which contain no other members of {L_i}
or {R_i} except at their end points. For 1<=j<=m, define theta_j=
G(q_j-)-G(p_j+). Then theta_j>=0 and sum_j(of theta_j)=1.
The likelihood is proportional to

     Lik(theta_1,theta_2,...,theta_m)
        = prod_i[of sum_j(of alpha_ij * theta_j)]

where alpha_ij= 1 if [q_j,p_j] lies in [L_i,R_i] and 0 otherwise.
The maximum likelihood estimates of theta_1, ... ,theta_m are
obtained by an NLP optimization routine or by Turnbull (1976)'s
self-consistency algorithm. The covariance matrix of the estimated
parameters is obtained by inverting the estimated matrix of the
second partial derivatives of the log-likelihood.

The following arguments may be listed within parentheses in any order,
separated by commas. Only the TIME= argument is required, all other
arguments are optional.


   DATA=      SAS data set to be analyzed.

   BY=        List of variables for BY groups.

   TIME=      Two variables (separated by blanks) representing the left
              and right endpoints of the time interval. You may enclosed
              these variable names by a pair of parentheses/brackets/
              braces, but a comma should not be used to separate the
              names.

   FREQ=      A single numeric variable whose values represent the
              frequency of occurrence of the observations.

   TECH=      Optimization technique for maximizing the likelihood. Valid
              values are:

              NRA --  Newton-Raphson Ridge
              QN  --  Quasi-Newton
              CG  --  Conjugate Gradient
              EM  --  Self-Consistency Algorithm of Turnbull

              NRA, QN and CG are NLP optimization routines. EM is the
              self-consistency algorithm. With m as the number of
              estimated parameters, the default technique is

                    NRA  if m <=30
                    QN   if 30 < m <= 200
                    CG   if m > 200


   LBOUND=    Lower bound for the estimated parameters. The
              default is 1e-6. Only used in the NRA, QN and
              CG techniques.

   ALPHA=     A number between 0 and 1 that sets the level of the
              confidence intervals for the survival curve. The
              confidence level for the intervals is 1-ALPHA. The default
              is .05.

   OPTIONS=   List of display options (separated by blanks):

              NOPRINT  Suppress printing of the parameter estimates,
                       the survival curve estimates and confidence
                       limits for the survival curve.

              PLOT     Graphical display of the estimated survival
                       curve.

   NLPOPT=    An IML row vector to be passed into the OPT argument of
              the NLP optimization routines. This vector controls the
              option vector of the NLP optimization routine. The default
              is {1 0}.

   NLPTC=     An IML row vector to be passed into the TC argument
              of the NLP optimization routine. This vector controls
              the termination criteria of the NLP optimization
              routine. The default is {2000 5000}.

   EMCONV=    Convergence criterion for the EM technique. Convergence
              is declared if the increase in the log-likelihood
              is less than the convergence criterion. The default is
              1e-8.

   OUTE=      A SAS data set name containing the parameter estimates.

   OUTS=      A SAS data set name containing the estimates of the
              survival curve and the corresponding confidence limits.

Example:

   data ex1;
      input l r f;
      cards;
   0 2  1
   1 3  1
   2 10 4
   4 10 4
   ;
   run;
   %ice(data=ex1,time=(l r),freq=f);


The following statements may be useful for diagnosing errors:

   %let _notes_=1;       %* Prints SAS notes for all steps;
   %let _echo_=1;        %* Prints the arguments to the TCHAID macro;
   %let _echo_=2;        %* Prints the arguments to the TCHAID macro
                            after defaults have been set;
   options mprint;       %* Prints SAS code generated by the macro
                            language;
   options mlogic symbolgen; %* Prints lots of macro debugging info;

This macro will not work in 6.07 or earlier releases.

References:

Peto, R. (1973), "Experimental survival curves for interval-censored
   data". Appl. Statistist., 22, pp 86-93.

Turnbull, B.W. (1976), "The empirical distribution function from
   arbitrarily grouped, censored and truncated data. J. Royal Statist.
   Soc. Ser B, 38, pp 290-295.

 *******************************************************************/
%inc '/sas/m610/stat/sampsrc/xmacro.sas';

 /***********************************************************/
 /******************** BEGIN ICE MACRO **********************/
 /***********************************************************/

%macro ice(
   data=,
   by=,
   time=,
   freq=,
   tech=,
   lbound=,
   alpha=,
   nlpopt=,
   nlptc=,
   emconv=,
   options=,
   oute=,
   outs= )/parmbuff;

************** initialize xmacros **************;
%local pbuff; %let pbuff=&syspbuff;
%xinit( ice, %nrbquote(&pbuff))


************** check arguments **************;
%xchkdata(data,_LAST_)
%xchkeq(by)
%xchkdef(time)
%xchkname(freq)
%xchknum(lbound,1e-6,0<LBOUND)
%xchknum(alpha,.05,0<ALPHA and ALPHA<1)
%xchknum(emconv,1e-8,0<EMCONV)
%xchkdsn(oute)
%xchkdsn(outs)
%xchkeq(options)


*********** process time ************;
%let ltime=%scan(&time,1,%bquote( ()[]{}));
%if %bquote(&ltime)= %then %do;
   %let _xrc_=%str(The TIME= argument is not specified);
   %put ERROR: &_xrc_..;
   %goto exit;
%end;
%if ^%xname(%bquote(&ltime)) %then %do;
   %let _xrc_=%str(%upcase(&ltime) is not a valid SAS variable name);
   %put ERROR: &_xrc_..;
   %goto exit;
%end;

%let rtime=%scan(&time,2,%bquote( ()[]{}));
%if %bquote(&rtime)= %then %do;
   %let _xrc_=%qcmpres(The variable representing the right endpoint
                       of the time interval is not specified);
   %put ERROR: &_xrc_..;
   %goto exit;
%end;
%if ^%xname(%bquote(&rtime)) %then %do;
   %let _xrc_=%str(%upcase(&ltime) is not a valid SAS variable name);
   %put ERROR: &_xrc_..;
   %goto exit;
%end;

************** process nlpopt ************;
%xchkdefv(nlpopt,{1 0});

************** process nlptc ************;
%xchkdefv(nlptc,{1000 5000});


************** process tech ************;
%xchkkey(tech, 0, NRA:1 QN:2 CG:3 EM:4)



************** process options ************;
%let print= 1;
%let plot= 0;
%let n=1;
%let token=%scan(&options,&n,%str( ));
%do %while(%bquote(&token)^=);
   %let token=%upcase(&token);
   %if %xsubstr(&token,1,7)=NOPRINT %then %let print=0; %else
   %if %xsubstr(&token,1,4)=PLOT %then %let plot=1; %else
   %do;
      %let _xrc_=Unrecognized option &token;
      %put ERROR: &_xrc_..;
   %end;
   %let n=%eval(&n+1);
   %let token=%scan(&options,&n,%str( ));
%end;


************** process BY variables ************;
%xbylist;
%xvlist(data=&data, _list=by, _name=by, _count=nby);


************** dummy data step to check for errors ***************;
%xchkvar(&data,&by,&ltime &rtime)


************** time to check return code *************;
%if &_xrc_^=OK %then %goto chkend;


************** process FREQ= variable ***************;
%xvfreq(&data)

%chkend:
%xchkend(&data)
%if &_xrc_^=OK %then %goto exit;

************** turn notes back on before creating
               the real output data sets ****************;
%xnotes(1)


************** interval censoring ****************;
%let ii= 1;

%if %bquote(&by)= %then %do;
   %xice(data=&data,ltime=&ltime,rtime=&rtime,alpha= &alpha,
         emconv=&emconv,freq=&freq,oute=&oute,outs=&outs);
%end;
%else %do;  /* by processing */
    proc summary data= &data;
       var &by;  /* this will fail with a character variable */
       output out=_by n=_nbyobs;
       by &by;
       run;
    data _null_;
       retain _nbygrp 0;
       set _by end= last;
       _nbygrp + 1;
       if last then call symput('nbygrp', trim(left(put(_nbygrp,12.))));
       run;
   proc print data= _by; run;
   %put nbygrp= &nbygrp;

   %let first= 1;
   %let last= 0;

   %do ii=1 %to &nbygrp;
      data _null_;
         array byvar &by;
         set _by(firstobs=&ii obs=&ii);
         call symput('nbyobs', trim(left(put(_nbyobs,12.))));
         %do jj= 1 %to &nby;
            call symput("byval&jj", trim(left(put(&&by&jj,12.))));
         %end;
         run;

      %do jj= 1 %to &nby;
          %put &&by&jj = &&byval&jj;
      %end;
      %put nbyobs= &nbyobs;

      %let last= %eval(&last + &nbyobs);

      data _data1;
         set &data(firstobs=&first obs=&last);
         output;
         run;
      proc print data= _data1; run;

      %xice(data=_data1,ltime=&ltime,rtime=&rtime,alpha= &alpha,
            emconv=&emconv,freq= &freq,oute=&oute,outs=&outs);
      %let first= %eval(&last + 1);
   %end;
%end;

************** termination ***************;
%exit:

%xterm;

%mend ice;


%macro xice(data=,ltime=,rtime=,alpha=,emconv=,freq=,oute=,outs=);
proc iml;

start interval(l,r) global(_x,nobs,nparm,_zfreq,_freq);


   nobs= nrow(l);

  /* GENERATE NON-OVERLAPPING INTERVALS */
   p=0;
   q=0;
   call nolap(nparm, p, q, l, r);


  /* GENERATE THE ALPHA-MATRIX */
   _x= j(nobs, nparm, 0);
   do j= 1 to nparm;
      _x[,j]= choose(l <= q[j]  & p[j] <= r, 1, 0);
      end;
   *print _x;


  /* NO NEED FOR l,r */
   *free l r;

  /* USING NLP TO MAXIMIZE LIKELIHOOD FUNCTION */
  /* options */
   optn= &nlpopt;
   *print optn;


  /* constraints */
   con= j(3, nparm + 2, .);
   con[1, 1:nparm]= &lbound;
   con[2:3, 1:nparm]= 1;
   con[3,nparm + 1]=0;
   con[3,nparm + 2]=1;

  /* initial estimates */
   x0= j(1, nparm, 1/nparm);

  /* call the optimization routine */
   method= &tech;
   if method = 0 then do;
      if nparm <= 30 then method= 1;
      else if nparm < 200 then method= 2;
      else method= 3;
   end;
   if (method = 1) then do;
      call nlpnrr(rc,rx,"LL",x0,optn,con,,,,"GRAD","HESS");
      *call nlpnra(rc,rx,"LL",x0,optn,con,,,,"GRAD","HESS");
      end;
   else if ( method = 2) then do;
      call nlpqn(rc,rx,"LL",x0,optn,con,,,,"GRAD");
      end;
   else if (method = 3) then do;
      call nlpcg(rc,rx,"LL",x0,optn,con,,,,"GRAD");
      end;
   else if (method = 4) then rx=em(x0, &emconv);


q= q`;
p= p`;
theta= rx`;


   %if ( (%bquote(&oute)^=) or (%bquote(&outs)^=) ) %then
   %do jj= 1 %to &nby;
       &&by&jj = j(nobs,1,&&byval&jj);
   %end;

   %if (%bquote(&oute) ^=) %then %do;
      %if (&ii = 1) %then %do;
         create &oute var{&by q p theta};
         append;
      %end;
      %else %do;
         edit &oute var{&by q p theta};
         append;
      %end;
   %end;



  /* COMPUTE THE SURVIVAL DISTRIBUTION FUNCTION */
   tmp1= cusum(rx[nparm:1]);
   sdf= tmp1[nparm-1:1];

  /* COMPUTE THE CONFIDENCE LIMITS OF THE SDF */
   mm= nparm -1;

  /* covariance matrix of the first mm parameters */
   _x= _x - _x[,nparm] * (j(1, mm, 1) || {0});
   h= j(mm, mm, 0);
   ixtheta= 1 / (_x * ((rx[,1:mm]) || {1})`);
   if _zfreq then
      do i= 1 to nobs;
         rowtmp= ixtheta[i] # _x[i,1:mm];
         h= h + (_freq[i] # (rowtmp` * rowtmp));
      end;
   else do i= 1 to nobs;
      rowtmp= ixtheta[i] # _x[i,1:mm];
      h= h + (rowtmp` * rowtmp);
   end;
   sigma2= inv(h);
   *print sigma2;

  /* estimated variance of the SDF */
   sigma3= j(mm, 1, 0);
   tmp1= sigma3;
   do i= 1 to mm;
      tmp1[i]= 1;
      sigma3[i]= tmp1` * sigma2 * tmp1;
   end;
   *print sigma3;

  /* confidence limits */
   tmp1= probit(1 - .5 * &alpha);
   *print tmp1;
   tmp1= tmp1 *sqrt(sigma3);
   lcl= choose(sdf > tmp1, sdf - tmp1, 0);
   ucl= sdf + tmp1;
   ucl= choose( ucl > 1., 1., ucl);

  /* PRINTOUT #3*/
   left= {0} // p;
   right= q // p[nparm];
   sdf= {1} // sdf // {0};
   lcl= {.} // lcl //{.};
   ucl= {.} // ucl //{.};

  /* PRINTOUT  */
%if &print = 1 %then %do;

   if (&nby > 0) then print "-----"
      %do jj= 1 %to &nby;
        " &&by&jj = &&byval&jj "
      %end;
      "-----",;

   print "Nonparametric Survival Curve for Interval Censoring",,;
   reset noname nocenter spaces=0;
   print "Number of Observations: " (trim(left(char(nobs))));
   print "Number of Parameters: " (trim(left(char(nparm))));
   if method = 1 then
      print "Optimization Technique: Newton Raphson Ridge";
   else if method = 2 then
      print "Optimization Technique: Quasi-Newton";
   else if method = 3 then
      print "Optimization Technique: Conjugate Gradient";
   else if method = 4 then
      print "Optimization Technique: Self-Consistency Algorithm";

   reset center;
   print ,"Parameter Estimates", ,q[colname={q}] p[colname={p}]
         theta[colname={theta} format=12.7],;

   tmp1= 100. * (1. - &alpha);
   print , "Survival Curve Estimates and "(trim(left(char(tmp1))))
           "% Confidence Intervals", ,
         left[colname={left}] right[colname={right}]
         sdf[colname={estimate} format=12.4]
         lcl[colname={lower} format=12.4]
         ucl[colname={upper} format=12.4];
%end;

   %if (%bquote(&outs) ^=) %then %do;
      %if (&ii = 1) %then %do;
         create &outs var{&by left right sdf lcl ucl};
         append;
      %end;
      %else %do;
         edit &outs var{&by left right sdf lcl ucl};
         append;
      %end;
   %end;


  /* PLOTTING THE SURVIVAL FUNCTION */
%if &plot = 1 %then %do;

   xy1= left || sdf;
   xy2= right || sdf;

   pmax= left[nparm+1];;
   c= log10(pmax / 10);
   b= int(c);
   d= 10 ** (c-b);
   if d <= 2 then     a=2;
   else if d <=5 then a=5;
   else               a=10;
   width= a * 10 ** b;
   c= pmax / width;
   b= int(c);
   if (b < c) then do;
      b= b+1;
      pmax= b * width;
      end;
   *print b pmax;

   world= {0 0, 1 1};
   world[2,1]= pmax;
   leng= world[2,];
   window= world + 0.2 * {-1 , 1} * leng;

   call gstart;

   call gwindow (window);
   *call gpoint (rowvec(time),rowvec(prob)) color="red";
   *call gdraw( rowvec(time),rowvec(prob),1,"cyan");
   call gdrawl(xy1,xy2) color="cyan";

   call gxaxis ({0 0}, pmax, b);
   call gyaxis ({0 0}, 1, 10) format="3.1";

   call gtext( .5 # pmax, -.15, "Time");
   call gvtext( -width # 1.5, 1, "SDF" );

   call gset("font","swiss");
   call gset("height",1.3);
   call gscenter(.5 # pmax, 1.1, "Survival Curve Estimate");

   call gshow;

%end;

finish  interval;


%* loglikelihood function *;
start LL(theta) global(_x,nparm,_zfreq,_freq);
  if _zfreq then xlt= _freq # (log(_x * theta`));
  else           xlt= log(_x * theta`);
  f= xlt[+];
  return(f);
  print f;
finish LL;

%* gradient vector *;
start GRAD(theta) global(_x,nparm,_zfreq,_freq);
  g= j(1,nparm,0);
  if _zfreq then do;
     tmp= _x # (_freq / (_x * theta`));
  end;
  else do;
     tmp= _x # (1 /  (_x * theta`) );
  end;
  g= tmp[+,];
  return(g);
finish GRAD;

%* hessian matrix *;
start HESS(theta) global(_x,nparm,nobs,_zfreq,_freq);
   h= j(nparm, nparm, 0);
   tmp= _x # (1/ (_x * theta`));
   if _zfreq then do;
      do i= 1 to nobs;
         rowtmp= tmp[i,];
         h= h + (_freq[i] # (rowtmp` * rowtmp));
      end;
   end;
   else do;
      do i= 1 to nobs;
         rowtmp= tmp[i,];
         h= h + (rowtmp` * rowtmp);
      end;
   end;
   h= -1 # h;
   return(h);
finish HESS;


%****** CONSTRUCT THE NON-OVERLAPPING TIME ******;
%****** INTERVALS FOR THE TURNBULL METHOD *******;
start nolap(nq, p,q,l,r);
   pp= unique(r); npp= ncol(pp);
   qq= unique(l); nqq= ncol(qq);
   q= j(1,npp, .);
   do i= 1 to npp;
      do j= 1 to nqq;
         if ( qq[j] < pp[i] ) then q[i]= qq[j];
      end;
      if q[i] = qq[nqq] then goto lab1;
   end;
lab1:
   if i > npp then nq= npp;
   else            nq= i;
   q= unique(q[1:nq]);
   nq= ncol(q);
   p= j(1,nq, .);
   do i= 1 to nq;
     do j= npp to 1 by -1;
        if ( pp[j] > q[i] ) then p[i]= pp[j];
     end;
   end;
   *print nq p q;
finish nolap;


%****** Self-Consistency Algorithm *******;
start em(theta0, conv) global(_x,nobs,_zfreq,_freq);
   iter=0;
   u= _x # theta0;
   xt= u[,+];
   lxt= log(xt);
   if _zfreq then do;
      lxt= lxt # _freq;
      u= u # (_freq / xt);
      ntot= _freq[+];
   end;
   else do;
      u= u # (1 / xt);
      ntot= nobs;
   end;
   ll0= lxt[+];
   print ll0;
   theta0= u[+,] / ntot;
   difcrit= 1;

   do while ( difcrit > conv );
      iter= iter + 1;
      u= _x # theta0;
      xt= u[,+];
      lxt= log(xt);
      if _zfreq then do;
         lxt= lxt # _freq;
         u= u # (_freq / xt);
      end;
      else u= u # (1 / xt);
      ll= lxt[+];
      theta0= u[+,] / ntot;
      difcrit= ll - ll0;
      print iter ll[format=20.10] difcrit[format=20.10];
      ll0= ll;
   end;
   *print theta0;
   return(theta0);
finish;


%*-- CENTER TEXT STRING IN IML GRAPHICS --*;
start gscenter(x,y,str);
  call gstrlen(len,str);
  call gscript(x-len/2,y,str);
finish gscenter;


%*---------- Main IML Program -----------*;
   use &data;
   read all var{&ltime &rtime &freq};
   %if %bquote(&freq)= %then %do;
      _zfreq= 0;
      _freq= 1;
   %end;
   %else %do;
      _zfreq= 1;
      _freq= &freq;
   %end;

   call interval(&ltime,&rtime);
   quit;

%mend xice;

%************************** xchkdefv **********************;
%* If argument value is blank, set it to default value.
   Otherwise, put it in the form of an IML rowvector, ie,
   enclose the numbers with braces and eliminate any
   parentheses or brackets;

%* _arg      name of argument to check;
%* def       (optional) default value;

%macro xchkdefv(_arg,def);
   %* put %upcase(&_arg)=&&&_arg;
   %* set default for &_arg;
   %xchkech(&_arg);
   %if %bquote(&&&_arg)= %then %let &_arg=&def;
   %else %do;
      %let tmp1=;
      %let n=1;
      %let token=%scan(&&&_arg,&n,%bquote( ()[]{}));
      %do %while(%bquote(&token)^=);
         %if %verify(&token,&_digits_)= 0 %then %let tmp1=&tmp1 &token;
         %else %do;
           %let _xrc_=Error: Incorrect %upcase(&_arg)= specification;
           %if &_xrc_^=OK %then %put &_xrc_..;
           %goto skip1;
         %end;
         %let n=%eval(&n+1);
         %let token=%scan(&&&_arg,&n,%bquote( ()[]{}));
      %end;
      %let &_arg={&tmp1};
%skip1:
   %end;
   %* put %upcase(&_arg)=&&&_arg;
%mend xchkdefv;

