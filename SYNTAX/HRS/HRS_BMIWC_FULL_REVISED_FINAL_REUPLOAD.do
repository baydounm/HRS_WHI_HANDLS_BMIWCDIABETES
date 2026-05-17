clear
clear mata
clear matrix
set maxvar 20000, permanently


**D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_DIET_FRAILTY_COG**

*********************************************************************************************************************************************

capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\DATA_MANAGEMENT_HRS.txt",text replace

**STEP 0: OPEN FILES AND CREATE HHIDPN VARIABLE, SORT BY THIS VARIABLE**

cd "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\"

use randhrs1992_2020v2,clear


capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

use trk2022tr_r,clear
capture rename HHID-VERSION,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

**STEP 1: REDUCE RAND FILE TO RESPONDENT VARIABLE FILE****

use randhrs1992_2020v2,clear
 
keep HHIDPN r* inw* h*

save randhrs1992_2020v2_resp, replace



**STEP 2: MERGE REDUCED RAND FILE WITH TRACKER FILE****

use randhrs1992_2020v2_resp,clear
capture drop _merge
merge HHIDPN using trk2022tr_r
tab _merge
capture drop _merge
sort HHIDPN
save randhrs1992_2020v2_resp_tracker, replace




**STEP 3: DESCRIBE AND SUMMARIZE THE FILE****

describe 

su 

**STEP 4: IDENTIFY THE REQUIRED VARIABLES USING RAND AND TRACKER FILE DOCUMENTATION AND LIST THEM ****
use randhrs1992_2020v2_resp_tracker,clear


**LIST OF AGE VARIABLES (2006-2018):
**2006 is r8: r8agey_e
**2008 is r9: r9agey_e
**2010 is r10: r10agey_e
**2012 is r11: r11agey_e
**2014 is r12: r12agey_e
**2016 is r13: r13agey_e
**2018 is r14: r14agey_e

su r8agey_e r9agey_e r10agey_e r11agey_e r12agey_e r13agey_e r14agey_e


**LIST OF VARIABLES NEEDED TO CREATE THE RACE/ETHNICITY (fixed):

**RACD: need to impute, n=5 missing**

capture drop RACE
gen RACE=rarace

tab RACE 

**Ethnicity: 1=Hispanic, 0=Non-Hispanic: n=1 missing

capture drop ETHNICITY
gen ETHNICITY=rahispan

tab ETHNICITY 

**RACE/ETHNICITY: 

capture drop RACE_ETHN
gen RACE_ETHN=.
replace RACE_ETHN=1 if RACE==1 & ETHNICITY==0
replace RACE_ETHN=2 if RACE==2 & ETHNICITY==0
replace RACE_ETHN=3 if ETHNICITY==1 & RACE~=.
replace RACE_ETHN=4 if RACE==3 & ETHNICITY==0

tab RACE_ETHN,missing
tab RACE_ETHN 


**GENDER (fixed):

capture drop SEX
gen SEX=ragender

tab SEX 


**EDUCATION (fixed):

tab raeduc, missing 

capture drop education
gen education = .
replace education = 1 if raeduc == 1 /*< HS*/
replace education = 2 if raeduc == 2 /*GED*/
replace education = 3 if raeduc == 3 /*HS GRADUATE*/
replace education = 4 if raeduc == 4 /*SOME COLLEGE*/
replace education = 5 if raeduc == 5 /*COLLEGE AND ABOVE*/

tab education , missing
tab education 

************************************************************2006*************************************************************


**INCOME VARIABLE (2006):

tab h8itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2006
gen totwealth_2006 = .
replace totwealth_2006 = 1 if h8itot < 25000
replace totwealth_2006 = 2 if h8itot >= 25000 & h8itot < 125000
replace totwealth_2006 = 3 if h8itot >= 125000 & h8itot < 300000
replace totwealth_2006 = 4 if h8itot >= 300000 & h8itot < 650000
replace totwealth_2006 = 5 if h8itot >= 650000 & h8itot ~= .


tab totwealth_2006 , missing
tab totwealth_2006 

save, replace

**MARITAL STATUS (2006)**

tab r8mstat, missing

capture drop marital_2006
gen marital_2006 = .
replace marital_2006 = 1 if r8mstat == 8 /*never married*/
replace marital_2006 = 2 if (r8mstat == 1 | r8mstat == 2 | r8mstat == 3) /*married / partnered*/
replace marital_2006 = 3 if (r8mstat == 4 | r8mstat == 5 | r8mstat == 6) /*separated / divorced*/
replace marital_2006 = 4 if (r8mstat == 7) /*widowed*/

tab marital_2006, missing
tab marital_2006

**EMPLOYMENT (2006):

tab r8work, missing

capture drop work_st_2006
gen work_st_2006 = .
replace work_st_2006 = 0 if r8work == 0
replace work_st_2006 = 1 if r8work == 1

tab work_st_2006, missing
tab work_st_2006


**CIGARETTE SMOKING (2006): 
tab r8smokev, missing
tab r8smoken, missing

capture drop smoking_2006
gen smoking_2006 = .
replace smoking_2006 = 1 if r8smokev == 0
replace smoking_2006 = 2 if r8smokev == 1 & r8smoken == 0
replace smoking_2006 = 3 if r8smokev == 1 & r8smoken == 1

tab smoking_2006, missing
tab smoking_2006 

save, replace



*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2006* n=173 missing/


tab r8drink, missing
tab r8drinkd, missing


capture drop alcohol_2006
gen alcohol_2006 = .
replace alcohol_2006 = 1 if r8drink == 0
replace alcohol_2006 = 2 if r8drink == 1 & r8drinkd == 0
replace alcohol_2006 = 3 if r8drink == 1 & (r8drinkd == 1 | r8drinkd == 2)
replace alcohol_2006 = 4 if r8drink == 1 & (r8drinkd > 3 & r8drinkd ~= . & r8drinkd ~= .d & r8drinkd ~= .m & r8drinkd ~= .r)

tab alcohol_2006, missing


**PHYSICAL ACTIVITY (2006):
tab r8vgactx, missing
tab r8mdactx, missing

capture drop physic_act_2006
gen physic_act_2006 = .
replace physic_act_2006 = 1 if (r8vgactx ==  5 & r8mdactx == 5)
replace physic_act_2006 = 2 if (r8vgactx ==  3 | r8mdactx == 3 | r8vgactx ==  4 | r8mdactx == 4)
replace physic_act_2006 = 3 if (r8vgactx ==  1 | r8mdactx == 1 | r8vgactx ==  2 | r8mdactx == 2)

tab physic_act_2006, missing
tab physic_act_2006


**SELF-RATED HEALTH (2006):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r8shlt, missing

capture drop srh_2006
gen srh_2006 = .
replace srh_2006 = 1 if (r8shlt == 1 | r8shlt == 2 | r8shlt == 3)
replace srh_2006 = 2 if (r8shlt == 4 | r8shlt == 5)

tab srh_2006, missing
tab srh_2006 

save, replace


**WEIGTH STATUS, 2006**
/*body mass index*/

/*2006*/

*<25 
**  25-29.9
**  ≥30


tab r8pmbmi, missing
tab r8bmi, missing
tab r8bmi , missing
tab r8bmi 
su r8bmi ,det


capture drop bmi_2006
gen bmi_2006 = r8pmbmi if r8pmbmi < 100
else replace bmi_2006 = r8bmi if r8bmi < 100

tab bmi_2006, missing
tab bmi_2006 , missing
tab bmi_2006 
su bmi_2006 , det



capture drop bmibr_2006
gen bmibr_2006 = 1 if bmi_2006 < 25
replace bmibr_2006 = 2 if bmi_2006 >= 25 & bmi_2006 < 30
replace bmibr_2006 = 3 if bmi_2006 >= 30 & bmi_2006 ~= .

tab bmibr_2006, missing


/*cardiometabolic risk factors and chronic conditions, 2006*/

/*HYPERTENSION*/

tab r8hibpe, missing

capture drop hbp_ever_2006sv
gen hbp_ever_2006 = .
replace hbp_ever_2006 = 0 if r8hibpe == 0
replace hbp_ever_2006 = 1 if r8hibpe == 1

tab hbp_ever_2006, missing
tab hbp_ever_2006 


/*DIABETES*/

tab r8diabe, missing

capture drop diab_ever_2006
gen diab_ever_2006 = .
replace diab_ever_2006 = 0 if r8diabe == 0
replace diab_ever_2006 = 1 if r8diabe == 1

tab diab_ever_2006, missing
tab diab_ever_2006 


/*HEART PROBLEMS*/

tab r8hearte, missing

capture drop heart_ever_2006
gen heart_ever_2006 = .
replace heart_ever_2006 = 0 if r8hearte == 0
replace heart_ever_2006 = 1 if r8hearte == 1

tab heart_ever_2006, missing
tab heart_ever_2006 


/*STROKE*/

tab r8stroke, missing

capture drop stroke_ever_2006
gen stroke_ever_2006 = .
replace stroke_ever_2006 = 0 if r8stroke == 0
replace stroke_ever_2006 = 1 if r8stroke == 1

tab stroke_ever_2006, missing
tab stroke_ever_2006 , missing
tab stroke_ever_2006 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2006
gen cardiometcond_2006 = .
replace cardiometcond_2006 = hbp_ever_2006 + diab_ever_2006 + heart_ever_2006 + stroke_ever_2006

tab cardiometcond_2006, missing
tab cardiometcond_2006 , missing
tab cardiometcond_2006 


capture drop cardiometcondbr_2006
gen cardiometcondbr_2006 = .
replace cardiometcondbr_2006 = 1 if cardiometcond_2006 ==0
replace cardiometcondbr_2006 = 2 if (cardiometcond_2006 == 1 | cardiometcond_2006 == 2)
replace cardiometcondbr_2006 = 3 if (cardiometcond_2006 == 3 | cardiometcond_2006 == 4)

tab cardiometcondbr_2006, missing
tab cardiometcondbr_2006 

**2006 CESD**
capture drop cesd_2006
gen cesd_2006=r8cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2006-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 


************************************************2008****************************************************************************************************

**INCOME VARIABLE (2008):

tab h9itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2008
gen totwealth_2008 = .
replace totwealth_2008 = 1 if h9itot < 25000
replace totwealth_2008 = 2 if h9itot >= 25000 & h9itot < 125000
replace totwealth_2008 = 3 if h9itot >= 125000 & h9itot < 300000
replace totwealth_2008 = 4 if h9itot >= 300000 & h9itot < 650000
replace totwealth_2008 = 5 if h9itot >= 650000 & h9itot ~= .


tab totwealth_2008 , missing
tab totwealth_2008 

save, replace

**MARITAL STATUS (2008)**

tab r9mstat, missing

capture drop marital_2008
gen marital_2008 = .
replace marital_2008 = 1 if r9mstat == 8 /*never married*/
replace marital_2008 = 2 if (r9mstat == 1 | r9mstat == 2 | r9mstat == 3) /*married / partnered*/
replace marital_2008 = 3 if (r9mstat == 4 | r9mstat == 5 | r9mstat == 6) /*separated / divorced*/
replace marital_2008 = 4 if (r9mstat == 7) /*widowed*/

tab marital_2008, missing
tab marital_2008

**EMPLOYMENT (2008):

tab r9work, missing

capture drop work_st_2008
gen work_st_2008 = .
replace work_st_2008 = 0 if r9work == 0
replace work_st_2008 = 1 if r9work == 1

tab work_st_2008, missing
tab work_st_2008


**CIGARETTE SMOKING (2008): 
tab r9smokev, missing
tab r9smoken, missing

capture drop smoking_2008
gen smoking_2008 = .
replace smoking_2008 = 1 if r9smokev == 0
replace smoking_2008 = 2 if r9smokev == 1 & r9smoken == 0
replace smoking_2008 = 3 if r9smokev == 1 & r9smoken == 1

tab smoking_2008, missing
tab smoking_2008 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2008* n=173 missing/


tab r10drink, missing
tab r10drinkd, missing


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2008* n=173 missing/


tab r9drink, missing
tab r9drinkd, missing


capture drop alcohol_2008
gen alcohol_2008 = .
replace alcohol_2008 = 1 if r9drink == 0
replace alcohol_2008 = 2 if r9drink == 1 & r9drinkd == 0
replace alcohol_2008 = 3 if r9drink == 1 & (r9drinkd == 1 | r9drinkd == 2)
replace alcohol_2008 = 4 if r9drink == 1 & (r9drinkd > 3 & r9drinkd ~= . & r9drinkd ~= .d & r9drinkd ~= .m & r9drinkd ~= .r)

tab alcohol_2008, missing


**PHYSICAL ACTIVITY (2008):
tab r9vgactx, missing
tab r9mdactx, missing

capture drop physic_act_2008
gen physic_act_2008 = .
replace physic_act_2008 = 1 if (r9vgactx ==  5 & r9mdactx == 5)
replace physic_act_2008 = 2 if (r9vgactx ==  3 | r9mdactx == 3 | r9vgactx ==  4 | r9mdactx == 4)
replace physic_act_2008 = 3 if (r9vgactx ==  1 | r9mdactx == 1 | r9vgactx ==  2 | r9mdactx == 2)

tab physic_act_2008, missing
tab physic_act_2008


**SELF-RATED HEALTH (2008):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r9shlt, missing

capture drop srh_2008
gen srh_2008 = .
replace srh_2008 = 1 if (r9shlt == 1 | r9shlt == 2 | r9shlt == 3)
replace srh_2008 = 2 if (r9shlt == 4 | r9shlt == 5)

tab srh_2008, missing
tab srh_2008 

save, replace


**WEIGTH STATUS, 2008**
/*body mass index*/

/*2008*/

*<25 
**  25-29.9
**  ≥30


tab r9pmbmi, missing
tab r9bmi, missing
tab r9bmi , missing
tab r9bmi 
su r9bmi ,det


capture drop bmi_2008
gen bmi_2008 = r9pmbmi if r9pmbmi < 100
else replace bmi_2008 = r9bmi if r9bmi < 100

tab bmi_2008, missing
tab bmi_2008 , missing
tab bmi_2008 
su bmi_2008 , det



capture drop bmibr_2008
gen bmibr_2008 = 1 if bmi_2008 < 25
replace bmibr_2008 = 2 if bmi_2008 >= 25 & bmi_2008 < 30
replace bmibr_2008 = 3 if bmi_2008 >= 30 & bmi_2008 ~= .

tab bmibr_2008, missing


/*cardiometabolic risk factors and chronic conditions, 2008*/

/*HYPERTENSION*/

tab r9hibpe, missing

capture drop hbp_ever_2008
gen hbp_ever_2008 = .
replace hbp_ever_2008 = 0 if r9hibpe == 0
replace hbp_ever_2008 = 1 if r9hibpe == 1

tab hbp_ever_2008, missing
tab hbp_ever_2008 


/*DIABETES*/

tab r9diabe, missing

capture drop diab_ever_2008
gen diab_ever_2008 = .
replace diab_ever_2008 = 0 if r9diabe == 0
replace diab_ever_2008 = 1 if r9diabe == 1

tab diab_ever_2008, missing
tab diab_ever_2008 


/*HEART PROBLEMS*/

tab r9hearte, missing

capture drop heart_ever_2008
gen heart_ever_2008 = .
replace heart_ever_2008 = 0 if r9hearte == 0
replace heart_ever_2008 = 1 if r9hearte == 1

tab heart_ever_2008, missing
tab heart_ever_2008 


/*STROKE*/

tab r9stroke, missing

capture drop stroke_ever_2008
gen stroke_ever_2008 = .
replace stroke_ever_2008 = 0 if r9stroke == 0
replace stroke_ever_2008 = 1 if r9stroke == 1

tab stroke_ever_2008, missing
tab stroke_ever_2008 , missing
tab stroke_ever_2008 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2008
gen cardiometcond_2008 = .
replace cardiometcond_2008 = hbp_ever_2008 + diab_ever_2008 + heart_ever_2008 + stroke_ever_2008

tab cardiometcond_2008, missing
tab cardiometcond_2008 , missing
tab cardiometcond_2008 


capture drop cardiometcondbr_2008
gen cardiometcondbr_2008 = .
replace cardiometcondbr_2008 = 1 if cardiometcond_2008 ==0
replace cardiometcondbr_2008 = 2 if (cardiometcond_2008 == 1 | cardiometcond_2008 == 2)
replace cardiometcondbr_2008 = 3 if (cardiometcond_2008 == 3 | cardiometcond_2008 == 4)

tab cardiometcondbr_2008, missing
tab cardiometcondbr_2008 

**2008 CESD**
capture drop cesd_2008
gen cesd_2008=r9cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2008-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 


**********************************************2010***************************************************************


**INCOME VARIABLE (2010):

tab h10itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2010
gen totwealth_2010 = .
replace totwealth_2010 = 1 if h10itot < 25000
replace totwealth_2010 = 2 if h10itot >= 25000 & h10itot < 125000
replace totwealth_2010 = 3 if h10itot >= 125000 & h10itot < 300000
replace totwealth_2010 = 4 if h10itot >= 300000 & h10itot < 650000
replace totwealth_2010 = 5 if h10itot >= 650000 & h10itot ~= .


tab totwealth_2010 , missing
tab totwealth_2010 

save, replace

**MARITAL STATUS (2010)**

tab r10mstat, missing

capture drop marital_2010
gen marital_2010 = .
replace marital_2010 = 1 if r10mstat == 8 /*never married*/
replace marital_2010 = 2 if (r10mstat == 1 | r10mstat == 2 | r10mstat == 3) /*married / partnered*/
replace marital_2010 = 3 if (r10mstat == 4 | r10mstat == 5 | r10mstat == 6) /*separated / divorced*/
replace marital_2010 = 4 if (r10mstat == 7) /*widowed*/

tab marital_2010, missing
tab marital_2010

**EMPLOYMENT (2010):

tab r10work, missing

capture drop work_st_2010
gen work_st_2010 = .
replace work_st_2010 = 0 if r10work == 0
replace work_st_2010 = 1 if r10work == 1

tab work_st_2010, missing
tab work_st_2010


**CIGARETTE SMOKING (2010): 
tab r10smokev, missing
tab r10smoken, missing

capture drop smoking_2010
gen smoking_2010 = .
replace smoking_2010 = 1 if r10smokev == 0
replace smoking_2010 = 2 if r10smokev == 1 & r10smoken == 0
replace smoking_2010 = 3 if r10smokev == 1 & r10smoken == 1

tab smoking_2010, missing
tab smoking_2010 

save, replace


*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2010* n=173 missing/


tab r10drink, missing
tab r10drinkd, missing


