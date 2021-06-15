****DATA PREP				


/* Extract all Philippine cross-sections from the original WVS timeseries dataset. 
	S024 is the variable code for country-wave.*/

keep if S024==6083 | S024==6084 | S024==6086 | S024==6087

*Retain all relevant variables.

keep S002 S007 S016 S020 /// 
	A009 A165 A170 C006 ///
	E003 E069_04 E069_06 E069_07 ///
	E069_08 E069_11 E069_17 ///
	X001 X003 X007 X025 ///
	X028 X040 X044 ///
	X045 X047 X049

*Set as panel using S002 (wave) as the cross-sectional identifier. 

xtset S002

*Rename variable names.

rename S002 wave
rename S007 idnum
rename S016 language
rename S020 year
rename A009 health
rename A165 trust
rename A170 ls
rename C006 finansit
rename E003 Poli
rename E069_04 press
rename E069_06 police
rename E069_07 congress
rename E069_08 civilserv
rename E069_11 govt
rename E069_17 judi
rename X001 sex
rename X003 age
rename X007 marital
rename X025 edu
rename X028 employ
rename X040 chiefwage
rename X044 famsavings
rename X045 socclass
rename X047 income
rename X049 settsize

*Generate Age^2.

gen agesq= age^2

/* Reverse the value order of some variables using rev package (ssc install rev).
	The command will generate a new variable with the reversed value order (RVO) but will
	retain the original varible (e.g. 'health' and 'rv_health', where 'rv_health' 
	contains the RVO.
	
	What I did is I dropped first all original variables and then renamed the RVO
	with the original names. Or you can just stick in using the generated
	variable names in the analysis. */ 

ssc install rev

rev health
rev press
rev police
rev congress
rev civilserv
rev govt
rev judi
rev socclass

drop press
drop police
drop congress
drop civilserv
drop govt
drop judi
drop health
drop socclass

rename rv_health health
rename rv_press press
rename rv_police police
rename rv_congress congress
rename rv_civilserv civilserv
rename rv_govt govt
rename rv_judi judi
rename rv_socclass socclass

/*Change numerical label of interpersonal trust dummy. The original WVS dataset	
	reports: 2=need to be very careful, 1=most people can be trusted. 
	For uniformity purposes, we change it to the conventional 1-or-0 dummy. 
	We therefore change 2 to 0 and 1 remains the same.*/
	
replace trust=0 if trust==2
label define A165 0 "Need to be very careful", modify

*To check

codebook trust


*Recode mising values (.) as 5. 

*trust has 31 missing values 
recode trust (.=3)

*ls has 1 missing value
recode ls (.=0)

*edu has 1241 missing values 
recode edu (.=9)

*income has 1,209 missing values 
recode income (.=0)

*recode missing values in the main covariates
foreach x of varlist press-judi {
	recode `x' (.=5)
}

*socclass has 17 missing values 
recode socclas (.=5)

*Generate Age Groups 

gen agegrp=. 
replace agegrp=1 if age>=15 & age<=19 
replace agegrp=2 if age>=20 & age <=24 
replace agegrp=3 if age>=25 & age <=29 
replace agegrp=4 if age>=30 & age <=34 
replace agegrp=5 if age>=35 & age <=39
replace agegrp=6 if age>=40 & age <=44 
replace agegrp=7 if age>= 45 & age <=49
replace agegrp=8 if age>=50 & age <=54
replace agegrp=9 if age>=55 & age <=59
replace agegrp=10 if age>=60 & age <=64 
replace agegrp=11 if age>=65 & age <=69 
replace agegrp=12 if age>=70 & age <=74
replace agegrp=13 if age>=75 & age <=79
replace agegrp=14 if age>=80 & age <=84 
replace agegrp=15 if age>=84 & age <=105 

xtset wave

****					TABLE 1: DESCRIPTIVE STATISTICS						****


*	1. DS for Main Variables

by wave, sort : summarize ls press police congress civilserv govt judi, detail
summarize ls press police congress civilserv govt judi, detail

*	2. DS for ALL Variables 

foreach x of varlist trust-socclass {
	by wave, sort: summarize `x'
	summarize `x'
}

****					Table 2: Polychronic Correlation Matrix				****

*Install polychoric from http://staskolenikov.net/stata 

polychoric police congress civilserv govt judi trust ls 



****					TABLE 2: LS and Controls Variables 					**** 


*Vectors C, CQ, CQZ

foreach y in "reg" {
	`y' ls age agesq i.sex i.wave, robust
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ i.wave, robust
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ ib3.health ib5.income i.trust i.wave, robust
}





