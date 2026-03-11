//load data

use "O:\Files\NSDUH_2010_2019.dta", clear

// Line 250 creates health dummies
// Line 763 creates identity dummies
// Line 950 creates SES dummies
// After editing vars and creating dummies I exported the necessary variables to a SAS file
// Got mean and SE for eachy dummy variable by identity using SAS macro
*************************************************************
*************************************************************
//define sample
recode analwt (-9/0=0)
svyset [pweight=analwt], strata(vestr) psu(verep) vce(linearized) singleunit(missing)

*************************************************************
//set up who is in sample data or not
gen sample=1
//remove respondents aged >65 or <18
replace sample=0 if catag6 == 1 | catag6==6
//remove respondents who did not answer question regarding sexual orientation
replace sample=0 if sexident<1 /*| sexident>84*/
//remove respondent if no response for education
replace sample=0 if ireduhighst2==-9 
*************************************************************
*************************************************************




/*************************************************************
Clean Variables
*************************************************************/
*************************************************************
///gen female variable
gen female = irsex==2
gen male = irsex==1
********************************************************************************
//recode race variable
*colapse newrace 3-5,other race goes last
recode newrace (3/5=3) (7=4) (6=5) 
//recode newrace (3/5=3 "AIPI") (7=4 "Hispanic") (6=5 "NonHisp Other") 
label define newrace 1 "NonHisp White" 2 "NonHisp Black" 3 "AAIPI" 4 "Hispanic" 5 "Other"
label values newrace newrace

********************************************************************************
//gen sexident variable in sample
gen sexidentx = sexident
//set sexidentx==0 if did not respond as hetero, gay, bisexual
replace sexidentx = 0 if sexident<1 | sexident>84
replace sexidentx = 0 if sexidentx==4
//label sexidentx as hetero, gay, bi, for 1,2,3 respectively
label define sexidentx 1 "straight_hetero" 2 "gay/lesbian" 3 "bisexual" 
label values sexidentx sexidentx


//gen dummy variables for refuse to answered about sexual identity and sexual attraction
gen refuse_sexident = 1 if sexident==97
replace refuse_sexident = 0 if sexident != 97 & sexident != -9

gen refuse_sexattract = 1 if sexatract==97
replace refuse_sexattract = 0 if sexatract != 97 & sexatract != -9


********************************************************************************
//gen interesection of race/ethnicity, sex and sexual orientation
gen race_sex_sexident = 18 
replace race_sex_sexident = 0 if sexidentx==0 | newrace==3 | newrace==5
//white male
replace race_sex_sexident = 1 if newrace==1 & female==0 & sexidentx==1
replace race_sex_sexident = 2 if newrace==1 & female==0 & sexidentx==2
replace race_sex_sexident = 3 if newrace==1 & female==0 & sexidentx==3
//white female
replace race_sex_sexident = 4 if newrace==1 & female==1 & sexidentx==1
replace race_sex_sexident = 5 if newrace==1 & female==1 & sexidentx==2
replace race_sex_sexident = 6 if newrace==1 & female==1 & sexidentx==3
//black male
replace race_sex_sexident = 7 if newrace==2 & female==0 & sexidentx==1
replace race_sex_sexident = 8 if newrace==2 & female==0 & sexidentx==2
replace race_sex_sexident = 9 if newrace==2 & female==0 & sexidentx==3
//black female
replace race_sex_sexident = 10 if newrace==2 & female==1 & sexidentx==1
replace race_sex_sexident = 11 if newrace==2 & female==1 & sexidentx==2
replace race_sex_sexident = 12 if newrace==2 & female==1 & sexidentx==3
//hispanic male
replace race_sex_sexident = 13 if newrace==4 & female==0 & sexidentx==1
replace race_sex_sexident = 14 if newrace==4 & female==0 & sexidentx==2
replace race_sex_sexident = 15 if newrace==4 & female==0 & sexidentx==3
//hispanic female
replace race_sex_sexident = 16 if newrace==4 & female==1 & sexidentx==1
replace race_sex_sexident = 17 if newrace==4 & female==1 & sexidentx==2
replace race_sex_sexident = 18 if newrace==4 & female==1 & sexidentx==3

 label define race_sex_sexident 1 "White Male Het" 2 "White Male Gay" 3 "White Male Bi" 4 "White Female Het" 5 "White Female Gay" 6 "White Female Bi" 7 "Black Male Het" 8 "Black Male Gay" 9 "Black Male Bi" 10 "Black Female Het" 11 "Black Female Gay" 12 "Black Female Bi"  13 "Hisp Male Het" 14 "Hisp Male Gay" 15 "Hisp Male Bi" 16 "Hisp Female Het" 17 "Hisp Female Gay" 18 "Hisp Female Bi" 
label values race_sex_sexident race_sex_sexident


********************************************************************************
//make any mh treatment dummy
gen any_mhtreat_py = amhtxrc3==1
//outpatient dummy
gen out_mhtreat_py = amhoutp3==1 

********************************************************************************
//make alternative mh treatment dummy
gen aualtyrx2 = aualtyr 
recode aualtyrx2 (80/max=0) (2=1) (1=2) (3=2) 
label define aualtyrx2 1 "Did not recieve alt MHT" 2 "Recieved alt MHT"
label values aualtyrx2 aualtyrx2

*************************************************************
//recode k6 score into categories based on severity
recode k6scmon (min/6 = 1) (7/12 = 2) (13/max = 3), gen(K6_cat)
label define K6_cat 1 "mild" 2 "moderate" 3 "severe" 
label values K6_cat K6_cat

*************************************************************
//replace marriage varriage to exclude non-responses
//label new marriage var as married, widowed, divorced, or never married
gen irmaritx = 4
replace irmaritx=0 if irmarit<0 | irmarit>90
replace irmaritx = 1 if irmarit==1 | irmaritstat==1 
replace irmaritx = 2 if irmarit==2 | irmaritstat==2
replace irmaritx = 3 if irmarit==3 | irmaritstat==3
replace irmaritx = 4 if irmarit==4 | irmaritstat==4
label define irmaritx 1 "Married" 2 "Widowed" 3 "Divorce or Spearated" 4 "Never Married"
label values irmaritx irmaritx
*************************************************************
//create clean version of educ that only has highest educ level
gen ireduhighst2x = ireduhighst2
replace ireduhighst2x=0 if ireduhighst2<0
recode ireduhighst2x (1/7=1) (8/9=2) (10=3) (11=4)
//label based on education level
label define ireduhighst2x 1 "less than high school" 2 "high school graduate" 3 "some college"  4 "college graduate"
label values ireduhighst2x ireduhighst2x


*************************************************************
//create clean version of county that only has county type
gen coutyp4x = coutyp4
replace coutyp4x=0 if coutyp4<1
//label for metro type
label define coutyp4x 1 "large metro" 2 "small metro" 3 "nonmetro"  
label values coutyp4x coutyp4x

*************************************************************
//create clean version of poverty3 that gets rid of neg missing value
gen poverty3x = poverty3
replace poverty3x=0 if poverty3<1 
label define poverty3x 1 "living in poverty" 2 "up to 2x fed poverty line" 3 ">2x fed poverty line"  
label values poverty3x poverty3x

********************************************************************************
********************************************************************************
//replace insurance variables with new labeled variable
gen insur_cat = 5
replace insur_cat = 1 if irprvhlt==1 | irothhlt == 1
replace insur_cat = 2 if irchmpus==1
replace insur_cat = 3 if irmcdchp==1
replace insur_cat = 4 if irmedicr==1
su irothhlt irchmpus irmedicr irmcdchp irprvhlt
label define insur_cat 1 "private" 2 "Tricare" 3 "Medicaid" 4 "Medicare" 5 "uninsured"
label values insur_cat insur_cat

//generate health insurance variable of just public, private, and unisured
gen insur_type = 3
replace insur_type = 1 if irprvhlt==1 | irothhlt == 1 | irchmpus==1
replace insur_type = 2 if irmcdchp==1 | irmedicr==1
su irothhlt irchmpus irmedicr irmcdchp irprvhlt
label define insur_type 1 "Private" 2 "Public" 3  "uninsured"
label values insur_type insur_type

