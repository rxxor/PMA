data reading;
input reading verbal achmot;
cards;
2 1 3
4 2 5
4 1 3
1 1 4
5 3 6
4 4 5
7 5 6
9 5 7
7 7 8
8 6 4
5 4 3
2 3 4
8 6 6
6 6 7
10 8 7
9 9 6
3 2 6
6 6 5
7 4 6
10 4 9
;
proc means; 
title 'basic descriptive statistics';
 
proc standard mean=0 data=reading out=reading;
var reading verbal achmot;
title 'transforms data to deviation score matrix';
title2 'notice that the intercept for all printouts will now be 0';
 
 
proc corr cov;var reading verbal achmot;
title 'correlation matrix and covariance matrix';
title2 ;
 
proc reg;model reading=verbal achmot/stb;
output out=resids r=residr;
title 'standard regression output';
 
proc glm data=reading;model reading=verbal achmot;
title 'same analysis, but using proc glm';
 
proc calis data=reading cov rdf=0 method=ml ;
lineqs
reading= beta1 verbal + beta2 achmot +e1;
std
e1=residual,
verbal=verbvar (2),
achmot=achvar (2);
cov
verbal achmot=covar;
title 'Least Squares Regression as simple Multiple Correlation';
 
proc calis data=reading rdf=2 cov method=ml ;
lineqs
reading= beta1 verbal + beta2 achmot +e1;
std
e1=residual,
verbal=verbvar (2),
achmot=achvar (2);
cov
verbal achmot=covar;
title 'Least Squares Regression as simple Multiple Correlation';
title2 '(adjustment to the degrees of freedom so that the ';
title3 'standard errors match regression)';
 
proc standard mean=0 std=1 data=resids out=resids;
var reading verbal achmot residr;
title 'notice that we can get the same values in the path diagram by standardizing all exogenous variables';
title2 'the residual is merely another variable we could calculate- notice that rsquare is now 1 as assumed in the model';
proc reg data=resids;
model reading=verbal achmot residr/stb;
