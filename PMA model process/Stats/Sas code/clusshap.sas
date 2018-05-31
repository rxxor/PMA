 /****************************************************************/
 /*          S A S   S A M P L E   L I B R A R Y                 */
 /*                                                              */
 /*    NAME: CLUSSHAP                                            */
 /*   TITLE: ANALYZING SHAPE DISTANCE                            */
 /* PRODUCT: SAS                                                 */
 /*  SYSTEM: ALL                                                 */
 /*    KEYS: CLUSTER DISTANCE                                    */
 /*   PROCS: CLUSTER TREE TABULATE FORMAT                        */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT: WSS             UPDATE: 26sep96                     */
 /*     REF:                                                     */
 /*    MISC: Removed ID statements from CLUSTER                  */
 /*          steps due to TREE bug                     26sep96   */
 /*                                                              */
 /****************************************************************/

Title 'Analyzing Shape Distance';

 /***

The following example shows the analysis of a data set in which
size information is detrimental to the classification.
Imagine that an archaeologist of the future is excavating a 20th
century grocery store. The archaeologist has discovered a large
number of boxes of various sizes, shapes, and colors and wants
to do a preliminary classification based on simple external
measurements: height, width, depth, weight, and the predominant
color of the box. It is known that a given product may have been
sold in packages of different size, so the archaeologist wants
to remove the effect of size from the classification. It is not
known whether color is relevant to the use of the products, so
the analysis should be done both with and without color information.

Unknown to the archaeologist, the boxes actually fall into six
general categories according to the use of the product:
breakfast cereals, crackers, laundry detergents, Little Debbie
snacks, tea, and toothpaste.
These categories are shown in the analysis so that you can
evaluate the effectiveness of the classification.

Since there is no reason for the archaeologist to assume that the
true categories have equal sample sizes or variances, the centroid
method is used to avoid undue bias. Each analysis is done with
Euclidean distances after suitable transformations of the data.
Color is coded as five dummy variables with values of 0 or 1.
The DATA step is as follows:

 ***/

options ls=120;
title2 'Cluster Analysis of Grocery Boxes';
data grocery;
   length name $35   /* name of product */
          class $16  /* category of product */
          unit $1    /* unit of measurement for weights:
                           g=gram
                           o=ounce
                           l=lb
                        all weights are converted to grams */
          color $8   /* predominant color of box */
          height 8   /* height of box in cm. */
          width 8    /* width of box in cm. */
          depth 8    /* depth of box (front to back) in cm. */
          weight 8   /* weight of box in grams */
          c_white c_yellow c_red c_green c_blue 4; /* dummy variables */
   retain class;
   drop unit;

   /*--- read name with possible embedded blanks ---*/
   input name & @;

   /*--- if name starts with "---", it's really a category value ---*/
   if substr(name,1,3) = '---' then do;
      class = substr(name,4,index(substr(name,4),'-')-1);
      delete;
      return;
   end;

   /*--- read the rest of the variables ---*/
   input height width depth weight unit color;

   /*--- convert weights to grams ---*/
   select (unit);
      when ('l') weight = weight * 454;
      when ('o') weight = weight * 28.3;
      when ('g') ;
      otherwise put 'Invalid unit ' unit;
   end;

   /*--- use 0/1 coding for dummy variables for colors ---*/
   c_white  = (color = 'w');
   c_yellow = (color = 'y');
   c_red    = (color = 'r');
   c_green  = (color = 'g');
   c_blue   = (color = 'b');

cards;

---Breakfast cereals---

Cheerios                            32.5 22.4  8.4  567 g y
Cheerios                            30.3 20.4  7.2  425 g y
Cheerios                            27.5 19    6.2  283 g y
Cheerios                            24.1 17.2  5.3  198 g y
Special K                           30.1 20.5  8.5   18 o w
Special K                           29.6 19.2  6.7   12 o w
Special K                           23.4 16.6  5.7    7 o w
Corn Flakes                         33.7 25.4  8     24 o w
Corn Flakes                         30.2 20.6  8.4   18 o w
Corn Flakes                         30   19.1  6.6   12 o w
Grape Nuts                          21.7 16.3  4.9  680 g w
Shredded Wheat                      19.7 19.9  7.5  283 g y
Shredded Wheat, Spoon Size          26.6 19.6  5.6  510 g r
All-Bran                            21.1 14.3  5.2 13.8 o y
Froot Loops                         30.2 20.8  8.5 19.7 o r
Froot Loops                         25   17.7  6.4   11 o r

