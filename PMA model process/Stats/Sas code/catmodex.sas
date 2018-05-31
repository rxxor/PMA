 /****************************************************************/
 /*          S A S   S A M P L E   L I B R A R Y                 */
 /*                                                              */
 /*    NAME: CATMODEX                                            */
 /*   TITLE: Documentation Examples for PROC CATMOD              */
 /* PRODUCT: STAT                                                */
 /*  SYSTEM: ALL                                                 */
 /*    KEYS: categorical data analysis,                          */
 /*   PROCS: CATMOD                                              */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT: dlw/red          UPDATE: 9/23/87 (DCS)              */
 /*     REF:                                                     */
 /*    MISC:                                                     */
 /*                                                              */
 /****************************************************************/

 /* Getting Started Example: WLS Analysis of Mean Response --------*/
 /*                                                                */
 /* From: Stokes, Davis, and Koch (1995, 307-313).                 */
 /*----------------------------------------------------------------*/

data colds;
   input sex $ residence $ periods count @@;
   datalines;
female rural 0  45  female rural 1  64  female rural 2  71
female urban 0  80  female urban 1 104  female urban 2 116
male   rural 0  84  male   rural 1 124  male   rural 2  82
male   urban 0 106  male   urban 1 117  male   urban 2  87
;
run;

proc catmod data=colds;
   weight count;
   response means;
   model periods = sex residence sex*residence;
run;
   model periods = sex residence;
run;
   population sex residence;
   model periods = sex;
run;


 /* Getting Started Example: Generalized Logits Model -------------*/
 /*                                                                */
 /* From: Stokes, Davis, and Koch (1995, 235-240).                 */
 /*----------------------------------------------------------------*/

data school;
   length Program $ 9;
   input School Program $ Style $ Count @@;
   datalines;
1 regular   self 10  1 regular   team 17  1 regular   class 26
1 afternoon self  5  1 afternoon team 12  1 afternoon class 50
2 regular   self 21  2 regular   team 17  2 regular   class 26
2 afternoon self 16  2 afternoon team 12  2 afternoon class 36
3 regular   self 15  3 regular   team 15  3 regular   class 16
3 afternoon self 12  3 afternoon team 12  3 afternoon class 20
;
proc catmod order=data;
   weight Count;
   model Style=School Program School*Program;
run;

proc catmod order=data;
   weight Count;
   model Style=School Program School*Program;
run;
   model Style=School Program;
run;


 /* Example 1: Linear Response Function, r=2 Responses ------------*/
 /*                                                                */
 /*               Detergent Preference Study                       */
 /*               --------------------------                       */
 /* The data are from a consumer blind trial of detergent          */
 /* preference. The variables measured in the study were           */
 /*    softness=softness of laundry water (soft, med, hard)        */
 /*    prev=previous user of brand m? (yes, no)                    */
 /*    temp=temperature of laundry water (high, low)               */
 /*    brand=brand preferred (m, x).                               */
 /*                                                                */
 /* From: Ries and Smith (1963).                                   */
 /*       See also Cox (1970, 38).                                 */
 /*----------------------------------------------------------------*/

title 'Detergent Preference Study';
data detergent;
   input Softness $ Brand $ Previous $ Temperature $ Count @@;
   datalines;
soft X yes high 19   soft X yes low 57
soft X no  high 29   soft X no  low 63
soft M yes high 29   soft M yes low 49
soft M no  high 27   soft M no  low 53
med  X yes high 23   med  X yes low 47
med  X no  high 33   med  X no  low 66
med  M yes high 47   med  M yes low 55
med  M no  high 23   med  M no  low 50
hard X yes high 24   hard X yes low 37
hard X no  high 42   hard X no  low 68
hard M yes high 43   hard M yes low 52
hard M no  high 30   hard M no  low 42
;

proc catmod data=detergent;
   response 1 0;
   weight Count;
   model Brand=Softness|Previous|Temperature
       / freq prob nodesign;
   title2 'Saturated Model';
run;
   model Brand=Softness Previous Temperature / noprofile;
   title2 'Main-Effects Model';