capture drop alcohol_2010
gen alcohol_2010 = .
replace alcohol_2010 = 1 if r10drink == 0
replace alcohol_2010 = 2 if r10drink == 1 & r10drinkd == 0
replace alcohol_2010 = 3 if r10drink == 1 & (r10drinkd == 1 | r10drinkd == 2)
replace alcohol_2010 = 4 if r10drink == 1 & (r10drinkd > 3 & r10drinkd ~= . & r10drinkd ~= .d & r10drinkd ~= .m & r10drinkd ~= .r)

tab alcohol_2010, missing


**PHYSICAL ACTIVITY (2010):
tab r10vgactx, missing
tab r10mdactx, missing

capture drop physic_act_2010
gen physic_act_2010 = .
replace physic_act_2010 = 1 if (r10vgactx ==  5 & r10mdactx == 5)
replace physic_act_2010 = 2 if (r10vgactx ==  3 | r10mdactx == 3 | r10vgactx ==  4 | r10mdactx == 4)
replace physic_act_2010 = 3 if (r10vgactx ==  1 | r10mdactx == 1 | r10vgactx ==  2 | r10mdactx == 2)

tab physic_act_2010, missing
tab physic_act_2010


**SELF-RATED HEALTH (2010):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r10shlt, missing

capture drop srh_2010
gen srh_2010 = .
replace srh_2010 = 1 if (r10shlt == 1 | r10shlt == 2 | r10shlt == 3)
replace srh_2010 = 2 if (r10shlt == 4 | r10shlt == 5)

tab srh_2010, missing
tab srh_2010 

save, replace


**WEIGTH STATUS, 2010**
/*body mass index*/

/*2010*/

*<25 
**  25-29.9
**  ≥30


tab r10pmbmi, missing
tab r10bmi, missing
tab r10bmi , missing
tab r10bmi 
su r10bmi ,det


capture drop bmi_2010
gen bmi_2010 = r10pmbmi if r10pmbmi < 100
else replace bmi_2010 = r10bmi if r10bmi < 100

tab bmi_2010, missing
tab bmi_2010 , missing
tab bmi_2010 
su bmi_2010 , det



capture drop bmibr_2010
gen bmibr_2010 = 1 if bmi_2010 < 25
replace bmibr_2010 = 2 if bmi_2010 >= 25 & bmi_2010 < 30
replace bmibr_2010 = 3 if bmi_2010 >= 30 & bmi_2010 ~= .

tab bmibr_2010, missing


/*cardiometabolic risk factors and chronic conditions, 2010*/

/*HYPERTENSION*/

tab r10hibpe, missing

capture drop hbp_ever_2010
gen hbp_ever_2010 = .
replace hbp_ever_2010 = 0 if r10hibpe == 0
replace hbp_ever_2010 = 1 if r10hibpe == 1

tab hbp_ever_2010, missing
tab hbp_ever_2010 


/*DIABETES*/

tab r10diabe, missing

capture drop diab_ever_2010
gen diab_ever_2010 = .
replace diab_ever_2010 = 0 if r10diabe == 0
replace diab_ever_2010 = 1 if r10diabe == 1

tab diab_ever_2010, missing
tab diab_ever_2010 


/*HEART PROBLEMS*/

tab r10hearte, missing

capture drop heart_ever_2010
gen heart_ever_2010 = .
replace heart_ever_2010 = 0 if r10hearte == 0
replace heart_ever_2010 = 1 if r10hearte == 1

tab heart_ever_2010, missing
tab heart_ever_2010 


/*STROKE*/

tab r10stroke, missing

capture drop stroke_ever_2010
gen stroke_ever_2010 = .
replace stroke_ever_2010 = 0 if r10stroke == 0
replace stroke_ever_2010 = 1 if r10stroke == 1

tab stroke_ever_2010, missing
tab stroke_ever_2010 , missing
tab stroke_ever_2010 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2010
gen cardiometcond_2010 = .
replace cardiometcond_2010 = hbp_ever_2010 + diab_ever_2010 + heart_ever_2010 + stroke_ever_2010

tab cardiometcond_2010, missing
tab cardiometcond_2010 , missing
tab cardiometcond_2010 


capture drop cardiometcondbr_2010
gen cardiometcondbr_2010 = .
replace cardiometcondbr_2010 = 1 if cardiometcond_2010 ==0
replace cardiometcondbr_2010 = 2 if (cardiometcond_2010 == 1 | cardiometcond_2010 == 2)
replace cardiometcondbr_2010 = 3 if (cardiometcond_2010 == 3 | cardiometcond_2010 == 4)

tab cardiometcondbr_2010, missing
tab cardiometcondbr_2010 

**2010 CESD**
capture drop cesd_2010
gen cesd_2010=r10cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2010-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace


**********************************************2012***************************************************************


**INCOME VARIABLE (2012):

tab h11itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2012
gen totwealth_2012 = .
replace totwealth_2012 = 1 if h11itot < 25000
replace totwealth_2012 = 2 if h11itot >= 25000 & h11itot < 125000
replace totwealth_2012 = 3 if h11itot >= 125000 & h11itot < 300000
replace totwealth_2012 = 4 if h11itot >= 300000 & h11itot < 650000
replace totwealth_2012 = 5 if h11itot >= 650000 & h11itot ~= .


tab totwealth_2012 , missing
tab totwealth_2012 

save, replace

**MARITAL STATUS (2012)**

tab r11mstat, missing

capture drop marital_2012
gen marital_2012 = .
replace marital_2012 = 1 if r11mstat == 8 /*never married*/
replace marital_2012 = 2 if (r11mstat == 1 | r11mstat == 2 | r11mstat == 3) /*married / partnered*/
replace marital_2012 = 3 if (r11mstat == 4 | r11mstat == 5 | r11mstat == 6) /*separated / divorced*/
replace marital_2012 = 4 if (r11mstat == 7) /*widowed*/

tab marital_2012, missing
tab marital_2012

**EMPLOYMENT (2012):

tab r11work, missing

capture drop work_st_2012
gen work_st_2012 = .
replace work_st_2012 = 0 if r11work == 0
replace work_st_2012 = 1 if r11work == 1

tab work_st_2012, missing
tab work_st_2012


**CIGARETTE SMOKING (2012): 
tab r11smokev, missing
tab r11smoken, missing

capture drop smoking_2012
gen smoking_2012 = .
replace smoking_2012 = 1 if r11smokev == 0
replace smoking_2012 = 2 if r11smokev == 1 & r11smoken == 0
replace smoking_2012 = 3 if r11smokev == 1 & r11smoken == 1

tab smoking_2012, missing
tab smoking_2012 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2012* n=173 missing/


tab r11drink, missing
tab r11drinkd, missing


capture drop alcohol_2012
gen alcohol_2012 = .
replace alcohol_2012 = 1 if r11drink == 0
replace alcohol_2012 = 2 if r11drink == 1 & r11drinkd == 0
replace alcohol_2012 = 3 if r11drink == 1 & (r11drinkd == 1 | r11drinkd == 2)
replace alcohol_2012 = 4 if r11drink == 1 & (r11drinkd > 3 & r11drinkd ~= . & r11drinkd ~= .d & r11drinkd ~= .m & r11drinkd ~= .r)

tab alcohol_2012, missing


**PHYSICAL ACTIVITY (2012):
tab r11vgactx, missing
tab r11mdactx, missing

capture drop physic_act_2012
gen physic_act_2012 = .
replace physic_act_2012 = 1 if (r11vgactx ==  5 & r11mdactx == 5)
replace physic_act_2012 = 2 if (r11vgactx ==  3 | r11mdactx == 3 | r11vgactx ==  4 | r11mdactx == 4)
replace physic_act_2012 = 3 if (r11vgactx ==  1 | r11mdactx == 1 | r11vgactx ==  2 | r11mdactx == 2)

tab physic_act_2012, missing
tab physic_act_2012


**SELF-RATED HEALTH (2012):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r11shlt, missing

capture drop srh_2012
gen srh_2012 = .
replace srh_2012 = 1 if (r11shlt == 1 | r11shlt == 2 | r11shlt == 3)
replace srh_2012 = 2 if (r11shlt == 4 | r11shlt == 5)

tab srh_2012, missing
tab srh_2012 

save, replace


**WEIGTH STATUS, 2012**
/*body mass index*/

/*2012*/

*<25 
**  25-29.9
**  ≥30


tab r11pmbmi, missing
tab r11bmi, missing
tab r11bmi , missing
tab r11bmi 
su r11bmi ,det


capture drop bmi_2012
gen bmi_2012 = r11pmbmi if r11pmbmi < 100
else replace bmi_2012 = r11bmi if r11bmi < 100

tab bmi_2012, missing
tab bmi_2012 , missing
tab bmi_2012 
su bmi_2012 , det



capture drop bmibr_2012
gen bmibr_2012 = 1 if bmi_2012 < 25
replace bmibr_2012 = 2 if bmi_2012 >= 25 & bmi_2012 < 30
replace bmibr_2012 = 3 if bmi_2012 >= 30 & bmi_2012 ~= .

tab bmibr_2012, missing


/*cardiometabolic risk factors and chronic conditions, 2012*/

/*HYPERTENSION*/

tab r11hibpe, missing

capture drop hbp_ever_2012
gen hbp_ever_2012 = .
replace hbp_ever_2012 = 0 if r11hibpe == 0
replace hbp_ever_2012 = 1 if r11hibpe == 1

tab hbp_ever_2012, missing
tab hbp_ever_2012 


/*DIABETES*/

tab r11diabe, missing

capture drop diab_ever_2012
gen diab_ever_2012 = .
replace diab_ever_2012 = 0 if r11diabe == 0
replace diab_ever_2012 = 1 if r11diabe == 1

tab diab_ever_2012, missing
tab diab_ever_2012 


/*HEART PROBLEMS*/

tab r11hearte, missing

capture drop heart_ever_2012
gen heart_ever_2012 = .
replace heart_ever_2012 = 0 if r11hearte == 0
replace heart_ever_2012 = 1 if r11hearte == 1

tab heart_ever_2012, missing
tab heart_ever_2012 


/*STROKE*/

tab r11stroke, missing

capture drop stroke_ever_2012
gen stroke_ever_2012 = .
replace stroke_ever_2012 = 0 if r11stroke == 0
replace stroke_ever_2012 = 1 if r11stroke == 1

tab stroke_ever_2012, missing
tab stroke_ever_2012 , missing
tab stroke_ever_2012 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2012
gen cardiometcond_2012 = .
replace cardiometcond_2012 = hbp_ever_2012 + diab_ever_2012 + heart_ever_2012 + stroke_ever_2012

tab cardiometcond_2012, missing
tab cardiometcond_2012 , missing
tab cardiometcond_2012 


capture drop cardiometcondbr_2012
gen cardiometcondbr_2012 = .
replace cardiometcondbr_2012 = 1 if cardiometcond_2012 ==0
replace cardiometcondbr_2012 = 2 if (cardiometcond_2012 == 1 | cardiometcond_2012 == 2)
replace cardiometcondbr_2012 = 3 if (cardiometcond_2012 == 3 | cardiometcond_2012 == 4)

tab cardiometcondbr_2012, missing
tab cardiometcondbr_2012 

**2012 CESD**
capture drop cesd_2012
gen cesd_2012=r11cesd


save, replace




**********************************************2014***************************************************************


**INCOME VARIABLE (2014):

tab h12itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2014
gen totwealth_2014 = .
replace totwealth_2014 = 1 if h12itot < 25000
replace totwealth_2014 = 2 if h12itot >= 25000 & h12itot < 125000
replace totwealth_2014 = 3 if h12itot >= 125000 & h12itot < 300000
replace totwealth_2014 = 4 if h12itot >= 300000 & h12itot < 650000
replace totwealth_2014 = 5 if h12itot >= 650000 & h12itot ~= .


tab totwealth_2014 , missing
tab totwealth_2014 

save, replace

**MARITAL STATUS (2014)**

tab r12mstat, missing

capture drop marital_2014
gen marital_2014 = .
replace marital_2014 = 1 if r12mstat == 8 /*never married*/
replace marital_2014 = 2 if (r12mstat == 1 | r12mstat == 2 | r12mstat == 3) /*married / partnered*/
replace marital_2014 = 3 if (r12mstat == 4 | r12mstat == 5 | r12mstat == 6) /*separated / divorced*/
replace marital_2014 = 4 if (r12mstat == 7) /*widowed*/

tab marital_2014, missing
tab marital_2014

**EMPLOYMENT (2014):

tab r12work, missing

capture drop work_st_2014
gen work_st_2014 = .
replace work_st_2014 = 0 if r12work == 0
replace work_st_2014 = 1 if r12work == 1

tab work_st_2014, missing
tab work_st_2014


**CIGARETTE SMOKING (2014): 
tab r12smokev, missing
tab r12smoken, missing

capture drop smoking_2014
gen smoking_2014 = .
replace smoking_2014 = 1 if r12smokev == 0
replace smoking_2014 = 2 if r12smokev == 1 & r12smoken == 0
replace smoking_2014 = 3 if r12smokev == 1 & r12smoken == 1

tab smoking_2014, missing
tab smoking_2014 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2014* n=173 missing/


tab r12drink, missing
tab r12drinkd, missing


capture drop alcohol_2014
gen alcohol_2014 = .
replace alcohol_2014 = 1 if r12drink == 0
replace alcohol_2014 = 2 if r12drink == 1 & r12drinkd == 0
replace alcohol_2014 = 3 if r12drink == 1 & (r12drinkd == 1 | r12drinkd == 2)
replace alcohol_2014 = 4 if r12drink == 1 & (r12drinkd > 3 & r12drinkd ~= . & r12drinkd ~= .d & r12drinkd ~= .m & r12drinkd ~= .r)

tab alcohol_2014, missing


**PHYSICAL ACTIVITY (2014):
tab r12vgactx, missing
tab r12mdactx, missing

capture drop physic_act_2014
gen physic_act_2014 = .
replace physic_act_2014 = 1 if (r12vgactx ==  5 & r12mdactx == 5)
replace physic_act_2014 = 2 if (r12vgactx ==  3 | r12mdactx == 3 | r12vgactx ==  4 | r12mdactx == 4)
replace physic_act_2014 = 3 if (r12vgactx ==  1 | r12mdactx == 1 | r12vgactx ==  2 | r12mdactx == 2)

tab physic_act_2014, missing
tab physic_act_2014


**SELF-RATED HEALTH (2014):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r12shlt, missing

capture drop srh_2014
gen srh_2014 = .
replace srh_2014 = 1 if (r12shlt == 1 | r12shlt == 2 | r12shlt == 3)
replace srh_2014 = 2 if (r12shlt == 4 | r12shlt == 5)

tab srh_2014, missing
tab srh_2014 

save, replace


**WEIGTH STATUS, 2014**
/*body mass index*/

/*2014*/

*<25 
**  25-29.9
**  ≥30


tab r12pmbmi, missing
tab r12bmi, missing
tab r12bmi , missing
tab r12bmi 
su r12bmi ,det


capture drop bmi_2014
gen bmi_2014 = r12pmbmi if r12pmbmi < 100
else replace bmi_2014 = r12bmi if r12bmi < 100

tab bmi_2014, missing
tab bmi_2014 , missing
tab bmi_2014 
su bmi_2014 , det



capture drop bmibr_2014
gen bmibr_2014 = 1 if bmi_2014 < 25
replace bmibr_2014 = 2 if bmi_2014 >= 25 & bmi_2014 < 30
replace bmibr_2014 = 3 if bmi_2014 >= 30 & bmi_2014 ~= .

tab bmibr_2014, missing


/*cardiometabolic risk factors and chronic conditions, 2014*/

/*HYPERTENSION*/

tab r12hibpe, missing

capture drop hbp_ever_2014
gen hbp_ever_2014 = .
replace hbp_ever_2014 = 0 if r12hibpe == 0
replace hbp_ever_2014 = 1 if r12hibpe == 1

tab hbp_ever_2014, missing
tab hbp_ever_2014 


/*DIABETES*/

tab r12diabe, missing

capture drop diab_ever_2014
gen diab_ever_2014 = .
replace diab_ever_2014 = 0 if r12diabe == 0
replace diab_ever_2014 = 1 if r12diabe == 1

tab diab_ever_2014, missing
tab diab_ever_2014 


/*HEART PROBLEMS*/

tab r12hearte, missing

capture drop heart_ever_2014
gen heart_ever_2014 = .
replace heart_ever_2014 = 0 if r12hearte == 0
replace heart_ever_2014 = 1 if r12hearte == 1

tab heart_ever_2014, missing
tab heart_ever_2014 


/*STROKE*/

tab r12stroke, missing

capture drop stroke_ever_2014
gen stroke_ever_2014 = .
replace stroke_ever_2014 = 0 if r12stroke == 0
replace stroke_ever_2014 = 1 if r12stroke == 1

tab stroke_ever_2014, missing
tab stroke_ever_2014 , missing
tab stroke_ever_2014 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2014
gen cardiometcond_2014 = .
replace cardiometcond_2014 = hbp_ever_2014 + diab_ever_2014 + heart_ever_2014 + stroke_ever_2014

tab cardiometcond_2014, missing
tab cardiometcond_2014 , missing
tab cardiometcond_2014 


capture drop cardiometcondbr_2014
gen cardiometcondbr_2014 = .
replace cardiometcondbr_2014 = 1 if cardiometcond_2014 ==0
replace cardiometcondbr_2014 = 2 if (cardiometcond_2014 == 1 | cardiometcond_2014 == 2)
replace cardiometcondbr_2014 = 3 if (cardiometcond_2014 == 3 | cardiometcond_2014 == 4)

tab cardiometcondbr_2014, missing
tab cardiometcondbr_2014 

**2014 CESD**
capture drop cesd_2014
gen cesd_2014=r12cesd


save, replace