*************************************************************
/*create variable that represents any tobacco recency
irsmklssrecx=smokeless tobacco recency,ircigrc=cig use recency,  irgrrc=cigar recency, irpipmn=pipe use recency
*/
gen irsmklssrecxx = irsmklssrec
replace irsmklssrecxx = 0 if irsmklssrec==-9
gen any_tobaco_usex = 0 if ircigrc==9 & ircgrrc==9 & irpipmn==9 & irsmklssrecxx==9
replace any_tobaco_usex = 1 if ircigrc==2 | ircigrc==3 | ircigrc==4 | ircgrrc==2 | ircgrrc==3 | ircgrrc==4 | irsmklssrecxx==2 | irsmklssrecxx==3 | irsmklssrecxx==4 | irpipmn==2
replace any_tobaco_usex = 2 if ircigrc==1 | ircgrrc==1 | irpipmn==1 | irsmklssrecxx==1
label define any_tobaco_usex 0 "No tobacco use" 1 "Tobacco use more than 30 days ago" 2 "Tobacco use within past 30 days"
label values any_tobaco_usex any_tobaco_usex

/*alcohol use*/
recode iralcrc (9 = 0) (2/3 = 1) (1 = 2), gen(alcohol_recency)
label define alcohol_recency 0 "No alcohol use" 1 "Alcohol use more than 30 days ago" 2 "Alcohol use within past 30 days" 
label values alcohol_recency alcohol_recency

/*marijuana use*/
recode irmjrc (9 = 0) (2/3 = 1) (1 = 2), gen(mj_recency)
label define mj_recency 0 "No marijuana use" 1 "Marijuana use more than 30 days ago" 2 "Marijuana use within past 30 days" 
label values mj_recency mj_recency

*************************************************************
/*create variable that represents illegal drug use
irherrc:heroin irlsdrc:lsd irdamtfxrecx:DMT/AMT/FOXY
ircocrc:cocaine, ircrkrc:crack, irpcprc:pcp, irmethamrecx:meth
irhallucrec:hallcuigen, irsalviarec:salvia, irinhalrec:inahalant
*/
//dmt recode
gen irdamtfxrecx = irdamtfxrec
replace irdamtfxrecx = 0 if irdamtfxrec==-9
//meth recode
gen irmethamrecx = irmethamrec
replace irmethamrecx = 0 if irmethamrec==-9

gen illicit_recency = 0 if irherrc==9 & irlsdrc==9 & irdamtfxrecx==9 & ircocrc==9 & ircrkrc==9 & irpcprc==9 & irmethamrecx==9 & irhallucrec==9 & irsalviarec==9 & irinhalrec==9 
replace illicit_recency = 1 if irherrc==2 | irherrc==3 |  irlsdrc==2 | irlsdrc==3 | irdamtfxrecx==2 | irdamtfxrecx==3  |  ircocrc==2 | ircocrc==3 | ircrkrc==2 | ircrkrc==3  |  irpcprc==2 | irpcprc==3 | irmethamrecx==2 | irmethamrecx==3 | irhallucrec==2 | irhallucrec==3  |  irsalviarec==2 | irsalviarec==3 | irinhalrec==2 | irinhalrec==3  
replace illicit_recency = 2 if irherrc==1 | irlsdrc==1 | irdamtfxrecx==1 | ircocrc==1 | ircrkrc==1 | irpcprc==1 | irmethamrecx==1 | irhallucrec==1 | irsalviarec==1 | irinhalrec==1 
label define illicit_recency 0 "Never used Illicit Drug" 1 "More than 30 days ago" 2 "Used within past 30 days"
label values illicit_recency illicit_recency

*************************************************************
/*create variable that represents prescription drug misuse
irpnrnmrec:pain reliever, irtrqnmrec:tranquilizer, irstmnmrec:stimulant, irsednmrec:sedative
*/

gen prescrip_misuse = 0 if irpnrnmrec==9 & irtrqnmrec==9 & irstmnmrec==9 & irsednmrec==9
replace prescrip_misuse = 1 if irpnrnmrec==2 | irpnrnmrec==3 |  irtrqnmrec==2 | irtrqnmrec==3 | irstmnmrec==2 | irstmnmrec==3  |  irsednmrec==2 | irsednmrec==3 
replace prescrip_misuse = 2 if irpnrnmrec==1 | irtrqnmrec==1 | irstmnmrec==1 | irsednmrec==1 
label define prescrip_misuse 0 "Never misused precription drug" 1 "More than 30 days ago" 2 "Misused within past 30 days"
label values prescrip_misuse prescrip_misuse


********************************************************************************
//number of members in household <18 and >64
gen irki17_2x = irki17_2
replace irki17_2x = 0 if irki17_2==1
replace irki17_2x = 1 if irki17_2==2
replace irki17_2x = 2 if irki17_2==3
replace irki17_2x = 3 if irki17_2==4
label define irki17_2x 0 "No children under 18" 1 "One child under 18" 2 "Two children under 18" 3 "Three or more children under 18"
label values irki17_2x irki17_2x

gen  irhh65_2x =  irhh65_2
replace irhh65_2x = 0 if irhh65_2==1
replace irhh65_2x = 1 if irhh65_2==2
replace irhh65_2x = 2 if irhh65_2==3
label define irhh65_2x 0 "No people over 65" 1 "One person over 65" 2 "Two or more adults over 65"
label values irhh65_2x irhh65_2x


********************************************************************************
//language variable dummy
gen spanish = 1 if langver==2
replace spanish = 0 if langver==1





/***************************************************************************************************************
****************************************************************************************************************
THE CODE IN THIS SECTION CRETES THE HEALTH DUMMY VARIABLES
****************************************************************************************************************
***************************************************************************************************************/
/*******************************************************************************
IOM Cleanup
Create dummy variables for health variables
*******************************************************************************/
//Age variables for IOM
gen age18_25 = catag6==2
gen age26_34 = catag6==3
gen age35_49 = catag6==4
gen age50_64 = catag6==5

********************************************************************************
//Overall health for IOM
gen health_excellent = health2==1
gen health_very_good = health2==2
gen health_good = health2==3
gen health_fair_poor = health2==4

********************************************************************************
//k6 severetity for IOM
gen k6_mild = K6_cat==1
gen k6_moderate = K6_cat==2
gen k6_severe = K6_cat==3
********************************************************************************
//sexual orientation for IOM
gen hetero = sexidentx==1
gen gay = sexidentx==2 
gen bisexual = sexidentx==3
********************************************************************************
//race/ethnicity
gen white = newrace==1
gen black = newrace==2
gen aipi = newrace==3
gen hispanic = newrace==4
gen other = newrace==5
********************************************************************************
//year
gen pre_2015 = year<2015
gen year_2015 = year==2015
gen year_2016 = year==2016
gen year_2017 = year==2017
gen year_2018 = year==2018
gen year_2019 = year==2019
********************************************************************************
//tobacco use*
gen no_tobacco_use = any_tobaco_usex==0
gen over30_tobacco_use = any_tobaco_usex==1
gen under30_tobacco_use = any_tobaco_usex==2

********************************************************************************
//alcohol recency
gen no_alcohol_use = alcohol_recency==0
gen over30_alcohol_use = alcohol_recency==1
gen under30_alcohol_use = alcohol_recency==2

********************************************************************************
//marijuana recency
gen no_mj_use = mj_recency==0
gen over30_mj_use = mj_recency==1
gen under30_mj_use = mj_recency==2

********************************************************************************
//illicit recency
gen no_illicit_use = illicit_recency==0
gen over30_illicit_use = illicit_recency==1
gen under30_illicit_use = illicit_recency==2

********************************************************************************
//presciption drug misuse
gen no_pres_misuse = prescrip_misuse==0
gen over30_pres_misuse = prescrip_misuse==1
gen under30_pres_misuse = prescrip_misuse==2

********************************************************************************
//recode inpatient and prescription mht
gen inpatient_py = amhinp2==1
gen mh_presc_py = amhrx2==1
/***************************************************************************************************************
****************************************************************************************************************
****************************************************************************************************************
***************************************************************************************************************/





********************************************************************************
********************************************************************************
//table any mh treatment with unmet need and sexident
tab amhtxrc3 amhtxnd2
tab sexident amhtxrc3
********************************************************************************
//tab with race/ethnicity, sex, and sexuality
//Received outpatient MH TRT at MH CLINIC/CENTER in past year 
tab sexidentx mhlmnt3 
//Received outpatient MH TRT at PRIV THERAPIST OFC in past year 
tab sexidentx mhlther3
//Received outpatient MH TRT at NON CLINIC DR OFFCE in past year 
tab sexidentx mhldoc3	 
//Received outpatient MH TRT at MEDICAL CLINIC in past year  
tab sexidentx mhlclnc3  
//Received outpatient MH TRT at DAY HOSP OR TRT PGM in past year 
tab sexidentx mhldtmt3 
********************************************************************************

