/*This program is to get the descriptive stats for the paper with Adam Biener
 * on race/ethnicity, sex, and sexual orientation disparities in mental health 
 * treatment. Data is only observations in my sample and variables I am interested
 * in getting the descriptive stats for.
 * Program created: March 12, 2025 */
PROC IMPORT OUT= WORK.nsduh 
            DATAFILE= "O:\Files\sas code.dta" 
            DBMS=STATA REPLACE;

RUN;


proc contents data=nsduh varnum;
run;


/*create macro*/
%macro varmeans (varname=);
proc sort data=nsduh; 
by &varname.;
run;


proc means data=nsduh nmiss;
var /*health*/ age18_25 age26_34 age35_49 age50_64 /*age*/
health_fair_poor health_good health_very_good health_excellent /*health*/
k6_mild k6_moderate k6_severe /*k6*/
/*Drug use recency*/ 
no_alcohol_use under30_alcohol_use over30_alcohol_use
no_illicit_use under30_illicit_use over30_illicit_use
no_mj_use under30_mj_use over30_mj_use
no_pres_misuse under30_pres_misuse over30_pres_misuse
no_tobacco_use under30_tobacco_use over30_tobacco_use
/*SES*/
no_kid one_kid two_kids more3_kids  /*children*/
no_elder one_elder two_elders /*elders*/
no_hs hs_grad some_college college_grad /*education*/
poverty upto_2xpoverty above_2xpoverty  /*income*/
private public uninsured /*insurance*/
never_married married divorced widowed /*marital status*/
nonmetro small_metro large_metro /*county type*/
spanish  /*survey language*/
year_2015 year_2016 year_2017 year_2018 year_2019 /*year of survey*/
;
by &varname.;
run;
%mend varmeans;





ODS rtf file="O:\Stat MS\Spring 2025\Sta 512\descriptivestat.rtf";
%varmeans (varname=sub_wfh);
%varmeans (varname=sub_bfh);
%varmeans (varname=sub_hfh);

%varmeans (varname=sub_wfb);
%varmeans (varname=sub_bfb);
%varmeans (varname=sub_hfb);

%varmeans (varname=sub_wfg);
%varmeans (varname=sub_bfg);
%varmeans (varname=sub_hfg);

%varmeans (varname=sub_wmh);
%varmeans (varname=sub_bmh);
%varmeans (varname=sub_hmh);

%varmeans (varname=sub_wmb);
%varmeans (varname=sub_bmb);
%varmeans (varname=sub_hmb);

%varmeans (varname=sub_wmg);
%varmeans (varname=sub_bmg);
%varmeans (varname=sub_hmg);
ods rtf close;







/* This is what I did to correct missing values in poverty 
%macro povmeans (varname=);
data nsduh2;
set nsduh;
if below_poverty=1 then poverty3x="Below";
if upto_2xpoverty=1 then poverty3x="Lower";
if over_2xpoverty=1 then poverty3x="Over";
run;

proc sort data=nsduh2;
by  &varname.;
run;

proc surveyfreq data=nsduh2;
by  &varname.;
tables poverty3x ; 
run;
%mend povmeans;

ODS rtf file="O:\Stat povstats.rtf";
%povmeans (varname=sub_wfh);
%povmeans (varname=sub_bfh);
%povmeans (varname=sub_hfh);

%povmeans (varname=sub_wfb);
%povmeans (varname=sub_bfb);
%povmeans (varname=sub_hfb);

%povmeans (varname=sub_wfg);
%povmeans (varname=sub_bfg);
%povmeans (varname=sub_hfg);

%povmeans (varname=sub_wmh);
%povmeans (varname=sub_bmh);
%povmeans (varname=sub_hmh);

%povmeans (varname=sub_wmb);
%povmeans (varname=sub_bmb);
%povmeans (varname=sub_hmb);

%povmeans (varname=sub_wmg);
%povmeans (varname=sub_bmg);
%povmeans (varname=sub_hmg);
ods rtf close;








%macro marmeans (varname=);
data nsduh2;
set nsduh;
if never_married=1 then marriage="Alone";
if married=1 then marriage="Married";
if divorced=1 then marriage="Seperated";
if widowed=1 then marriage="Widowed";
run;

proc sort data=nsduh2;
by  &varname.;
run;

proc surveyfreq data=nsduh2;
by  &varname.;
tables marriage ; 
run;
%mend marmeans;

ODS rtf file="O:\Stat marstats.rtf";
%marmeans (varname=sub_wfh);
%marmeans (varname=sub_bfh);
%marmeans (varname=sub_hfh);

%marmeans (varname=sub_wfb);
%marmeans (varname=sub_bfb);
%marmeans (varname=sub_hfb);

%marmeans (varname=sub_wfg);
%marmeans (varname=sub_bfg);
%marmeans (varname=sub_hfg);

%marmeans (varname=sub_wmh);
%marmeans (varname=sub_bmh);
%marmeans (varname=sub_hmh);

%marmeans (varname=sub_wmb);
%marmeans (varname=sub_bmb);
%marmeans (varname=sub_hmb);

%marmeans (varname=sub_wmg);
%marmeans (varname=sub_bmg);
%marmeans (varname=sub_hmg);
ods rtf close;

proc freq data=nsduh2;
table irmaritx*sub_wfh;
run;