run;
quit;


 /* Example 2: Mean Score Response Function, r=3 Responses --------*/
 /*                                                                */
 /*                Dumping Syndrome Data                           */
 /*                ---------------------                           */
 /* Four surgical operations for duodenal ulcers were compared     */
 /* in a clinical trial at four hospitals. The response was the    */
 /* severity of an undesirable complication called dumping         */
 /* syndrome. The operations were                                  */
 /*                                                                */
 /*      a. drainage and vagotomy                                  */
 /*      b. 25% resection and vagotomy                             */
 /*      c. 50% resection and vagotomy                             */
 /*      d. 75% resection                                          */
 /*                                                                */
 /* From: Grizzle, Starmer, and Koch (1969, 489-504).              */
 /*----------------------------------------------------------------*/

title 'Dumping Syndrome Data';
data operate;
  input Hospital Treatment $ Severity $ wt @@;
  datalines;
1 a none 23    1 a slight  7    1 a moderate 2
1 b none 23    1 b slight 10    1 b moderate 5
1 c none 20    1 c slight 13    1 c moderate 5
1 d none 24    1 d slight 10    1 d moderate 6
2 a none 18    2 a slight  6    2 a moderate 1
2 b none 18    2 b slight  6    2 b moderate 2
2 c none 13    2 c slight 13    2 c moderate 2
2 d none  9    2 d slight 15    2 d moderate 2
3 a none  8    3 a slight  6    3 a moderate 3
3 b none 12    3 b slight  4    3 b moderate 4
3 c none 11    3 c slight  6    3 c moderate 2
3 d none  7    3 d slight  7    3 d moderate 4
4 a none 12    4 a slight  9    4 a moderate 1
4 b none 15    4 b slight  3    4 b moderate 2
4 c none 14    4 c slight  8    4 c moderate 3
4 d none 13    4 d slight  6    4 d moderate 4
;

proc catmod data=operate order=data ;
   weight wt;
   response 0  0.5  1;
   model Severity=Treatment Hospital / freq oneway;
   title2 'Main-Effects Model';
quit;


 /* Example 3: Logistic Regression, Standard Response Function ----*/
 /*                                                                */
 /*          Maximum Likelihood Logistic Regression                */
 /*          --------------------------------------                */
 /* Ingots prepared with different heating and soaking times are   */
 /* tested for readiness to roll.                                  */
 /*                                                                */
 /* From: Cox (1970, 67-68).                                       */
 /*----------------------------------------------------------------*/

title 'Maximum Likelihood Logistic Regression';
data ingots;
   input Heat Soak nready ntotal @@;
   Count=nready;
   Y=1;
   output;
   Count=ntotal-nready;
   Y=0;
   output;
   drop nready ntotal;
   datalines;
7 1.0 0 10   14 1.0 0 31   27 1.0 1 56   51 1.0 3 13
7 1.7 0 17   14 1.7 0 43   27 1.7 4 44   51 1.7 0  1
7 2.2 0  7   14 2.2 2 33   27 2.2 0 21   51 2.2 0  1
7 2.8 0 12   14 2.8 0 31   27 2.8 1 22   51 4.0 0  1
7 4.0 0  9   14 4.0 0 19   27 4.0 1 16
;

proc catmod data=ingots;
   weight Count;
   direct Heat Soak;
   model Y=Heat Soak / freq covb corrb;
quit;


 /* Example 4: Log-Linear Model, Three Dependent Variables --------*/
 /*                                                                */
 /*                  Bartlett's Data                               */
 /*                  ---------------                               */
 /* Cuttings of two different lengths were planted at one of two   */
 /* time points, and their survival status was recorded. The       */
 /* variables are                                                  */
 /*    v1=survival status (dead or alive)                          */
 /*    v2=time of planting (spring or at_once)                     */
 /*    v3=length of cutting (long or short).                       */
 /*                                                                */
 /* From: Bishop, Fienberg, and Holland (1975, 89)                 */
 /*----------------------------------------------------------------*/

title 'Bartlett''s Data';
data b;
   input Length Time Status wt @@;
   datalines;
1 1 1 156     1 1 2  84     1 2 1 84     1 2 2 156
2 1 1 107     2 1 2 133     2 2 1 31     2 2 2 209
;

proc catmod data=b;
   weight wt;
   model Length*Time*Status=_response_
       / noparm noresponse pred=freq;
   loglin Length|Time|Status @ 2;
   title2 'Model with No 3-Variable Interaction';