---Crackers---

Wheatsworth                         11.1 25.2  5.5  326 g w
Ritz                                23.1 16    5.3  340 g r
Ritz                                23.1 20.7  5.2  454 g r
Premium Saltines                    11   25   10.7  454 g w
Waverly Wafers                      14.4 22.5  6.2  454 g g

---Detergent---

Arm & Hammer Detergent              38.8 30   16.9   25 l y
Arm & Hammer Detergent              39.5 25.8 11   14.2 l y
Arm & Hammer Detergent              33.7 22.8  7      7 l y
Arm & Hammer Detergent              27.8 19.4  6.3    4 l y
Tide                                39.4 24.8 11.3  9.2 l r
Tide                                32.5 23.2  7.3  4.5 l r
Tide                                26.5 19.9  6.3   42 o r
Tide                                19.3 14.6  4.7   17 o r

---Little Debbie---

Figaroos                            13.5 18.6  3.7   12 o y
Swiss Cake Rolls                    10.1 21.8  5.8   13 o w
Fudge Brownies                      11   30.8  2.5   12 o w
Marshmallow Supremes                 9.4 32    7     10 o w
Apple Delights                      11.2 30.1  4.9   15 o w
Snack Cakes                         13.4 32    3.4   13 o b
Nutty Bar                           13.2 18.5  4.2   12 o y
Lemon Stix                          13.2 18.5  4.2    9 o w
Fudge Rounds                         8.1 28.3  5.4  9.5 o w

---Tea---

Celestial Saesonings Mint Magic      7.8 13.8  6.3   49 g b
Celestial Saesonings Cranberry Cove  7.8 13.8  6.3   46 g r
Celestial Saesonings Sleepy Time     7.8 13.8  6.3   37 g g
Celestial Saesonings Lemon Zinger    7.8 13.8  6.3   56 g y
Bigelow Lemon Lift                   7.7 13.4  6.9   40 g y
Bigelow Plantation Mint              7.7 13.4  6.9   35 g g
Bigelow Earl Grey                    7.7 13.4  6.9   35 g b
Luzianne                             8.9 22.8  6.4    6 o r
Luzianne                            18.4 20.2  6.9    8 o r
Luzianne Decaffeinated               8.9 22.8  6.4 5.25 o g
Lipton Tea Bags                     17.1 20    6.7    8 o r
Lipton Tea Bags                     11.5 14.4  6.6 3.75 o r
Lipton Tea Bags                      6.7 10    5.7 1.25 o r
Lipton Family Size Tea Bags         13.7 24    9     12 o r
Lipton Family Size Tea Bags          8.7 20.8  8.2    6 o r
Lipton Family Size Tea Bags          8.9 11.1  8.2    3 o r
Lipton Loose Tea                    12.7 10.9  5.4    8 o r

---Paste, Tooth---

Colgate                              4.4 22    3.5    7 o r
Colgate                              3.6 15.6  3.3    3 o r
Colgate                              4.2 18.3  3.5    5 o r
Crest                                4.3 21.7  3.7  6.4 o w
Crest                                4.3 17.4  3.6  4.6 o w
Crest                                3.5 15.2  3.2  2.7 o w
Crest                                3.0 10.9  2.8  .85 o w
Arm & Hammer                         4.4 17    3.7    5 o w
;

 /***

PROC FORMAT is used to define to formats to make the printed output
easier to read. The STARS. format is used for graphical
crosstabulations in PROC TABULATE. The $COLOR format prints the
names of the colors instead of just the first letter.

 ***/

    /*------ formats and macros for displaying cluster results ------*/

proc format; value stars
      0='               '
      1='              *'
      2='             **'
      3='            ***'
      4='           ****'
      5='          *****'
      6='         ******'
      7='        *******'
      8='       ********'
      9='      *********'
     10='     **********'
     11='    ***********'
     12='   ************'
     13='  *************'
     14=' **************'
15-high='>**************';
run;

proc format; value $color
   'w'='White'
   'y'='Yellow'
   'r'='Red'
   'g'='Green'
   'b'='Blue';
run;

 /***

Since a full display of the results of each cluster analysis would
be very long, a macro is used with five macro variables to select
parts of the output. The macro variables are set to select only
the CLUSTER printout and the crosstabulation of clusters and
true categories for the first two analyses. The example could be run
with different settings of the macro variables to show the full
output or other selected parts.

 ***/