**INW VARIABLES FROM TRACKER FILE (2014-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace


**************************************************2016************************************************************


**INCOME VARIABLE (2016):

tab h13itot, missing

 /*< 25,000*/ 
/*25,000–124,999*/ 
/*125,000–299,999*/ 
/*300,000–649,999*/ 
/*≥ 650,000*/


capture drop totwealth_2016
gen totwealth_2016 = .
replace totwealth_2016 = 1 if h13itot < 25000
replace totwealth_2016 = 2 if h13itot >= 25000 & h13itot < 125000
replace totwealth_2016 = 3 if h13itot >= 125000 & h13itot < 300000
replace totwealth_2016 = 4 if h13itot >= 300000 & h13itot < 650000
replace totwealth_2016 = 5 if h13itot >= 650000 & h13itot ~= .


tab totwealth_2016 , missing
tab totwealth_2016 

save, replace

**MARITAL STATUS (2016)**

tab r13mstat, missing

capture drop marital_2016
gen marital_2016 = .
replace marital_2016 = 1 if r13mstat == 8 /*never married*/
replace marital_2016 = 2 if (r13mstat == 1 | r13mstat == 2 | r13mstat == 3) /*married / partnered*/
replace marital_2016 = 3 if (r13mstat == 4 | r13mstat == 5 | r13mstat == 6) /*separated / divorced*/
replace marital_2016 = 4 if (r13mstat == 7) /*widowed*/

tab marital_2016, missing
tab marital_2016

**EMPLOYMENT (2016):

tab r13work, missing

capture drop work_st_2016
gen work_st_2016 = .
replace work_st_2016 = 0 if r13work == 0
replace work_st_2016 = 1 if r13work == 1

tab work_st_2016, missing
tab work_st_2016


**CIGARETTE SMOKING (2016): 
tab r13smokev, missing
tab r13smoken, missing

capture drop smoking_2016
gen smoking_2016 = .
replace smoking_2016 = 1 if r13smokev == 0
replace smoking_2016 = 2 if r13smokev == 1 & r13smoken == 0
replace smoking_2016 = 3 if r13smokev == 1 & r13smoken == 1

tab smoking_2016, missing
tab smoking_2016 

save, replace

*Alcohol driking:(abstinent, 1-3 days per month, 1-2 days per week, ≥3 days per week) *2016* n=173 missing/


tab r13drink, missing
tab r13drinkd, missing


capture drop alcohol_2016
gen alcohol_2016 = .
replace alcohol_2016 = 1 if r13drink == 0
replace alcohol_2016 = 2 if r13drink == 1 & r13drinkd == 0
replace alcohol_2016 = 3 if r13drink == 1 & (r13drinkd == 1 | r13drinkd == 2)
replace alcohol_2016 = 4 if r13drink == 1 & (r13drinkd > 3 & r13drinkd ~= . & r13drinkd ~= .d & r13drinkd ~= .m & r13drinkd ~= .r)

tab alcohol_2016, missing


**PHYSICAL ACTIVITY (2016):
tab r13vgactx, missing
tab r13mdactx, missing

capture drop physic_act_2016
gen physic_act_2016 = .
replace physic_act_2016 = 1 if (r13vgactx ==  5 & r13mdactx == 5)
replace physic_act_2016 = 2 if (r13vgactx ==  3 | r13mdactx == 3 | r13vgactx ==  4 | r13mdactx == 4)
replace physic_act_2016 = 3 if (r13vgactx ==  1 | r13mdactx == 1 | r13vgactx ==  2 | r13mdactx == 2)

tab physic_act_2016, missing
tab physic_act_2016


**SELF-RATED HEALTH (2016):


/*   Excellent/very good/good
    Fair/poor 
*/


tab r13shlt, missing

capture drop srh_2016
gen srh_2016 = .
replace srh_2016 = 1 if (r13shlt == 1 | r13shlt == 2 | r13shlt == 3)
replace srh_2016 = 2 if (r13shlt == 4 | r13shlt == 5)

tab srh_2016, missing
tab srh_2016 

save, replace


**WEIGTH STATUS, 2016**
/*body mass index*/

/*2016*/

*<25 
**  25-29.9
**  ≥30


tab r13pmbmi, missing
tab r13bmi, missing
tab r13bmi , missing
tab r13bmi 
su r13bmi ,det


capture drop bmi_2016
gen bmi_2016 = r13pmbmi if r13pmbmi < 100
else replace bmi_2016 = r13bmi if r13bmi < 100

tab bmi_2016, missing
tab bmi_2016 , missing
tab bmi_2016 
su bmi_2016 , det



capture drop bmibr_2016
gen bmibr_2016 = 1 if bmi_2016 < 25
replace bmibr_2016 = 2 if bmi_2016 >= 25 & bmi_2016 < 30
replace bmibr_2016 = 3 if bmi_2016 >= 30 & bmi_2016 ~= .

tab bmibr_2016, missing


/*cardiometabolic risk factors and chronic conditions, 2016*/

/*HYPERTENSION*/

tab r13hibpe, missing

capture drop hbp_ever_2016
gen hbp_ever_2016 = .
replace hbp_ever_2016 = 0 if r13hibpe == 0
replace hbp_ever_2016 = 1 if r13hibpe == 1

tab hbp_ever_2016, missing
tab hbp_ever_2016 


/*DIABETES*/

tab r13diabe, missing

capture drop diab_ever_2016
gen diab_ever_2016 = .
replace diab_ever_2016 = 0 if r13diabe == 0
replace diab_ever_2016 = 1 if r13diabe == 1

tab diab_ever_2016, missing
tab diab_ever_2016 


/*HEART PROBLEMS*/

tab r13hearte, missing

capture drop heart_ever_2016
gen heart_ever_2016 = .
replace heart_ever_2016 = 0 if r13hearte == 0
replace heart_ever_2016 = 1 if r13hearte == 1

tab heart_ever_2016, missing
tab heart_ever_2016 


/*STROKE*/

tab r13stroke, missing

capture drop stroke_ever_2016
gen stroke_ever_2016 = .
replace stroke_ever_2016 = 0 if r13stroke == 0
replace stroke_ever_2016 = 1 if r13stroke == 1

tab stroke_ever_2016, missing
tab stroke_ever_2016 , missing
tab stroke_ever_2016 


/*NUMBER OF CONDITIONS*/
**  0
**    1-2
**    ≥ 3


capture drop cardiometcond_2016
gen cardiometcond_2016 = .
replace cardiometcond_2016 = hbp_ever_2016 + diab_ever_2016 + heart_ever_2016 + stroke_ever_2016

tab cardiometcond_2016, missing
tab cardiometcond_2016 , missing
tab cardiometcond_2016 


capture drop cardiometcondbr_2016
gen cardiometcondbr_2016 = .
replace cardiometcondbr_2016 = 1 if cardiometcond_2016 ==0
replace cardiometcondbr_2016 = 2 if (cardiometcond_2016 == 1 | cardiometcond_2016 == 2)
replace cardiometcondbr_2016 = 3 if (cardiometcond_2016 == 3 | cardiometcond_2016 == 4)

tab cardiometcondbr_2016, missing
tab cardiometcondbr_2016 

**2016 CESD**
capture drop cesd_2016
gen cesd_2016=r13cesd


save, replace

**************************************************2018************************************************************

**INCOME / WEALTH VARIABLE (2018):

tab h14itot, missing

capture drop totwealth_2018
gen totwealth_2018 = .
replace totwealth_2018 = 1 if h14itot < 25000
replace totwealth_2018 = 2 if h14itot >= 25000 & h14itot < 125000
replace totwealth_2018 = 3 if h14itot >= 125000 & h14itot < 300000
replace totwealth_2018 = 4 if h14itot >= 300000 & h14itot < 650000
replace totwealth_2018 = 5 if h14itot >= 650000 & h14itot ~= .

tab totwealth_2018, missing
tab totwealth_2018

save, replace


**MARITAL STATUS (2018)**

tab r14mstat, missing

capture drop marital_2018
gen marital_2018 = .
replace marital_2018 = 1 if r14mstat == 8
replace marital_2018 = 2 if inlist(r14mstat, 1, 2, 3)
replace marital_2018 = 3 if inlist(r14mstat, 4, 5, 6)
replace marital_2018 = 4 if r14mstat == 7

tab marital_2018, missing
tab marital_2018


**EMPLOYMENT (2018)**

tab r14work, missing

capture drop work_st_2018
gen work_st_2018 = .
replace work_st_2018 = 0 if r14work == 0
replace work_st_2018 = 1 if r14work == 1

tab work_st_2018, missing
tab work_st_2018


**CIGARETTE SMOKING (2018)**

tab r14smokev, missing
tab r14smoken, missing

capture drop smoking_2018
gen smoking_2018 = .
replace smoking_2018 = 1 if r14smokev == 0
replace smoking_2018 = 2 if r14smokev == 1 & r14smoken == 0
replace smoking_2018 = 3 if r14smokev == 1 & r14smoken == 1

tab smoking_2018, missing
tab smoking_2018

save, replace


**ALCOHOL DRINKING (2018)**

tab r14drink, missing
tab r14drinkd, missing

capture drop alcohol_2018
gen alcohol_2018 = .
replace alcohol_2018 = 1 if r14drink == 0
replace alcohol_2018 = 2 if r14drink == 1 & r14drinkd == 0
replace alcohol_2018 = 3 if r14drink == 1 & inlist(r14drinkd, 1, 2)
replace alcohol_2018 = 4 if r14drink == 1 & r14drinkd > 3 & r14drinkd ~= .

tab alcohol_2018, missing
tab alcohol_2018


**PHYSICAL ACTIVITY (2018)**

tab r14vgactx, missing
tab r14mdactx, missing

capture drop physic_act_2018
gen physic_act_2018 = .
replace physic_act_2018 = 1 if r14vgactx == 5 & r14mdactx == 5
replace physic_act_2018 = 2 if inlist(r14vgactx, 3, 4) | inlist(r14mdactx, 3, 4)
replace physic_act_2018 = 3 if inlist(r14vgactx, 1, 2) | inlist(r14mdactx, 1, 2)

tab physic_act_2018, missing
tab physic_act_2018


**SELF-RATED HEALTH (2018)**

tab r14shlt, missing

capture drop srh_2018
gen srh_2018 = .
replace srh_2018 = 1 if inlist(r14shlt, 1, 2, 3)
replace srh_2018 = 2 if inlist(r14shlt, 4, 5)

tab srh_2018, missing
tab srh_2018

save, replace


**WEIGHT STATUS / BMI (2018)**

tab r14pmbmi, missing
tab r14bmi, missing
su r14bmi, detail

capture drop bmi_2018
gen bmi_2018 = .
replace bmi_2018 = r14pmbmi if r14pmbmi < 100
replace bmi_2018 = r14bmi if missing(bmi_2018) & r14bmi < 100

tab bmi_2018, missing
su bmi_2018, detail

capture drop bmibr_2018
gen bmibr_2018 = .
replace bmibr_2018 = 1 if bmi_2018 < 25
replace bmibr_2018 = 2 if bmi_2018 >= 25 & bmi_2018 < 30
replace bmibr_2018 = 3 if bmi_2018 >= 30 & bmi_2018 ~= .

tab bmibr_2018, missing


**CARDIOMETABOLIC RISK FACTORS AND CHRONIC CONDITIONS, 2018**

/* HYPERTENSION */

tab r14hibpe, missing

capture drop hbp_ever_2018
gen hbp_ever_2018 = .
replace hbp_ever_2018 = 0 if r14hibpe == 0
replace hbp_ever_2018 = 1 if r14hibpe == 1

tab hbp_ever_2018, missing
tab hbp_ever_2018


/* DIABETES */

tab r14diabe, missing

capture drop diab_ever_2018
gen diab_ever_2018 = .
replace diab_ever_2018 = 0 if r14diabe == 0
replace diab_ever_2018 = 1 if r14diabe == 1

tab diab_ever_2018, missing
tab diab_ever_2018


/* HEART PROBLEMS */

tab r14hearte, missing

capture drop heart_ever_2018
gen heart_ever_2018 = .
replace heart_ever_2018 = 0 if r14hearte == 0
replace heart_ever_2018 = 1 if r14hearte == 1

tab heart_ever_2018, missing
tab heart_ever_2018


/* STROKE */

tab r14stroke, missing

capture drop stroke_ever_2018
gen stroke_ever_2018 = .
replace stroke_ever_2018 = 0 if r14stroke == 0
replace stroke_ever_2018 = 1 if r14stroke == 1

tab stroke_ever_2018, missing
tab stroke_ever_2018


/* NUMBER OF CONDITIONS */

capture drop cardiometcond_2018
gen cardiometcond_2018 = hbp_ever_2018 + diab_ever_2018 + heart_ever_2018 + stroke_ever_2018

tab cardiometcond_2018, missing
tab cardiometcond_2018


capture drop cardiometcondbr_2018
gen cardiometcondbr_2018 = .
replace cardiometcondbr_2018 = 1 if cardiometcond_2018 == 0
replace cardiometcondbr_2018 = 2 if inlist(cardiometcond_2018, 1, 2)
replace cardiometcondbr_2018 = 3 if inlist(cardiometcond_2018, 3, 4)

tab cardiometcondbr_2018, missing
tab cardiometcondbr_2018


**2018 CESD**

capture drop cesd_2018
gen cesd_2018 = r14cesd

tab cesd_2018, missing
su cesd_2018, detail


save, replace


*****CONTINUE FROM HERE****

**************************************************2020************************************************************

**INCOME / WEALTH VARIABLE (2020):

tab h15itot, missing

capture drop totwealth_2020
gen totwealth_2020 = .
replace totwealth_2020 = 1 if h15itot < 25000
replace totwealth_2020 = 2 if h15itot >= 25000 & h15itot < 125000
replace totwealth_2020 = 3 if h15itot >= 125000 & h15itot < 300000
replace totwealth_2020 = 4 if h15itot >= 300000 & h15itot < 650000
replace totwealth_2020 = 5 if h15itot >= 650000 & h15itot ~= .

tab totwealth_2020, missing
tab totwealth_2020

save, replace


**MARITAL STATUS (2020)**

tab r15mstat, missing

capture drop marital_2020
gen marital_2020 = .
replace marital_2020 = 1 if r15mstat == 8
replace marital_2020 = 2 if inlist(r15mstat, 1, 2, 3)
replace marital_2020 = 3 if inlist(r15mstat, 4, 5, 6)
replace marital_2020 = 4 if r15mstat == 7

tab marital_2020, missing
tab marital_2020


**EMPLOYMENT (2020)**

tab r15work, missing

capture drop work_st_2020
gen work_st_2020 = .
replace work_st_2020 = 0 if r15work == 0
replace work_st_2020 = 1 if r15work == 1

tab work_st_2020, missing
tab work_st_2020


**CIGARETTE SMOKING (2020)**

tab r15smokev, missing
tab r15smoken, missing

capture drop smoking_2020
gen smoking_2020 = .
replace smoking_2020 = 1 if r15smokev == 0
replace smoking_2020 = 2 if r15smokev == 1 & r15smoken == 0
replace smoking_2020 = 3 if r15smokev == 1 & r15smoken == 1

tab smoking_2020, missing
tab smoking_2020

save, replace


**ALCOHOL DRINKING (2020)**

tab r15drink, missing
tab r15drinkd, missing

capture drop alcohol_2020
gen alcohol_2020 = .
replace alcohol_2020 = 1 if r15drink == 0
replace alcohol_2020 = 2 if r15drink == 1 & r15drinkd == 0
replace alcohol_2020 = 3 if r15drink == 1 & inlist(r15drinkd, 1, 2)
replace alcohol_2020 = 4 if r15drink == 1 & r15drinkd > 3 & r15drinkd ~= .

tab alcohol_2020, missing
tab alcohol_2020


**PHYSICAL ACTIVITY (2020)**

tab r15vgactx, missing
tab r15mdactx, missing

capture drop physic_act_2020
gen physic_act_2020 = .
replace physic_act_2020 = 1 if r15vgactx == 5 & r15mdactx == 5
replace physic_act_2020 = 2 if inlist(r15vgactx, 3, 4) | inlist(r15mdactx, 3, 4)
replace physic_act_2020 = 3 if inlist(r15vgactx, 1, 2) | inlist(r15mdactx, 1, 2)

tab physic_act_2020, missing
tab physic_act_2020


**SELF-RATED HEALTH (2020)**

tab r15shlt, missing

capture drop srh_2020
gen srh_2020 = .
replace srh_2020 = 1 if inlist(r15shlt, 1, 2, 3)
replace srh_2020 = 2 if inlist(r15shlt, 4, 5)

tab srh_2020, missing
tab srh_2020

save, replace


**WEIGHT STATUS / BMI (2020)**

tab r15bmi, missing
su r15bmi, detail

capture drop bmi_2020
gen bmi_2020 = .
replace bmi_2020 = r15bmi if r15bmi < 100
replace bmi_2020 = r15bmi if missing(bmi_2020) & r15bmi < 100

tab bmi_2020, missing
su bmi_2020, detail

capture drop bmibr_2020
gen bmibr_2020 = .
replace bmibr_2020 = 1 if bmi_2020 < 25
replace bmibr_2020 = 2 if bmi_2020 >= 25 & bmi_2020 < 30
replace bmibr_2020 = 3 if bmi_2020 >= 30 & bmi_2020 ~= .

tab bmibr_2020, missing


**CARDIOMETABOLIC RISK FACTORS AND CHRONIC CONDITIONS, 2020**

/* HYPERTENSION */

tab r15hibpe, missing

capture drop hbp_ever_2020
gen hbp_ever_2020 = .
replace hbp_ever_2020 = 0 if r15hibpe == 0
replace hbp_ever_2020 = 1 if r15hibpe == 1

tab hbp_ever_2020, missing
tab hbp_ever_2020


/* DIABETES */

tab r15diabe, missing

capture drop diab_ever_2020
gen diab_ever_2020 = .
replace diab_ever_2020 = 0 if r15diabe == 0
replace diab_ever_2020 = 1 if r15diabe == 1

tab diab_ever_2020, missing
tab diab_ever_2020


/* HEART PROBLEMS */

tab r15hearte, missing

capture drop heart_ever_2020
gen heart_ever_2020 = .
replace heart_ever_2020 = 0 if r15hearte == 0
replace heart_ever_2020 = 1 if r15hearte == 1

tab heart_ever_2020, missing
tab heart_ever_2020


/* STROKE */

tab r15stroke, missing

capture drop stroke_ever_2020
gen stroke_ever_2020 = .
replace stroke_ever_2020 = 0 if r15stroke == 0
replace stroke_ever_2020 = 1 if r15stroke == 1

tab stroke_ever_2020, missing
tab stroke_ever_2020


/* NUMBER OF CONDITIONS */

capture drop cardiometcond_2020
gen cardiometcond_2020 = hbp_ever_2020 + diab_ever_2020 + heart_ever_2020 + stroke_ever_2020

tab cardiometcond_2020, missing
tab cardiometcond_2020


capture drop cardiometcondbr_2020
gen cardiometcondbr_2020 = .
replace cardiometcondbr_2020 = 1 if cardiometcond_2020 == 0
replace cardiometcondbr_2020 = 2 if inlist(cardiometcond_2020, 1, 2)
replace cardiometcondbr_2020 = 3 if inlist(cardiometcond_2020, 3, 4)

tab cardiometcondbr_2020, missing
tab cardiometcondbr_2020


**2020 CESD**

capture drop cesd_2020
gen cesd_2020 = r15cesd

tab cesd_2020, missing
su cesd_2020, detail


save, replace

**INW VARIABLES FROM TRACKER FILE (2016-2018):

tab1 inw*

save, replace

**PSU, STRATUM AND WEIGHT VARIABLES (NOT NEEDED FOR THIS ANALYSIS):
tab1 secu stratum 

save,replace

*******************************************STEP 5: MERGE WITH TELOMERE LENGTH DATA**************************************************************

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\randhrs1992_2020v2_resp_tracker",clear

sort HHIDPN
capture drop _merge

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\randhrs1992_2020v2_resp_tracker",replace


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\TELOMERESA_R",clear
 
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

save, replace

merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\randhrs1992_2020v2_resp_tracker"

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_TLHEIFRAILEPIGENMORT.dta", replace 


******************************************


capture log close

capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\HEI2015.txt",text replace

************************************************HEI 2015********************

**STEP A: RUN STATA SCRIPTS FOR LEGUMES:

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HCNS13_R_NT",clear
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", replace


**STEP A: RUN STATA SCRIPTS FOR LEGUMES:

capture drop m_mpf m_egg m_nutsd m_soy m_fish_hi m_fish_lo legumes kcal v_total v_drkgr 
  
gen m_mpf=C6D_FF_13+C6E_FF_13+C6F_FF_13+C6G_FF_13+C6H_FF_13+C6I_FF_13+C6J_FF_13+C6K_FF_13+C6L_FF_13+C6M_FF_13+C6N_FF_13+C6O_FF_13+C6P_FF_13+C6R_FF_13+C6S_FF_13+C6T_FF_13+C6U_FF_13+C6V_FF_13+C6W_FF_13+C6Q_FF_13
gen m_egg=C6A_FF_13+C6B_FF_13+C6C_FF_13
gen m_nutsd=C9V_FF_13+C9W_FF_13+C9X_FF_13+C9F_FF_13 
gen m_soy=C5E_FF_13+C3D_FF_13
gen m_fish_hi=C6V_FF_13+C6S_FF_13
gen m_fish_lo=C6T_FF_13+C6U_FF_13+C6W_FF_13
gen legumes=C5N_FF_13+C5P_FF_13 
gen kcal=CALOR_SUM
gen v_total = C5A_FF_13+C5B_FF_13+C5C_FF_13+C5D_FF_13+ C5F_FF_13+C5G_FF_13+C5H_FF_13+C5I_FF_13+C5J_FF_13+C5K_FF_13+C5L_FF_13+C5M_FF_13+C5N_FF_13+C5O_FF_13+C5P_FF_13+C5Q_FF_13+C5R_FF_13+ C5S_FF_13+C5T_FF_13+C5U_FF_13+C5V_FF_13+C5W_FF_13+C5X_FF_13+C5Y_FF_13+C5Z_FF_13+C5AA_FF_13+C5AB_FF_13 
gen v_drkgr=C5T_FF_13+C5U_FF_13+C5V_FF_13
 



**pf_mps_total: m_mpf
**pf_eggs: m_egg 
**pf_nutsds: m_nutsd
*pf_soy: m_soy

/* This program calculates legumes that get counted as meat and those that get
counted as veggies*/
/** This macro gets called into the program that calculates HEI 2015 scores**/

capture drop allmeat 
capture drop seaplant
capture drop mbmax
capture drop meatleg
capture drop legume_added_*
capture drop meatveg
capture drop extrmeat
capture drop extrleg


gen allmeat=m_mpf+m_egg+m_nutsd+m_soy
gen seaplant=m_fish_hi+m_fish_lo+m_nutsd + m_soy
gen mbmax=2.5*(kcal/1000)
gen needmeat=mbmax-allmeat if allmeat<mbmax
gen meatleg=4*legumes
/*Needs more meat, and all beans go to meat*/
gen all2meat=1 if meatleg<=needmeat /*folks who don't meet meat max and the amount
of legumes they consume is less than the amount they need to reach mbmax*/
foreach var in allmeat seaplant {
gen legume_added_`var'=`var'+meatleg if all2meat==1
}
foreach var in v_total v_drkgr {
gen legume_added_`var'=`var' if all2meat==1
}
/*Needs more meat, and some beans go to meat, some go to veggies*/
gen meatveg=1 if meatleg>needmeat
gen extrmeat=meatleg-needmeat
gen extrleg=extrmeat/4
foreach var in allmeat seaplant {
replace legume_added_`var'=`var'+needmeat if meatveg==1 /*folks who don't meet
meat max and the amount of legumes they consume is more than the amount they need
to reach mbmax--rest go to veggies*/
}
foreach var in v_total v_drkgr {
replace legume_added_`var'=`var'+extrleg if meatveg==1
}
gen all2veg=1 if allmeat>=mbmax /*Folks who meet the meat requirement so all
legumes count as veggies*/
foreach var in allmeat seaplant {
replace legume_added_`var'=`var' if all2veg==1
}
foreach var in v_total v_drkgr {
replace legume_added_`var'=`var'+legumes if all2veg==1
}

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", replace


**STEP B: RUN STATA SCRIPT FOR HEI-2015


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", clear

capture drop monofat 
capture drop polyfat 
capture drop add_sug 
capture drop discfat_sol 
capture drop alcohol 
capture drop f_total 
capture drop frtjuice 
capture drop wholefrt 
capture drop g_whl 
capture drop d_total 
capture drop Satfat 
capture drop sodi 
capture drop g_nwhl 
capture drop sfat 

gen monofat=MONFAT_SUM
gen polyfat=POLY_SUM
gen add_sug=C9AH_FF_13 
gen discfat_sol=ADDFAT_SOL_SUM
gen alcohol=ALCO_SUM
gen f_total= C4A_FF_13+C4B_FF_13+C4C_FF_13+C4D_FF_13+C4E_FF_13+C4F_FF_13+C4G_FF_13+C4H_FF_13+C4I_FF_13+C4J_FF_13+C4K_FF_13+C4L_FF_13+C4M_FF_13+C4N_FF_13+C4O_FF_13+C4P_FF_13+C4Q_FF_13+C4R_FF_13+ C4S_FF_13+C4C_FF_13 
gen frtjuice=C4I_FF_13+C4K_FF_13+C4L_FF_13+C4N_FF_13+C4O_FF_13
gen wholefrt=f_total-frtjuice
gen g_whl=C7B_FF_13+C7F_FF_13+C7G_FF_13+C7J_FF_13+C7SA_FF_13+C9AB_FF_13+C9AC_FF_13+C9AD_FF_13+C9G_FF_13+C9H_FF_13 
gen d_total= C3A_FF_13+C3B_FF_13+C3C_FF_13 + C3E_FF_13+C3G_FF_13+C3H_FF_13+C3I_FF_13+C3J_FF_13+C3L_FF_13+ C3M_FF_13+C3N_FF_13+C3D_FF_13 
gen Satfat=SATFAT_SUM 
gen sodi=SODIUM_SUM
gen g_nwhl=C7A_FF_13+C7C_FF_13+C7E_FF_13+C7H_FF_13+C7I_FF_13+C7K_FF_13+C7L_FF_13+C7M_FF_13+C7N_FF_13+C7O_FF_13+C7SB_FF_13+C7T_FF_13+C9J_FF_13+C9K_FF_13+C9L_FF_13+C9M_FF_13+C9N_FF_13+C9O_FF_13+C9P_FF_13+C9Q_FF_13+C9R_FF_13+C9S_FF_13+C9T_FF_13+C9U_FF_13+C9Y_FF_13+C9Z_FF_13+C9AA_FF_13
gen sfat=SATFAT_SUM 
gen SatFat=SATFAT_SUM

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", replace

capture drop monopoly
capture drop addsugc
capture drop solfatc
capture drop maxalcgr
capture drop ethcal
capture drop exalccal
capture drop emptycal10
capture drop vegden
capture drop hei*
capture drop grbnden
capture drop frtden
capture drop wholefrt
capture drop whfrden
capture drop wgrnden
capture drop monopoly
capture drop farmin
capture drop farmax
capture drop sodden
capture drop sodmin
capture drop sodmax
capture drop rgden
capture drop rgmin
capture drop rgmax
capture drop sofa*
capture drop addedsugar_perc 
capture drop addsugmin 
capture dorp addsugmax 
capture drop heix12_addedsugar
capture drop saturatedfat_perc 
capture drop saturatedfatmin 
capture drop saturatedfatmax 
capture drop heix13_saturatedfat



/*This do file creates HEI-2015 component densities and scores*/
gen monopoly=monofat+polyfat
gen addsugc=16*add_sug
gen solfatc=9*discfat_sol
gen maxalcgr=13*(kcal/1000)
gen ethcal=7*alcohol
gen exalccal=7*(alcohol-maxalcgr)
replace exalccal=0 if alcohol<=maxalcgr
gen emptycal10=addsugc+solfatc+exalccal
gen vegden=legume_added_v_total/(kcal/1000)
gen heix1_totalveg=5*(vegden/1.1)
replace heix1_totalveg=5 if heix1_totalveg>5
replace heix1_totalveg=0 if heix1_totalveg<0
gen grbnden=legume_added_v_drkgr/(kcal/1000)
gen heix2_greens_and_bean=5*(grbnden/.2)
replace heix2_greens_and_bean=5 if heix2_greens_and_bean>5
replace heix2_greens_and_bean=0 if heix2_greens_and_bean<0
gen frtden=f_total/(kcal/1000)
gen heix3_totalfruit=5*(frtden/.8)
replace heix3_totalfruit=5 if heix3_totalfruit>5
replace heix3_totalfruit=0 if heix3_totalfruit<0
gen wholefrt=f_total-frtjuice
gen whfrden=wholefrt/(kcal/1000)
gen heix4_wholefruit=5*(whfrden/.4)
replace heix4_wholefruit=5 if heix4_wholefruit>5
replace heix4_wholefruit=0 if heix4_wholefruit<0
gen wgrnden=g_whl/(kcal/1000)
gen heix5_wholegrain=10*(wgrnden/1.5)
replace heix5_wholegrain=10 if heix5_wholegrain>10
replace heix5_wholegrain=0 if heix5_wholegrain<0
gen dairyden=d_total/(kcal/1000)
gen heix6_totaldairy=10*(dairyden/1.3)
replace heix6_totaldairy=10 if heix6_totaldairy>10
replace heix6_totaldairy=0 if heix6_totaldairy<0
gen meatden=legume_added_allmeat/(kcal/1000)
gen heix7_totprot=5*(meatden/2.5)
replace heix7_totprot=5 if heix7_totprot>5
replace heix7_totprot=0 if heix7_totprot<0
gen seaplden=legume_added_seaplant/(kcal/1000)
gen heix8_seaplant_prot=5*(seaplden/.8)
replace heix8_seaplant_prot=5 if heix8_seaplant_prot>5
replace heix8_seaplant_prot=0 if heix8_seaplant_prot<0
gen faratio=monopoly/SatFat if SatFat>0




gen farmin=1.2
gen farmax=2.5
gen heix9_fattyacid=0 if SatFat==0 & monopoly==0
replace heix9_fattyacid=10 if SatFat==0 & monopoly>0
replace heix9_fattyacid=10 if faratio>=farmax & faratio !=.
replace heix9_fattyacid=0 if faratio<=farmin & faratio !=.
replace heix9_fattyacid=10*((faratio-farmin)/(farmax-farmin)) if faratio !=.
gen sodden=sodi/kcal
gen sodmin=1.1
gen sodmax=2
gen heix10_sodium=10
replace heix10_sodium=0 if sodden>=sodmax
replace heix10_sodium=10-(10*(sodden-sodmin)/(sodmax-sodmin))
gen rgden=g_nwhl/(kcal/1000)
gen rgmin=1.8
gen rgmax=4.3
gen heix11_refinedgrain=10
replace heix11_refinedgrain=0 if rgden>=rgmax
replace heix11_refinedgrain=10-(10*(rgden-rgmin)/(rgmax-rgmin))


gen addedsugar_perc=100*add_sug*16/kcal
gen addsugmin=6.5
gen addsugmax=26
gen heix12_addedsugar=0 if addedsugar_perc>=addsugmax
replace heix12_addedsugar=10 if addedsugar_perc<=addsugmin
replace heix12_addedsugar=10-(10*(addedsugar_perc-addsugmin)/(addsugmax-addsugmin))



gen saturatedfat_perc=100*sfat*9/kcal
gen saturatedfatmin=7
gen saturatedfatmax=15
gen heix13_saturatedfat=0 if saturatedfat_perc>=saturatedfatmax
replace heix13_saturatedfat=10 if saturatedfat_perc<=saturatedfatmin
replace heix13_saturatedfat=10-(10*(saturatedfat_perc-saturatedfatmin)/(saturatedfatmax-saturatedfatmin))


foreach var in vegden grbnden frtden whfrden wgrnden dairyden meatden seaplden faratio sodden rgden {
replace `var'=0 if `var'==.
}




foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if kcal==0
}
foreach var in 1_totalveg 2_greens_and_bean 3_totalfruit 4_wholefruit 5_wholegrain 6_totaldairy 7_totprot 8_seaplant 9_fattyacid 10_sodium 11_refinedgrain 12_addedsugar 13_saturatedfat {
replace heix`var'=0 if heix`var'<0 & heix`var'!=.
}
foreach var in 9_fattyacid 10_sodium 11_refinedgrain {
replace heix`var'=10 if heix`var'>10 & heix`var'!=.
}
replace heix12_addedsugar=10 if heix12_addedsugar>10 & heix12_addedsugar!=.
replace heix13_saturatedfat=10 if heix13_saturatedfat>10 & heix13_saturatedfat!=.


