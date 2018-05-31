/*****************************************************************************
                                                                            
                             ESTSTATS macro
                                  V2.2
                                                                            
    DISCLAIMER:                                                             
      THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A SERVICE TO    
      ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO WARRANTIES,         
      EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR FITNESS FOR A          
      PARTICULAR PURPOSE REGARDING THE ACCURACY OF THE MATERIALS OR CODE    
      CONTAINED HEREIN.                                                     
                                                                            
    PURPOSE:                                                                
      Produces a SAS dataset containing test statistics and confidence
      intervals for regression parameter estimates obtained from the
      REG, LOGISTIC (including probit models), PHREG, or LIFEREG
      procedures.  Approximate confidence intervals for the parameter
      estimates are not given by the REG, PHREG, PROBIT, or LIFEREG
      procedures, but are provided by this macro.  For logistic and
      proportional hazards models, odds or risk ratios and their
      confidence intervals are also given.

    REQUIRES:
      Base SAS and SAS/STAT Software.  All releases are supported except 
      for probit models which require Release 6.11 TS020 or later.

    USAGE:
      First submit this file to the SAS System to define the ESTSTATS 
      macro.  You can do this either by copying this file into the
      program editor and submitting it, or by submitting a %INCLUDE
      statement that gives the path and filename of this file on your
      system.

      Once the macro is defined, call the macro using the desired 
      options.  See the section below for an example.

      This macro assumes that the model will be fitted and the 
      procedure's OUTEST= data set will be created without errors.  It 
      is recommended that you first use the desired procedure directly 
      to fit and confirm the model.  Then use this macro to extract the 
      parameter estimates and other statistics.

      The available options and their descriptions appear at the top of
      the macro definition below.  The Y= and METHOD= options are
      required and you'll typically need the X= option to specify the
      explanatory variables.  The FORM= option allows you to select
      between two forms of the output data set that are the transpose of
      each other -- either statistics as rows as in OUTEST= data sets
      (the default), or statistics as columns.

    DETAILS:
      Note that normal regression, binary logistic and probit models are
      all in the class of generalized linear models.  As such, maximum
      likelihood parameter estimates can also be obtained for these
      models with the GENMOD procedure.  The GENMOD procedure uses the
      Output Delivery System which allows you to output any of its
      printed tables to a SAS data set.  See the GENMOD documentation.
      Since GENMOD has a CLASS statement, parameter estimates for models
      including class variables can be output.  Note that GENMOD can
      also fit poisson regression models.
 
    PRINTED OUTPUT:
      Following is output from the example presented below.  Note that 
      BETA_LCL and BETA_UCL give the lower and upper confidence limits
      on each parameter estimate.  P is the p-value for each estimate.

------------------------------- PULSE=Mod. Low -------------------------------

VARIABLE   _LABEL_      PARMS   STDERR      T        P     BETA_LCL  BETA_UCL

INTERCEP  Intercept   70.7562  14.0191   5.04714  0.00050   39.5198   101.993
RUNTIME               -2.5805   0.4998  -5.16351  0.00042   -3.6941    -1.467
AGE                   -0.0603   0.1426  -0.42307  0.68120   -0.3781     0.257
WEIGHT                 0.0735   0.1280   0.57399  0.57866   -0.2117     0.359


------------------------------- PULSE=Very Low -------------------------------

VARIABLE   _LABEL_      PARMS   STDERR      T        P     BETA_LCL  BETA_UCL

INTERCEP  Intercept   101.155  9.40999   10.7497  0.00000   80.8257   121.484
RUNTIME                -3.211  0.66014   -4.8640  0.00031   -4.6371    -1.785
AGE                    -0.284  0.16283   -1.7422  0.10507   -0.6355     0.068
WEIGHT                 -0.073  0.07180   -1.0101  0.33090   -0.2276     0.083


      Using the default FORM=STATROW option with this example results in
      the following output:


------------------------------- PULSE=Mod. Low -------------------------------

           _TYPE_      INTERCEP     RUNTIME       AGE       WEIGHT

           PARMS         70.756    -2.58054    -0.06034     0.07346
           STDERR        14.019     0.49976     0.14263     0.12797
           T              5.047    -5.16351    -0.42307     0.57399
           P              0.001     0.00042     0.68120     0.57866
           BETA_LCL      39.520    -3.69408    -0.37814    -0.21169
           BETA_UCL     101.993    -1.46699     0.25746     0.35860


------------------------------- PULSE=Very Low -------------------------------

           _TYPE_      INTERCEP     RUNTIME       AGE       WEIGHT

           PARMS        101.155    -3.21091    -0.28368    -0.07252
           STDERR         9.410     0.66014     0.16283     0.07180
           T             10.750    -4.86397    -1.74219    -1.01005
           P              0.000     0.00031     0.10507     0.33090
           BETA_LCL      80.826    -4.63706    -0.63546    -0.22763
           BETA_UCL     121.484    -1.78476     0.06809     0.08259

    LIMITATIONS:
      Limited error checking is done.  Be sure that the DATA= data set
      exists and that the variables given in the Y=, X=, BY=, FREQ=,
      WEIGHT=, and CENSOR= options exist on that data set.  Be sure that
      the value given in the ALPHA= option is between 0 and 1.  All X=
      variables must be numeric and are treated as continuous
      regressors.  CLASS (i.e. nominal-scale) variables are not allowed.

      Additional special variables in OUTEST= data sets (e.g. _LNLIKE_,
      _LINK_, _DIST_, etc.) are not kept by this macro.

      The fitted model must contain an intercept in all regression
      models other than the proportional hazards (PHREG) model.  An
      intercept-only model is fit if X= is omitted.
      
      Only Wald confidence intervals can be output in logistic models.
      Only binary response variables can be modeled with the logistic
      and probit methods.

      Time-dependent variables and stratified analyses are not allowed
      in proportional hazards models.  Offset variables are not allowed
      in these models or in logistic or probit models.  A non-zero
      threshold parameter is not allowed in probit or logistic models.

    EXAMPLE:
      In this example, test statistics and 95% confidence intervals are
      obtained for each parameter in the regression model:  

        E(oxy) = intercept + b1*runtime + b2*age + b3*weight .

      Separate models are fit for individuals with very low resting 
      pulse (below 55 beats/min) and moderately low resting pulse (55 to 
      the maximum of 70 beats/min).


      data fitness;
        input age weight oxy runtime rstpulse runpulse maxpulse;
        if rstpulse<55 then pulse='Very Low'; else pulse='Mod. Low';
      cards;
      44 89.47  44.609 11.37 62 178 182
      40 75.07  45.313 10.07 62 185 185
      44 85.84  54.297  8.65 45 156 168
      42 68.15  59.571  8.17 40 166 172
      38 89.02  49.874  9.22 55 178 180
      47 77.45  44.811 11.63 58 176 176
      40 75.98  45.681 11.95 70 176 180
      43 81.19  49.091 10.85 64 162 170
      44 81.42  39.442 13.08 63 174 176
      38 81.87  60.055  8.63 48 170 186
      44 73.03  50.541 10.13 45 168 168
      45 87.66  37.388 14.03 56 186 192
      45 66.45  44.754 11.12 51 176 176
      47 79.15  47.273 10.60 47 162 164
      54 83.12  51.855 10.33 50 166 170
      49 81.42  49.156  8.95 44 180 185
      51 69.63  40.836 10.95 57 168 172
      51 77.91  46.672 10.00 48 162 168
      48 91.63  46.774 10.25 48 162 164
      49 73.37  50.388 10.08 67 168 168
      57 73.37  39.407 12.63 58 174 176
      54 79.38  46.080 11.17 62 156 165
      52 76.32  45.441  9.63 48 164 166
      50 70.87  54.625  8.92 48 146 155
      51 67.25  45.118 11.08 48 172 172
      54 91.63  39.203 12.88 44 168 172
      51 73.71  45.790 10.47 59 186 188
      57 59.08  50.545  9.93 49 148 155
      49 76.32  48.673  9.40 56 186 188
      48 61.24  47.920 11.50 52 170 176
      52 82.78  47.467 10.50 53 170 172
      ;

      %eststats(  data = fitness, 
                method = reg,
                    by = pulse, 
                     y = oxy, 
                     x = runtime age weight,
                  form = statcol,
                   out = regout)

      proc print data=regout noobs;
        by pulse;
        run;

    MISSING VALUES:
      Observations with missing values on any of the Y=, X=, FREQ=, or
      WEIGHT= variables are omitted from the analysis.

    SEE ALSO: 
      The SAS/STAT Sample Library program REGCI.SAS (title: "Extracting
      Anova Data from the Reg Output Data Set") does the same thing for
      normal regression models with no BY statement.

      The program REGCI_BY.SAS does the same thing for normal regression
      models with one BY variable.  It is available via the Web at:
      http://www.sas.com/techsup/download/stat/
      
*****************************************************************************/  