***					TABLE 3.1 and 3.2: LS AND MAIN COVARIATES				***

*Police 
foreach y in "reg" { 
	`y' ls age agesq i.sex ib3.police i.wave, robust 
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ ib3.police i.wave, robust
	`y' ls  age agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.police i.wave, robust
	vif
}

*Congress
foreach y in "reg" { 
	`y' ls age agesq i.sex ib3.congress i.wave, robust 
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ ib3.congress i.wave, robust
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress i.wave, robust
	vif
}


*Civil Service 
foreach y in "reg" { 
	`y' ls age agesq i.sex ib3.civilserv i.wave, robust 
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ ib3.civilserv i.wave, robust
	`y' ls  age agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.civilserv i.wave, robust
	vif
}


*Executive/Govt/National Govt
foreach y in "reg" { 
	`y' ls age agesq i.sex ib3.govt i.wave, robust 
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ ib3.govt i.wave, robust
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.govt i.wave, robust
	vif
}


*Judiciary/Judicial System 
foreach y in "reg" { 
	`y' ls age agesq i.sex ib3.judi i.wave, robust 
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ ib3.judi i.wave, robust
	`y' ls age agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.judi i.wave, robust
	vif
}



tab judi

***						TABLE 4: FULL EQUATION 								***



foreach y in "reg" {
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt i.wave, robust
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt ib3.judi i.wave, robust
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.police ib3.congress ib3.govt ib3.civilserv ib3.judi i.wave, robust 
}

*Wald test

quietly reg ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt i.wave, robust
testparm ib3.congress ib3.govt

quietly reg ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt ib3.judi i.wave, robust	
testparm ib3.congress ib3.govt ib3.judi

quietly reg ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.police ib3.congress ib3.govt ib3.civilserv ib3.judi i.wave, robust
testparm ib3.police ib3.congress ib3.govt ib3.civilserv ib3.judi

 


***						TABLE 5: ROBUSTNESS CHECK							***

foreach y in "ologit" {
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt i.wave, or robust
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt ib3.judi i.wave, or robust
}

