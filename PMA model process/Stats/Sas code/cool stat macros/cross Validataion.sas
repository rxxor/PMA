data rx(type=profit);
	input CLASS$ prior le50K gt50K;
	datalines;

<=50K .98  0   -.8
>50k  .02  0  39.2
;
run;

data randomize;
	set &_train;
	u=ranuni(9);
run;

proc rank data=randomize groups=10 out=crossdata;
var u;
ranks cross;
run;

%macro cvch(maxbranch=2,maxdepth=12,splitsize=30,leafsize=15,nodesample=1500,
				exhaust=5000,adjust=kassafter,assess=PROFIT,maxminid=maxid);

proc datasets;
     delete all: /gennum=all;
run;

%local i;
%do i=0 %to 500 %by 20;
	
	data dataset;
	     set crossdata;
		if &i=0 then do;
			p=.0001;
		end;
		else p=(&i/5000);	
	run;

	data _null_;
		set dataset;
		call symput ('p',p);
	run;

	proc datasets;
    	delete last: /gennum=all;
	run;

	%local j;
	%do j=0 %to 9 %by 1;

		data dataset&j;
			set dataset;
    		if cross ne &j;
    	run;

		data valid&j;
			set dataset;
			if cross=&j;
		run;

		proc dmdb data=dataset&j dmdbcat=dmdset&j out=dset&j;
			var &_intrvl;
			class &_class &_targets(desc);
			target &_targets;
		run;

		proc split data=dset&j  dmdbcat=dmdset&j
				criterion=probchisq
				worth=&p
				splitsize=&splitsize
				leafsize=&leafsize	 
				padjust=&adjust
				subtree=largest
				maxbranch=&maxbranch
        		maxdepth=&maxdepth
				nodesample=&nodesample
				exhaustive=&exhaust
				assess=&assess
				validata=valid&j
        		outseq=subtree&j;
		decision decdata=rx decvar=le50K gt50K priorvar=prior;
		input &_nominal &_binary /level=nominal;
		input &_ordinal/ level=ordinal;
		input &_intrvl/ level=interval;
		target &_targets / level=&_tgmeas;
		run;
 
		data last&j;
   			set subtree&j end=last;
   			if last=1 then output;
		run;

		proc append base=last data=last&j;
		run;

	%end;

		proc means data=last noprint;
		var _qscore_ _vqscor_;
		output out=fin&i mean (_qscore_) =  trainmean 
		stderr (_qscore_) = tse mean (_vqscor_)=
		valmean stderr(_vqscor_)=vse;
	run;
   
		data fin&i;
		set fin&i;
		worth=&p;
	run;
	
	proc append base=all data=fin&i;
	run;

%end;

title "Cross-validated &assess vs Worth";
proc print data=all  label split='*' noobs;
	var worth trainmean tse valmean vse _freq_;
	label trainmean = "Average &assess*on*Training"
			tse = 'Approximate*Training*Standard Error'
			valmean = "Average &assess*on*Validation"
			vse = 'Approximate*Validation*Standard Error'
            _freq_ = 'Number of*Assessments'; 
run;

axis1 label=("&assess") w=2 offset=(5pct);
axis2 label=('Worth') w=2 offset=(10pct); 
symbol1 c=red v=dot h=2pct;
symbol2 c=black v=square h=2pct;

legend1 frame cframe=ligr label=none value=('Validation data' 'Training data') cborder=black 
        position=center; 


proc gplot data=all;
	plot valmean*worth trainmean*worth/overlay frame legend=legend1 vaxis=axis1 haxis=axis2;
run;
quit;

proc means data=all noprint;
   var valmean;
   output out=best &maxminid(valmean(worth))=pval;
run;

data _null_;
   set best;
   call symput('pval',pval);
run;

title 'Best Worth';
proc print data=best;
run;
proc dmdb data=dataset dmdbcat=dmdset out=dset;
		var &_intrvl;
		class &_class &_targets(desc);
		target &_targets;
run;

proc split data=dset  dmdbcat=dmdset
		criterion=probchisq
		worth=&pval
		splitsize=&splitsize
		leafsize=&leafsize
		padjust=&adjust
		subtree=largest
		maxbranch=&maxbranch
   		maxdepth=&maxdepth
		nodesample=&nodesample
		exhaustive=&exhaust
		assess=&assess
		outleaf=leaf
		outmatrix=matrix;
	decision decdata=rx decvar= le50K gt50K priorvar=prior;
	input &_nominal &_binary /level=nominal;
	input &_ordinal/ level=ordinal;
	input &_intrvl/ level=interval;
	target &_targets / level=&_tgmeas;
run;
 
title "Final tree: Worth=&pval";

proc print data=leaf;
run;

proc print data=matrix;
run;

%mend cvch;

%cvch
run;