*************************************************************
*************************Regressions*************************
*************************************************************
// test sample works with dif means
svy, subpop(sample): mean  i.sexidentx, over(newrace)
svy, subpop(sample): mean  i.sexidentx, over(female)
svy, subpop(sample): mean  i.newrace, over(sexidentx)
svy, subpop(sample): mean  i.newrace, over(female)
svy, subpop(sample): mean  i.female, over(newrace)
svy, subpop(sample): mean  i.female, over(sexidentx)

mhlmnt3 mhlther3 mhldoc3 mhlclnc3 mhldtmt3

//prescription
//AHRQ Disp mean mh treatment for dif groups
//race/ethnicity 
fvset base 1 newrace
svy, subpop(sample): reg mh_presc_py i.newrace
//sex
fvset base 0 female
svy, subpop(sample): reg mh_presc_py female
//sexual orientation
fvset base 1 sexidentx
svy, subpop(sample): reg mh_presc_py i.sexidentx

//test over different groups
svy, subpop(sample): mean any_mhtreat_py, over(newrace female)
svy, subpop(sample): mean any_mhtreat_py, over(newrace sexidentx)
svy, subpop(sample): mean any_mhtreat_py, over(sexidentx female)

//svy, subpop(sample): mean any_mh_treat_py, over(snrldcsn sexidentx)

//any, precription, and priv therapist
//white hetero male
fvset base 1 race_sex_sexident
svy, subpop(sample): reg any_mhtreat_py i.race_sex_sexident
svy, subpop(sample): reg mh_presc_py i.race_sex_sexident
svy, subpop(sample): reg mhlther3 i.race_sex_sexident
//white bisexual female
fvset base 6 race_sex_sexident
svy, subpop(sample): reg any_mhtreat_py i.race_sex_sexident
svy, subpop(sample): reg mh_presc_py i.race_sex_sexident
svy, subpop(sample): reg mhlther3 i.race_sex_sexident


**************************************************************
/*************************************************************
Modified AHRQ regs
mhlmnt3 mhlther3 mhldoc3 mhlclnc3 mhldtmt3 aualtyrx2 inpatient_py mh_presc_py
*************************************************************/

fvset base 1 newrace
fvset base 1 sexidentx

svy, subpop(sample): reg aualtyrx2 i.newrace  i.sexidentx i.female
svy, subpop(sample): reg inpatient_py i.newrace  i.sexidentx i.female
svy, subpop(sample): reg mh_presc_py i.newrace  i.sexidentx i.female


//means
svy, subpop(sample): reg any_mhtreat_py i.newrace 
svy, subpop(sample): reg any_mhtreat_py i.female  
svy, subpop(sample): reg any_mhtreat_py i.sexidentx  
**************************************************************


**************************************************************
/*************************************************************
Health adjusted regression
mhlmnt3 mhlther3 mhldoc3 mhlclnc3 mhldtmt3 aualtyrx2 inpatient_py mh_presc_py
*************************************************************/
svy, subpop(sample): reg mhlmnt3 i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg mhlther3 i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg mhldoc3 i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg mhlclnc3 i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg mhldtmt3 i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg aualtyrx2 i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg inpatient_py i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sample): reg mh_presc_py i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat



*get predicted means for outcomes from this model using margins command.
margins , over(i.newrace) subpop(sample) 
margins , over(i.sexidentx) subpop(sample) 
margins , over(i.female) subpop(sample) 
********************************************************************************


**************************************************************
/*************************************************************
Adjusted for health and SES variables
mhlmnt3 mhlther3 mhldoc3 mhlclnc3 mhldtmt3 aualtyrx2 inpatient_py mh_presc_py
*************************************************************/
//any, precription, and priv therapist
//white hetero male
fvset base 1 race_sex_sexident
svy, subpop(sample): reg any_mhtreat_py i.race_sex_sexident i.catag6 i.health2 i.K6_cat i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.any_tobaco_use i.alcohol_recency i.mj_recency i.illicit_recency i.prescrip_misuse i.irki17_2x i.irhh65_2x i.spanish 
svy, subpop(sample): reg mh_presc_py i.race_sex_sexident i.catag6 i.health2 i.K6_cat i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.any_tobaco_use i.alcohol_recency i.mj_recency i.illicit_recency i.prescrip_misuse i.irki17_2x i.irhh65_2x i.spanish 
svy, subpop(sample): reg mhlther3 i.race_sex_sexident i.catag6 i.health2 i.K6_cat i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.any_tobaco_use i.alcohol_recency i.mj_recency i.illicit_recency i.prescrip_misuse i.irki17_2x i.irhh65_2x i.spanish 

//white bisexual female
fvset base 6 race_sex_sexident
svy, subpop(sample): reg any_mhtreat_py i.race_sex_sexident i.catag6 i.health2 i.K6_cat i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.any_tobaco_use i.alcohol_recency i.mj_recency i.illicit_recency i.prescrip_misuse i.irki17_2x i.irhh65_2x i.spanish 
svy, subpop(sample): reg mh_presc_py i.race_sex_sexident i.catag6 i.health2 i.K6_cat i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.any_tobaco_use i.alcohol_recency i.mj_recency i.illicit_recency i.prescrip_misuse i.irki17_2x i.irhh65_2x i.spanish 
svy, subpop(sample): reg mhlther3 i.race_sex_sexident i.catag6 i.health2 i.K6_cat i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.any_tobaco_use i.alcohol_recency i.mj_recency i.illicit_recency i.prescrip_misuse i.irki17_2x i.irhh65_2x i.spanish 


margins , over(i.newrace) subpop(sample) 
margins , over(i.sexidentx) subpop(sample) 
margins , over(i.female) subpop(sample) 
****************************************************

gen sexatractx = sexatract
replace sexatractx=0 if sexatractx<1 | sexatractx>8

svy, subpop(sample): mean i.sexatractx, over(sexidentx newrace)

svy, subpop(sample): reg any_mh_treat_py i.newrace $rhs_Hx i.sexidentx $rhs_X
*************************************************************
*************************************************************



*************************************************************
*************************************************************
/****************************************************
IOM Method
****************************************************/
//generate races who are in our sample
gen sub_W=sample==1 & newrace==1
gen sub_B=sample==1 & newrace==2
gen sub_A=sample==1 & newrace==3
gen sub_H=sample==1 & newrace==4
gen sub_O=sample==1 & newrace==5
gen sub_Wx = sub_W
gen sub_Bx = sub_B
gen sub_Ax = sub_A
gen sub_Hx = sub_H 
gen sub_Ox = sub_O

//generate male female dummies
gen sub_F = sample==1 & irsex==2
gen sub_M = sample==1 & irsex==1
gen sub_Fx = sub_F
gen sub_Mx = sub_M

//generate het gay bi dummies
gen sub_D = sexidentx==1
gen sub_G = sexidentx==2
gen sub_K = sexidentx==3
gen sub_Dx = sub_D
gen sub_Gx = sub_G
gen sub_Kx = sub_K






//outpatient types to insert in IOM
//mhlmnt3 mhlther3 mhldoc3 mhlclnc3 mhldtmt3

/*******************************************************************************
********************************************************************************
IOM Race/Ethnicity PRESCRIPTION
CLICK AND DRAG FROM HERE.
mhlmnt3 mhlther3 mhldoc3 mhlclnc3 mhldtmt3 aualtyrx2 inpatient_py mh_presc_py
********************************************************************************
*******************************************************************************/
global rhs_X_all female gay bisexual hetero age18_25 age26_34 age35_49 age50_64 health_excellent health_very_good health_good health_fair_poor k6_mild k6_moderate k6_severe  pre_2015 year_2015 year_2016 year_2017  year_2018  year_2019 no_tobacco_use  over30_tobacco_use  under30_tobacco_use no_alcohol_use over30_alcohol_use under30_alcohol_use no_mj_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use  no_illicit_use no_pres_misuse over30_pres_misuse under30_pres_misuse
*use white Black AIPI hispanic 
local subs W B A H O
*calculate the mean of ses vars for each race subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1
}
}

*health variable that we are including in rgerssion and run regrssion of sample
local y mh_presc_py /*OUTCOME OF INTEREST HERE*/
global rhs_Hx female gay bisexual age26_34 age35_49 age50_64  health_very_good health_good health_fair_poor  k6_moderate k6_severe year_2015 year_2016 year_2017 year_2018  year_2019   over30_tobacco_use under30_tobacco_use over30_alcohol_use under30_alcohol_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use over30_pres_misuse under30_pres_misuse
global rhs_X i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.irki17_2x i.irhh65_2x i.spanish 