%macro eststats (

               data=_last_ ,  /* Input data set.  Default is last created   */
                              /* data set.                                  */

               out=eststats,  /* Name of output data set containing the     */
                              /* tests and confidence bounds.               */

 /*REQUIRED*/  method=     ,  /* METHOD=REG for normal regression,          */
                              /* METHOD=LOGISTIC for logistic model,        */
                              /* METHOD=PROBIT for probit model,            */
                              /* METHOD=PHREG for proportional hazards model*/
                              /* METHOD=LIFEREG for accelerated failure time*/  
                              /* model.                                     */

 /*REQUIRED*/  y=          ,  /* Dependent variable - this may be a single  */
                              /* variable name or events/trials form for    */
                              /* logistic and probit models or (time1,time2)*/
                              /* form for counting process input in         */
                              /* proportional hazards models and interval   */
                              /* censoring in accelerated failure time      */
                              /* time models.                               */

               x=          ,  /* Independent variable(s).  Must NOT be a    */
                              /* list e.g. var1-var10.  If not specified,   */
                              /* a model containing only an intercept is    */
                              /* fit.  Separate variable names by blanks,   */
                              /* not commas.                                */

               by=         ,  /* Variables defining BY groups.  Must NOT    */
                              /* be a list e.g. var1-var10.                 */

               freq=       ,  /* Frequency variable (used in FREQ statement)*/
                              /* This should not be specified for LIFEREG   */
                              /* models.                                    */

               weight=     ,  /* Weight variable (used in WEIGHT statement) */
                              /* This should not be specified for PHREG     */
                              /* models.                                    */

               censor=     ,  /* Censoring variable and values for PHREG    */
                              /* models.  Example:  censor=status(0)        */

               dist=       ,  /* Distribution for LIFEREG models.  Specify  */
                              /* as shown in LIFEREG documentation.         */
                
               descend=    ,  /* DESCENDING option for logistic and probit  */
                              /* models.  See LOGISTIC documentation.       */
                              /* Specify descend=des to use the DESCENDING  */
                              /* option.                                    */

           order=formatted ,  /* ORDER= option for logistic and probit      */
                              /* models.  See LOGISTIC documentation.       */

               nolog=      ,  /* NOLOG option for LIFEREG models.  See      */
                              /* LIFEREG documentation.  Specify nolog=nolog*/
                              /* to use the NOLOG option.                   */

               ties=breslow,  /* TIES= option for PHREG models.  Specify as */
                              /* shown in PHREG documentation.              */

               alpha=.05   ,  /* Alpha level for confidence bounds.  Value  */
                              /* must be between 0 and 1.  alpha=.05 yields */
                              /* 95% confidence bounds.                     */

               print=no    ,  /* Show regression procedure output? (yes, no)*/

               form=statrow   /* Output data set has statistics as rows,    */
                              /* variables as columns (OUTEST= form).  If   */
                              /* outform=statcol, then statistics are       */
                              /* columns, variables are rows.               */
               );