quit;


 /* Example 5: Log-Linear Model, Structural and Sampling Zeros ----*/
 /*                                                                */
 /*               Behavior of Squirrel Monkeys                     */
 /*               ----------------------------                     */
 /* In a population of 6 squirrel monkeys, the joint distribution  */
 /* of genital display with respect to (active role, passive role) */
 /* was observed. Since a monkey cannot have both the active and   */
 /* passive roles in the same interaction, the diagonal cells of   */
 /* the table are structural zeros.                                */
 /*                                                                */
 /* From: Fienberg (1980, Table 8-2)                               */
 /*----------------------------------------------------------------*/

title 'Behavior of Squirrel Monkeys';
data Display;
   input Active $ Passive $ wt @@;
   if Active ne 't';
   if Active ne Passive then
      if wt=0 then wt=1e-20;
   datalines;
r r  0   r s  1   r t  5   r u  8   r v  9   r w  0
s r 29   s s  0   s t 14   s u 46   s v  4   s w  0
t r  0   t s  0   t t  0   t u  0   t v  0   t w  0
u r  2   u s  3   u t  1   u u  0   u v 38   u w  2
v r  0   v s  0   v t  0   v u  0   v v  0   v w  1
w r  9   w s 25   w t  4   w u  6   w v 13   w w  0
;

proc catmod data=Display;
   weight wt;
   model Active*Passive=_response_
       / freq pred=freq noparm noresponse oneway;
   loglin Active Passive;
   contrast 'Passive, U vs. V' Passive 0 0 0 1 -1;
   contrast 'Active,  U vs. V' Active  0 0 1 -1;
   title2 'Test Quasi-Independence for the Incomplete Table';
quit;


 /* Example 6: Repeated Measures, 2 Response Levels, 3 Populations */
 /*                                                                */
 /*            Multi-Population Repeated Measures                  */
 /*            ----------------------------------                  */
 /* Subjects from 3 groups have their response (0 or 1) recorded   */
 /* at each of four trials.                                        */
 /*                                                                */
 /* From: Guthrie (1981).                                          */
 /*----------------------------------------------------------------*/

title 'Multi-Population Repeated Measures';
data group;
   input a b c d Group wt @@;
   datalines;
1 1 1 1 2 2     0 0 0 0 2 2     0 0 1 0 1 2     0 0 1 0 2 2
0 0 0 1 1 4     0 0 0 1 2 1     0 0 0 1 3 3     1 0 0 1 2 1
0 0 1 1 1 1     0 0 1 1 2 2     0 0 1 1 3 5     0 1 0 0 1 4
0 1 0 0 2 1     0 1 0 1 2 1     0 1 0 1 3 2     0 1 1 0 3 1
1 0 0 0 1 3     1 0 0 0 2 1     0 1 1 1 2 1     0 1 1 1 3 2
1 0 1 0 1 1     1 0 1 1 2 1     1 0 1 1 3 2
;

proc catmod data=group;
   weight wt;
   response marginals;
   model a*b*c*d=Group _response_ Group*_response_
       / freq nodesign;
   repeated Trial 4;
   title2 'Saturated Model';
run;
   model a*b*c*d=Group _response_(Group=3)
       / noprofile noparm;
   title2 'Trial Nested within Group 3';
quit;


 /* Example 7: Repeated Measures, 4 Response Levels, 1 Population -*/
 /*                                                                */
 /*           Testing Vision: Right Eye vs. Left                   */
 /*           ----------------------------------                   */
 /* 7477 women aged 30-39 were tested for vision in both right and */
 /* left eyes. Marginal homogeneity is tested by the main effect   */
 /* of the repeated measurement factor, SIDE.                      */
 /*                                                                */
 /* From: Grizzle, Starmer and Koch (1969, 493).                   */
 /*----------------------------------------------------------------*/

title 'Vision Symmetry';
data vision;
   input Right Left count @@;
   datalines;
1 1 1520    1 2  266    1 3  124    1 4  66
2 1  234    2 2 1512    2 3  432    2 4  78
3 1  117    3 2  362    3 3 1772    3 4 205
4 1   36    4 2   82    4 3  179    4 4 492
;

proc catmod data=vision;
   weight count;
   response marginals;
   model Right*Left=_response_ / freq;
   repeated Side 2;
   title2 'Test of Marginal Homogeneity';