gen hei2015_total_score=heix1_totalveg+heix2_greens_and_bean+heix3_totalfruit+ ///
heix4_wholefruit+heix5_wholegrain+heix6_totaldairy+heix7_totprot+heix8_seaplant ///
+heix9_fattyacid+heix10_sodium+heix11_refinedgrain+heix12_addedsugar+heix13_saturatedfat



label var hei2015_total_score "total hei-2015 score"
label var heix1_totalveg "hei-2015 component 1 total vegetables"
label var heix2_greens_and_bean "hei-2015 component 2 greens and beans"
label var heix3_totalfruit "hei-2015 component 3 total fruit"
label var heix4_wholefruit "hei-2015 component 4 whole fruit"
label var heix5_wholegrain "hei-2015 component 5 whole grains"
label var heix6_totaldairy "hei-2015 component 6 dairy"
label var heix7_totprot "hei-2015 component 7 total protein foods"

label var heix8_seaplant_prot "hei-2015 component 8 seafood and plant protein"
label var heix9_fattyacid "hei-2015 component 9 fatty acid ratio"
label var heix10_sodium "hei-2015 component 10 sodium"
label var heix11_refinedgrain "hei-2015 component 11 refined grains"
label var heix12_addedsugar "hei-2015 component 12 added sugar"
label var heix13_saturatedfat "hei-2015 component 13 saturated fat"

label var vegden "density of mped total vegetables per 1000 kcal"
label var grbnden "density of mped of dark green veg and beans per 1000 kcal"
label var frtden "density of mped total fruit per 1000 kcal"
label var whfrden "density of mped whole fruit per 1000 kcal"
label var wgrnden "density of mped of whole grain per 1000 kcal"
label var dairyden "density of mped of dairy per 1000 kcal"
label var meatden "density of mped total meat/protein per 1000 kcal"
label var seaplden "denstiy of mped of seafood and plant protein per 1000 kcal"
label var faratio "fatty acid ratio"
label var sodden "density of sodium per 1000 kcal"
label var rgden "density of mped of refined grains per 1000 kcal"
label var addedsugar_perc "percent of calories from added sugar"
label var saturatedfat_perc "percent of calories from saturated fat"

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", replace

destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su hei*

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", replace
capture drop _merge
sort HHIDPN
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015", replace

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015",clear
su HHIDPN,det



capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\FRAILTY.txt",text replace

***************Step 0: Extract RAND file variables needed**********************


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\randhrs1992_2020v2_resp_tracker",clear

sort HHIDPN
capture drop _merge

keep HHIDPN HHID PN r13agey_e  ragender r13bmi  r13vgactx r13mdactx r12agey_e   r12bmi r13walksa

su HHID

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**        HHID |     46,850      310929    252815.4          1     959738

su PN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**          PN |     46,850    14.88907    7.343958         10         43

su HHIDPN

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |     46,851    3.11e+07    2.53e+07        110   9.60e+07


save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\rand2016.dta",replace
 

********************************************************************************
* Step 1: Define directories and datasets

***********Physical measures, 2016*********

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\H16I_R",clear

destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su HHID


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**        HHID |     20,912    386529.5    276018.4      10001     959738


su PN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**          PN |     20,912    14.94606    7.209694         10         43

su HHIDPN

**   Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |     20,912    3.87e+07    2.76e+07    1000110   9.60e+07

codebook

****Hand Grip strength: Average of right/left, first and second trial****

keep HHIDPN HHID PN PI816 PI851  PI852  PI853  

capture drop pm16gripmax
foreach var in PI816 PI851 PI852 PI853 {
    replace `var' = . if inlist(`var', 993, 998, 999)
}
egen pm16gripmax = rowmean(PI816 PI851 PI852 PI853)


su pm16gripmax
histogram pm16gripmax


**HAND STRENGTH VARIABLES:  PI816 PI851  PI852  PI853  (TAKE AVERAGE FOR L/R HAND, FIRST/SECOND TRIAL)
sort HHIDPN

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\pm16.dta",replace



**https://hrs.isr.umich.edu/sites/default/files/meta/2016/core/codebook/h16lb_ri.htm**

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\H16LB_R",clear

destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su HHID


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**        HHID |     20,912    386529.5    276018.4      10001     959738


su PN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**          PN |     20,912    14.94606    7.209694         10         43


su HHIDPN


**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |     20,912    3.87e+07    2.76e+07    1000110   9.60e+07




tab1 PLB018* PLB019*


**PLB018G: Corresponds to "I felt that everything I did was an effort." (18G: IMPOSSIBLE TO REACH GOALS)
***PLB018J: Corresponds to "I could not get going."​ ( 18J: NO USE IN TRYING TO GET SOMETHING)

tab1 PLB018G PLB018J, miss


**PLB018G                       Q18G. IMPOSSIBLE TO REACH GOALS
**         Section: LB    Level: Respondent      TypD: Numeric    Width: 1   Decimals: 0

