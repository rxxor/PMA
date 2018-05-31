/************************************************************************

                                SCORENEW


   DISCLAIMER:
     THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A SERVICE TO
     ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO WARRANTIES,
     EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR FITNESS FOR A
     PARTICULAR PURPOSE REGARDING THE ACCURACY OF THE MATERIALS OR CODE
     CONTAINED HEREIN.

   PURPOSE:
     Demonstrates using a logistic model fit on one data set to score a
     data set of new observations.  Predicted probabilities are computed
     for the new observations.

   REQUIRES:
     Release 6.11 or later.  Preferably, Release 6.12 TS045 or later.
     See "Limitations" below.

   USAGE:
     The OUTEST= option is used in the first run of PROC LOGISTIC to
     output the parameter estimates.  This data set is input using the
     INEST= option in the second run when scoring the new observations.
     The MAXITER=0 option is used to force LOGISTIC to use the provided
     estimates.

     To illustrate that predicted probabilities for new observations are
     correct, a subset of the data set used to fit the model are scored
     in a second run of LOGISTIC as though they were new observations.
     Note that their predicted probabilities are the same as from the
     first run of LOGISTIC.  Also note that the parameter estimates in
     both runs are the same.  If you see a change in standard errors and
     p-values, see "Limitations" below.

   LIMITATIONS:
     See SAS Note V6-LOGISTIC-D908, which documents a bug prior to
     Release 6.12 TS045 in which the covariance matrix (and therefore
     any related statistics such as confidence intervals on predicted
     probabilities) is incorrect when the INEST= and MAXITER=0 options
     are used together.  Other statistics, such as predicted probabilities
     are correct.

************************************************************************/
data remiss;
  input remiss cell smear infil li blast temp;
  cards;
    1 .8 .83 .66 1.9 1.1 .996
    1 .9 .36 .32 1.4 .74 .992
    0 .8 .88 .7 .8 .176 .982
    0 1 .87 .87 .7 1.053 .986
    1 .9 .75 .68 1.3 .519 .98
    0 1 .65 .65 .6 .519 .982
    1 .95 .97 .92 1 1.23 .992
    0 .95 .87 .83 1.9 1.354 1.02
    0 1 .45 .45 .8 .322 .999
    0 .95 .36 .34 .5 0 1.038
    0 .85 .39 .33 .7 .279 .988
    0 .7 .76 .53 1.2 .146 .982
    0 .8 .46 .37 .4 .38 1.006
    0 .2 .39 .08 .8 .114 .99
    0 1 .9 .9 1.1 1.037 .99
    1 1 .84 .84 1.9 2.064 1.02
    0 .65 .42 .27 .5 .114 1.014
    0 1 .75 .75 1 1.322 1.004
    0 .5 .44 .22 .6 .114 .99
    1 1 .63 .63 1.1 1.072 .986
    0 1 .33 .33 .4 .176 1.01
    0 .9 .93 .84 .6 1.591 1.02
    1 1 .58 .58 1 .531 1.002
    0 .95 .32 .3 1.6 .886 .988
    1 1 .6 .6 1.7 .964 .99
    1 1 .69 .69 .9 .398 .986
    0 1 .73 .73 .7 .398 .986
;

proc logistic data=remiss outest=parms descending;
  model remiss = li cell temp;
  output out=out1 p=p;
  run;

proc print data=out1;
  var li cell temp _level_ p;
  run;

data new;
  input remiss cell smear infil li blast temp;
  cards;
    1 .8 .83 .66 1.9 1.1 .996
    1 .9 .36 .32 1.4 .74 .992
    0 .8 .88 .7 .8 .176 .982
    0 1 .87 .87 .7 1.053 .986
    1 .9 .75 .68 1.3 .519 .98
;

proc logistic data=new inest=parms descending;
  model remiss = li cell temp / maxiter=0;
  output out=out2 p=p;
  run;

proc print data=out2;
  var li cell temp _level_ p;
  run;