quit;


 /* Example 8: Repeated Measures, Logistic Analysis of Growth Curve*/
 /*                                                                */
 /*                Growth Curve Analysis                           */
 /*                ---------------------                           */
 /* Subjects from 2 diagnostic groups (mild or severe) are given   */
 /* one of 2 treatments (std or new), and their response to        */
 /* treatment (n=normal or a=abnormal) is recorded at each of 3    */
 /* times (weeks 1, 2, and 4)                                      */
 /*                                                                */
 /* From: Koch et al. (1977)                                       */
 /*----------------------------------------------------------------*/

title 'Growth Curve Analysis';
data growth2;
   input Diagnosis $ Treatment $ week1 $ week2 $ week4 $ count @@;
   datalines;
mild std n n n 16    severe std n n n  2
mild std n n a 13    severe std n n a  2
mild std n a n  9    severe std n a n  8
mild std n a a  3    severe std n a a  9
mild std a n n 14    severe std a n n  9
mild std a n a  4    severe std a n a 15
mild std a a n 15    severe std a a n 27
mild std a a a  6    severe std a a a 28
mild new n n n 31    severe new n n n  7
mild new n n a  0    severe new n n a  2
mild new n a n  6    severe new n a n  5
mild new n a a  0    severe new n a a  2
mild new a n n 22    severe new a n n 31
mild new a n a  2    severe new a n a  5
mild new a a n  9    severe new a a n 32
mild new a a a  0    severe new a a a  6
;

proc catmod data=growth2 order=data;
   title2 'Reduced Logistic Model';
   weight count;
   population Diagnosis Treatment;
   response logit;
   model week1*week2*week4=(1 0 0 0,  /* mild, std */
                            1 0 1 0,
                            1 0 2 0,

                            1 0 0 0,  /* mild, new */
                            1 0 0 1,
                            1 0 0 2,

                            0 1 0 0,  /* severe, std */
                            0 1 1 0,
                            0 1 2 0,

                            0 1 0 0,  /* severe, new */
                            0 1 0 1,
                            0 1 0 2)(1='Mild diagnosis, week 1',
                                     2='Severe diagnosis, week 1',
                                     3='Time effect for std trt',
                                     4='Time effect for new trt')
                                     / freq;
   contrast 'Diagnosis effect, week 1' all_parms 1 -1 0 0;
   contrast 'Equal time effects' all_parms 0 0 1 -1;
quit;


 /* Example 9: Repeated Measures, Two Repeated Measurement Factors */
 /*                                                                */
 /*              Diagnostic Procedure Comparison                   */
 /*              -------------------------------                   */
 /* Two diagnostic procedures (standard and test) are done on each */
 /* subject, and the results of both are evaluated at each of two  */
 /* times as being positive or negative.                           */
 /*                                                                */
 /* From: MacMillan et al. (1981).                                 */
 /*----------------------------------------------------------------*/


title 'Diagnostic Procedure Comparison';
data a;
   input std1 $ test1 $ std2 $ test2 $ wt @@;
   datalines;
neg neg neg neg 509  neg neg neg pos  4  neg neg pos neg  17
neg neg pos pos   3  neg pos neg neg 13  neg pos neg pos   8
neg pos pos pos   8  pos neg neg neg 14  pos neg neg pos   1
pos neg pos neg  17  pos neg pos pos  9  pos pos neg neg   7
pos pos neg pos   4  pos pos pos neg  9  pos pos pos pos 170
;

proc catmod data=a;
   title2 'Marginal Symmetry, Saturated Model';
   weight wt;
   response marginals;
   model std1*test1*std2*test2=_response_ / freq noparm;
   repeated Time 2, Treatment 2 / _response_=Time Treatment Time*Treatment;
run;
   title2 'Marginal Symmetry, Reduced Model';
   model std1*test1*std2*test2=_response_ / noprofile corrb;
   repeated Time 2, Treatment 2 / _response_=Treatment;
run;

   title2 'Sensitivity and Specificity Analysis, '
   'Main-Effects Model';
   model std1*test1*std2*test2=_response_ / covb noprofile;
   repeated Time 2, Accuracy 2 / _response_=Time Accuracy;
   response exp  1 -1  0  0  0  0  0  0,
                 0  0  1 -1  0  0  0  0,
                 0  0  0  0  1 -1  0  0,
                 0  0  0  0  0  0  1 -1

            log 0 0 0 0   0 0 0   0 0 0 0   1 1 1 1,
                0 0 0 0   0 0 0   1 1 1 1   1 1 1 1,
                1 1 1 1   0 0 0   0 0 0 0   0 0 0 0,
                1 1 1 1   1 1 1   0 0 0 0   0 0 0 0,
                0 0 0 1   0 0 1   0 0 0 1   0 0 0 1,
                0 0 1 1   0 0 1   0 0 1 1   0 0 1 1,
                1 0 0 0   1 0 0   1 0 0 0   1 0 0 0,
                1 1 0 0   1 1 0   1 1 0 0   1 1 0 0;