**         Please say how much you agree or disagree with each of the following statements.
**         (Mark (X) one box for each line.)
**         
**         I feel it is impossible for me to reach the goals that I would like to strive
**         for.
**
**         .................................................................................
**          2147           1.  STRONGLY DISAGREE
**          1399           2.  SOMEWHAT DISAGREE
**           803           3.  SLIGHTLY DISAGREE
**           735           4.  SLIGHTLY AGREE
**           610           5.  SOMEWHAT AGREE
**           482           6.  STRONGLY AGREE
**         14736       Blank.  INAP (Inapplicable); Partial Interview




**PLB018J                       Q18J. NO USE IN TRYING TO GET SOMETHING
**         Section: LB    Level: Respondent      TypD: Numeric    Width: 1   Decimals: 0

**         Please say how much you agree or disagree with each of the following statements.
**         (Mark (X) one box for each line.)
**         
**         There's no use in really trying to get something I want because I probably won't
**         get it.
**
**         .................................................................................
**          3355           1.  STRONGLY DISAGREE
**          1129           2.  SOMEWHAT DISAGREE
**           712           3.  SLIGHTLY DISAGREE
**           444           4.  SLIGHTLY AGREE
**           305           5.  SOMEWHAT AGREE
**           247           6.  STRONGLY AGREE
**         14720       Blank.  INAP (Inapplicable); Partial Interview


capture drop r13cesd4
gen r13cesd4=.
replace r13cesd4=1 if PLB018G>=4 & PLB018G~=.
replace r13cesd4=0 if r13cesd4~=1 & PLB018G~=.

tab r13cesd4

capture drop r13cesd6
gen r13cesd6=.
replace r13cesd6=1 if PLB018J>=4 & PLB018J~=.
replace r13cesd6=0 if r13cesd6~=1 & PLB018J~=.

tab r13cesd6


capture drop cycle
gen cycle=2016

keep HHIDPN  HHID PN cycle PLB018G PLB018J r13cesd4 r13cesd6

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\ces2016.dta",replace


********************************************************************************
global rand_file "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\rand2016.dta"
global pm_file   "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\pm16.dta"
global ces_file   "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\ces2016.dta"
global output_folder "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\"




********************************************************************************
* Step 2: Load RAND and PM 2016 files
********************************************************************************
* Load RAND file
use "$rand_file", clear

save $rand_file, replace

* If you have date variables for BMI measures (e.g., date14 and date16)
capture drop time_years
gen time_years = (r13agey_e-r12agey_e) 
gen delta_bmi_annual = (r12bmi - r13bmi) / time_years

* Apply the annual threshold: assuming 175 cm average height, 10 lb loss per year
capture drop weightloss
gen weightloss = .
replace weightloss = 1 if delta_bmi_annual >=1.48 & r12bmi~=. & r13bmi~=.
replace weightloss = 0 if delta_bmi_annual < 1.48 & r12bmi~=. & r13bmi~=.

tab weightloss

capture drop underweight
gen underweight=.
replace underweight=1 if r13bmi<18.5 & r13bmi~=.
replace underweight=0 if underweight~=1 & r13bmi~=.

tab underweight


****Difficulty walking several blocks: Proxy for walking speed***
tab r13walksa

**      r13walksa:w13 r any |
**     diff-walk sev blocks |      Freq.     Percent        Cum.
**--------------------------+-----------------------------------
**                     0.no |     13,593       68.04       68.04
**                    1.yes |      6,386       31.96      100.00
**--------------------------+-----------------------------------
**                    Total |     19,979      100.00

capture drop r13walkspeed
gen r13walkspeed=r13walksa

tab r13walkspeed

tab r13vgactx



**     r13vgactx:w13 r freq |
**      vigorous phys activ |
**            {finer scale} |      Freq.     Percent        Cum.
**--------------------------+-----------------------------------
**              1.every day |        478        2.38        2.38
**            2.>1 per week |      4,362       21.76       24.14
**             3.1 per week |      2,139       10.67       34.81
**            4.l-3 per mon |      1,963        9.79       44.61
**                  5.never |     11,104       55.39      100.00
**--------------------------+-----------------------------------
**                    Total |     20,046      100.00

tab r13mdactx

**    r13mdactx:w13 r freq |
**      moderate phys activ |
**            {finer scale} |      Freq.     Percent        Cum.
**--------------------------+-----------------------------------
**              1.every day |      1,619        7.77        7.77
**            2.>1 per week |      8,444       40.54       48.31
**             3.1 per week |      3,672       17.63       65.94
**            4.l-3 per mon |      2,569       12.33       78.27
**                  5.never |      4,526       21.73      100.00
**--------------------------+-----------------------------------
**                    Total |     20,830      100.00


destring HHIDPN,replace
su HHIDPN

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\rand2016.dta",replace

global rand_file_small "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\rand2016.dta"



*Load small RAND file**
use $rand_file_small,clear
capture drop HHIDPN
egen HHIDPN = concat(HHID PN)
keep if HHIDPN~=".."
destring HHIDPN, replace
sort HHIDPN
save $rand_file_small, replace



* Load 2016 Physical Measures
use "$pm_file", clear
destring HHIDPN,replace
sort HHIDPN
save $pm_file, replace

*Load  2016 CES-D scores**/

use "$ces_file", clear
sort HHIDPN
destring HHIDPN,replace
sort HHIDPN
save $ces_file, replace




********************************************************************************
* Step 3: Merge RAND WITH CES and PM files
********************************************************************************
use $rand_file_small,clear
destring HHIDPN, replace
sort HHIDPN
save $rand_file_small,replace
use $pm_file, clear
sort HHIDPN
save $pm_file,replace
use $ces_file,clear
sort HHIDPN
save $ces_file,replace

use $rand_file_small, clear
capture drop _merge 
merge HHIDPN using $pm_file
sort HHIDPN
tab _merge
capture drop _merge
merge HHIDPN using $ces_file
tab _merge


keep if _merge==3
capture drop _merge

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\FRAILTY_MERGEED_FILE_HRS", replace

********************************************************************************
* Step 4: Define Fried Frailty Components
********************************************************************************
* 1. Shrinking: unintentional weight loss >10 lbs
capture drop shrinking
gen shrinking =.
replace shrinking=1 if weightloss == 1 | underweight==1
replace shrinking=0 if shrinking~=1 & weightloss~=. & underweight~=.
 
tab shrinking

* 2. Weakness: low grip strength (sex-specific)

capture drop female
gen female = (ragender == 2)


tab pm16gripmax if female==0
**find 20th percentile**
capture drop male20
gen male20 =  27.125

tab pm16gripmax if female==1
**find 20th percentile**
capture drop female20
gen female20 = 16.625

capture drop weakness
gen weakness = .
replace weakness = 1 if (female==0 & pm16gripmax <= male20)
replace weakness = 1 if (female==1 & pm16gripmax <= female20)
replace weakness = 0 if weakness~=1 & pm16gripmax~=.

tab weakness

* 3. Slowness: low walking speed
capture drop slowness
gen slowness = ( r13walkspeed ==1)

tab slowness

* 4. Exhaustion: using CES-D fatigue items
capture drop exhaustion
gen exhaustion =.
replace exhaustion=1 if r13cesd4==1 & r13cesd4~=. | r13cesd6==1 & r13cesd6~=.
replace exhaustion=0 if exhaustion~=1 &  r13cesd4~=. & r13cesd6~=.

tab exhaustion

* 5. Low physical activity: low vigorous activity
capture drop low_pa
gen low_pa =.
replace low_pa=1 if r13vgactx >= 4 & r13vgactx~=.  | r13mdactx>=4 &  r13mdactx~=. // 4=1-3x/month or 5=hardly ever/never
replace low_pa=0 if low_pa~=1 & r13vgactx~=. & r13mdactx~=.

tab low_pa

********************************************************************************
* Step 5: Calculate Fried Frailty Score
********************************************************************************
capture drop fried_sum
capture drop fried_status

gen fried_sum = shrinking+weakness+slowness+exhaustion+low_pa

gen fried_status = .
replace fried_status = 0 if fried_sum == 0 
replace fried_status = 1 if inlist(fried_sum,1,2) 
replace fried_status = 2 if fried_sum >= 3 & fried_sum~=.

capture label drop friedlbl
label define friedlbl 0 "Robust" 1 "Pre-frail" 2 "Frail"
label values fried_status friedlbl

tab fried_status
su fried_sum
histogram fried_sum


********************************************************************************
* Step 6: Save final dataset
********************************************************************************
save "$output_folder/hrs2016_friedfrailty_final.dta", replace

capture drop ragender r12agey_e r13agey_e r13vgactx r13mdactx r12bmi  r13bmi r13walksa

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_FRAILTY.dta", replace

capture log close
capture log using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\MERGING_CODE.txt",text replace


****************************************STEP 7: MERGE WITH EPIGENETIC,  DIETARY DATA AND FRAILTY DATA *******************************************************************************

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_TLHEIFRAILEPIGENMORT.dta",clear
capture rename hhidpn HHIDPN
sort HHIDPN
capture drop _merge
su HHIDPN

save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_TLHEIFRAILEPIGENMORT.dta", replace 


use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\EPICLOCKA_R.dta",clear
destring HHID, replace
destring PN, replace

capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN

su HHIDPN

**    Variable |        Obs        Mean    Std. dev.       Min        Max
**-------------+---------------------------------------------------------
**      HHIDPN |      4,018    3.34e+07    2.95e+07    1003810   9.53e+07


capture drop _merge
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\EPICLOCKA_R.dta",replace




use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_FRAILTY",clear
sort HHIDPN
capture drop _merge
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_FRAILTY",replace


**Start the merging here**
use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_TLHEIFRAILEPIGENMORT.dta", replace 
merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\EPICLOCKA_R.dta"
tab _merge
capture drop _merge
sort HHIDPN
merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HEI2015"
tab _merge
capture drop _merge
sort HHIDPN
merge HHIDPN using "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_FRAILTY"
tab _merge
capture drop _merge
sort HHIDPN
save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_TLHEIFRAILEPIGENMORTfin.dta", replace



**STEP 8: DEMENTIA PROBABILITY DATA 2006 THROUGH 2016**

cd "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\"

use HRS_TLHEIFRAILEPIGENMORTfin,clear

sort HHIDPN
capture drop _merge

use Dementia_prob2000_2016,clear

destring HHID, replace
destring PN, replace

capture rename HHID-HRS_year,lower
save, replace

capture drop HHID PN
gen HHID=hhid
gen PN=pn
destring HHID, replace
destring PN, replace


capture drop HHIDPN
egen HHIDPN = concat(HHID PN)

destring HHIDPN, replace
sort HHIDPN



sort HHIDPN
save, replace

**HRS year 2016**
keep if hrs_year==2016

save Dementia_prob2016, replace


use HRS_TLHEIFRAILEPIGENMORTfin,clear
sort HHIDPN
capture drop _merge
save, replace


merge HHIDPN using Dementia_prob2016

save HRS_TLHEIFRAILEPIGENMORTfinLONG, replace


***STEP 9: NEUROPATHOLOGICAL MARKERS

*-----------------------------*
* Prepare HCAPBIOPILOTA_R
*-----------------------------*
use HCAPBIOPILOTA_R, clear

capture drop _merge

* Ensure source IDs are numeric
capture confirm numeric variable hhid
if _rc {
    destring hhid, replace force
}

capture confirm numeric variable pn
if _rc {
    destring pn, replace force
}

* Recreate numeric HHIDPN using HRS convention
capture drop HHIDPN
gen double HHIDPN = hhid*100 + pn

sort HHIDPN
save HCAPBIOPILOTA_Rfin, replace


*------------------------------------------*
* Prepare HRS_TLHEIFRAILEPIGENMORTfinLONG
*------------------------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG, clear

capture drop _merge

* If lowercase variables exist, use them
capture confirm variable hhid
if !_rc {
    capture confirm numeric variable hhid
    if _rc destring hhid, replace force
}

capture confirm variable pn
if !_rc {
    capture confirm numeric variable pn
    if _rc destring pn, replace force
}

* If uppercase variables exist instead, use them
capture confirm variable HHID
if !_rc {
    capture confirm numeric variable HHID
    if _rc destring HHID, replace force
}

capture confirm variable PN
if !_rc {
    capture confirm numeric variable PN
    if _rc destring PN, replace force
}

capture drop HHIDPN

* Create HHIDPN from whichever pair exists
capture confirm variable hhid
if !_rc {
    gen double HHIDPN = hhid*100 + pn
}
else {
    gen double HHIDPN = HHID*100 + PN
}

sort HHIDPN
save HRS_TLHEIFRAILEPIGENMORTfinLONG, replace


*-----------------------------*
* Merge files
*-----------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG, clear

capture drop dup
duplicates tag HHIDPN, gen(dup)
keep if dup==0 

save HRS_TLHEIFRAILEPIGENMORTfinLONG,replace

merge 1:1 HHIDPN using HCAPBIOPILOTA_Rfin



tab _merge
capture drop _merge


save HRS_TLHEIFRAILEPIGENMORTfinLONG,replace



***STEP 10: GENERATE LN-TRANSFORMED BIOMARKERS, REMOVE OUTLIERS****
use HRS_TLHEIFRAILEPIGENMORTfinLONG,clear


**REMOVE OUTLIERS****

* List of variables
local vars pNfL pGFAP pAbeta42 pAB42_40_ratio pptau181 pGDF_15 puPAR pTSH pT3 pT4

foreach v of local vars {
    
    quietly summarize `v', detail
    
    local p25 = r(p25)
    local p75 = r(p75)
    local iqr = `p75' - `p25'
    
    local lb = `p25' - 1.5*`iqr'
    local ub = `p75' + 1.5*`iqr'
    
    * Set outliers to missing
    replace `v' = . if `v' < `lb' | `v' > `ub'
}


local vars pNfL pGFAP pAbeta42 pAB42_40_ratio pptau181 pGDF_15 puPAR pTSH pT3 pT4

foreach v of local vars {
    capture drop Ln`v'
    gen Ln`v' = . 
    replace Ln`v' = ln(`v') if `v' > 0
}

save HRS_TLHEIFRAILEPIGENMORTfinLONG_final,replace

su Ln*

histogram LnpNfL
graph save HIST_NFL.gph,replace

histogram LnpGDF_15
graph save HIST_pGDF_15.gph,replace


histogram LnpGFAP
graph save HIST_GFAP.gph,replace

save HRS_TLHEIFRAILEPIGENMORTfinLONG_final,replace

***STEP 11: LANGA-WEIR DATASET**

*-----------------------------*
* Prepare cogfinalimp_9522wide
*-----------------------------*
use cogfinalimp_9522wide, clear

capture drop _merge

* Ensure source IDs are numeric
capture confirm numeric variable hhid
if _rc {
    destring hhid, replace force
}

capture confirm numeric variable pn
if _rc {
    destring pn, replace force
}

* Recreate numeric HHIDPN using HRS convention
capture drop HHIDPN
gen double HHIDPN = hhid*100 + pn

* Check for duplicates in cogfinalimp_9522wide by HHIDPN
capture drop dup
duplicates tag HHIDPN, gen(dup)
tab dup

* Keep only unique HHIDPN values before merge
keep if dup==0 | missing(dup)
drop dup

sort HHIDPN
save cogfinalimp_9522wide_fin, replace


*------------------------------------------*
* Prepare HRS_TLHEIFRAILEPIGENMORTfinLONG_final
*------------------------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG_final, clear

capture drop _merge

* If lowercase variables exist, use them
capture confirm variable hhid
if !_rc {
    capture confirm numeric variable hhid
    if _rc destring hhid, replace force
}

capture confirm variable pn
if !_rc {
    capture confirm numeric variable pn
    if _rc destring pn, replace force
}

* If uppercase variables exist instead, use them
capture confirm variable HHID
if !_rc {
    capture confirm numeric variable HHID
    if _rc destring HHID, replace force
}

capture confirm variable PN
if !_rc {
    capture confirm numeric variable PN
    if _rc destring PN, replace force
}

capture drop HHIDPN

* Create HHIDPN from whichever pair exists
capture confirm variable hhid
if !_rc {
    gen double HHIDPN = hhid*100 + pn
}
else {
    gen double HHIDPN = HHID*100 + PN
}

sort HHIDPN
save HRS_TLHEIFRAILEPIGENMORTfinLONG_final, replace


*-----------------------------*
* Deduplicate master file
*-----------------------------*
use HRS_TLHEIFRAILEPIGENMORTfinLONG_final, clear

capture drop dup
duplicates tag HHIDPN, gen(dup)
tab dup

keep if dup==0 | missing(dup)
drop dup

sort HHIDPN
save HRS_TLHEIFRAILEPIGENMORTfinLONG_final, replace


*-----------------------------*
* Merge files
*-----------------------------*
merge 1:1 HHIDPN using cogfinalimp_9522wide_fin

tab _merge
capture drop _merge

save HRS_TLHEIFRAILEPIGENMORTfinLONG_final, replace

capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\SAMPLE_SELECTION_FLOWCHART_DIABETES_2006BASE.txt", ///
text replace

********************************************************************************
** STUDY SAMPLE SELECTION: WOMEN, 2006 BASELINE, DIABETES INCIDENCE THROUGH 2020
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_TLHEIFRAILEPIGENMORTfinLONG_final.dta", ///
clear

********************************************************************************
** 0. HOUSEKEEPING
********************************************************************************

capture drop dup
duplicates tag HHIDPN, gen(dup)
tab dup
keep if dup == 0 | missing(dup)
drop dup

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_BASE_2006.dta", ///
replace

********************************************************************************
** 1. CREATE 2006 BMI, WAIST CIRCUMFERENCE, AND DIABETES VARIABLES
********************************************************************************

** BMI in 2006: r9
tab r9pmbmi, missing
tab r9bmi, missing
su r9bmi, detail

capture drop bmi_2006
gen bmi_2006 = .
replace bmi_2006 = r9pmbmi if r9pmbmi < 100
replace bmi_2006 = r9bmi if missing(bmi_2006) & r9bmi < 100
label var bmi_2006 "BMI in 2006"

capture drop bmibr_2006
gen bmibr_2006 = .
replace bmibr_2006 = 1 if bmi_2006 >= 18.5 & bmi_2006 < 25
replace bmibr_2006 = 2 if bmi_2006 >= 25   & bmi_2006 < 30
replace bmibr_2006 = 3 if bmi_2006 >= 30   & bmi_2006 < .
label define bmibr_lbl 1 "18.5-24.9" 2 "25-29.9" 3 ">=30", replace
label values bmibr_2006 bmibr_lbl
label var bmibr_2006 "BMI category in 2006"