options nonotes nostimer;

/* SOME LIMITED ERROR CHECKING */
/* Verify that Y= option is specified */
%if %quote(&y)= %then %do;
    %put ERROR: Specify dependent variable in the Y= argument;
    %goto exit;
%end;

/* Verify that METHOD= option is specified and is correct */
%if %upcase(&method) ne REG and 
    %upcase(&method) ne LOGISTIC and
    %upcase(&method) ne PROBIT and
    %upcase(&method) ne LIFEREG and
    %upcase(&method) ne PHREG %then %do;
    %put ERROR: METHOD= must be REG, LOGISTIC, PROBIT, PHREG, or LIFEREG;
    %goto exit;
%end;

/* Get number of regressors */
%let i=1;
%do %while (%scan(&x,&i) ne %str() );
   %let arg&i=%scan(&x,&i);
   %let i=%eval(&i+1);
%end;
%let nx=%eval(&i-1);


/* Sort the data by the BY variables if BY variables are given */
%if &by ne %then %do;
proc sort data=&data out=_regin_;
  by &by;
  run;
%end;


/* MODEL FITTING --
   Output parameter estimates & covariance matrix with OUTEST= for each 
   BY group. */

%let proc=&method;
%if %upcase(&method)=PROBIT %then %let proc=logistic; 