quit;


 /* Example 10: Direct Input of Response Functions and Covariance Matrix */
 /*                                                                */
 /*              Health Survey Data Analysis                       */
 /*              ---------------------------                       */
 /* Variational models are fit to health survey data. Estimates    */
 /* of a well-being index have been computed for domains           */
 /* corresponding to an age by sex cross-classification.           */
 /*                                                                */
 /* From: Koch and Stokes (1979).                                  */
 /*----------------------------------------------------------------*/

data fbeing(type=est);
   input   b1-b5   _type_ $  _name_ $  b6-b10 #2;
   datalines;
7.93726   7.92509   7.82815   7.73696   8.16791  parms    .
7.24978   7.18991   7.35960   7.31937   7.55184
0.00739   0.00019   0.00146  -0.00082   0.00076  cov      b1
0.00189   0.00118   0.00140  -0.00140   0.00039
0.00019   0.01172   0.00183   0.00029   0.00083  cov      b2
-0.00123  -0.00629  -0.00088  -0.00232   0.00034
0.00146   0.00183   0.01050  -0.00173   0.00011  cov      b3
0.00434  -0.00059  -0.00055   0.00023  -0.00013
-0.00082   0.00029  -0.00173   0.01335   0.00140  cov      b4
0.00158   0.00212   0.00211   0.00066   0.00240
0.00076   0.00083   0.00011   0.00140   0.01430  cov      b5
-0.00050  -0.00098   0.00239  -0.00010   0.00213
0.00189  -0.00123   0.00434   0.00158  -0.00050  cov      b6
0.01110   0.00101   0.00177  -0.00018  -0.00082
0.00118  -0.00629  -0.00059   0.00212  -0.00098  cov      b7
0.00101   0.02342   0.00144   0.00369   0.25300
0.00140  -0.00088  -0.00055   0.00211   0.00239  cov      b8
0.00177   0.00144   0.01060   0.00157   0.00226
-0.00140  -0.00232   0.00023   0.00066  -0.00010  cov      b9
-0.00018   0.00369   0.00157   0.02298   0.00918
0.00039   0.00034  -0.00013   0.00240   0.00213  cov     b10
-0.00082   0.00253   0.00226   0.00918   0.01921
;

proc catmod data=fbeing;
   title 'Complex Sample Survey Analysis';
   response read b1-b10;
   factors sex $ 2, age $ 5 / _response_=sex age
   profile=(male     '25-34',
            male     '35-44',
            male     '45-54',
            male     '55-64',
            male     '65-74',
            female   '25-34',
            female   '35-44',
            female   '45-54',
            female   '55-64',
            female   '65-74');
   model _f_=_response_ / title='Main Effects for Sex and Age';
run;
   contrast 'No Age Effect for Age<65' all_parms 0 0 1 0 0 -1,
                                       all_parms 0 0 0 1 0 -1,
                                       all_parms 0 0 0 0 1 -1;
run;

   model _f_=(1  1  1,
              1  1  1,
              1  1  1,
              1  1  1,
              1  1 -1,
              1 -1  1,
              1 -1  1,
              1 -1  1,
              1 -1  1,
              1 -1 -1) (1='Intercept' ,
                        2='Sex'       ,
                        3='Age (25-64 vs. 65-74)')
                        / title='Binary Age Effect (25-64 vs. 65-74)' ;
quit;


 /* Example 11:  Predicted Probabilities */

data loan;
   input Education $ Income $ Purchase $ wt;
   datalines;
high  high  yes    54
high  high  no     23
high  low   yes    41
high  low   no     12
low   high  yes    35
low   high  no     42
low   low   yes    19
low   low   no      8
;

ods output PredictedValues=Predicted(keep=Education Income PredFunction);

proc catmod data=loan order=data;
   weight wt;
   response marginals;
   model Purchase=Education Income / pred;
run;

proc sort data=Predicted;
   by descending PredFunction;
run;

proc print data=Predicted;
run;