tab bmi_2006, missing
tab bmibr_2006, missing

** Waist circumference in 2006
capture drop waist_2006
gen waist_2006 = .

capture confirm variable r9waist
if _rc == 0 {
    replace waist_2006 = r9waist if r9waist > 0 & r9waist < .
}

capture confirm variable r9pmwaist
if _rc == 0 {
    replace waist_2006 = r9pmwaist if missing(waist_2006) & ///
        r9pmwaist > 0 & r9pmwaist < .
}

label var waist_2006 "Waist circumference in 2006"
tab waist_2006, missing
su waist_2006, detail

** Diabetes status: 2006 through 2020
foreach wave in 9 10 11 12 13 14 15 {
    capture drop diab_ever_r`wave'
    gen diab_ever_r`wave' = .
    replace diab_ever_r`wave' = 0 if r`wave'diabe == 0
    replace diab_ever_r`wave' = 1 if r`wave'diabe == 1
    label var diab_ever_r`wave' "Ever had diabetes, HRS wave r`wave'"
}

capture drop diab_ever_2006 diab_ever_2008 diab_ever_2010 ///
             diab_ever_2012 diab_ever_2014 diab_ever_2016 ///
             diab_ever_2018 diab_ever_2020

gen diab_ever_2006 = diab_ever_r9
gen diab_ever_2008 = diab_ever_r10
gen diab_ever_2010 = diab_ever_r11
gen diab_ever_2012 = diab_ever_r12
gen diab_ever_2014 = diab_ever_r13
gen diab_ever_2016 = diab_ever_r14
gen diab_ever_2018 = diab_ever_r15

capture confirm variable r16diabe
if _rc == 0 {
    gen diab_ever_2020 = .
    replace diab_ever_2020 = 0 if r16diabe == 0
    replace diab_ever_2020 = 1 if r16diabe == 1
}

capture confirm variable r15diabe
if _rc == 0 {
    capture confirm variable diab_ever_2020
    if _rc != 0 {
        gen diab_ever_2020 = .
        replace diab_ever_2020 = 0 if r15diabe == 0
        replace diab_ever_2020 = 1 if r15diabe == 1
    }
}

label var diab_ever_2006 "Ever had diabetes by 2006"
label var diab_ever_2008 "Ever had diabetes by 2008"
label var diab_ever_2010 "Ever had diabetes by 2010"
label var diab_ever_2012 "Ever had diabetes by 2012"
label var diab_ever_2014 "Ever had diabetes by 2014"
label var diab_ever_2016 "Ever had diabetes by 2016"
label var diab_ever_2018 "Ever had diabetes by 2018"
label var diab_ever_2020 "Ever had diabetes by 2020"

********************************************************************************
** 2. DEFINE CORE 2006 ELIGIBILITY
********************************************************************************

capture drop elig_age50
gen elig_age50 = .
replace elig_age50 = 1 if r9agey_e >= 50 & r9agey_e < .
replace elig_age50 = 0 if r9agey_e < 50
label var elig_age50 "Age >=50 years in 2006"

capture drop elig_alive2006
gen elig_alive2006 = .
replace elig_alive2006 = 1 if inw9 == 1
replace elig_alive2006 = 0 if inw9 != 1 & inw9 < .
label var elig_alive2006 "Alive/interviewed in 2006"

capture drop sample_step1
gen sample_step1 = 0
replace sample_step1 = 1 if elig_age50 == 1 & elig_alive2006 == 1
label var sample_step1 "Eligible 2006 age/alive sample"

tab sample_step1, missing

********************************************************************************
** 2A. RESTRICT TO WOMEN ONLY
********************************************************************************

capture drop female_2006
gen female_2006 = .
replace female_2006 = 1 if ragender == 2
replace female_2006 = 0 if ragender == 1
label define femlbl 0 "Male" 1 "Female", replace
label values female_2006 femlbl
label var female_2006 "Female participant"

capture drop sample_step1_women
gen sample_step1_women = 0
replace sample_step1_women = 1 if sample_step1 == 1 & female_2006 == 1
label var sample_step1_women "Eligible 2006 sample restricted to women"

tab female_2006, missing
tab sample_step1_women, missing

********************************************************************************
** 3. COMPLETE 2006 BMI AND WAIST CIRCUMFERENCE
********************************************************************************

capture drop complete_bmi_wc_2006
gen complete_bmi_wc_2006 = !missing(bmi_2006, waist_2006)
label var complete_bmi_wc_2006 "Complete BMI and waist circumference in 2006"

capture drop sample_step2
gen sample_step2 = 0
replace sample_step2 = 1 if sample_step1_women == 1 & complete_bmi_wc_2006 == 1
label var sample_step2 "Eligible women + complete 2006 BMI and waist circumference"

tab sample_step2, missing

********************************************************************************
** 4. EXCLUDE PREVALENT DIABETES IN 2006 ONLY
********************************************************************************

capture drop prevalent_diabetes_2006
gen prevalent_diabetes_2006 = .
replace prevalent_diabetes_2006 = 1 if diab_ever_2006 == 1
replace prevalent_diabetes_2006 = 0 if diab_ever_2006 == 0
label var prevalent_diabetes_2006 "Prevalent diabetes in 2006"

capture drop diabetes_free_2006
gen diabetes_free_2006 = .
replace diabetes_free_2006 = 1 if prevalent_diabetes_2006 == 0
replace diabetes_free_2006 = 0 if prevalent_diabetes_2006 == 1
label var diabetes_free_2006 "Free of diabetes at 2006 baseline"

capture drop sample_step3
gen sample_step3 = 0
replace sample_step3 = 1 if sample_step2 == 1 & diabetes_free_2006 == 1
label var sample_step3 "Diabetes-free women risk set at 2006 baseline"

tab prevalent_diabetes_2006, missing
tab sample_step3, missing

********************************************************************************
** 5. COMPLETE 2006 COVARIATE DATA
********************************************************************************

capture drop nmiss_covars
egen nmiss_covars = rowmiss(r9agey_e ragender RACE_ETHN ///
                            totwealth_2006 marital_2006 education ///
                            smoking_2006 alcohol_2006 physic_act_2006)

capture drop complete_covars
gen complete_covars = (nmiss_covars == 0)
label var complete_covars "Complete 2006 covariate data"

tab complete_covars, missing

********************************************************************************
** 5A. FINAL BMI ELIGIBILITY: BMI >=18.5 AND NON-MISSING IN 2006
********************************************************************************

capture drop valid_bmi_2006
gen valid_bmi_2006 = 0
replace valid_bmi_2006 = 1 if bmi_2006 >= 18.5 & bmi_2006 < .
label var valid_bmi_2006 "BMI >=18.5 and non-missing in 2006"

tab valid_bmi_2006 if sample_step3 == 1, missing

********************************************************************************
** 6. INCIDENT DIABETES THROUGH 2020 + DEATH CENSORING
********************************************************************************

capture drop incident_diabetes_2006_2020
gen incident_diabetes_2006_2020 = .
replace incident_diabetes_2006_2020 = 1 if sample_step3 == 1 & ///
    (diab_ever_2008 == 1 | diab_ever_2010 == 1 | ///
     diab_ever_2012 == 1 | diab_ever_2014 == 1 | ///
     diab_ever_2016 == 1 | diab_ever_2018 == 1 | ///
     diab_ever_2020 == 1)

replace incident_diabetes_2006_2020 = 0 if sample_step3 == 1 & ///
    incident_diabetes_2006_2020 != 1

label var incident_diabetes_2006_2020 "Incident diabetes from 2006 to 2020"

tab incident_diabetes_2006_2020 if sample_step3 == 1, missing

********************************************************************************
** 7. SURVIVAL TIME: START JAN 1, 2006; ADMIN CENSOR JAN 1, 2021
********************************************************************************

capture drop start_date end_admin_date diabetes_date death_date censor_date ///
             exit_date fail_diabetes followup_days followup_years

gen start_date = mdy(1,1,2006)
gen end_admin_date = mdy(1,1,2021)

format start_date end_admin_date %td
label var start_date "Baseline date: Jan 1, 2006"
label var end_admin_date "Administrative censoring date: Jan 1, 2021"

gen diabetes_date = .
replace diabetes_date = mdy(1,1,2008) if missing(diabetes_date) & diab_ever_2008 == 1
replace diabetes_date = mdy(1,1,2010) if missing(diabetes_date) & diab_ever_2010 == 1
replace diabetes_date = mdy(1,1,2012) if missing(diabetes_date) & diab_ever_2012 == 1
replace diabetes_date = mdy(1,1,2014) if missing(diabetes_date) & diab_ever_2014 == 1
replace diabetes_date = mdy(1,1,2016) if missing(diabetes_date) & diab_ever_2016 == 1
replace diabetes_date = mdy(1,1,2018) if missing(diabetes_date) & diab_ever_2018 == 1
replace diabetes_date = mdy(1,1,2020) if missing(diabetes_date) & diab_ever_2020 == 1

format diabetes_date %td
label var diabetes_date "Incident diabetes date/proxy"

gen death_date = .

capture confirm variable death_yr
if _rc == 0 {
    capture confirm variable death_mo
    if _rc == 0 {
        replace death_date = mdy(death_mo, 15, death_yr) ///
            if death_yr >= 2006 & death_yr <= 2020 & ///
               death_mo >= 1 & death_mo <= 12
    }
}

capture confirm variable death_2020
if _rc == 0 {
    replace death_date = mdy(1,1,2020) if missing(death_date) & death_2020 == 1
}

format death_date %td
label var death_date "Death date/proxy censoring date"

gen censor_date = end_admin_date
replace censor_date = death_date if death_date < end_admin_date & death_date < .
format censor_date %td
label var censor_date "Censoring date: death or Jan 1, 2021"

gen fail_diabetes = 0
replace fail_diabetes = 1 if sample_step3 == 1 & ///
                            diabetes_date <= censor_date & ///
                            diabetes_date < .
label var fail_diabetes "Incident diabetes before censoring"

gen exit_date = censor_date
replace exit_date = diabetes_date if fail_diabetes == 1
format exit_date %td
label var exit_date "Exit date: diabetes, death, or Jan 1, 2021"

gen followup_days = exit_date - start_date
gen followup_years = followup_days / 365.25

su followup_years if sample_step3 == 1, detail
tab fail_diabetes if sample_step3 == 1, missing

********************************************************************************
** 8. FINAL ANALYTIC SAMPLE
********************************************************************************

capture drop sample_final
gen sample_final = 0
replace sample_final = 1 if sample_step3 == 1 & ///
                           complete_covars == 1 & ///
                           valid_bmi_2006 == 1 & ///
                           exit_date > start_date & ///
                           exit_date < .
label var sample_final "Final analytic sample: women diabetes-free in 2006, BMI>=18.5, complete data"

tab sample_final, missing

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINAL.dta", ///
replace

********************************************************************************
** 9. STSET: INCIDENT DIABETES, DEATH AS CENSORING
********************************************************************************

stset exit_date if sample_final == 1, ///
    failure(fail_diabetes == 1) ///
    origin(time start_date) ///
    enter(time start_date) ///
    id(HHIDPN) ///
    scale(365.25)

stsum
stdescribe


save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINAL.dta", ///
replace

********************************************************************************
** 10. DISPLAY COUNTS FOR FIGURE 1
********************************************************************************

display "------------------------------------------------------------"
count
display "Total records in merged analytic file = " r(N)

count if sample_step1 == 1
display "Step 1: Age >=50 and alive/interviewed in 2006 = " r(N)

count if sample_step1 == 1 & female_2006 == 0
display "Excluded: men = " r(N)

count if sample_step1_women == 1
display "Step 1a: Eligible women aged >=50 and alive/interviewed in 2006 = " r(N)

count if sample_step1_women == 1 & complete_bmi_wc_2006 == 0
display "Excluded: missing BMI or waist circumference in 2006 = " r(N)

count if sample_step2 == 1
display "Step 2: Eligible women with complete 2006 BMI and waist circumference = " r(N)

count if sample_step2 == 1 & diabetes_free_2006 == 0
display "Excluded: prevalent diabetes in 2006 = " r(N)

count if sample_step3 == 1
display "Step 3: Diabetes-free women risk set at 2006 baseline = " r(N)

count if sample_step3 == 1 & complete_covars == 0
display "Excluded: missing 2006 covariates = " r(N)

count if sample_step3 == 1 & complete_covars == 1 & valid_bmi_2006 == 0
display "Excluded: BMI <18.5 or missing BMI in 2006 = " r(N)

count if sample_step3 == 1 & complete_covars == 1 & valid_bmi_2006 == 1 & ///
    (missing(exit_date) | exit_date <= start_date)
display "Excluded: invalid or missing survival follow-up time = " r(N)

count if sample_final == 1
display "Final analytic sample = " r(N)
display "------------------------------------------------------------"

********************************************************************************
** 11. CREATE FLOWCHART DATASET FOR EXPORT
********************************************************************************

tempname memhold
postfile `memhold' str100 flow_step N using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\flowchart_counts_diabetes_2006base.dta", ///
replace

quietly count
post `memhold' ("Merged analytic file") (`r(N)')

quietly count if sample_step1 == 1
post `memhold' ("Age >=50 and alive/interviewed in 2006") (`r(N)')

quietly count if sample_step1 == 1 & female_2006 == 0
post `memhold' ("Excluded: men") (`r(N)')

quietly count if sample_step1_women == 1
post `memhold' ("Eligible women aged >=50 and alive/interviewed in 2006") (`r(N)')

quietly count if sample_step1_women == 1 & complete_bmi_wc_2006 == 0
post `memhold' ("Excluded: missing BMI or waist circumference in 2006") (`r(N)')

quietly count if sample_step2 == 1
post `memhold' ("Eligible women with complete 2006 BMI and waist circumference") (`r(N)')

quietly count if sample_step2 == 1 & diabetes_free_2006 == 0
post `memhold' ("Excluded: prevalent diabetes in 2006") (`r(N)')

quietly count if sample_step3 == 1
post `memhold' ("Diabetes-free women risk set at 2006 baseline") (`r(N)')

quietly count if sample_step3 == 1 & complete_covars == 0
post `memhold' ("Excluded: missing 2006 covariates") (`r(N)')

quietly count if sample_step3 == 1 & complete_covars == 1 & valid_bmi_2006 == 0
post `memhold' ("Excluded: BMI <18.5 or missing BMI in 2006") (`r(N)')

quietly count if sample_step3 == 1 & complete_covars == 1 & valid_bmi_2006 == 1 & ///
    (missing(exit_date) | exit_date <= start_date)
post `memhold' ("Excluded: invalid or missing survival follow-up time") (`r(N)')

quietly count if sample_final == 1
post `memhold' ("Final analytic sample") (`r(N)')