proc &proc data=%if &by ne %then _regin_; %else &data;
           outest=_est_ covout
           %if %upcase(&method)=REG %then outsscp=_sscp_; 
           %if %upcase(&method)=LOGISTIC or %upcase(&method)=PROBIT 
           %then %do;
               %if %upcase(&descend)=DES %then descending;
               %if &order ne %then order=&order;
           %end;
           %if %upcase(&print)=NO %then noprint;
           ;
  model %quote(&y)
        %if %upcase(&method)=PHREG or %upcase(&method)=LIFEREG 
        and %quote(&censor) ne %then *&censor;
        = &x /
        %if %upcase(&method)=PROBIT %then %do;
          link=probit technique=newton
        %end;
        %if %upcase(&method)=LIFEREG and &dist ne %then dist=&dist;
        %if %upcase(&method)=PHREG and &ties ne %then ties=&ties;
        %if %upcase(&method)=LIFEREG and %upcase(&nolog)=NOLOG %then nolog;
        ;
  %if &by ne %then %str(by &by;);
  %if &freq ne %then %str(freq &freq;);
  %if &weight ne %then %str(weight &weight;);
  run;


/* Convert covariance matrix to one observation of standard errors.  Add
   sample size in REG models. */
%let int=1;  %let sclshp=0; %let arrvars=intercep &x;
%if %upcase(&method)=PHREG %then %do;
  %let int=0;  %let arrvars=&x;
%end;
%if %upcase(&method)=LIFEREG %then %do;
  %let sclshp=1; %let arrvars=intercep &x _scale_;
  %if %upcase(&dist)=GAMMA %then %do;
    %let sclshp=2; %let arrvars=intercep &x _scale_ _shape1_;
  %end;
%end;
data _estse_;
  array _x{%eval(&nx+&int+&sclshp)} &arrvars;
  array se{%eval(&nx+&int+&sclshp)};
  keep _type_ &by &arrvars;

  /* Pick out stderrs */
  do i=1 to &nx+1+&int+&sclshp;
    set _est_;
    if _type_='PARMS' then output;
    else se{i-1}=sqrt(_x{i-1});
  end;

  /* Add observation of stderrs */
  _type_='STDERR';
  do i=1 to &nx+&int+&sclshp;
    _x{i}=se{i};
  end;
  output;

  /* Add observation of sample sizes in REG models */
  %if %upcase(&method)=REG %then %do;
  set _sscp_ (where=(_type_='N'));
  output;
  run;
  %end;


/* Make each estimate a row.  Columns for each statistic. */
proc transpose data=_estse_ out=_testse_
     (rename=(col1=parms col2=stderr 
      %if %upcase(&method)=REG %then col3=n;
      _name_=variable)
     );
  %if &by ne %then %str(by &by;);
  var &arrvars;
  run;


/* Compute test statistic, p-value and confidence bounds */
%if %upcase(&form)=STATCOL %then %str(options notes stimer;);
%if %upcase(&method)=REG %then %do;
data &out;
  set _testse_;
  t=parms/stderr;
  p=2*probt(-abs(t),n-&nx-1);
  tval=-tinv(&alpha/2,n-&nx-1);
  beta_lcl=parms-tval*stderr;  
  beta_ucl=parms+tval*stderr;
  drop tval n;
  run;
%end;

%if %upcase(&method)=LOGISTIC 
 or %upcase(&method)=PROBIT
 or %upcase(&method)=LIFEREG
 or %upcase(&method)=PHREG %then %do;
data &out;
  set _testse_;
  if variable notin ('_SCALE_','_SHAPE1_') then do;
     chisq=(parms/stderr)**2;
     p=1-probchi(chisq,1);
     beta_lcl=parms-probit(1-(&alpha/2))*stderr;
     beta_ucl=parms+probit(1-(&alpha/2))*stderr;
     %if %upcase(&method)=LOGISTIC %then %do;
       if variable ne 'INTERCEP' then do;
         or=exp(parms);
         or_lcl=exp(beta_lcl);
         or_ucl=exp(beta_ucl);
       end;
     %end;
     %if %upcase(&method)=PHREG %then %do;
       rr=exp(parms);
       rr_lcl=exp(beta_lcl);
       rr_ucl=exp(beta_ucl);
     %end;
  end;
  run;
%end;


/* Put in OUTEST= form */
%if %upcase(&form)=STATROW %then %do;
options notes stimer;
proc transpose data=&out out=&out (rename=(_name_=_type_));
  id variable;
  %if &by ne %then %str(by &by;);
  run;
%end;

%exit:
options notes stimer;
%mend eststats;

