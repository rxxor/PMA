 /****************************************************************/
 /*          S A S   A U T O C A L L   L I B R A R Y             */
 /*                                                              */
 /*    NAME: PHCHOICE                                            */
 /*   TITLE: Customize PROC PHREG Output for Choice Models       */
 /* PRODUCT: STAT                                                */
 /*  SYSTEM: ALL                                                 */
 /*    KEYS: marketing research, choice modeling                 */
 /*   PROCS: TEMPLATE                                            */
 /*    DATA:                                                     */
 /*                                                              */
 /* SUPPORT: saswfk                      UPDATE:  20APR00        */
 /*     REF: See "Multinomial Logit, Discrete Choice Modeling"   */
 /*          in the Book "Marketing Research Methods in the SAS  */
 /*          System, A Collection of Papers and Handouts"        */
 /*          (available from saswfk@wnt.sas.com) for more        */
 /*          information on this macro.                          */
 /****************************************************************/

 /*--------------------------------------------------------------------

Run %phchoice(on) to run PROC TEMPLATE to customize the
output of PROC PHREG for choice models.

Run %phchoice(off) to return to the default templates.

Run %phchoice(expb) customize the output for choice models
and add the Hazard Ratio Statistic, exp(Beta Hat) to the
output.

You can optionally specify a second argument that
contains a list of columns to print.
Select names from the following list:
   Variable DF Estimate StdErr ChiSq ProbChiSq
   HazardRatio HRLowerCL HRUpperCL Label

Example, to print the variable instead of the label, specify:
%phchoice(on, Variable DF Estimate StdErr ChiSq ProbChiSq)

The default columns are:
   Label DF Estimate StdErr ChiSq ProbChiSq HazardRatio

-----------------------------------------------------------------------

 DISCLAIMER:

       THIS INFORMATION IS PROVIDED BY SAS INSTITUTE INC. AS A SERVICE
 TO ITS USERS.  IT IS PROVIDED "AS IS".  THERE ARE NO WARRANTIES,
 EXPRESSED OR IMPLIED, AS TO MERCHANTABILITY OR FITNESS FOR A
 PARTICULAR PURPOSE REGARDING THE ACCURACY OF THE MATERIALS OR CODE
 CONTAINED HEREIN.


---------------------------------------------------------------------*/

                         /*--------------------------------------*/
%macro phchoice(onoff,   /* ON   - turn on choice model          */
                         /*        customization.                */
                         /* OFF  - turn off choice model         */
                         /*        customization, return to      */
                         /*        default PROC PHREG templates. */
                         /* EXPB - turn on choice model          */
                         /*        customization and adds the    */
                         /*        hazard ratio to the output.   */
                         /* Upper/lower case does not matter.    */
                         /*--------------------------------------*/
                column); /* Optional column list for more        */
                         /* extensive customizations.            */
                         /*--------------------------------------*/

* Set default columns, handle ONOFF = EXPB;
%if %nrbquote(&column) eq %then %do;
   %let column = Label DF Estimate StdErr ChiSq ProbChiSq;
   %if %upcase(%nrbquote(&onoff)) eq EXPB %then %do;
      %let column = &column HazardRatio;
      %let onoff = ON;
      %end;
   %end;

* Customize PROC PHREG output for choice models;
%if %upcase(%nrbquote(&onoff)) eq ON %then %do;

   proc template;
      edit Stat.Phreg.ParameterEstimates;
         column &column;
         header h1;
         define h1;
            text "Multinomial Logit Parameter Estimates";
            space = 1;
            spill_margin;
            end;

         %let column = %upcase(%nrbquote(&column));

         %if %index(%nrbquote(&column), LABEL) %then %do;
            define Label;
               header = " " style = RowHeader;
               end;
            %end;

         %if %index(%nrbquote(&column), HAZARDRATIO) %then %do;
            define HazardRatio;
               header = "exp(B)";
               format = 8.3;
               end;
            %end;

         end;

      edit Stat.Phreg.CensoredSummary;
         column Stratum Pattern Freq GenericStrVar Total Event Censored;
         header h1;
         define h1;
            text "Summary of Subjects, Sets, "
                 "and Chosen and Unchosen Alternatives";
            space = 1;
            spill_margin;
            first_panel;
         end;
         define Freq;
           header=";Number of;Choices" format=6.0;
         end;
         define Total;
            header = ";Number of;Alternatives";
            format_ndec = ndec;
            format_width = 8;
         end;
         define Event;
            header = ";Chosen;Alternatives";
            format_ndec = ndec;
            format_width = 8;
         end;
         define Censored;
            header = "Not Chosen";
            format_ndec = ndec;
            format_width = 8;
         end;
         end;
      run;

   %end;

%* Delete edited templates, restore original templates;
%else %do;

   proc template;
      delete Stat.Phreg.ParameterEstimates;
      delete Stat.Phreg.CensoredSummary;
      run;

   %end;

%mend;