postclose `memhold'

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\flowchart_counts_diabetes_2006base.dta", ///
clear

list, noobs abbreviate(40)

export excel using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\flowchart_counts_diabetes_2006base.xlsx", ///
firstrow(variables) replace

********************************************************************************
** 12. RELOAD FINAL ANALYTIC FILE FOR FIGURES
********************************************************************************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINAL.dta", ///
clear

stset exit_date if sample_final == 1, ///
    failure(fail_diabetes == 1) ///
    origin(time start_date) ///
    enter(time start_date) ///
    id(HHIDPN) ///
    scale(365.25)

********************************************************************************
** 13. FIGURE EXAMPLES: SAVE BOTH IMAGE FILES AND .GPH FILES
********************************************************************************
********************************************************************************
** 13A. Kaplan-Meier / failure curve by BMI category
********************************************************************************

sts graph, by(bmibr_2006) failure ///
    title("Incident diabetes by BMI category, 2006 baseline") ///
    ytitle("Cumulative incidence of diabetes", ///
        margin(large) justification(center)) ///
    xtitle("Years since 2006 baseline") ///
    legend(order(1 "18.5-24.9" 2 "25-29.9" 3 ">=30") ///
        rows(1) ///
        symxsize(6) ///
        colgap(4) ///
        keygap(2) ///
        size(small) ///
        region(lstyle(none))) ///
    graphregion(margin(large)) ///
    plotregion(margin(medium))

graph export ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\KM_diabetes_bmi_2006base.png", ///
replace width(2400)

graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\KM_diabetes_bmi_2006base.gph", ///
replace

********************************************************************************
** 13B. Kaplan-Meier / failure curve by waist circumference tertile
********************************************************************************

capture drop waist_tert_2006
xtile waist_tert_2006 = waist_2006 if sample_final == 1, nq(3)
label define waisttert_lbl 1 "Tertile 1" 2 "Tertile 2" 3 "Tertile 3", replace
label values waist_tert_2006 waisttert_lbl
label var waist_tert_2006 "Waist circumference tertile in 2006"

sts graph, by(waist_tert_2006) failure ///
    title("Incident diabetes by waist circumference tertile, 2006 baseline") ///
    ytitle("Cumulative incidence of diabetes", ///
        margin(large) justification(center)) ///
    xtitle("Years since 2006 baseline") ///
    legend(order(1 "Tertile 1" 2 "Tertile 2" 3 "Tertile 3") ///
        rows(1) ///
        symxsize(6) ///
        colgap(4) ///
        keygap(2) ///
        size(small) ///
        region(lstyle(none))) ///
    graphregion(margin(large)) ///
    plotregion(margin(medium))
    

graph export ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\KM_diabetes_waist_tertile_2006base.png", ///
replace width(2400)

graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\KM_diabetes_waist_tertile_2006base.gph", ///
replace
********************************************************************************
** 13C. Histogram of BMI among final analytic sample
********************************************************************************

histogram bmi_2006 if sample_final == 1, ///
    percent ///
    title("Distribution of BMI in 2006") ///
    xtitle("BMI") ///
    ytitle("Percent")

graph export ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\hist_bmi_2006base.png", ///
replace width(2400)

graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\hist_bmi_2006base.gph", ///
replace

********************************************************************************
** 13D. Histogram of waist circumference among final analytic sample
********************************************************************************

histogram waist_2006 if sample_final == 1, ///
    percent ///
    title("Distribution of waist circumference in 2006") ///
    xtitle("Waist circumference") ///
    ytitle("Percent")

graph export ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\hist_waist_2006base.png", ///
replace width(2400)

graph save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\hist_waist_2006base.gph", ///
replace

********************************************************************************
** END
********************************************************************************


save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINAL.dta", ///
replace

capture log close


***************************************************************************
capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\TIMETOEVENTSETUP_DIABETES_2006_2020.txt", ///
text replace

*********************** TIME TO EVENT SET UP: INCIDENT DIABETES ************

use ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINAL.dta", ///
clear

********************************************************************************
** STEP 1. RESTRICT TO FINAL ANALYTIC SAMPLE
********************************************************************************

keep if sample_final==1
tab sample_final, missing
count

********************************************************************************
** STEP 2. CONFIRM DIABETES VARIABLES: BASELINE 2006 THROUGH 2020
********************************************************************************

tab diab_ever_2006, missing
tab diab_ever_2008, missing
tab diab_ever_2010, missing
tab diab_ever_2012, missing
tab diab_ever_2014, missing
tab diab_ever_2016, missing
tab diab_ever_2018, missing
tab diab_ever_2020, missing

* Baseline risk set: diabetes-free in 2006
keep if diab_ever_2006==0
count

********************************************************************************
** STEP 3. CREATE DEATH DATE FROM TRACKER FILE
********************************************************************************

capture drop died
gen died=.
replace died=1 if knowndeceasedyr<.
replace died=0 if knowndeceasedyr==.
label var died "Died during follow-up according to tracker file"

capture drop deathmonth
gen deathmonth=knowndeceasedmo
replace deathmonth=. if inlist(deathmonth, 0, 98, 99)

capture drop deathyear
gen deathyear=knowndeceasedyr
replace deathyear=. if inlist(deathyear, 0, 9998, 9999)

* If death month missing but death year known, assign June
replace deathmonth=6 if deathyear<. & deathmonth==.

capture drop deathday
gen deathday=15 if deathyear<.

capture drop dod
gen dod=mdy(deathmonth, deathday, deathyear)
format dod %td
label var dod "Date of death from tracker file"

summ dod if died==1, detail

********************************************************************************
** STEP 4. CREATE BASELINE, FOLLOW-UP WAVE, AND ADMINISTRATIVE CENSORING DATES
********************************************************************************

capture drop doenter
gen doenter=mdy(1,1,2006)
format doenter %td
label var doenter "Baseline date: Jan 1, 2006"

capture drop doiw2008 doiw2010 doiw2012 doiw2014 doiw2016 doiw2018 doiw2020

gen doiw2008=mdy(7,1,2008)
gen doiw2010=mdy(7,1,2010)
gen doiw2012=mdy(7,1,2012)
gen doiw2014=mdy(7,1,2014)
gen doiw2016=mdy(7,1,2016)
gen doiw2018=mdy(7,1,2018)
gen doiw2020=mdy(7,1,2020)

format doiw2008 doiw2010 doiw2012 doiw2014 doiw2016 doiw2018 doiw2020 %td

capture drop doadmin
gen doadmin=mdy(1,1,2021)
format doadmin %td
label var doadmin "Administrative censoring date: Jan 1, 2021"

********************************************************************************
** STEP 5. INCIDENT DIABETES FLAGS AT EACH FOLLOW-UP WAVE
********************************************************************************

capture drop event2008 event2010 event2012 event2014 event2016 event2018 event2020

gen event2008=0
replace event2008=1 if diab_ever_2006==0 & diab_ever_2008==1

gen event2010=0
replace event2010=1 if diab_ever_2006==0 & ///
    (diab_ever_2008==0 | missing(diab_ever_2008)) & diab_ever_2010==1

gen event2012=0
replace event2012=1 if diab_ever_2006==0 & ///
    (diab_ever_2008==0 | missing(diab_ever_2008)) & ///
    (diab_ever_2010==0 | missing(diab_ever_2010)) & diab_ever_2012==1

gen event2014=0
replace event2014=1 if diab_ever_2006==0 & ///
    (diab_ever_2008==0 | missing(diab_ever_2008)) & ///
    (diab_ever_2010==0 | missing(diab_ever_2010)) & ///
    (diab_ever_2012==0 | missing(diab_ever_2012)) & diab_ever_2014==1

gen event2016=0
replace event2016=1 if diab_ever_2006==0 & ///
    (diab_ever_2008==0 | missing(diab_ever_2008)) & ///
    (diab_ever_2010==0 | missing(diab_ever_2010)) & ///
    (diab_ever_2012==0 | missing(diab_ever_2012)) & ///
    (diab_ever_2014==0 | missing(diab_ever_2014)) & diab_ever_2016==1

gen event2018=0
replace event2018=1 if diab_ever_2006==0 & ///
    (diab_ever_2008==0 | missing(diab_ever_2008)) & ///
    (diab_ever_2010==0 | missing(diab_ever_2010)) & ///
    (diab_ever_2012==0 | missing(diab_ever_2012)) & ///
    (diab_ever_2014==0 | missing(diab_ever_2014)) & ///
    (diab_ever_2016==0 | missing(diab_ever_2016)) & diab_ever_2018==1

gen event2020=0
replace event2020=1 if diab_ever_2006==0 & ///
    (diab_ever_2008==0 | missing(diab_ever_2008)) & ///
    (diab_ever_2010==0 | missing(diab_ever_2010)) & ///
    (diab_ever_2012==0 | missing(diab_ever_2012)) & ///
    (diab_ever_2014==0 | missing(diab_ever_2014)) & ///
    (diab_ever_2016==0 | missing(diab_ever_2016)) & ///
    (diab_ever_2018==0 | missing(diab_ever_2018)) & diab_ever_2020==1

********************************************************************************
** STEP 6. FIRST INCIDENT DIABETES DATE
********************************************************************************

capture drop dodiabevent
gen dodiabevent=.

replace dodiabevent = doenter   + floor((doiw2008-doenter)/2)   if event2008==1
replace dodiabevent = doiw2008  + floor((doiw2010-doiw2008)/2)  if event2010==1
replace dodiabevent = doiw2010  + floor((doiw2012-doiw2010)/2)  if event2012==1
replace dodiabevent = doiw2012  + floor((doiw2014-doiw2012)/2)  if event2014==1
replace dodiabevent = doiw2014  + floor((doiw2016-doiw2014)/2)  if event2016==1
replace dodiabevent = doiw2016  + floor((doiw2018-doiw2016)/2)  if event2018==1
replace dodiabevent = doiw2018  + floor((doiw2020-doiw2018)/2)  if event2020==1

format dodiabevent %td
label var dodiabevent "Estimated date of first incident diabetes"

********************************************************************************
** STEP 7. CENSORING AND FINAL FOLLOW-UP DATE
********************************************************************************

capture drop docensor
gen docensor=doadmin
replace docensor=dod if dod<docensor & dod<.
format docensor %td
label var docensor "Censoring date: death or Jan 1, 2021"

capture drop fail_diabetes
gen fail_diabetes=0
replace fail_diabetes=1 if dodiabevent<. & ///
    (dod==. | dodiabevent<=dod) & ///
    dodiabevent<=doadmin

label var fail_diabetes "Incident diabetes during follow-up"

capture drop doevent
gen doevent=docensor
replace doevent=dodiabevent if fail_diabetes==1
format doevent %td
label var doevent "End of follow-up date"

********************************************************************************
** STEP 8. PERSON-TIME VARIABLES
********************************************************************************

capture drop fu_days fu_yrs
gen fu_days = doevent - doenter
replace fu_days = . if fu_days<0
gen fu_yrs = fu_days/365.25

label var fu_days "Follow-up time in days"
label var fu_yrs  "Follow-up time in years"

summ fu_yrs, detail
summ fu_yrs if fail_diabetes==1, detail
summ fu_yrs if fail_diabetes==0, detail

********************************************************************************
** STEP 9. COMPETING DEATH INDICATOR
********************************************************************************

capture drop death_before_diabetes
gen death_before_diabetes=0
replace death_before_diabetes=1 if died==1 & ///
    (dodiabevent==. | dod<dodiabevent) & ///
    dod<=doadmin

label var death_before_diabetes "Death before incident diabetes"

capture drop fu_status
gen fu_status=.
replace fu_status=1 if fail_diabetes==1
replace fu_status=2 if fail_diabetes==0 & death_before_diabetes==1
replace fu_status=0 if fail_diabetes==0 & death_before_diabetes==0

label define fu_status_diab 0 "censored" 1 "incident diabetes" 2 "death before diabetes", replace
label values fu_status fu_status_diab
tab fu_status, missing

********************************************************************************
** STEP 10. AGE-AT-ENTRY / AGE-AT-EVENT VARIABLES
********************************************************************************

capture drop dob
gen dob=mdy(birthmo,15,birthyr)
format dob %td
label var dob "Date of birth"

capture drop ageenter ageevent
gen ageenter=(doenter-dob)/365.25
gen ageevent=(doevent-dob)/365.25

label var ageenter "Age at baseline"
label var ageevent "Age at diabetes/death/censoring"

summ ageenter ageevent, detail

********************************************************************************
** STEP 11. STSET FOR MAIN COX / WEIBULL MODELS
********************************************************************************

stset ageevent, origin(time ageenter) enter(time ageenter) ///
    failure(fail_diabetes==1) id(HHIDPN)

stsum
sts list, by(fail_diabetes)

********************************************************************************
** STEP 12. OPTIONAL CHECKS
********************************************************************************

count if fail_diabetes==1
count if death_before_diabetes==1
count if fu_status==0

quietly summarize fu_yrs
scalar total_py = r(sum)

quietly count if fail_diabetes==1
scalar total_events = r(N)

display "Total person-years = " total_py
display "Total incident diabetes events = " total_events
display "Incidence rate per 1,000 PY = " (total_events/total_py)*1000

********************************************************************************
** STEP 13. SAVE ANALYTIC FILE WITH SURVIVAL VARIABLES
********************************************************************************

save ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINALfin.dta", ///
replace

capture log close

***********************************************************
capture log close
capture log using ///
"D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS\SVYSETUP.txt", text replace



**********************SVY SET UP*********************************************
********************************************************************************
** SURVEY DESIGN SETUP FOR HRS
********************************************************************************

use "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINALfin.dta", clear

* restrict to analytic sample
keep if sample_final==1


* check survey variables
describe secu stratum kwgtr

* set survey design
svyset secu [pweight=kwgtr], strata(stratum) vce(linearized) singleunit(centered)

svydes


save "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS\HRS_BMWCDIABETES_ANALYTIC_FINALfin.dta", replace


capture log close
*******************************************MAIN ANALYSIS**************************************************
clear all
set more off
set maxvar 20000

********************************************************************************
** 0. PATHS
********************************************************************************

global datadir "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS"
global outdir  "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS"

capture log close
capture log using "$outdir\HRS_TABLES_FIGURES_DIABETES_2006BASE_WOMEN.txt", text replace

********************************************************************************
* HRS TABLES AND FIGURES: WOMEN ONLY
* Central adiposity within BMI categories and incident diabetes
* Baseline: 2006 HRS EFTF
* Follow-up: incident diabetes through 2020
* Administrative censoring: Jan 1, 2021
********************************************************************************

use "$datadir\HRS_BMWCDIABETES_ANALYTIC_FINAL.dta", clear

keep if sample_final == 1

********************************************************************************
** 1. RESTRICT TO WOMEN ONLY
********************************************************************************

keep if ragender == 2
count
display "Women-only final analytic sample = " r(N)

********************************************************************************
** 2. SURVEY DESIGN
********************************************************************************

svyset secu [pweight=kwgtr], strata(stratum) vce(linearized) singleunit(centered)
svydes

********************************************************************************
** 3. ALIGN FOLLOW-UP VARIABLES
********************************************************************************

capture confirm variable fu_yrs
if _rc != 0 {
    gen fu_yrs = followup_years
    label var fu_yrs "Follow-up time in years"
}

********************************************************************************
** 4. EXPOSURE CATEGORIES: BMI AND BMI-SPECIFIC WAIST CIRCUMFERENCE
********************************************************************************

********************************************************************************
** 4A. BMI CATEGORIES
********************************************************************************

capture drop bmi5_2006
gen bmi5_2006 = .

replace bmi5_2006 = 1 if bmi_2006 >= 18.5 & bmi_2006 < 25
replace bmi5_2006 = 2 if bmi_2006 >= 25   & bmi_2006 < 30
replace bmi5_2006 = 3 if bmi_2006 >= 30   & bmi_2006 < 35
replace bmi5_2006 = 4 if bmi_2006 >= 35   & bmi_2006 < 40
replace bmi5_2006 = 5 if bmi_2006 >= 40   & bmi_2006 < .

label define bmi5lbl ///
    1 "Normal" ///
    2 "Overweight" ///
    3 "Obesity 1" ///
    4 "Obesity 2" ///
    5 "Obesity 3", replace

label values bmi5_2006 bmi5lbl
label var bmi5_2006 "BMI category in 2006"

tab bmi5_2006, missing

********************************************************************************
** 4B. STANDARDIZE WAIST CIRCUMFERENCE TO CENTIMETERS
********************************************************************************

summ waist_2006, detail

capture drop waist_cm_2006
gen waist_cm_2006 = .

/*
HRS waist circumference may be stored in inches depending on source variable.
If waist_2006 is <70, it is likely inches and is converted to cm.
If waist_2006 is >=70, it is treated as already in cm.
*/

replace waist_cm_2006 = waist_2006 * 2.54 if waist_2006 > 0 & waist_2006 < 70
replace waist_cm_2006 = waist_2006       if waist_2006 >= 70 & waist_2006 < .

label var waist_cm_2006 "Waist circumference in 2006, cm"

summ waist_2006 waist_cm_2006, detail

********************************************************************************
** 4C. BMI-SPECIFIC HIGH WAIST CIRCUMFERENCE
********************************************************************************

capture drop wc_high_bmi_2006
gen wc_high_bmi_2006 = .

replace wc_high_bmi_2006 = 0 if bmi5_2006 == 1 & waist_cm_2006 <  80
replace wc_high_bmi_2006 = 1 if bmi5_2006 == 1 & waist_cm_2006 >= 80 & waist_cm_2006 < .

replace wc_high_bmi_2006 = 0 if bmi5_2006 == 2 & waist_cm_2006 <  90
replace wc_high_bmi_2006 = 1 if bmi5_2006 == 2 & waist_cm_2006 >= 90 & waist_cm_2006 < .

replace wc_high_bmi_2006 = 0 if bmi5_2006 == 3 & waist_cm_2006 < 105
replace wc_high_bmi_2006 = 1 if bmi5_2006 == 3 & waist_cm_2006 >=105 & waist_cm_2006 < .

replace wc_high_bmi_2006 = 0 if bmi5_2006 == 4 & waist_cm_2006 < 115
replace wc_high_bmi_2006 = 1 if bmi5_2006 == 4 & waist_cm_2006 >=115 & waist_cm_2006 < .

replace wc_high_bmi_2006 = 0 if bmi5_2006 == 5 & waist_cm_2006 < 115
replace wc_high_bmi_2006 = 1 if bmi5_2006 == 5 & waist_cm_2006 >=115 & waist_cm_2006 < .

label define wchighlbl ///
    0 "Lower WC within BMI" ///
    1 "Higher WC within BMI", replace

label values wc_high_bmi_2006 wchighlbl
label var wc_high_bmi_2006 "BMI-specific high waist circumference in 2006"

tab wc_high_bmi_2006, missing
tab bmi5_2006 wc_high_bmi_2006, missing row

********************************************************************************
** 4D. JOINT 10-CATEGORY BMI AND BMI-SPECIFIC WC VARIABLE
********************************************************************************

capture drop bmi_wc10_2006
gen bmi_wc10_2006 = .

replace bmi_wc10_2006 = 1  if bmi5_2006 == 1 & wc_high_bmi_2006 == 0
replace bmi_wc10_2006 = 2  if bmi5_2006 == 1 & wc_high_bmi_2006 == 1

replace bmi_wc10_2006 = 3  if bmi5_2006 == 2 & wc_high_bmi_2006 == 0
replace bmi_wc10_2006 = 4  if bmi5_2006 == 2 & wc_high_bmi_2006 == 1

replace bmi_wc10_2006 = 5  if bmi5_2006 == 3 & wc_high_bmi_2006 == 0
replace bmi_wc10_2006 = 6  if bmi5_2006 == 3 & wc_high_bmi_2006 == 1

replace bmi_wc10_2006 = 7  if bmi5_2006 == 4 & wc_high_bmi_2006 == 0
replace bmi_wc10_2006 = 8  if bmi5_2006 == 4 & wc_high_bmi_2006 == 1

replace bmi_wc10_2006 = 9  if bmi5_2006 == 5 & wc_high_bmi_2006 == 0
replace bmi_wc10_2006 = 10 if bmi5_2006 == 5 & wc_high_bmi_2006 == 1

label define bmiwc10lbl ///
    1  "Normal, lower WC" ///
    2  "Normal, higher WC" ///
    3  "Overweight, lower WC" ///
    4  "Overweight, higher WC" ///
    5  "Obesity 1, lower WC" ///
    6  "Obesity 1, higher WC" ///
    7  "Obesity 2, lower WC" ///
    8  "Obesity 2, higher WC" ///
    9  "Obesity 3, lower WC" ///
    10 "Obesity 3, higher WC", replace

label values bmi_wc10_2006 bmiwc10lbl
label var bmi_wc10_2006 "Joint BMI and BMI-specific WC categories in 2006"

tab bmi_wc10_2006, missing
tab bmi5_2006 wc_high_bmi_2006, missing row

********************************************************************************
** 4E. CHECK COUNTS BY JOINT CATEGORY
********************************************************************************

display "------------------------------------------------------------"
display "Check: BMI-specific waist categories"
tab bmi5_2006 wc_high_bmi_2006, missing row
display "------------------------------------------------------------"

display "Check: 10-category joint BMI-WC exposure"
tab bmi_wc10_2006, missing
display "------------------------------------------------------------"

********************************************************************************
** 10-CATEGORY JOINT BMI AND BMI-SPECIFIC WC VARIABLE
********************************************************************************

capture drop bmi_wc10_2006
gen bmi_wc10_2006 = .

replace bmi_wc10_2006 = 1  if bmi5_2006==1 & wc_high_bmi_2006==0
replace bmi_wc10_2006 = 2  if bmi5_2006==1 & wc_high_bmi_2006==1
replace bmi_wc10_2006 = 3  if bmi5_2006==2 & wc_high_bmi_2006==0
replace bmi_wc10_2006 = 4  if bmi5_2006==2 & wc_high_bmi_2006==1
replace bmi_wc10_2006 = 5  if bmi5_2006==3 & wc_high_bmi_2006==0
replace bmi_wc10_2006 = 6  if bmi5_2006==3 & wc_high_bmi_2006==1
replace bmi_wc10_2006 = 7  if bmi5_2006==4 & wc_high_bmi_2006==0
replace bmi_wc10_2006 = 8  if bmi5_2006==4 & wc_high_bmi_2006==1
replace bmi_wc10_2006 = 9  if bmi5_2006==5 & wc_high_bmi_2006==0
replace bmi_wc10_2006 = 10 if bmi5_2006==5 & wc_high_bmi_2006==1

label define bmiwc10lbl ///
    1  "Normal, WC <80" ///
    2  "Normal, WC >=80" ///
    3  "Overweight, WC <90" ///
    4  "Overweight, WC >=90" ///
    5  "Obesity 1, WC <105" ///
    6  "Obesity 1, WC >=105" ///
    7  "Obesity 2, WC <115" ///
    8  "Obesity 2, WC >=115" ///
    9  "Obesity 3, WC <115" ///
    10 "Obesity 3, WC >=115", replace

label values bmi_wc10_2006 bmiwc10lbl
label var bmi_wc10_2006 "Joint BMI and BMI-specific WC categories in 2006"

tab bmi_wc10_2006 if sample_final==1, missing
tab bmi5_2006 wc_high_bmi_2006 if sample_final==1, missing
capture drop agecat_2006
gen agecat_2006 = .
replace agecat_2006 = 1 if r9agey_e >=50 & r9agey_e <60
replace agecat_2006 = 2 if r9agey_e >=60 & r9agey_e <70
replace agecat_2006 = 3 if r9agey_e >=70 & r9agey_e <.
label define agecatlbl 1 "50-59" 2 "60-69" 3 "70+", replace
label values agecat_2006 agecatlbl
label var agecat_2006 "Age group in 2006"

********************************************************************************
** 5. COMPLETE-CASE FLAG FOR TABLES AND MODELS
********************************************************************************

capture drop nmiss_tables_models cc_tables_models
egen nmiss_tables_models = rowmiss(bmi5_2006 bmi_wc10_2006 fail_diabetes fu_yrs ///
    r9agey_e RACE_ETHN totwealth_2006 marital_2006 education ///
    smoking_2006 alcohol_2006 physic_act_2006)

gen cc_tables_models = (nmiss_tables_models == 0)
label var cc_tables_models "Complete case for women-only HRS tables/models"

keep if cc_tables_models == 1
count
display "Women-only complete-case analytic sample = " r(N)

********************************************************************************
** 6. MODEL COVARIATE SETS AND WHI-STYLE OUTPUT STRUCTURE
********************************************************************************

global datadir "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HRS"
global outdir  "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HRS"
capture mkdir "$outdir"

global xlsx    "$outdir\HRS_Supplementary_Datasheet_Tables1_to_6.xlsx"
global mainlog "$outdir\HRS_MASTER_FULL_WHI_STYLE_DOFILE_LOG.txt"

capture program drop open_section_log
program define open_section_log
    args section
    capture log close
    capture log using "$outdir\HRS_`section'.txt", text replace