foreach y in "oprobit" {
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt i.wave, robust
	`y' ls agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust ib3.congress ib3.govt ib3.judi i.wave, robust
}


***								FIGURES										***

*Cumulative Distribution Functions (CDF) using Jenkin's ineqord and codes*
**First generate the groups**


ssc install ineqord, replace


*Generate two income groups

gen incgrp=.
replace incgrp=1 if income>=1 & income<=5
replace incgrp=2 if income>=6 & income<=10

*Generate three education groups


gen edgrp=. 
replace edgrp=1 if edu<=2 
replace edgrp=2 if edu>=3 & edu<=6
replace edgrp=3 if edu>=7 & edu<=8 

*Generate Health Groups

gen healthgrp=. 
replace healthgrp=1 if health==1 |health==2 | health==3
replace healthgrp=2 if health==4 | health==5 


*Congress CDF
gen congcdf=. 
replace congcdf=1 if congress>=1 & congress <=2
replace congcdf=2 if congress>=3 & congress <=4  

*Executive CDF 

gen govtcdf=. 
replace govtcdf=1 if govt>=1 & govt <=2
replace govtcdf=2 if govt>=3 & govt <=4

*Police CDF
gen policecdf=. 
replace policecdf=1 if police>=1 & police <=2
replace policecdf=2 if police>=3 & police <=4

*Civil Service CDf 
gen civilservcdf=. 
replace civilservcdf=1 if civilserv>=1 & civilserv <=2
replace civilservcdf=2 if civilserv>=3 & civilserv <=4

*Judiciary
 
gen judicdf=. 
replace judicdf=1 if judi>=1 & judi <=2
replace judicdf=2 if judi>=3 & judi <=4



tab ls
gen sat= ls+1
label variable sat "= ls + 1"



*CDFs by sex 

ineqord sat
tab sat sex, column nofreq

ineqord sat if sex == 1 & sat != 1, alpha(.9) ///
catv(v_male) catpr(f_male) catcpr(F_male) catspr(S_male) ///
gldvar(gld_male) gluvar(glu_male) hplus(hp_male) hminus(hm_male)

ineqord sat if sex == 2 & sat != 1, alpha(.9) ///
catv(v_fem) catpr(f_fem) catcpr(F_fem) catspr(S_fem) ///
gldvar(gld_fem) gluvar(glu_fem) hplus(hp_fem) hminus(hm_fem)

tw (line F_male v_male, sort c(stairstep) lcolor(black) ) ///
(line F_fem v_fem, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "Male") label(2 "Female") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(sex.gph, replace) 


*CDFs by incgroup

ineqord sat
tab sat incgrp, column nofreq

ineqord sat if incgrp == 1 & sat != 1, alpha(.9) ///
catv(v_bel) catpr(f_bel) catcpr(F_bel) catspr(S_bel) ///
gldvar(gld_bel) gluvar(glu_bel) hplus(hp_bel) hminus(hm_bel)

ineqord sat if incgrp == 2 & sat !=1, alpha(.9) ///
catv(v_abv) catpr(f_abv) catcpr(F_abv) catspr(S_abv) ///
gldvar(gld_abv) gluvar(glu_abv) hplus(hp_abv) hminus(hm_abv)

tw (line F_bel v_bel, sort c(stairstep) lcolor(black) ) ///
(line F_abv v_abv, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "Income<=5") label(2 "Income >=6 & Income <=10") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(income.gph, replace) 



*CDFs by education group 


ineqord sat if edgrp == 1 & sat != 1, alpha(.9) ///
catv(v_elem) catpr(f_elem) catcpr(F_elem) catspr(S_elem) ///
gldvar(gld_elem) gluvar(glu_elem) hplus(hp_elem) hminus(hm_elem)

ineqord sat if edgrp == 2 & sat !=1, alpha(.9) ///
catv(v_sec) catpr(f_sec) catcpr(F_sec) catspr(S_sec) ///
gldvar(gld_sec) gluvar(glu_sec) hplus(hp_sec) hminus(hm_sec)

ineqord sat if edgrp == 3 & sat !=1, alpha(.9) ///
catv(v_uni) catpr(f_uni) catcpr(F_uni) catspr(S_uni) ///
gldvar(gld_uni) gluvar(glu_uni) hplus(hp_uni) hminus(hm_uni)


tw (line F_elem v_elem, sort c(stairstep) lcolor(black) ) ///
(line F_sec v_sec, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
(line F_uni v_uni, sort c(stairstep) lcolor(black) lpatt(longdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "Elementary Level-Un/completed") label(2 "Secondary Level-Un/completed") ///
label(3 "University Level-Un/completed") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(income.gph, replace) 


*CDFs by employment status Employed vs Unemployed 


ineqord sat if employ==1,  alpha(.9) ///
catv(v_full) catpr(f_full) catcpr(F_full) catspr(S_full) ///
gldvar(gld_full) gluvar(glu_full) hplus(hp_full) hminus(hm_full)

ineqord sat if employ== 7 & sat != 1, alpha(.9) ///
catv(v_unem) catpr(f_unem) catcpr(F_unem) catspr(S_unem) ///
gldvar(gld_unem) gluvar(glu_unem) hplus(hp_unem) hminus(hm_unem)

tw (line F_full v_full, sort c(stairstep) lcolor(black) ) ///
(line F_unem v_unem, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "Full time") label(2 "Unemployed") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(employ.gph, replace) 


*CDFs by Health Status 

ineqord sat if healthgrp == 1 & sat != 1,  alpha(.9) ///
catv(v_poor) catpr(f_poor) catcpr(F_poor) catspr(S_poor) ///
gldvar(gld_poor) gluvar(glu_poor) hplus(hp_poor) hminus(hm_poor)

ineqord sat if healthgrp== 2 & sat != 1, alpha(.9) ///
catv(v_good) catpr(f_good) catcpr(F_good) catspr(S_good) ///
gldvar(gld_good) gluvar(glu_good) hplus(hp_good) hminus(hm_good)

tw (line F_poor v_poor, sort c(stairstep) lcolor(black) ) ///
(line F_good v_good, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "Very Poor to Fair") label(2 "Good to Very Good") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(health.gph, replace) 


*CDFs of main covariates 

*Congress


ineqord sat if congcdf  == 1 & sat !=1, alpha(.9) ///
catv(v_not) catpr(f_not) catcpr(F_not) catspr(S_not) ///
gldvar(gld_not) gluvar(glu_not) hplus(hp_not) hminus(hm_not)

ineqord sat if congcdf == 2 & sat !=1, alpha(.9) ///
catv(v_notvm) catpr(f_notvm) catcpr(F_notvm) catspr(S_notvm) ///
gldvar(gld_notvm) gluvar(glu_notvm) hplus(hp_notvm) hminus(hm_notvm) 


tw (line F_not v_not, sort c(stairstep) lcolor(black) ) ///
(line F_notvm v_notvm, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "None at all & Not very much") label(2 "Quite a lot & A great deal") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(cong.gph, replace) 

drop v_not gld_not glu_not hp_not hm_not f_not F_not S_not v_notvm gld_notvm glu_notvm hp_notvm hm_notvm f_notvm F_notvm S_notvm 


*Executive 


ineqord sat if govtcdf  == 1 & sat !=1, alpha(.9) ///
catv(v_not) catpr(f_not) catcpr(F_not) catspr(S_not) ///
gldvar(gld_not) gluvar(glu_not) hplus(hp_not) hminus(hm_not)

ineqord sat if govtcdf == 2 & sat !=1, alpha(.9) ///
catv(v_notvm) catpr(f_notvm) catcpr(F_notvm) catspr(S_notvm) ///
gldvar(gld_notvm) gluvar(glu_notvm) hplus(hp_notvm) hminus(hm_notvm) 


tw (line F_not v_not, sort c(stairstep) lcolor(black) ) ///
(line F_notvm v_notvm, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "None at all & Not very much") label(2 "Quite a lot & A great deal") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(cong.gph, replace) 

drop v_not gld_not glu_not hp_not hm_not f_not F_not S_not v_notvm gld_notvm glu_notvm hp_notvm hm_notvm f_notvm F_notvm S_notvm



*Police 

ineqord sat if policecdf  == 1 & sat !=1, alpha(.9) ///
catv(v_not) catpr(f_not) catcpr(F_not) catspr(S_not) ///
gldvar(gld_not) gluvar(glu_not) hplus(hp_not) hminus(hm_not)

ineqord sat if policecdf == 2 & sat !=1, alpha(.9) ///
catv(v_notvm) catpr(f_notvm) catcpr(F_notvm) catspr(S_notvm) ///
gldvar(gld_notvm) gluvar(glu_notvm) hplus(hp_notvm) hminus(hm_notvm) 


tw (line F_not v_not, sort c(stairstep) lcolor(black) ) ///
(line F_notvm v_notvm, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "No trust at all & Not very much") label(2 "Quite a lot & A great deal") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(cong.gph, replace) 

drop v_not gld_not glu_not hp_not hm_not f_not F_not S_not v_notvm gld_notvm glu_notvm hp_notvm hm_notvm f_notvm F_notvm S_notvm


*Civil Service 


ineqord sat if civilservcdf == 1 & sat !=1, alpha(.9) ///
catv(v_not) catpr(f_not) catcpr(F_not) catspr(S_not) ///
gldvar(gld_not) gluvar(glu_not) hplus(hp_not) hminus(hm_not)

ineqord sat if civilservcdf == 2 & sat !=1, alpha(.9) ///
catv(v_notvm) catpr(f_notvm) catcpr(F_notvm) catspr(S_notvm) ///
gldvar(gld_notvm) gluvar(glu_notvm) hplus(hp_notvm) hminus(hm_notvm) 


tw (line F_not v_not, sort c(stairstep) lcolor(black) ) ///
(line F_notvm v_notvm, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "No trust at all & Not very much") label(2 "Quite a lot & A great deal") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(cong.gph, replace) 

drop v_not gld_not glu_not hp_not hm_not f_not F_not S_not v_notvm gld_notvm glu_notvm hp_notvm hm_notvm f_notvm F_notvm S_notvm



*Judiciary 

ineqord sat if judicdf == 1 & sat !=1, alpha(.9) ///
catv(v_not) catpr(f_not) catcpr(F_not) catspr(S_not) ///
gldvar(gld_not) gluvar(glu_not) hplus(hp_not) hminus(hm_not)

ineqord sat if judicdf == 2 & sat !=1, alpha(.9) ///
catv(v_notvm) catpr(f_notvm) catcpr(F_notvm) catspr(S_notvm) ///
gldvar(gld_notvm) gluvar(glu_notvm) hplus(hp_notvm) hminus(hm_notvm) 


tw (line F_not v_not, sort c(stairstep) lcolor(black) ) ///
(line F_notvm v_notvm, sort c(stairstep) lcolor(black) lpatt(shortdash) ) ///
, xlab(1(1)11) yline(0.5, lpatt(shortdash) lcol(black)) ///
ylab(0(.1)1, angle(0)) ytitle("{it:p}") xtitle("Response (rescaled)") ///
legend(label(1 "No trust at all & Not very much") label(2 "Quite a lot & A great deal") col(1) ///
ring(0) position(11) ) ///
scheme(s1color) graphregion(color(white)) ///
saving(cong.gph, replace) 

drop v_not gld_not glu_not hp_not hm_not f_not F_not S_not v_notvm gld_notvm glu_notvm hp_notvm hm_notvm f_notvm F_notvm S_notvm
















****				SUPPLEMENTARY/NOT REPORTED IN THE ARTICLE				****


***Third Robustness Check 


*LS of Differenct Pop Groups and How Different Institutions affect LS of different population groups*

*First we recode back 5 as missing (.) for all variables 

recode congress (5=.)
recode govt (5=.)
recode judi (5=.)
recode police (5=.)
recode press (5=.)
recode income (0=.)
recode ls (0=.)
recode edu (9=.)



*Predicted LS of people with different education levels
reg ls age agesq i.sex i.edu ib3.marital ib6.employ health i.income i.trust i.wave, robust
margins i.edu
marginsplot,recast(line) recastci(rarea) ciopts(color(*.8)) 

*Predicted LS of people with different income level 
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health i.income i.trust i.wave, robust
margins i.income, atmean
marginsplot,recast(line) recastci(rarea) ciopts(color(*.8)) 

*Predicted LS of people with different health levels 
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ i.health i.income i.trust i.wave, robust
margins health, atmean
marginsplot,recast(line) recastci(rarea) ciopts(color(*.8)) 

*Predicted LS of people with different employment 
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health i.income i.trust i.wave, robust
margins i.employ, atmean
marginsplot,recast(line) recastci(rarea) ciopts(color(*.8)) 


*Congress x social status 
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health income i.socclass i.trust ib3.congress i.congress##i.socclass i.wave, robust
margins i.congress##i.socclass, atmean
marginsplot, by(socclass) recast(line) recastci(rarea) ciopts(color(*.8)) 


*Executive x social status 
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health income i.socclass i.trust ib3.govt i.govt##i.socclass i.wave, robust
margins i.govt##i.socclass, atmean
marginsplot, by(socclass) recast(line) recastci(rarea) ciopts(color(*.8)) 

*Judiciary x social status 
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health income i.socclass i.trust ib3.judi i.judi##i.socclass i.wave, robust
margins i.judi##i.socclass, atmean
marginsplot, by(socclass) recast(line) recastci(rarea) ciopts(color(*.8)) 

**Congress x income
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health i.income i.trust ib3.congress i.congress##i.income i.wave, robust
margins i.congress##i.income, atmean
marginsplot, by(income) recast(line) recastci(rarea) ciopts(color(*.8)) 


*Executive x income
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health i.income i.trust ib3.govt i.govt##i.income i.wave, robust
margins i.govt##i.income, atmean
marginsplot, by(income) recast(line) recastci(rarea) ciopts(color(*.8)) 

*Judiciary x income
reg ls  age agesq i.sex i.edu ib3.marital ib6.employ health i.income  i.trust ib3.judi i.judi##i.income i.wave, robust
margins i.judi##i.income, atmean
marginsplot, by(income) recast(line) recastci(rarea) ciopts(color(*.8))  
	



***Suppementary Graphs

/*Generate descriptive graphs for main covariates. Combine graphs in one panel. Note that times 1 to 4 are Waves 3,4,6 and 7, respectivelu*/

*Press from Time 1 to 4
histogram press in 1/1200, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 1) name (pt1) 

histogram press in 1201/2400, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 2) name (pt2)

histogram press in 2401/3600, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 3) name (pt3)

histogram press in 3601/4800, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 4) name (pt4)
 
*Police from Time 1 to 4

histogram police in 1/1200, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 1) name (pol1)

histogram police in 1201/2400, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 2) name (pol2)

histogram police in 2401/3600, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 3) name (pol3)

histogram police in 3601/4800, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 4) name (pol4)

*Congress from Time 1 to 4

histogram congress in 1/1200, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 1) name (cong1)

histogram congress in 1201/2400, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 2) name (cong2)

histogram congress in 2401/3600, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 3) name (cong3)

histogram congress in 3601/4800, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 4) name (cong4)


*Civilserv from Time 1 to 4

histogram civilserv in 1/1200, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 1) name (civ1)

histogram civilserv in 1201/2400, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 2) name (civ2)

histogram civilserv in 2401/3600, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave3) name (civ3)

histogram civilserv in 3601/4800, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 4) name (civ4)
 
*Govt from Time 1 to 4
 
histogram govt in 1/1200, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 1) name (g1)

histogram govt in 1201/2400, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 2) name (g2)

histogram govt in 2401/3600, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 3) name (g3)

histogram govt in 3601/4800, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 4) name (g4)

*Judi from Time 1 to 4

histogram judi in 1/1200, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 1) name (j1)

histogram judi in 2401/3600, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 3) name (j3)

histogram judi in 3601/4800, frequency fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) title(Wave 4) name (j4)

*combine graphs 

graph combine pt1 pt2 pt3 pt4 pol1 pol2 pol3 pol4 cong1 cong2 cong3 cong4 civ1 civ2 civ3 civ4 g1 g2 g3 g4 j1 j3 j4, col(4) row(6)

 
*Generate hist for ls 

histogram ls in 1/1200, frequency bin(10) fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) normal xlabel(#10) title(Wave 1) name(l1)

histogram ls in 1201/2400, frequency bin(10) fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) normal xlabel(#10) title(Wave 2) name(l2)

histogram ls in 2401/3600, frequency bin(10) fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) normal xlabel(#10) title(Wave 3) name(l3)

histogram ls in 3601/4800, frequency bin(10) fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) normal xlabel(#10) title(Wave 4) name (l4)

graph combine l1 l2 l3 l4, col(2) row(2)


histogram ls, frequency bin(10) fcolor(dknavy) ylabel(,labsize(tiny)) lcolor(none) barwidth(1) normal xlabel(#10) title(Wave 4) name (ls) 