%let cluster=1;   /* 1=show CLUSTER output, 0=don't */
%let tree=0;      /* 1=print TREE diagram, 0=don't */
%let list=0;      /* 1=list clusters, 0=don't */
%let crosstab=1;  /* 1=crosstabulate clusters and classes, 0=don't */
%let crosscol=0;  /* 1=crosstabulate clusters and colors, 0=don't */

   /*--- define macro with options for TREE ---*/
%macro treeopt;
   %if &tree %then h page=1;
   %else noprint;
%mend;

   /*--- define macro with options for CLUSTER ---*/
%macro clusopt;
   %if &cluster %then pseudo ccc p=20;
   %else noprint;
%mend;

   /*------------ macro for showing cluster results ------------*/
%macro show(n); /* n=number of clusters to show results for */

proc tree data=tree %treeopt n=&n out=out;
   id name;
   copy class height width depth weight color;
run;

%if &list %then %do;
   proc sort;
      by cluster;
   run;

   proc print;
      var class name height width depth weight color;
      by cluster clusname;
   run;
%end;

%if &crosstab %then %do;
   proc tabulate noseps /* formchar='           ' */;
        class class cluster;
        table cluster, class*n=' '*f=stars./rts=10 misstext=' ';
run;
%end;

%if &crosscol %then %do;
   proc tabulate noseps /* formchar='           ' */;
      class color cluster;
      table cluster, color*n=' '*f=stars./rts=10 misstext=' ';
      format color $color.;
run;
%end;
%mend;

 /***

The first analysis uses the variables HEIGHT, WIDTH, DEPTH, and
WEIGHT in standardized form to show the effect of including size
information. The CCC, pseudo F, and pseudo t**2 statistics
indicate 10 clusters. Most of the clusters do not correspond closely
to the true categories, and four of the clusters have only one or two
observations.

 ***/

   /****************************************************************/
   /*                                                              */
   /*          Analysis 1: standardized box measurements           */
   /*                                                              */
   /****************************************************************/

title3 'Analysis 1: Standardized data';
proc cluster data=grocery m=cen std %clusopt outtree=tree;
   var height width depth weight;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class color;
run;

%show(10);

 /***

The second analysis uses logarithms of HEIGHT, WIDTH, DEPTH, and
the cube root of WEIGHT--the cube root is used for consistency with
the linear measures. The rows are then centered to remove size
information. Finally, the columns are standardized to have a standard
deviation of 1. There is no compelling a priori reason to standardize
the columns, but if they are not standardized, HEIGHT dominates the
analysis because of its large variance. PROC STANDARD is used instead
of the STD option in CLUSTER so that a subsequent analysis can
separately standardize the dummy variables for color.

 ***/

   /****************************************************************/
   /*                                                              */
   /*       Analysis 2: standardized row-centered logarithms       */
   /*                                                              */
   /****************************************************************/

title3 'Row-centered logarithms';
data shape;
   set grocery;
   array x height width depth weight;
   array l l_height l_width l_depth l_weight; /* logarithms */
   weight=weight ** (1/3);     /* take cube root to conform with
                                  the other linear  measurements */
   do over l;                  /* take logarithms */
      l=log(x);
   end;
   mean=mean( of l(*));        /* find row mean of logarithms */
   do over l;
      l=l-mean;                /* center row */
   end;
run;

title3 'Analysis 2: Standardized row-centered logarithms';
proc standard data=shape out=shapstan m=0 s=1;
   var l_height l_width l_depth l_weight;
run;

proc cluster data=shapstan m=cen %clusopt outtree=tree;
   var l_height l_width l_depth l_weight;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class height width depth weight color;
run;

%show(8);

 /***

The results of the second analysis are shown for eight clusters.
Clusters 1 through 4 correspond fairly well to tea, toothpaste,
breakfast cereals, and detergents. Crackers and Little Debbie products
are scattered among several clusters.

 ***/

%show(8);

 /***

The third analysis is similar to the second analysis except that
the rows are standardized rather than just centered. There is a
clear indication of 7 clusters from the CCC, pseudo F, and pseudo t**2
statistics. The clusters are listed as well as crosstabulated with
the true categories and colors.

 ***/

   /****************************************************************/
   /*                                                              */
   /*     Analysis 3: standardized row-standardized logarithms     */
   /*                                                              */
   /****************************************************************/

%let list=1;
%let crosscol=1;