end

global COV_FULL c.r9agey_e i.RACE_ETHN i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006

global COV_RACE_STRAT c.r9agey_e i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006

global COV_AGE_STRAT c.r9agey_e i.RACE_ETHN i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006

* Keep only variables required for WHI-style HRS validation tables, models, tests, and figures.
* No additional analytic .dta files are saved from this point forward.
keep HHIDPN secu stratum kwgtr start_date exit_date fu_yrs fail_diabetes ///
     r9agey_e agecat_2006 RACE_ETHN marital_2006 education totwealth_2006 ///
     smoking_2006 alcohol_2006 physic_act_2006 bmi5_2006 bmi_wc10_2006 ///
     wc_high_bmi_2006 sample_final cc_tables_models

svyset secu [pweight=kwgtr], strata(stratum) vce(linearized) singleunit(centered)

capture log close
capture log using "$mainlog", text replace

********************************************************************************
** 7. TABLE 1: BASELINE CHARACTERISTICS BY BMI CATEGORY
********************************************************************************

open_section_log TABLE1

putexcel set "$xlsx", sheet("README") replace
putexcel A1="HRS supplementary datasheet: Tables 1 through 6"
putexcel A2="Women-only HRS validation analysis, 2006 baseline, incident diabetes follow-up through 2020."
putexcel A3="Cox models are limited to unadjusted and fully adjusted models, matching the requested simplified manuscript format."
putexcel A4="Fully adjusted covariates: age, race/ethnicity, marital status, education, wealth, smoking, alcohol consumption, and physical activity."
putexcel A5="Tables 5 and 6 use fully adjusted models overall and within age and race/ethnicity strata; interaction tests are provided in the same sheets."

putexcel set "$xlsx", sheet("Table1") modify
putexcel A1="Table 1. Demographic and lifestyle characteristics by body mass index in the HRS analytic sample"
putexcel A2="Survey design: secu/stratum with 2006 EFTF weight kwgtr."
putexcel A4="Characteristic" B4="Normal" C4="Overweight" D4="Obesity 1" E4="Obesity 2" F4="Obesity 3" G4="Design-based P value"

local row = 5

putexcel A`row' = "Unweighted N"

local cols B C D E F

forvalues b = 1/5 {
    quietly count if bmi5_2006 == `b'
    local col : word `b' of `cols'
    putexcel `col'`row' = (r(N))
}

local ++row

svy: mean r9agey_e, over(bmi5_2006)
putexcel A`row'="Age, years: mean by BMI category shown in log" G`row'="See log for svy: mean test output"
local ++row

foreach v in agecat_2006 RACE_ETHN marital_2006 education totwealth_2006 smoking_2006 alcohol_2006 physic_act_2006 {
    putexcel A`row'="`v': weighted row percentages and Pearson test shown in log"
    capture noisily svy: tab bmi5_2006 `v', row percent pearson
    local ++row
}

********************************************************************************
** 8. TABLE 2: INCIDENT CASES, PERSON-TIME, AND EXACT POISSON RATES
********************************************************************************

open_section_log TABLE2

putexcel set "$xlsx", sheet("Table2") modify
putexcel A1="Table 2. Incident diabetes cases, person-years, and incidence rates by BMI and BMI-specific waist circumference categories"
putexcel A3="Exposure" B3="Category" C3="Cases" D3="N" E3="Person-years" F3="Rate per 10,000 PY" G3="Lower 95% CI" H3="Upper 95% CI"

local row=4
foreach exp in bmi5_2006 bmi_wc10_2006 {
    levelsof `exp', local(levels)
    foreach lev of local levels {
        quietly count if `exp'==`lev'
        local n = r(N)
        quietly count if `exp'==`lev' & fail_diabetes==1
        local cases = r(N)
        quietly summarize fu_yrs if `exp'==`lev', meanonly
        local py = r(sum)
        local rate = (`cases'/`py')*10000
        if `cases' == 0 {
            local ll = 0
            local ul = (0.5*invchi2(2*(`cases'+1), .975)/`py')*10000
        }
        else {
            local ll = (0.5*invchi2(2*`cases', .025)/`py')*10000
            local ul = (0.5*invchi2(2*(`cases'+1), .975)/`py')*10000
        }
        local vl : value label `exp'
        local cat : label `vl' `lev'
        putexcel A`row'="`exp'" B`row'="`cat'" C`row'=`cases' D`row'=`n' ///
            E`row'=`py' F`row'=`rate' G`row'=`ll' H`row'=`ul'
        local ++row
    }
}

********************************************************************************
** 9. STSET FOR COX MODELS
********************************************************************************

open_section_log STSET

stset exit_date, failure(fail_diabetes==1) ///
    origin(time start_date) enter(time start_date) ///
    id(HHIDPN) scale(365.25)
stsum

********************************************************************************
** 10. TABLES 3-4: COX MODELS AND HARRELL'S C-STATISTICS
** Only unadjusted and fully adjusted models are exported.
********************************************************************************

capture program drop make_cox_table
program define make_cox_table
    syntax, EXPOSURE(name) SHEET(string)

    tempfile results
    postfile handle str24 table str30 model str40 exposure str100 category ///
        double HR LCL UCL P CSTAT N_EVENTS N_SUBJECTS using `results', replace

    foreach model in unadjusted full {
        if "`model'" == "unadjusted" local covars ""
        if "`model'" == "full"       local covars "$COV_FULL"

        quietly stcox ib1.`exposure' `covars'
        estimates store `sheet'_`model'
        quietly estat concordance
        capture local cstat = r(C)
        if _rc local cstat = .
        local nevents = e(N_fail)
        local nsubjects = e(N)

        levelsof `exposure' if e(sample), local(levels)
        foreach lev of local levels {
            if `lev' != 1 {
                capture quietly lincom `lev'.`exposure', hr
                if _rc == 0 {
                    local vl : value label `exposure'
                    if "`vl'" == "" local cat "`lev'"
                    else local cat : label `vl' `lev'
                    post handle ("`sheet'") ("`model'") ("`exposure'") ("`cat'") ///
                        (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`cstat') (`nevents') (`nsubjects')
                }
            }
        }

        di "=============================================================="
        di "`sheet' | `model' | exposure = `exposure'"
        estat concordance
        capture noisily estat phtest, detail
        estat ic
    }
    postclose handle

    preserve
        use `results', clear
        export excel using "$xlsx", sheet("`sheet'", replace) firstrow(variables)
    restore
end

open_section_log TABLE3
make_cox_table, exposure(bmi5_2006) sheet("Table3_BMI_Cox")

open_section_log TABLE4
make_cox_table, exposure(bmi_wc10_2006) sheet("Table4_BMIWC_Cox")

********************************************************************************
** 11. TABLE 5: FULLY ADJUSTED STRATIFIED COX MODELS FOR BMI CATEGORIES
********************************************************************************

capture program drop post_stratified_cox
program define post_stratified_cox
    syntax, EXPOSURE(name) SHEET(string)

    tempfile results
    postfile handle str24 table str30 stratum str80 subgroup str100 category ///
        double HR LCL UCL P CSTAT N_EVENTS N_SUBJECTS using `results', replace

    * Overall fully adjusted model.
    quietly stcox ib1.`exposure' $COV_FULL
    quietly estat concordance
    capture local cstat = r(C)
    if _rc local cstat = .
    local nevents=e(N_fail)
    local nsubjects=e(N)
    levelsof `exposure' if e(sample), local(levels)
    foreach lev of local levels {
        if `lev' != 1 {
            capture quietly lincom `lev'.`exposure', hr
            if _rc==0 {
                local vl : value label `exposure'
                if "`vl'" == "" local cat "`lev'"
                else local cat : label `vl' `lev'
                post handle ("`sheet'") ("Overall") ("All women") ("`cat'") ///
                    (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`cstat') (`nevents') (`nsubjects')
            }
        }
    }

    * Age strata, fully adjusted except no age-category term; continuous age retained.
    foreach s of numlist 1/3 {
        local sl : label agecatlbl `s'
        capture quietly stcox ib1.`exposure' $COV_AGE_STRAT if agecat_2006==`s'
        if _rc==0 {
            quietly estat concordance
            capture local cstat = r(C)
            if _rc local cstat = .
            local nevents=e(N_fail)
            local nsubjects=e(N)
            levelsof `exposure' if e(sample), local(levels)
            foreach lev of local levels {
                if `lev' != 1 {
                    capture quietly lincom `lev'.`exposure', hr
                    if _rc==0 {
                        local vl : value label `exposure'
                        if "`vl'" == "" local cat "`lev'"
                        else local cat : label `vl' `lev'
                        post handle ("`sheet'") ("Age") ("`sl'") ("`cat'") ///
                            (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`cstat') (`nevents') (`nsubjects')
                    }
                }
            }
        }
    }

    * Race/ethnicity strata; race/ethnicity covariate omitted within strata.
    levelsof RACE_ETHN, local(racelevels)
    foreach r of local racelevels {
        local rl "RACE_ETHN=`r'"
        capture quietly stcox ib1.`exposure' $COV_RACE_STRAT if RACE_ETHN==`r'
        if _rc==0 {
            quietly estat concordance
            capture local cstat = r(C)
            if _rc local cstat = .
            local nevents=e(N_fail)
            local nsubjects=e(N)
            levelsof `exposure' if e(sample), local(levels)
            foreach lev of local levels {
                if `lev' != 1 {
                    capture quietly lincom `lev'.`exposure', hr
                    if _rc==0 {
                        local vl : value label `exposure'
                        if "`vl'" == "" local cat "`lev'"
                        else local cat : label `vl' `lev'
                        post handle ("`sheet'") ("Race/ethnicity") ("`rl'") ("`cat'") ///
                            (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`cstat') (`nevents') (`nsubjects')
                    }
                }
            }
        }
    }

    postclose handle
    preserve
        use `results', clear
        export excel using "$xlsx", sheet("`sheet'", replace) firstrow(variables)
    restore
end

open_section_log TABLE5
post_stratified_cox, exposure(bmi5_2006) sheet("Table5_BMI_Full_Strat")

* Interaction tests for Table 5.
putexcel set "$xlsx", sheet("Table5_Interactions") modify
putexcel A1="Table 5 interaction tests: fully adjusted BMI models"
putexcel A3="Modifier" B3="df" C3="Wald chi-square" D3="P value"
local row=4
stcox ib1.bmi5_2006##i.agecat_2006 i.RACE_ETHN i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006
testparm i.bmi5_2006#i.agecat_2006
putexcel A`row' = "Age group" B`row' = (r(df)) C`row' = (r(chi2)) D`row' = (r(p))
local ++row
stcox ib1.bmi5_2006##i.RACE_ETHN c.r9agey_e i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006
testparm i.bmi5_2006#i.RACE_ETHN
putexcel A`row' = "Race/ethnicity" B`row' = (r(df)) C`row' = (r(chi2)) D`row' = (r(p))

********************************************************************************
** 12. TABLE 6: FULLY ADJUSTED STRATIFIED COX MODELS FOR BMI-SPECIFIC WC
********************************************************************************

open_section_log TABLE6
post_stratified_cox, exposure(bmi_wc10_2006) sheet("Table6_BMIWC_Full_Strat")

putexcel set "$xlsx", sheet("Table6_Interactions") modify
putexcel A1="Table 6 interaction tests: fully adjusted BMI-specific waist circumference models"
putexcel A3="Modifier" B3="df" C3="Wald chi-square" D3="P value"
local row=4
stcox ib1.bmi_wc10_2006##i.agecat_2006 i.RACE_ETHN i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006
testparm i.bmi_wc10_2006#i.agecat_2006
putexcel A`row' = "Age group" B`row' = (r(df)) C`row' = (r(chi2)) D`row' = (r(p))
local ++row
stcox ib1.bmi_wc10_2006##i.RACE_ETHN c.r9agey_e i.marital_2006 i.education ///
    i.totwealth_2006 i.smoking_2006 i.alcohol_2006 i.physic_act_2006
testparm i.bmi_wc10_2006#i.RACE_ETHN
putexcel A`row' = "Race/ethnicity" B`row' = (r(df)) C`row' = (r(chi2)) D`row' = (r(p))

********************************************************************************
** 13. FIGURE 2: KAPLAN-MEIER / FAILURE CURVE BY BMI CATEGORY
********************************************************************************

open_section_log FIGURE2
stset fu_yrs, failure(fail_diabetes==1) id(HHIDPN)
sts graph, by(bmi5_2006) failure ///
    title("HRS women: Incident diabetes by BMI category", size(small)) ///
    ytitle("Cumulative incidence of diabetes") ///
    xtitle("Years since 2006 baseline") xlabel(0(2)14) xscale(range(0 14)) ///
    yscale(range(0 0.5) noextend) ylabel(0(0.1)0.5, format(%3.1f)) ///
    risktable(0(2)14, size(vsmall)) ///
    legend(order(1 "Normal" 2 "Overweight" 3 "Obesity 1" 4 "Obesity 2" 5 "Obesity 3") rows(2) size(small) region(lstyle(none))) ///
    graphregion(margin(large)) plotregion(margin(medium))
graph save "$outdir\Figure2_HRS_Women_KM_BMI_diabetes.gph", replace
graph export "$outdir\Figure2_HRS_Women_KM_BMI_diabetes.png", replace width(2400)
graph export "$outdir\Figure2_HRS_Women_KM_BMI_diabetes.tif", replace width(2400)
sts test bmi5_2006, logrank
putexcel set "$xlsx", sheet("Figure2_Logrank_BMI") modify
putexcel A1="Figure 2 log-rank test: BMI category. Full output is in HRS_FIGURE2.txt."

********************************************************************************
** 14. FIGURE 3: KAPLAN-MEIER / FAILURE CURVE BY BMI-SPECIFIC WC CATEGORY
********************************************************************************

open_section_log FIGURE3
sts graph, by(bmi_wc10_2006) failure ///
    title("HRS women: Incident diabetes by BMI-specific waist circumference category", size(small)) ///
    ytitle("Cumulative incidence of diabetes") ///
    xtitle("Years since 2006 baseline") xlabel(0(2)14) xscale(range(0 14)) ///
    yscale(range(0 0.5) noextend) ylabel(0(0.1)0.5, format(%3.1f)) ///
    risktable(0(2)14, size(vsmall)) ///
    legend(cols(1) size(vsmall) position(3) ring(1) region(lstyle(none))) ///
    graphregion(margin(large)) plotregion(margin(medium))
graph save "$outdir\Figure3_HRS_Women_KM_BMIWC_diabetes.gph", replace
graph export "$outdir\Figure3_HRS_Women_KM_BMIWC_diabetes.png", replace width(2800)
graph export "$outdir\Figure3_HRS_Women_KM_BMIWC_diabetes.tif", replace width(2800)
sts test bmi_wc10_2006, logrank
putexcel set "$xlsx", sheet("Figure3_Logrank_BMIWC") modify
putexcel A1="Figure 3 log-rank test: BMI-specific waist circumference category. Full output is in HRS_FIGURE3.txt."

********************************************************************************
** 15. SURVEY-WEIGHTED COX MODELS AS DESIGN-BASED SENSITIVITY CHECKS
** Unadjusted and fully adjusted only.
********************************************************************************

open_section_log SURVEY_WEIGHTED_COX
stset exit_date, failure(fail_diabetes==1) origin(time start_date) enter(time start_date) id(HHIDPN) scale(365.25)
svy: stcox ib1.bmi5_2006
estimates store SVY_BMI_unadjusted
svy: stcox ib1.bmi5_2006 $COV_FULL
estimates store SVY_BMI_full
svy: stcox ib1.bmi_wc10_2006
estimates store SVY_BMIWC_unadjusted
svy: stcox ib1.bmi_wc10_2006 $COV_FULL
estimates store SVY_BMIWC_full

capture log close
********************************************************************************
* END: HRS WHI-style code. No final analytic .dta file is saved.
********************************************************************************