svy, subpop(sub_Wx): reg `y' $rhs_Hx $rhs_X
est sto W
svy, subpop(sub_Bx): reg `y' $rhs_Hx $rhs_X
est sto B
svy, subpop(sub_Ax): reg `y' $rhs_Hx $rhs_X
est sto A
svy, subpop(sub_Hx): reg `y' $rhs_Hx $rhs_X
est sto H
svy, subpop(sub_Ox): reg `y' $rhs_Hx $rhs_X
est sto O


*********************************************************
 /* Black and White */
quietly suest W B, coefleg
quietly margins, predict(equation(W)) predict(equation(B)) at(female=`female_W' gay=`gay_W' bisexual=`bisexual_W'  age26_34=`age26_34_W' age35_49=`age35_49_W' age50_64=`age50_64_W'  health_very_good=`health_very_good_W' health_good=`health_good_W' health_fair_poor=`health_fair_poor_W'  k6_moderate=`k6_moderate_W' k6_severe=`k6_severe_W' year_2015=`year_2015_W' year_2016=`year_2016_W' year_2017=`year_2017_W' year_2018=`year_2018_W' year_2019=`year_2019_W' over30_tobacco_use=`over30_tobacco_use_W' under30_tobacco_use=`under30_tobacco_use_W' over30_alcohol_use=`over30_alcohol_use_W' under30_alcohol_use=`under30_alcohol_use_W' over30_mj_use=`over30_mj_use_W' under30_mj_use=`under30_mj_use_W' over30_illicit_use=`over30_illicit_use_W' under30_illicit_use=`under30_illicit_use_W' over30_pres_misuse=`over30_pres_misuse_W' under30_pres_misuse=`under30_pres_misuse_W') over(i.newrace) subpop(sample) post coefleg
local W _b[1bn._predict#1bn.newrace]
local B _b[2._predict#2.newrace]
lincom `W' // MODEL PREDICTED AVERAGE OUTCOME FOR WHITES
lincom `B' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR BLACK ASSUMING SAME HEALTH AS WHITES
lincom `W'-`B' // IOM DISPARITY
*********************************************************

*********************************************************
 /* AIPI and White */
quietly suest W A, coefleg
quietly margins, predict(equation(W)) predict(equation(A)) at(female=`female_W' gay=`gay_W' bisexual=`bisexual_W'  age26_34=`age26_34_W' age35_49=`age35_49_W' age50_64=`age50_64_W'  health_very_good=`health_very_good_W' health_good=`health_good_W' health_fair_poor=`health_fair_poor_W'  k6_moderate=`k6_moderate_W' k6_severe=`k6_severe_W' year_2015=`year_2015_W' year_2016=`year_2016_W' year_2017=`year_2017_W' year_2018=`year_2018_W' year_2019=`year_2019_W' over30_tobacco_use=`over30_tobacco_use_W' under30_tobacco_use=`under30_tobacco_use_W' over30_alcohol_use=`over30_alcohol_use_W' under30_alcohol_use=`under30_alcohol_use_W' over30_mj_use=`over30_mj_use_W' under30_mj_use=`under30_mj_use_W' over30_illicit_use=`over30_illicit_use_W' under30_illicit_use=`under30_illicit_use_W' over30_pres_misuse=`over30_pres_misuse_W' under30_pres_misuse=`under30_pres_misuse_W') over(i.newrace) subpop(sample) post coefleg
local W _b[1bn._predict#1bn.newrace]
local A _b[2._predict#3.newrace] //be sure to align this for new race
lincom `W' // MODEL PREDICTED AVERAGE OUTCOME FOR WHITES
lincom `A' // COUNTERFACTUAL PREDICTED avg outcome for AIPI ASSUMING SAME HEALTH AS WHITES
lincom `W'-`A' // IOM DISPARITY
*********************************************************

*********************************************************
 /* Hispanic and White */
quietly suest W H, coefleg
quietly margins, predict(equation(W)) predict(equation(H)) at(female=`female_W' gay=`gay_W' bisexual=`bisexual_W'  age26_34=`age26_34_W' age35_49=`age35_49_W' age50_64=`age50_64_W'  health_very_good=`health_very_good_W' health_good=`health_good_W' health_fair_poor=`health_fair_poor_W'  k6_moderate=`k6_moderate_W' k6_severe=`k6_severe_W' year_2015=`year_2015_W' year_2016=`year_2016_W' year_2017=`year_2017_W' year_2018=`year_2018_W' year_2019=`year_2019_W' over30_tobacco_use=`over30_tobacco_use_W' under30_tobacco_use=`under30_tobacco_use_W' over30_alcohol_use=`over30_alcohol_use_W' under30_alcohol_use=`under30_alcohol_use_W' over30_mj_use=`over30_mj_use_W' under30_mj_use=`under30_mj_use_W' over30_illicit_use=`over30_illicit_use_W' under30_illicit_use=`under30_illicit_use_W' over30_pres_misuse=`over30_pres_misuse_W' under30_pres_misuse=`under30_pres_misuse_W') over(i.newrace) subpop(sample) post coefleg
local W _b[1bn._predict#1bn.newrace]
local H _b[2._predict#4.newrace] //be sure to align this for new race
lincom `W' // MODEL PREDICTED AVERAGE OUTCOME FOR WHITES
lincom `H' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HISPANIC ASSUMING SAME HEALTH AS WHITES
lincom `W'-`H' // IOM DISPARITY
*********************************************************

*********************************************************
 /* Other and White */
quietly suest W O, coefleg
quietly margins, predict(equation(W)) predict(equation(O)) at(female=`female_W' gay=`gay_W' bisexual=`bisexual_W'  age26_34=`age26_34_W' age35_49=`age35_49_W' age50_64=`age50_64_W'  health_very_good=`health_very_good_W' health_good=`health_good_W' health_fair_poor=`health_fair_poor_W'  k6_moderate=`k6_moderate_W' k6_severe=`k6_severe_W' year_2015=`year_2015_W' year_2016=`year_2016_W' year_2017=`year_2017_W' year_2018=`year_2018_W' year_2019=`year_2019_W' over30_tobacco_use=`over30_tobacco_use_W' under30_tobacco_use=`under30_tobacco_use_W' over30_alcohol_use=`over30_alcohol_use_W' under30_alcohol_use=`under30_alcohol_use_W' over30_mj_use=`over30_mj_use_W' under30_mj_use=`under30_mj_use_W' over30_illicit_use=`over30_illicit_use_W' under30_illicit_use=`under30_illicit_use_W' over30_pres_misuse=`over30_pres_misuse_W' under30_pres_misuse=`under30_pres_misuse_W') over(i.newrace) subpop(sample) post coefleg
local W _b[1bn._predict#1bn.newrace]
local O _b[2._predict#5.newrace] //be sure to align this for new race
lincom `W' // MODEL PREDICTED AVERAGE OUTCOME FOR WHITES
lincom `O' // COUNTERFACTUAL PREDICTED avg outcome for OTHER ASSUMING SAME HEALTH AS WHITES
lincom `W'-`O' // IOM DISPARITY

/********************************************************
STOP CLICK AND DRAG HERE FOR JUST RACE/ETHNICITY!!!!!!
********************************************************/






/*********************************************************************
**********************************************************************
REPEAT IOM FOR MALE AND FEMALE
**********************************************************************
*********************************************************************/
//START CLICKING AND DRAGGING HERE
global rhs_X_all white black aipi hispanic other hetero gay bisexual age18_25 age26_34 age35_49 age50_64 health_excellent health_very_good health_good health_fair_poor k6_mild k6_moderate k6_severe pre_2015 year_2015 year_2016 year_2017  year_2018  year_2019 no_tobacco_use  over30_tobacco_use  under30_tobacco_use no_alcohol_use over30_alcohol_use under30_alcohol_use no_mj_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use no_illicit_use no_pres_misuse over30_pres_misuse under30_pres_misuse

*use female and male
local subs F M
*calculate the mean of ses vars for each sex subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1
}
}

*health variable that we are including in rgerssion and run regrssion of sample
local y mh_presc_py /* outcome of interest*/
global rhs_Hx  black aipi hispanic other gay bisexual age26_34 age35_49 age50_64  health_very_good health_good health_fair_poor  k6_moderate k6_severe year_2015 year_2016 year_2017 year_2018  year_2019   over30_tobacco_use under30_tobacco_use over30_alcohol_use under30_alcohol_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use over30_pres_misuse under30_pres_misuse
global rhs_X i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.irki17_2x i.irhh65_2x i.spanish

svy, subpop(sub_Fx): reg `y' $rhs_Hx $rhs_X
est sto F
svy, subpop(sub_Mx): reg `y' $rhs_Hx $rhs_X
est sto M


 /* Male and Female */
quietly suest F M, coefleg
quietly margins, predict(equation(F)) predict(equation(M)) at(black=`black_F' aipi=`aipi_F' hispanic=`hispanic_F' other=`other_F' gay=`gay_F' bisexual=`bisexual_F'  age26_34=`age26_34_F' age35_49=`age35_49_F' age50_64=`age50_64_F'  health_very_good=`health_very_good_F' health_good=`health_good_F' health_fair_poor=`health_fair_poor_F'  k6_moderate=`k6_moderate_F' k6_severe=`k6_severe_F' year_2015=`year_2015_F' year_2016=`year_2016_F' year_2017=`year_2017_F' year_2018=`year_2018_F' year_2019=`year_2019_F' over30_tobacco_use=`over30_tobacco_use_F' under30_tobacco_use=`under30_tobacco_use_F' over30_alcohol_use=`over30_alcohol_use_F' under30_alcohol_use=`under30_alcohol_use_F' over30_mj_use=`over30_mj_use_F' under30_mj_use=`under30_mj_use_F' over30_illicit_use=`over30_illicit_use_F' under30_illicit_use=`under30_illicit_use_F' over30_pres_misuse=`over30_pres_misuse_F' under30_pres_misuse=`under30_pres_misuse_F') over(i.female) subpop(sample) post coefleg
local F _b[1bn._predict#1bn.female]
local M _b[2._predict#0.female]
lincom `F' // MODEL PREDICTED AVERAGE OUTCOME FOR FEMALE
lincom `M' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR MALES ASSUMING SAME HEALTH AS FEMALES
lincom `F'-`M' // IOM DISPARITY


/********************************************************
STOP CLICK AND DRAG HERE FOR SEX/GENDER!!!!!!
********************************************************/





/*********************************************************************
**********************************************************************
SEXUAL ORIENTATION
START CLICK AND DRAG HERE
**********************************************************************
*********************************************************************/
global rhs_X_all female white black aipi hispanic other age18_25 age26_34 age35_49 age50_64 health_excellent health_very_good health_good health_fair_poor k6_mild k6_moderate k6_severe pre_2015 year_2015 year_2016 year_2017  year_2018  year_2019 no_tobacco_use over30_tobacco_use  under30_tobacco_use no_alcohol_use over30_alcohol_use under30_alcohol_use no_mj_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use no_illicit_use no_pres_misuse over30_pres_misuse under30_pres_misuse

* SEXUAL ORIENTATION SUBGROUPS (make new tokens)
//het=D bi=K
local subs D G K 
*calculate the mean of ses vars for each race subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1	
}
}


local y mh_presc_py /*CHANGE THE OUTCOME OF INTEREST HERE*/
global rhs_Hx female  black aipi hispanic other  age26_34 age35_49 age50_64  health_very_good health_good health_fair_poor  k6_moderate k6_severe year_2015 year_2016 year_2017 year_2018  year_2019   over30_tobacco_use under30_tobacco_use over30_alcohol_use under30_alcohol_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use over30_pres_misuse under30_pres_misuse
global rhs_X i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.irki17_2x i.irhh65_2x i.spanish
svy, subpop(sub_Dx): reg `y' $rhs_Hx $rhs_X
est sto D
svy, subpop(sub_Gx): reg `y' $rhs_Hx $rhs_X
est sto G
svy, subpop(sub_Kx): reg `y' $rhs_Hx $rhs_X
est sto K


 /* gay and straight */
quietly suest D G, coefleg
quietly margins, predict(equation(D)) predict(equation(G)) at(female=`female_D'  black=`black_D' aipi=`aipi_D' hispanic=`hispanic_D' other=`other_D'  age26_34=`age26_34_D' age35_49=`age35_49_D' age50_64=`age50_64_D'  health_very_good=`health_very_good_D' health_good=`health_good_D' health_fair_poor=`health_fair_poor_D'  k6_moderate=`k6_moderate_D' k6_severe=`k6_severe_D' year_2015=`year_2015_D' year_2016=`year_2016_D' year_2017=`year_2017_D' year_2018=`year_2018_D' year_2019=`year_2019_D' over30_tobacco_use=`over30_tobacco_use_D' under30_tobacco_use=`under30_tobacco_use_D' over30_alcohol_use=`over30_alcohol_use_D' under30_alcohol_use=`under30_alcohol_use_D' over30_mj_use=`over30_mj_use_D' under30_mj_use=`under30_mj_use_D' over30_illicit_use=`over30_illicit_use_D' under30_illicit_use=`under30_illicit_use_D' over30_pres_misuse=`over30_pres_misuse_D' under30_pres_misuse=`under30_pres_misuse_D') over(i.sexidentx) subpop(sample) post coefleg
local D _b[1bn._predict#1bn.sexidentx]
local G _b[2._predict#2.sexidentx]
lincom `D' // MODEL PREDICTED AVERAGE OUTCOME FOR GAYS
lincom `G' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HETERO ASSUMING SAME HEALTH AS GAYS
lincom `D'-`G' // IOM DISPARITY
*********************************************************

 /* bi and straight */
quietly suest D K, coefleg
quietly margins, predict(equation(D)) predict(equation(K)) at(female=`female_D'  black=`black_D' aipi=`aipi_D' hispanic=`hispanic_D' other=`other_D'  age26_34=`age26_34_D' age35_49=`age35_49_D' age50_64=`age50_64_D'  health_very_good=`health_very_good_D' health_good=`health_good_D' health_fair_poor=`health_fair_poor_D'  k6_moderate=`k6_moderate_D' k6_severe=`k6_severe_D' year_2015=`year_2015_D' year_2016=`year_2016_D' year_2017=`year_2017_D' year_2018=`year_2018_D' year_2019=`year_2019_D' over30_tobacco_use=`over30_tobacco_use_D' under30_tobacco_use=`under30_tobacco_use_D' over30_alcohol_use=`over30_alcohol_use_D' under30_alcohol_use=`under30_alcohol_use_D' over30_mj_use=`over30_mj_use_D' under30_mj_use=`under30_mj_use_D' over30_illicit_use=`over30_illicit_use_D' under30_illicit_use=`under30_illicit_use_D' over30_pres_misuse=`over30_pres_misuse_D' under30_pres_misuse=`under30_pres_misuse_D') over(i.sexidentx) subpop(sample) post coefleg
local D _b[1bn._predict#1bn.sexidentx]
local K _b[2._predict#3.sexidentx]
lincom `D' // MODEL PREDICTED AVERAGE OUTCOME FOR BISEXUAL
lincom `K' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HETERO ASSUMING SAME HEALTH AS BISEXUAL
lincom `D'-`K' // IOM DISPARITY
*********************************************************

 /* bi and gay*/
quietly suest G K, coefleg
quietly margins, predict(equation(G)) predict(equation(K)) at(female=`female_G'  black=`black_G' aipi=`aipi_G' hispanic=`hispanic_G' other=`other_G'  age26_34=`age26_34_G' age35_49=`age35_49_G' age50_64=`age50_64_G'  health_very_good=`health_very_good_G' health_good=`health_good_G' health_fair_poor=`health_fair_poor_G'  k6_moderate=`k6_moderate_G' k6_severe=`k6_severe_G' year_2015=`year_2015_G' year_2016=`year_2016_G' year_2017=`year_2017_G' year_2018=`year_2018_G' year_2019=`year_2019_G' over30_tobacco_use=`over30_tobacco_use_G' under30_tobacco_use=`under30_tobacco_use_G' over30_alcohol_use=`over30_alcohol_use_G' under30_alcohol_use=`under30_alcohol_use_G' over30_mj_use=`over30_mj_use_G' under30_mj_use=`under30_mj_use_G' over30_illicit_use=`over30_illicit_use_G' under30_illicit_use=`under30_illicit_use_G' over30_pres_misuse=`over30_pres_misuse_G' under30_pres_misuse=`under30_pres_misuse_G') over(i.sexidentx) subpop(sample) post coefleg
local G _b[1bn._predict#2bn.sexidentx]
local K _b[2._predict#3.sexidentx]
lincom `G' // MODEL PREDICTED AVERAGE OUTCOME FOR GAYS
lincom `K' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR BISEXUAL ASSUMING SAME HEALTH AS GAYS
lincom `G'-`K' // IOM DISPARITY

/********************************************************
STOP HERE CLICK AND DRAG HERE FOR SEXUAL ORIENTATION!!!!!!
********************************************************/








/*******************************************************************************
********************************************************************************
********************************************************************************
								!!!!!!END OF IOM!!!!!!
********************************************************************************
********************************************************************************
*******************************************************************************/


/*******************************************************************************
********************************************************************************
********************************************************************************
								!!!!!!START INTERSECTED IOM!!!!!!
********************************************************************************
********************************************************************************
*******************************************************************************/

/***************************************************************************************************************
****************************************************************************************************************
CREATES THE DUMMY VARIABLES FOR COMBINATIONS OF RACE/ETHNICITY, SEX, AND SEXUALITY
****************************************************************************************************************
***************************************************************************************************************/

//read as race/ethnicity, sex, sexuality
//
gen sub_WMH = sample==1 & race_sex_sexident==1
gen sub_WMG = sample==1 & race_sex_sexident==2
gen sub_WMB = sample==1 & race_sex_sexident==3
gen sub_WFH = sample==1 & race_sex_sexident==4
gen sub_WFG = sample==1 & race_sex_sexident==5
gen sub_WFB = sample==1 & race_sex_sexident==6

gen sub_BMH = sample==1 & race_sex_sexident==7
gen sub_BMG = sample==1 & race_sex_sexident==8
gen sub_BMB = sample==1 & race_sex_sexident==9
gen sub_BFH = sample==1 & race_sex_sexident==10
gen sub_BFG = sample==1 & race_sex_sexident==11
gen sub_BFB = sample==1 & race_sex_sexident==12

gen sub_HMH = sample==1 & race_sex_sexident==13
gen sub_HMG = sample==1 & race_sex_sexident==14
gen sub_HMB = sample==1 & race_sex_sexident==15
gen sub_HFH = sample==1 & race_sex_sexident==16
gen sub_HFG = sample==1 & race_sex_sexident==17
gen sub_HFB = sample==1 & race_sex_sexident==18

//
gen sub_WMHx = sub_WMH
gen sub_WMGx = sub_WMG
gen sub_WMBx = sub_WMB
gen sub_WFHx = sub_WFH
gen sub_WFGx = sub_WFG
gen sub_WFBx = sub_WFB

gen sub_BMHx = sub_BMH
gen sub_BMGx = sub_BMG
gen sub_BMBx = sub_BMB
gen sub_BFHx = sub_BFH
gen sub_BFGx = sub_BFG
gen sub_BFBx = sub_BFB

gen sub_HMHx = sub_HMH
gen sub_HMGx = sub_HMG
gen sub_HMBx = sub_HMB
gen sub_HFHx = sub_HFH
gen sub_HFGx = sub_HFG 
gen sub_HFBx = sub_HFB




/*********************************************************************
**********************************************************************
START CLICK AND DRAG HERE
**********************************************************************
*********************************************************************/
global rhs_X_all age18_25 age26_34 age35_49 age50_64 health_excellent health_very_good health_good health_fair_poor k6_mild k6_moderate k6_severe pre_2015 year_2015 year_2016 year_2017  year_2018  year_2019 no_tobacco_use over30_tobacco_use  under30_tobacco_use no_alcohol_use over30_alcohol_use under30_alcohol_use no_mj_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use no_illicit_use no_pres_misuse over30_pres_misuse under30_pres_misuse

*SUBGROUPS (make new tokens)
local subs  WMH BMH HMH              
*calculate the mean of ses vars for each race subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1	
}
}


local y mh_presc_py /*CHANGE THE OUTCOME OF INTEREST HERE*/
global rhs_Hx age26_34 age35_49 age50_64  health_very_good health_good health_fair_poor  k6_moderate k6_severe year_2015 year_2016 year_2017 year_2018  year_2019   over30_tobacco_use under30_tobacco_use over30_alcohol_use under30_alcohol_use over30_mj_use under30_mj_use under30_illicit_use over30_illicit_use over30_pres_misuse under30_pres_misuse
global rhs_X i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_type i.irki17_2x i.irhh65_2x i.spanish
svy, subpop(sub_WMHx): reg `y' $rhs_Hx $rhs_X
est sto WMH
svy, subpop(sub_BMHx): reg `y' $rhs_Hx $rhs_X
est sto BMH
svy, subpop(sub_HMHx): reg `y' $rhs_Hx $rhs_X
est sto HMH


********************************************************************************
 /* white fem bi black fem bi */
 *******************************************************************************
quietly suest BMH WMH, coefleg
quietly margins, predict(equation(WMH)) predict(equation(BMH)) at(age26_34=`age26_34_WMH' age35_49=`age35_49_WMH' age50_64=`age50_64_WMH'  health_very_good=`health_very_good_WMH' health_good=`health_good_WMH' health_fair_poor=`health_fair_poor_WMH'  k6_moderate=`k6_moderate_WMH' k6_severe=`k6_severe_WMH' year_2015=`year_2015_WMH' year_2016=`year_2016_WMH' year_2017=`year_2017_WMH' year_2018=`year_2018_WMH' year_2019=`year_2019_WMH' over30_tobacco_use=`over30_tobacco_use_WMH' under30_tobacco_use=`under30_tobacco_use_WMH' over30_alcohol_use=`over30_alcohol_use_WMH' under30_alcohol_use=`under30_alcohol_use_WMH' over30_mj_use=`over30_mj_use_WMH' under30_mj_use=`under30_mj_use_WMH' over30_illicit_use=`over30_illicit_use_WMH' under30_illicit_use=`under30_illicit_use_WMH' over30_pres_misuse=`over30_pres_misuse_WMH' under30_pres_misuse=`under30_pres_misuse_WMH') over(i.race_sex_sexident) subpop(sample) post coefleg
local WMH _b[1bn._predict#3bn.race_sex_sexident]
local BMH _b[2._predict#9.race_sex_sexident]
lincom `BMH' // MODEL PREDICTED AVERAGE OUTCOME FOR GAYS
lincom `WMH' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HETERO ASSUMING SAME HEALTH AS GAYS
lincom `BMH'-`WMH' // IOM DISPARITY
********************************************************************************

********************************************************************************
  /*white fem bi hispanic fem bi */
********************************************************************************
quietly suest HMH WMH , coefleg
quietly margins, predict(equation(WMB)) predict(equation(HMB)) aat(age26_34=`age26_34_WMH' age35_49=`age35_49_WMH' age50_64=`age50_64_WMH'  health_very_good=`health_very_good_WMH' health_good=`health_good_WMH' health_fair_poor=`health_fair_poor_WMH'  k6_moderate=`k6_moderate_WMH' k6_severe=`k6_severe_WMH' year_2015=`year_2015_WMH' year_2016=`year_2016_WMH' year_2017=`year_2017_WMH' year_2018=`year_2018_WMH' year_2019=`year_2019_WMH' over30_tobacco_use=`over30_tobacco_use_WMH' under30_tobacco_use=`under30_tobacco_use_WMH' over30_alcohol_use=`over30_alcohol_use_WMH' under30_alcohol_use=`under30_alcohol_use_WMH' over30_mj_use=`over30_mj_use_WMH' under30_mj_use=`under30_mj_use_WMH' over30_illicit_use=`over30_illicit_use_WMH' under30_illicit_use=`under30_illicit_use_WMH' over30_pres_misuse=`over30_pres_misuse_WMH' under30_pres_misuse=`under30_pres_misuse_WMH') over(i.race_sex_sexident) subpop(sample) post coefleg
local WMH _b[1bn._predict#3bn.race_sex_sexident]
local HMH _b[2._predict#15.race_sex_sexident]
lincom `HMH' // MODEL PREDICTED AVERAGE OUTCOME FOR GAYS
lincom `WMH' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HETERO ASSUMING SAME HEALTH AS GAYS
lincom `HMH'-`WMH' // IOM DISPARITY

*********************************************************
/********************************************************
STOP CLICK AND DRAG HERE!!!!!!
********************************************************/





















/*******************************************************************************
********************************************************************************
							Test with outpatient 
********************************************************************************
*******************************************************************************/
//AHRQ Disp mean mh treatment for dif groups
svy, subpop(sample): mean out_mhtreat_py, over(newrace)
svy, subpop(sample): mean out_mhtreat_py, over(female)
svy, subpop(sample): mean out_mhtreat_py, over(sexidentx)

svy, subpop(sample): mean out_mhtreat_py, over(newrace female)
svy, subpop(sample): mean out_mhtreat_py, over(newrace sexidentx)
svy, subpop(sample): mean out_mhtreat_py, over(sexidentx female)
*************************************************************
//unadjusted reg
svy, subpop(sample): reg out_mhtreat_py i.newrace i.female i.sexidentx


*************************************************************
//adjusted for Health
svy, subpop(sample): reg out_mhtreat_py i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat
*get predicted means for outcomes from this model using margins command.
margins , over(i.newrace) subpop(sample) 
margins , over(i.sexidentx) subpop(sample) 
margins , over(i.female) subpop(sample) 


*************************************************************
//adjusted for health and SES variables
svy, subpop(sample): reg out_mhtreat_py i.newrace i.female i.sexidentx i.catag6 i.health2 i.K6_cat irmarit i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_cat

margins , over(i.newrace) subpop(sample) 
margins , over(i.sexidentx) subpop(sample) 
margins , over(i.female) subpop(sample) 
****************************************************

/*******************************************************************************
********************************************************************************
********************************************************************************
								!!!!!!END OF CODE!!!!!!
********************************************************************************
********************************************************************************
*******************************************************************************/







/***************************************************************************************************************
****************************************************************************************************************
SES DUMMY VARIABLES
****************************************************************************************************************
***************************************************************************************************************/

//IOM SES
//marriage
gen married = irmaritx==1
gen widowed = irmaritx==2
gen seperated = irmaritx==3
gen never_married = irmaritx==4

//education
gen no_hs = ireduhighst2x==1
gen hs_grad = ireduhighst2x==2
gen some_college = ireduhighst2x==3
gen college_grad = ireduhighst2x==4

//poverty
//only want values that are not missing for poverty 
gen below_poverty = poverty3x==1 
gen upto_2xpoverty = poverty3x==2
gen over_2xpoverty = poverty3x==3

//county type
gen large_metro = coutyp4x==1
gen small_metro = coutyp4x==2
gen non_metro = coutyp4x==3

//insurance category
gen private_ins = insur_type==1
gen public_ins = insur_type==2
gen uninsured = insur_cat==3






















*********************************************************************/
//START CLICKING AND DRAGGING HERE
global rhs_X_all  widowed seperated never_married hs_grad some_college college_grad upto_2xpoverty over_2xpoverty small_metro non_metro tricare medicaid medicarex uninsured
*use female and male
local subs F M
*calculate the mean of ses vars for each sex subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1
}
}

*health variable that we are including in rgerssion and run regrssion of sample
local y any_mh_treat_py /* outcome of interest*/
global rhs_Hx  widowed seperated never_married hs_grad some_college college_grad upto_2xpoverty over_2xpoverty small_metro non_metro ireduhighst2x tricare medicaid medicarex uninsured
global rhs_X i.newrace i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(sub_Fx): reg `y' $rhs_Hx $rhs_X
est sto F
svy, subpop(sub_Mx): reg `y' $rhs_Hx $rhs_X
est sto M


 /* Male and Female */
quietly suest F M, coefleg
quietly margins, predict(equation(F)) predict(equation(M)) at( widowed=`widowed_F' seperated=`seperated_F' never_married=`never_married_F' hs_grad=`hs_grad_F' some_college=`some_college_F' college_grad=`college_grad_F' upto_2xpoverty=`upto_2xpoverty_F' over_2xpoverty=`over_2xpoverty_F' small_metro=`small_metro_F' non_metro=`non_metro_F' tricare=`tricare_F' medicaid=`medicaid_F' medicare=`medicarex_F' uninsured=`uninsured_F') over(i.female) subpop(sample) post coefleg
local F _b[1bn._predict#1bn.female]
local M _b[2._predict#0.female]
lincom `F' // MODEL PREDICTED AVERAGE OUTCOME FOR FEMALE
lincom `M' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR MALES ASSUMING SAME HEALTH AS FEMALES
lincom `F'-`M' // IOM DISPARITY


/********************************************************
STOP CLICK AND DRAG HERE FOR SEX/GENDER!!!!!!
********************************************************/






/*********************************************************************
**********************************************************************
SEXUAL ORIENTATION
START CLICK AND DRAG HERE
**********************************************************************
*********************************************************************/
global rhs_X_all widowed seperated never_married hs_grad some_college college_grad upto_2xpoverty over_2xpoverty small_metro non_metro tricare medicaid medicarex uninsured
*use white black and hispanic --- ADD OTHER RACE/ETH AS WELL AS SEX AND SEX ORIENTATION SUBGROUPS (make new tokens)
//het=R bi=L
local subs D G K 
*calculate the mean of ses vars for each race subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1	
}
}



local y any_mh_treat_py /*CHANGE THE OUTCOME OF INTEREST HERE*/
global rhs_Hx female  widowed seperated never_married hs_grad some_college college_grad upto_2xpoverty over_2xpoverty small_metro non_metro tricare medicaid medicarex uninsured
global rhs_X i.newrace i.sexidentx i.catag6 i.health2 i.K6_cat
svy, subpop(hetero): reg `y' $rhs_Hx $rhs_X
est sto D
svy, subpop(gay): reg `y' $rhs_Hx $rhs_X
est sto G
svy, subpop(bisexual): reg `y' $rhs_Hx $rhs_X
est sto K


 /* gay and straight */
quietly suest D G, coefleg
quietly margins, predict(equation(D)) predict(equation(G)) at(widowed=`widowed_D' seperated=`seperated_D' never_married=`never_married_D' hs_grad=`hs_grad_D' some_college=`some_college_D' college_grad=`college_grad_D' upto_2xpoverty=`upto_2xpoverty_D' over_2xpoverty=`over_2xpoverty_D' small_metro=`small_metro_D' non_metro=`non_metro_D' tricare=`tricare_D' medicaid=`medicaid_D' medicare=`medicarex_D' uninsured=`uninsured_D') over(i.sexidentx) subpop(sample) post coefleg
local D _b[1bn._predict#1bn.sexidentx]
local G _b[2._predict#2.sexidentx]
lincom `D' // MODEL PREDICTED AVERAGE OUTCOME FOR GAYS
lincom `G' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HETERO ASSUMING SAME HEALTH AS GAYS
lincom `D'-`G' // IOM DISPARITY
*********************************************************

 /* bi and straight */
quietly suest D K, coefleg
quietly margins, predict(equation(D)) predict(equation(K)) at(widowed=`widowed_D' seperated=`seperated_D' never_married=`never_married_D' hs_grad=`hs_grad_D' some_college=`some_college_D' college_grad=`college_grad_D' upto_2xpoverty=`upto_2xpoverty_D' over_2xpoverty=`over_2xpoverty_D' small_metro=`small_metro_D' non_metro=`non_metro_D' tricare=`tricare_D' medicaid=`medicaid_D' medicare=`medicarex_D' uninsured=`uninsured_D') over(i.sexidentx) subpop(sample) post coefleg
local D _b[1bn._predict#1bn.sexidentx]
local K _b[2._predict#3.sexidentx]
lincom `D' // MODEL PREDICTED AVERAGE OUTCOME FOR BISEXUAL
lincom `K' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR HETERO ASSUMING SAME HEALTH AS BISEXUAL
lincom `D'-`K' // IOM DISPARITY
*********************************************************

 /* bi and gay*/
quietly suest G K, coefleg
quietly margins, predict(equation(G)) predict(equation(K)) at(widowed=`widowed_G' seperated=`seperated_G' never_married=`never_married_G' hs_grad=`hs_grad_G' some_college=`some_college_G' college_grad=`college_grad_G' upto_2xpoverty=`upto_2xpoverty_G' over_2xpoverty=`over_2xpoverty_G' small_metro=`small_metro_G' non_metro=`non_metro_G' tricare=`tricare_G' medicaid=`medicaid_G' medicare=`medicarex_G' uninsured=`uninsured_G') over(i.sexidentx) subpop(sample) post coefleg
local G _b[1bn._predict#2bn.sexidentx]
local K _b[2._predict#3.sexidentx]
lincom `G' // MODEL PREDICTED AVERAGE OUTCOME FOR GAYS
lincom `K' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR BISEXUAL ASSUMING SAME HEALTH AS GAYS
lincom `G'-`K' // IOM DISPARITY

/********************************************************
STOP HERE CLICK AND DRAG HERE FOR SEXUAL ORIENTATION!!!!!!
********************************************************/






























































/*********************************************************
*********************************************************
					Code Graveyard
*********************************************************
*********************************************************/

/* CLICK AND DRAG FROM HERE...*/
*ses variables we want to include in reg as dummies, or continuous (no factor vars) ADD TO THIS MACRO DUMMY VAR VERSIONS OF RACE/ETH AND SEX ORIENTATION, AND MALE!
global rhs_X_all female age18_25 age26_34 age35_49 age50_64 health_excellent health_very_good health_good health_fair_poor k6_mild k6_moderate k6_severe 
*use white black and hispanic --- ADD OTHER RACE/ETH AS WELL AS SEX AND SEX ORIENTATION SUBGROUPS (make new tokens)
local subs W B H 
*calculate the mean of ses vars for each race subgroup
*create a matrix of subgroups and ses variable
foreach S in `subs' {
svy, subpop(sub_`S'x): mean $rhs_X_all
mat `S'_b=e(b)
local i=1
local j: word count $rhs_X_all
while `i'<=`j'{
local x: word `i' of $rhs_X_all
local `x'_`S' = `S'_b[1,`i']
local i=`i'+1
}
}

***MAKE NEW SETS OF BELOW CODE FOR GENDER COMPARISON AND SEX ORIENTATION BECAUSE YOU NEED TO CYCLE THE COMPARISON VARIABLES OUT
*health variable that we are including in rgerssion and run regrssion of sample
local y any_mh_treat_py /*CHANGE THE OUTCOME OF INTEREST HERE*/
global rhs_Hx female  age26_34 age35_49 age50_64  health_very_good health_good health_fair_poor  k6_moderate k6_severe
global rhs_X i.irmaritx i.ireduhighst2x i.poverty3x i.coutyp4x i.insur_cat
svy, subpop(sub_Wx): reg `y' $rhs_Hx $rhs_X
est sto W
svy, subpop(sub_Bx): reg `y' $rhs_Hx $rhs_X
est sto B
svy, subpop(sub_Hx): reg `y' $rhs_Hx $rhs_X
est sto H


quietly suest W B, coefleg
 /* Black and White */

quietly margins, predict(equation(W)) predict(equation(B)) at(female=`female_W'  age26_34=`age26_34_W' age35_49=`age35_49_W' age50_64=`age50_64_W'  health_very_good=`health_very_good_W' health_good=`health_good_W' health_fair_poor=`health_fair_poor_W'  k6_moderate=`k6_moderate_W' k6_severe=`k6_severe_W') over(i.newrace) subpop(sample) post coefleg
local W _b[1bn._predict#1bn.newrace]
local B _b[2._predict#2.newrace]
lincom `W' // MODEL PREDICTED AVERAGE OUTCOME FOR WHITES
lincom `B' // COUNTERFACTUAL PREDICTED AVERAGE OUTCOME FOR BLACK ASSUMING SAME HEALTH AS WHITES
lincom `W'-`B' // IOM DISPARITY






*Create group variables*
/*gen new variables based on gender race and sexuality*/
***********White***********
*men (heterosexual, bisexual, gay/lesbian)
gen straightmw =  newrace==1 & sexident==1 & female==0
gen gaymw =  newrace==1 & sexident==2 & femlae==0
gen bimw = newrace==1 & sexident==3 & female==0
*women (heterosexual, bisexual, gay/lesbian)
gen straightfw =  newrace==1 & sexident==1 & female==1
gen gayfw =  newrace==1 & sexident==2 & female==1 
gen bifw = newrace==1 & sexident==3 & female==1 
*********************************************************

***********Black***********
*men (heterosexual, bisexual, gay/lesbian)
gen straightmb =  newrace==2 & sexident==1 & female==0
gen gaymb =  newrace==2 & sexident==2 & female==0
gen bimb = newrace==2 & sexident==3 & female==0
*women (heterosexual, bisexual, gay/lesbian)
gen straightfb =  newrace==2 & sexident==1 & female==1
gen gayfb =  newrace==2 & sexident==2 & female==1 
gen bifb = newrace==2 & sexident==3 & female==1 
*********************************************************

***********Asian, Indigenous, Pacific Islander***********
*men (heterosexual, bisexual, gay/lesbian)
gen straightma =  newrace==3 & sexident==1 & female==0
gen gayma =  newrace==3 & sexident==2 & female==0
gen bima = newrace==3 & sexident==3 & female==0
*women (heterosexual, bisexual, gay/lesbian)
gen straightfa =  newrace==3 & sexident==1 & female==1
gen gayfa =  newrace==3 & sexident==2 & female==1 
gen bifa = newrace==3 & sexident==3 & female==1 
*********************************************************

***********Hispanic***********
*men (heterosexual, bisexual, gay/lesbian)
gen straightmh =  newrace==4 & sexident==1 & female==0
gen gaymh =  newrace==4 & sexident==2 & female==0
gen bimh = newrace==4 & sexident==3 & female==0
*women (heterosexual, bisexual, gay/lesbian)
gen straightfh =  newrace==4 & sexident==1 & female==1
gen gayfh =  newrace==4 & sexident==2 & female==1 
gen bifh = newrace==4 & sexident==3 & female==1 
*********************************************************

***********Other***********
*men (heterosexual, bisexual, gay/lesbian)
gen straightmo =  newrace==5 & sexident==1 & female==0
gen gaymo =  newrace==5 & sexident==2 & female==0
gen bimo = newrace==5 & sexident==3 & female==0
*women (heterosexual, bisexual, gay/lesbian)
gen straightfo =  newrace==5 & sexident==1 & female==1
gen gayfo =  newrace==5 & sexident==2 & female==1 
gen bifo = newrace==5 & sexident==3 & female==1 
*********************************************************

gen sexor = sexident if sample==1
 egen rgsgroups = group(newrace female sexor)
 label define rgsgroups 1 "White Male Het" 2 "White Male Gay" 3 "White Male Bi" 4 "White Female Het" 5 "White Female Gay" 6 "White Female Bi" 7 "Black Male Het" 8 "Black Male Gay" 9 "Black Male Bi" 10 "Black Female Het" 11 "Black Female Gay" 12 "Black Female Bi" 13 "AIPI Male Het" 14 "AIPI Male Gay" 15 "AIPI Male Bi" 16 "AIPI Female Het" 17 "AIPI Female Gay" 18 "AIPI Female Bi" 19 "Hisp Male Het" 20 "Hisp Male Gay" 21 "Hisp Male Bi" 22 "Hisp Female Het" 23 "Hisp Female Gay" 24 "Hisp Female Bi" 25 "Other Male Het" 26 "Other Male Gay" 27 "Other Male Bi" 28 "Other Female Het" 29 "Other Female Gay" 30 "Other Female Bi"
label values rgsgroups rgsgroups

svy, subpop(sample): reg any_mh_treat_py rgsgroups

*********************************************************
*********************************************************
//interactions
svy, subpop(sample): reg amhtxrc3 i.newrace##i.female##i.sexidentx

svy, subpop(sample): reg amhtxrc3 i.newrace##i.female##i.sexidentx catag6 health K6_cat 
svy, subpop(sample): reg amhtxrc3 i.newrace##i.female##i.sexidentx catag6 health2 k6scmon irmarit educcat2x poverty3 coutyp4
svy, subpop(sample): reg amhtxrc3 i.newrace##i.female##i.sexid catag6 health k6scmon irmarit iieduhighst2 poverty3 coutyp4 irinsur4








*************************************************************
//Has driven under the influence in the past 12 months
// variable is: drvinaldrg, but data collection only started in 2015
tab sexidentx drvinaldrg
//bisexuals and gays more likely to DUI
//men more likely than women
//white more likely than non-whites

//Has been arrested and booked
tab booked
//bisexuals and gays slightly more likely but probs not significant
//men much more likely to have been booked
//most-least likely to be booked: black, other, white,| hispanic, aapi
// to the left of | has higher than average likelihood of having been arrested 
//I do not think this variable should be included due to known racial biases in the justice system



//start seeing if religiosity matters in regression
gen snrldcsnx=snrldcsn
replace snrldcsnx=0 if snrldcsn>10
fvset base 1 snrldcsnx

svy, subpop(sample): reg any_mh_treat_py i.snrldcsnx i.newrace i.female i.sexidentx 
svy, subpop(sample): reg any_mh_treat_py i.snrldcsnx i.newrace i.female i.sexidentx i.catag6 
svy, subpop(sample): reg any_mh_treat_py i.snrldcsnx i.newrace i.female i.sexidentx  i.K6_cat 
//adding age or(?) k6 severity makes religiosity have no effect
svy, subpop(sample): reg K6_cat i.snrldcsnx  

********************************************************************************
//since religiosity has no signifigant effect do not add into reg