title3 'Row-standardized logarithms';
data std;
   set grocery;
   array x height width depth weight;
   array l l_height l_width l_depth l_weight; /* logarithms */
   weight=weight**(1/3);     /* take cube root to conform with
                                the other linear  measurements */
   do over l;
      l=log(x);              /* take logarithms */
   end;
   mean=mean( of l(*));      /* find row mean of logarithms */
   std=std( of l(*));        /* find row standard deviation */
   do over l;
      l=(l-mean)/std;        /* standardize row */
   end;
run;

title3 'Analysis 3: Standardized row-standardized logarithms';
proc standard data=std out=stdstan m=0 s=1;
   var l_height l_width l_depth l_weight;
run;

proc cluster data=stdstan m=cen %clusopt outtree=tree;
   var l_height l_width l_depth l_weight;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class height width depth weight color;
run;

 /***

The output from the third analysis shows that cluster 1 contains 9
of the 17 teas. Cluster 2 contains all
of the detergents plus Grape Nuts, a very heavy cereal. Cluster 3
includes all of the toothpastes and one Little Debbie product that
is of very similar shape, although roughly twice as large.
Cluster 4 has most of the cereals, Ritz crackers (which come in a box
very similar to most of the cereal boxes), and Lipton Loose Tea (all
the other teas in the sample come in tea bags). Clusters 5
and 6 each contain several Luzianne and Lipton teas and one or two
miscellaneous items. Cluster 7 includes most of the Little Debbie
products and two types of crackers. Thus, the crackers are not
identified and the teas are broken up into three clusters, but
the other categories correspond to single clusters. This analysis
classifies toothpaste and Little Debbie products slightly better
than the second analysis,

  ***/

%show(7);

 /***

The last several analyses include color. Obviously, the dummy variables
must not be included in calculations to standardize the rows. If the
five dummy variables are simply standardized to variance 1.0 and
included with the other variables, color will dominate the analysis.
The dummy variables should be scaled to a smaller variance which must
be determined by trial and error. Four analyses are done using PROC
STANDARD to scale the dummy variables to a standard deviation of
.2, .3, .4, or .8. The cluster listings are suppressed.

Since dummy variables drastically violate the normality assumption
on which the CCC depends, the CCC will tend to indicate an excessively
large number of clusters.

 ***/


   /****************************************************************/
   /*                                                              */
   /*   Analyses 4-7: standardized row-standardized logs & color   */
   /*                                                              */
   /****************************************************************/

%let list=0;
%let crosscol=1;

title3
'Analysis 4: Standardized row-standardized logarithms and color (s=.2)';
proc standard data=stdstan out=stdstan m=0 s=.2;
   var c_:;
run;

proc cluster data=stdstan m=cen %clusopt outtree=tree;
   var l_height l_width l_depth l_weight c_:;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class height width depth weight color;
run;

%show(7);

title3
'Analysis 5: Standardized row-standardized logarithms and color (s=.3)';
proc standard data=stdstan out=stdstan m=0 s=.3;
   var c_:;
run;

proc cluster data=stdstan m=cen %clusopt outtree=tree;
   var l_height l_width l_depth l_weight c_:;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class height width depth weight color;
run;

%show(6);

title3
'Analysis 6: Standardized row-standardized logarithms and color (s=.4)';
proc standard data=stdstan out=stdstan m=0 s=.4;
   var c_:;
run;

proc cluster data=stdstan m=cen %clusopt outtree=tree;
   var l_height l_width l_depth l_weight c_:;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class height width depth weight color;
run;

%show(3);

title3
'Analysis 7: Standardized row-standardized logarithms and color (s=.8)';
proc standard data=stdstan out=stdstan m=0 s=.8;
   var c_:;
run;

proc cluster data=stdstan m=cen %clusopt outtree=tree;
   var l_height l_width l_depth l_weight c_:;
 /*id name; ID statement cannot be used due to bug in PROC TREE in 6.12 */
   copy name class height width depth weight color;
run;

%show(10);

 /***

Using PROC STANDARD on the dummy
variables with S=.2 causes four of the Little Debbie products to
join the toothpastes. Using S=.3 causes one of the tea clusters to
merge with the breakfast cereals while three cereals defect to the
detergents. Using S=.4 produces three clusters consisting of (1)
cereals and detergents, (2) Little Debbie products and toothpaste,
and (3) teas, with crackers divided among all three clusters and
a few other misclassifications. With S=.8, ten clusters are indicated,
each entirely monochrome. So, S=.2 or S=.3 degrades the classification,
S=.4 yields a good but perhaps excessively coarse classification,
and higher values of S= produce clusters that are determined mainly
by color.

 ***/
