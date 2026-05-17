********************************************************************************
* WHI BMI-WC AND INCIDENT DIABETES: FULL HRS-STYLE STATA DO FILE
* Central adiposity within BMI categories and incident diabetes in WHI women
*
* This do-file expands the translated WHI code to include:
*   - HRS-style sample flags and participant flowchart
*   - Excel output only for Flowchart, Table 1, and Table 2
*   - Exact Poisson incidence rates
*   - Tables 3 onward written to section-specific text logs only
*   - Training/test Cox models, Harrell's c-statistics
*   - AIC/BIC checks, proportional hazards tests, interaction tests
*   - Tables 5 and 6 stratified Cox models by age, race, and ethnicity
*   - Kaplan-Meier/failure curves and log-rank tests for Figures 2 and 3
*   - Separate log files for data management and each table/figure section
*
* A compact analytic .dta is saved after the flowchart exercise. Temporary files are used internally.
********************************************************************************

clear all
set more off
set linesize 255
set maxvar 30000
version 18

********************************************************************************
* 0. PATHS AND OUTPUT FILES
********************************************************************************

global datadir "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\WHI"
global outdir  "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\WHI"

capture mkdir "$outdir"

global xlsx "$outdir\WHI_Supplementary_Datasheet_Tables1_to_6.xlsx"
global mainlog "$outdir\WHI_MASTER_FULL_HRS_STYLE_DOFILE_LOG.txt"

capture log close
capture log using "$mainlog", text replace

capture program drop open_section_log
program define open_section_log
    args section
    capture log close
    capture log using "$outdir\WHI_`section'.txt", text replace
end

********************************************************************************
* 1. LABELS
********************************************************************************

label define obesityf 1 "Underweight (<18.5)" 2 "Normal (18.5-24.9)" 3 "Overweight (25.0-29.9)" 4 "Obesity I (30.0-34.9)" 5 "Obesity II (35.0-39.9)" 6 "Extreme Obesity III (>=40)", replace
label define bmi5lbl 1 "Normal" 2 "Overweight" 3 "Obesity 1" 4 "Obesity 2" 5 "Obesity 3", replace
label define agerf 1 "50-59" 2 "60-69" 3 "70-79", replace
label define racebrf 1 "African American" 2 "White" 3 "Other" 4 "Mixed", replace
label define ethnicbrf 0 "Non-Hispanic" 1 "Hispanic", replace
label define marital_brf 1 "Married/Partnered" 2 "Single" 3 "Divorced" 4 "Widowed", replace
label define educbrf 1 "Less than high school" 2 "High school" 3 "Some college" 4 "Completed college or higher", replace
label define occupf 1 "Managerial/professional" 2 "Technical/sales/administrative" 3 "Service/labor" 4 "Homemaker" 5 "Other" 6 "Not working/retired/disabled" 99 "Missing", replace
label define incomebrf 1 "< $20,000" 2 "$20,000-$49,999" 3 "$50,000-$99,999" 4 ">=$100,000" 99 "Missing", replace
label define smoking_brf 1 "Never smoker" 2 "Past smoker" 3 "Current smoker", replace
label define alcohol_brf 1 "Non-Drinker" 2 "Former Drinker" 3 "< 1 drink/week" 4 ">= 1 drink/week", replace
label define bmiwc10lbl 1 "Normal, WC <80" 2 "Normal, WC >=80" 3 "Overweight, WC <90" 4 "Overweight, WC >=90" 5 "Obesity 1, WC <105" 6 "Obesity 1, WC >=105" 7 "Obesity 2, WC <115" 8 "Obesity 2, WC >=115" 9 "Obesity 3, WC <115" 10 "Obesity 3, WC >=115", replace
label define splitlbl 0 "Test 30%" 1 "Training 70%", replace

********************************************************************************
* 2. DATA MANAGEMENT: IMPORT, HARMONIZE, MERGE, FLOWCHART, KEEP VARIABLES
********************************************************************************

open_section_log DATA_MANAGEMENT

tempfile bmiwc dem raceeth marital_occ lifestyle hei f2 f134 prev self mrc src follow diab analytic flow

* BMI and waist circumference from WHI F80, enrollment visit.
import sas using "$datadir\f80_ctos_inv.sas7bdat", clear
keep if F80VTYP == 1
keep ID F80DAYS F80VTYP F80VY F80VCLO F80EXPC BMI BMIC WAIST
rename ID HHIDPN
label values BMIC obesityf
label var BMI   "Body mass index at WHI baseline"
label var BMIC  "SAS BMI category at WHI baseline"
label var WAIST "Waist circumference at WHI baseline"

recode BMIC (2=1) (3=2) (4=3) (5=4) (6=5) (1=.) (else=.), gen(bmi5_base)
label values bmi5_base bmi5lbl
label var bmi5_base "BMI category at WHI baseline, excluding underweight"

gen byte wc_high_bmi_base = .
replace wc_high_bmi_base = 0 if BMIC == 2 & WAIST <  80
replace wc_high_bmi_base = 1 if BMIC == 2 & WAIST >= 80 & WAIST < .
replace wc_high_bmi_base = 0 if BMIC == 3 & WAIST <  90
replace wc_high_bmi_base = 1 if BMIC == 3 & WAIST >= 90 & WAIST < .
replace wc_high_bmi_base = 0 if BMIC == 4 & WAIST < 105
replace wc_high_bmi_base = 1 if BMIC == 4 & WAIST >=105 & WAIST < .
replace wc_high_bmi_base = 0 if BMIC == 5 & WAIST < 115
replace wc_high_bmi_base = 1 if BMIC == 5 & WAIST >=115 & WAIST < .
replace wc_high_bmi_base = 0 if BMIC == 6 & WAIST < 115
replace wc_high_bmi_base = 1 if BMIC == 6 & WAIST >=115 & WAIST < .

gen byte bmi_wc10_base = .
replace bmi_wc10_base = 1  if bmi5_base == 1 & wc_high_bmi_base == 0
replace bmi_wc10_base = 2  if bmi5_base == 1 & wc_high_bmi_base == 1
replace bmi_wc10_base = 3  if bmi5_base == 2 & wc_high_bmi_base == 0
replace bmi_wc10_base = 4  if bmi5_base == 2 & wc_high_bmi_base == 1
replace bmi_wc10_base = 5  if bmi5_base == 3 & wc_high_bmi_base == 0
replace bmi_wc10_base = 6  if bmi5_base == 3 & wc_high_bmi_base == 1
replace bmi_wc10_base = 7  if bmi5_base == 4 & wc_high_bmi_base == 0
replace bmi_wc10_base = 8  if bmi5_base == 4 & wc_high_bmi_base == 1
replace bmi_wc10_base = 9  if bmi5_base == 5 & wc_high_bmi_base == 0
replace bmi_wc10_base = 10 if bmi5_base == 5 & wc_high_bmi_base == 1
label values bmi_wc10_base bmiwc10lbl
label var bmi_wc10_base "Joint BMI and BMI-specific waist circumference categories"

keep HHIDPN BMI BMIC WAIST bmi5_base wc_high_bmi_base bmi_wc10_base
save `bmiwc', replace

* Age, education, income. This file is used as the master ID frame.
import sas using "$datadir\dem_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN AGE EDUC INCOME

gen byte AGE_BR = .
replace AGE_BR = 1 if AGE >= 50 & AGE < 60
replace AGE_BR = 2 if AGE >= 60 & AGE < 70
replace AGE_BR = 3 if AGE >= 70 & AGE < 80
label values AGE_BR agerf
label var AGE_BR "Age group at WHI baseline"

recode EDUC (1/4=1) (5=2) (6/7=3) (8/11=4) (else=.), gen(EDUC_BR)
label values EDUC_BR educbrf
label var EDUC_BR "Education"

recode INCOME (1/2=1) (3/4=2) (5/6=3) (7/8=4) (9=99) (.=99), gen(INCOME_BR)
label values INCOME_BR incomebrf
label var INCOME_BR "Household income"

keep HHIDPN AGE AGE_BR EDUC_BR INCOME_BR
save `dem', replace

* Race and ethnicity.
import sas using "$datadir\f41_imputed_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN RACENIH ETHNICNIH
rename RACENIH RACE
rename ETHNICNIH ETHNICITY

gen byte RACE_BR = .
replace RACE_BR = 1 if RACE == 4
replace RACE_BR = 2 if RACE == 5
replace RACE_BR = 3 if inlist(RACE,1,2,3)
replace RACE_BR = 4 if RACE == 6
label values RACE_BR racebrf
label var RACE_BR "Race"

gen byte ETHNICITY_BR = .
replace ETHNICITY_BR = ETHNICITY if inlist(ETHNICITY,0,1)
label values ETHNICITY_BR ethnicbrf
label var ETHNICITY_BR "Ethnicity"

keep HHIDPN RACE RACE_BR ETHNICITY ETHNICITY_BR
save `raceeth', replace

* Marital status and occupation.
import sas using "$datadir\f20_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN MARITAL EMPLOYED JOBHMMKR JOBMANGR JOBTECH JOBSERV JOBLABOR JOBOTH NOTWRK RETIRED DISABLED

gen byte MARITAL_BR = .
replace MARITAL_BR = 1 if inlist(MARITAL,4,5)
replace MARITAL_BR = 2 if MARITAL == 1
replace MARITAL_BR = 3 if MARITAL == 2
replace MARITAL_BR = 4 if MARITAL == 3
label values MARITAL_BR marital_brf
label var MARITAL_BR "Marital status"

gen byte OCCUPATION = 99
replace OCCUPATION = 1 if EMPLOYED == 1 & JOBMANGR == 1
replace OCCUPATION = 2 if JOBTECH == 1
replace OCCUPATION = 3 if JOBSERV == 1 | JOBLABOR == 1
replace OCCUPATION = 4 if JOBHMMKR == 1
replace OCCUPATION = 5 if JOBOTH == 1
replace OCCUPATION = 6 if NOTWRK == 1 | RETIRED == 1 | DISABLED == 1
label values OCCUPATION occupf
label var OCCUPATION "Occupation"

keep HHIDPN MARITAL_BR OCCUPATION
save `marital_occ', replace

* Smoking, alcohol, physical activity.
import sas using "$datadir\f34_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN SMOKING ALCOHOL TEXPWK

gen byte SMOKING_BR = SMOKING + 1 if !missing(SMOKING)
label values SMOKING_BR smoking_brf
label var SMOKING_BR "Smoking status"

gen byte ALCOHOL_BR = .
replace ALCOHOL_BR = 1 if ALCOHOL == 1
replace ALCOHOL_BR = 2 if ALCOHOL == 2
replace ALCOHOL_BR = 3 if inlist(ALCOHOL,3,4)
replace ALCOHOL_BR = 4 if inlist(ALCOHOL,5,6)
label values ALCOHOL_BR alcohol_brf
label var ALCOHOL_BR "Alcohol consumption"

gen double PHYSICAL_ACTIVITY_MET = TEXPWK
label var PHYSICAL_ACTIVITY_MET "Physical activity, MET-hours/week"

keep HHIDPN SMOKING_BR ALCOHOL_BR PHYSICAL_ACTIVITY_MET
save `lifestyle', replace

* HEI-2015, baseline F60VY=0.
import sas using "$datadir\f60_hei_2015_inv.sas7bdat", clear
rename ID HHIDPN
keep if F60VY == 0
keep HHIDPN HEI2015_TOTAL_SCORE
label var HEI2015_TOTAL_SCORE "Healthy Eating Index-2015 total score"
save `hei', replace

* Baseline prevalent diabetes.
import sas using "$datadir\f2_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN DIAB DIABAGE DIABCOMA DIABNW DIABPILL DIABTRT
save `f2', replace

import sas using "$datadir\f134_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN F134DIAB F134DAYS
save `f134', replace

use `f2', clear
merge 1:1 HHIDPN using `f134', nogen

gen byte PREVALENT_DIABETES = 0
replace PREVALENT_DIABETES = 1 if DIAB == 1 | DIABCOMA == 1 | DIABNW == 1 | DIABPILL == 1 | DIABTRT == 1
label var PREVALENT_DIABETES "Prevalent diabetes at WHI baseline"
keep HHIDPN PREVALENT_DIABETES
save `prev', replace

* Incident diabetes and censoring from WHI outcome files.
import sas using "$datadir\outc_self_ctos_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN F33DIABINSULIN F33DIABPILLS F33DIABDIETEX F33DIABTX F33DIABINSULINDY F33DIABPILLSDY F33DIABDIETEXDY F33DIABTXDY
rename F33DIABINSULINDY F33DIABINSULINDY_SELF
rename F33DIABPILLSDY   F33DIABPILLSDY_SELF
rename F33DIABDIETEXDY  F33DIABDIETEXDY_SELF
rename F33DIABTXDY      F33DIABTXDY_SELF
save `self', replace

import sas using "$datadir\outc_self_x2_mrc_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN F33DIABDIEX F33DIABDIEXDY F33DIABINSULIN F33DIABINSULINDY F33DIABPILLS F33DIABPILLSDY F33DIABTX F33DIABTXDY
rename F33DIABDIEXDY    F33DIABDIEXDY_MRC
rename F33DIABINSULINDY F33DIABINSULINDY_MRC
rename F33DIABPILLSDY   F33DIABPILLSDY_MRC
rename F33DIABTXDY      F33DIABTXDY_MRC
save `mrc', replace

import sas using "$datadir\outc_self_x2_src_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN F33DIABDIEX F33DIABDIEXDY F33DIABINSULIN F33DIABINSULINDY F33DIABPILLS F33DIABPILLSDY F33DIABTX F33DIABTXDY
rename F33DIABDIEXDY    F33DIABDIEXDY_SRC
rename F33DIABINSULINDY F33DIABINSULINDY_SRC
rename F33DIABPILLSDY   F33DIABPILLSDY_SRC
rename F33DIABTXDY      F33DIABTXDY_SRC
save `src', replace

import sas using "$datadir\outc_ct_os_inv.sas7bdat", clear
rename ID HHIDPN
keep HHIDPN ENDFOLLOWDY DEATH DEATHDY
save `follow', replace

use `prev', clear
merge 1:1 HHIDPN using `self', nogen
merge 1:1 HHIDPN using `mrc', nogen
merge 1:1 HHIDPN using `src', nogen
merge 1:1 HHIDPN using `follow', nogen

egen double DIAB_EVENT_DAY = rowmin(F33DIABDIETEXDY_SELF F33DIABINSULINDY_SELF F33DIABPILLSDY_SELF F33DIABTXDY_SELF F33DIABDIEXDY_MRC F33DIABINSULINDY_MRC F33DIABPILLSDY_MRC F33DIABTXDY_MRC F33DIABDIEXDY_SRC F33DIABINSULINDY_SRC F33DIABPILLSDY_SRC F33DIABTXDY_SRC)
egen double CENSOR_DAY = rowmin(DEATHDY ENDFOLLOWDY)

gen byte INCIDENT_DIABETES = .
gen double TTE_DIABETES_DAYS = .
replace INCIDENT_DIABETES = 1 if PREVALENT_DIABETES == 0 & !missing(DIAB_EVENT_DAY) & !missing(CENSOR_DAY) & DIAB_EVENT_DAY <= CENSOR_DAY
replace TTE_DIABETES_DAYS = DIAB_EVENT_DAY if INCIDENT_DIABETES == 1
replace INCIDENT_DIABETES = 0 if PREVALENT_DIABETES == 0 & missing(INCIDENT_DIABETES) & !missing(CENSOR_DAY)
replace TTE_DIABETES_DAYS = CENSOR_DAY if INCIDENT_DIABETES == 0

gen double fu_yrs = TTE_DIABETES_DAYS / 365.25
label var INCIDENT_DIABETES "Incident diabetes"
label var fu_yrs "Years from WHI baseline to diabetes/censoring"

keep HHIDPN PREVALENT_DIABETES INCIDENT_DIABETES TTE_DIABETES_DAYS DIAB_EVENT_DAY CENSOR_DAY fu_yrs DEATH DEATHDY ENDFOLLOWDY
save `diab', replace

* Merge master analytic file using DEM as the master to support participant flow.
use `dem', clear
merge 1:1 HHIDPN using `bmiwc', nogen
merge 1:1 HHIDPN using `raceeth', nogen
merge 1:1 HHIDPN using `marital_occ', nogen
merge 1:1 HHIDPN using `lifestyle', nogen
merge 1:1 HHIDPN using `hei', nogen
merge 1:1 HHIDPN using `diab', nogen

capture drop sample_step0 sample_step1 sample_step2 sample_step3 sample_step4 sample_step5 sample_final nmiss_cov

gen byte sample_step0 = 1
label var sample_step0 "All WHI participants in demographic file"

gen byte sample_step1 = (sample_step0 == 1 & PREVALENT_DIABETES == 0)
label var sample_step1 "No self-reported history of diabetes at enrollment"

gen byte sample_step2 = (sample_step1 == 1 & !missing(BMI, WAIST, bmi5_base, bmi_wc10_base))
label var sample_step2 "Complete BMI and waist circumference exposure data"

gen byte sample_step3 = (sample_step2 == 1 & BMI >= 18.5 & BMI < .)
label var sample_step3 "BMI >=18.5 kg/m2; underweight excluded"

egen byte nmiss_cov = rowmiss(AGE AGE_BR RACE_BR ETHNICITY_BR MARITAL_BR EDUC_BR OCCUPATION INCOME_BR SMOKING_BR ALCOHOL_BR HEI2015_TOTAL_SCORE PHYSICAL_ACTIVITY_MET)
gen byte sample_step4 = (sample_step3 == 1 & nmiss_cov == 0)
label var sample_step4 "Complete selected demographic, socioeconomic, and lifestyle covariates"

gen byte sample_step5 = (sample_step4 == 1 & TTE_DIABETES_DAYS > 365.25 & !missing(INCIDENT_DIABETES, fu_yrs))
label var sample_step5 "Follow-up >12 months and valid diabetes time"

gen byte sample_final = sample_step5
label var sample_final "Final WHI analytic sample"

********************************************************************************
* Flowchart dataset and Excel sheet: counts only, then save analytic .dta
********************************************************************************

preserve
    tempfile flowcounts

    count if sample_step0 == 1
    local n0 = r(N)
    count if sample_step1 == 1
    local n1 = r(N)
    count if sample_step2 == 1
    local n2 = r(N)
    count if sample_step3 == 1
    local n3 = r(N)
    count if sample_step4 == 1
    local n4 = r(N)
    count if sample_step5 == 1
    local n5 = r(N)

    clear
    set obs 6
    gen byte step = _n - 1
    gen str120 criterion = ""
    gen double n = .
    gen double excluded_from_previous = .

    replace criterion = "All WHI participants in demographic file" in 1
    replace criterion = "No self-reported history of diabetes at enrollment" in 2
    replace criterion = "Complete BMI and waist circumference exposure data" in 3
    replace criterion = "BMI >=18.5 kg/m2; underweight excluded" in 4
    replace criterion = "Complete selected demographic, socioeconomic, and lifestyle covariates" in 5
    replace criterion = "Follow-up >12 months and valid diabetes time" in 6

    replace n = `n0' in 1
    replace n = `n1' in 2
    replace n = `n2' in 3
    replace n = `n3' in 4
    replace n = `n4' in 5
    replace n = `n5' in 6

    replace excluded_from_previous = .              in 1
    replace excluded_from_previous = `n0' - `n1'   in 2
    replace excluded_from_previous = `n1' - `n2'   in 3
    replace excluded_from_previous = `n2' - `n3'   in 4
    replace excluded_from_previous = `n3' - `n4'   in 5
    replace excluded_from_previous = `n4' - `n5'   in 6

    label var step "Flowchart step"
    label var criterion "Inclusion/exclusion stage"
    label var n "Participants retained"
    label var excluded_from_previous "Excluded from previous step"
    format n excluded_from_previous %12.0fc

    save "$outdir\WHI_Flowchart_Counts.dta", replace

    capture confirm file "$xlsx"
    if _rc == 0 {
        export excel using "$xlsx", sheet("Flowchart") firstrow(variables) sheetreplace
    }
    else {
        export excel using "$xlsx", sheet("Flowchart") firstrow(variables) replace
    }
restore

********************************************************************************
* Keep final analytic sample and save compact analytic .dta
********************************************************************************

keep if sample_final == 1
keep HHIDPN AGE AGE_BR RACE_BR ETHNICITY_BR MARITAL_BR EDUC_BR OCCUPATION ///
     INCOME_BR SMOKING_BR ALCOHOL_BR HEI2015_TOTAL_SCORE PHYSICAL_ACTIVITY_MET ///
     BMI BMIC WAIST bmi5_base wc_high_bmi_base bmi_wc10_base ///
     PREVALENT_DIABETES INCIDENT_DIABETES fu_yrs TTE_DIABETES_DAYS ///
     DIAB_EVENT_DAY CENSOR_DAY DEATH DEATHDY ENDFOLLOWDY ///
     sample_step0 sample_step1 sample_step2 sample_step3 sample_step4 ///
     sample_step5 sample_final

rename INCIDENT_DIABETES fail_diabetes
label var fail_diabetes "Incident diabetes"

drop if missing(HHIDPN, fu_yrs, fail_diabetes, bmi5_base, bmi_wc10_base)
drop if fu_yrs <= 0

stset fu_yrs, failure(fail_diabetes == 1) id(HHIDPN) exit(time 29)
stsum

gen double py_stset = _t - _t0 if _st == 1
label var py_stset "Person-years after stset, truncated at 29 years"

sort HHIDPN
set seed 1234
gen double u_split = runiform() if _st == 1
gen byte train70 = .
replace train70 = 1 if _st == 1 & u_split < 0.70
replace train70 = 0 if _st == 1 & u_split >= 0.70
label values train70 splitlbl

save "$outdir\WHI_ANALYTIC_AFTER_FLOWCHART_COMPACT.dta", replace
save `analytic', replace

capture log close

********************************************************************************
* 3. TABLE 1: BASELINE CHARACTERISTICS BY BMI CATEGORY
********************************************************************************

open_section_log TABLE1
use `analytic', clear

capture program drop post_table1_cont
program define post_table1_cont
    args var labelname handle
    regress `var' i.bmi5_base if _st == 1
    testparm i.bmi5_base
    local p = r(p)
    local cells ""
    forvalues b=1/5 {
        summarize `var' if _st == 1 & bmi5_base == `b'
        local mean = r(mean)
        local sd = r(sd)
        local cell : display %9.2f `mean' " ± " %9.2f `sd'
        local cells `"`cells' ("`cell'")"'
    }
    post `handle' ("`labelname'") ("Mean ± SD") `cells' (`p')
end

capture program drop post_table1_cat
program define post_table1_cat
    args var labelname handle
    tab `var' bmi5_base if _st == 1, chi2
    local p = r(p)
    levelsof `var' if _st == 1, local(levels)
    local first = 1
    foreach lev of local levels {
        local vl : value label `var'
        if "`vl'" != "" local levlab : label `vl' `lev'
        else local levlab "`lev'"
        local cells ""
        forvalues b=1/5 {
            count if _st == 1 & bmi5_base == `b'
            local denom = r(N)
            count if _st == 1 & bmi5_base == `b' & `var' == `lev'
            local num = r(N)
            local pct = 100*`num'/`denom'
            local cell : display %12.0fc `num' " (" %5.2f `pct' ")"
            local cells `"`cells' ("`cell'")"'
        }
        if `first' == 1 {
            post `handle' ("`labelname'") ("`levlab'") `cells' (`p')
            local first = 0
        }
        else {
            post `handle' ("`labelname'") ("`levlab'") `cells' (.)
        }
    }
end

tempfile table1
postfile table1h str60 variable str60 level str30 normal str30 overweight str30 obesity1 str30 obesity2 str30 obesity3 double pvalue using `table1', replace

post_table1_cont AGE "Age (years)" table1h
post_table1_cat AGE_BR "Age group" table1h
post_table1_cat RACE_BR "Race" table1h
post_table1_cat ETHNICITY_BR "Ethnicity" table1h
post_table1_cat MARITAL_BR "Marital status" table1h
post_table1_cat EDUC_BR "Education" table1h
post_table1_cat OCCUPATION "Occupation" table1h
post_table1_cat INCOME_BR "Household income" table1h
post_table1_cat SMOKING_BR "Smoking status" table1h
post_table1_cat ALCOHOL_BR "Alcohol consumption" table1h
post_table1_cont HEI2015_TOTAL_SCORE "Healthy Eating Index-2015" table1h
post_table1_cont PHYSICAL_ACTIVITY_MET "Physical activity, MET-hours/week" table1h
postclose table1h

preserve
    use `table1', clear
    export excel using "$xlsx", sheet("Table1") firstrow(variables) sheetreplace
restore

capture log close

********************************************************************************
* 4. TABLE 2: CASES, PERSON-YEARS, EXACT POISSON RATES
********************************************************************************

open_section_log TABLE2
use `analytic', clear

tempfile table2
postfile t2h str30 exposure str70 category double cases n person_years rate_per_10000py lcl ucl using `table2', replace

foreach exp in bmi5_base bmi_wc10_base {
    levelsof `exp' if _st == 1, local(levels)
    foreach lev of local levels {
        count if _st == 1 & `exp' == `lev'
        local n = r(N)
        count if _st == 1 & `exp' == `lev' & fail_diabetes == 1
        local cases = r(N)
        summarize py_stset if _st == 1 & `exp' == `lev', meanonly
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
        post t2h ("`exp'") ("`cat'") (`cases') (`n') (`py') (`rate') (`ll') (`ul')
    }
}
postclose t2h

preserve
    use `table2', clear
    export excel using "$xlsx", sheet("Table2") firstrow(variables) sheetreplace
restore

capture log close


********************************************************************************
* 5. COX MODEL PROGRAMS FOR TABLES 3-6 AND CONCORDANCE
*    LOG-ONLY VERSION FOR TABLES 3 ONWARD:
*    - The active dataset is reduced before Table 3 onward.
*    - Separate ultra-compact tempfiles are created for BMI, BMI-WC, and KM analyses.
*    - No large analytic dataset is carried into Cox sections.
*    - Tables 3-6, concordance, interactions, AIC/BIC, and KM tests are printed to logs only.
********************************************************************************

tempfile coxbase cox_bmi cox_bmiwc cox_km

use `analytic', clear

capture confirm variable py_stset
if _rc {
    gen double py_stset = _t - _t0 if _st == 1
    label var py_stset "Person-years after stset, truncated at 29 years"
}

* Hard reduction before all Cox sections. This should drop the active dataset to the
* variables needed from Tables 3 onward only.
keep HHIDPN _st _d _t _t0 py_stset fail_diabetes ///
     bmi5_base bmi_wc10_base train70 ///
     AGE AGE_BR RACE_BR ETHNICITY_BR MARITAL_BR EDUC_BR OCCUPATION INCOME_BR ///
     SMOKING_BR ALCOHOL_BR HEI2015_TOTAL_SCORE PHYSICAL_ACTIVITY_MET
keep if _st == 1
compress
describe
save `coxbase', replace

* Ultra-compact model-specific files. These are the files used by Tables 3 onward.
preserve
    keep HHIDPN _st _d _t _t0 fail_diabetes bmi5_base train70 ///
         AGE AGE_BR RACE_BR ETHNICITY_BR MARITAL_BR EDUC_BR OCCUPATION INCOME_BR ///
         SMOKING_BR ALCOHOL_BR HEI2015_TOTAL_SCORE PHYSICAL_ACTIVITY_MET
    compress
    save `cox_bmi', replace
restore

preserve
    keep HHIDPN _st _d _t _t0 fail_diabetes bmi_wc10_base train70 ///
         AGE AGE_BR RACE_BR ETHNICITY_BR MARITAL_BR EDUC_BR OCCUPATION INCOME_BR ///
         SMOKING_BR ALCOHOL_BR HEI2015_TOTAL_SCORE PHYSICAL_ACTIVITY_MET
    compress
    save `cox_bmiwc', replace
restore

preserve
    keep HHIDPN _st _d _t _t0 fail_diabetes bmi5_base bmi_wc10_base
    compress
    save `cox_km', replace
restore

* Fully adjusted covariate sets. Keep these exactly aligned with manuscript/Table definitions.
global COV_FULL c.AGE i.RACE_BR i.ETHNICITY_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET
global COV_NO_RACE c.AGE i.ETHNICITY_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET
global COV_NO_ETHN c.AGE i.RACE_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET

* Speed switches.
* Concordance is needed for Tables 3-6, so keep this as 1 unless only debugging.
* Stepwise model selection is not needed for the simplified manuscript tables and is very slow in WHI.
global RUN_AICBIC      1
global RUN_STEPWISE    0

tempfile table3 table4 conc tests aic table5 table6 kmtests
postfile cnh str30 table str45 sample str45 model str40 exposure double c_stat se_c somers_d using `conc', replace
postfile testh str30 table str45 exposure str45 modifier double chi2 df pvalue using `tests', replace
postfile aich str30 table str45 sample str45 model str40 exposure double N ll k AIC BIC using `aic', replace

capture program drop model_stats_post
program define model_stats_post
    syntax, TABLE(string) SAMPLE(string) MODEL(string) EXPOSURE(string)

    local c = .
    local sec = .
    local d = .

    local N = e(N)
    local ll = e(ll)
    local k = colsof(e(b))
    local aic = .
    local bic = .
    if "$RUN_AICBIC" == "1" {
        local aic = -2*`ll' + 2*`k'
        local bic = -2*`ll' + ln(`N')*`k'
    }
    post aich ("`table'") ("`sample'") ("`model'") ("`exposure'") (`N') (`ll') (`k') (`aic') (`bic')
end

capture program drop post_cox_hr_fast
program define post_cox_hr_fast
    syntax, HANDLE(name) TABLE(string) SAMPLE(string) MODEL(string) EXPOSURE(name) [COVARS(string) IFCOND(string)]

    if "`ifcond'" == "" local ifcond "1"

    display " "
    display "------------------------------------------------------------"
    display "`table' | `sample' | `model' | exposure: `exposure'"
    display "if condition: `ifcond'"
    display "------------------------------------------------------------"

    stcox ib1.`exposure' `covars' if `ifcond', vce(robust)
    model_stats_post, table("`table'") sample("`sample'") model("`model'") exposure("`exposure'")

    levelsof `exposure' if e(sample), local(levels)
    foreach lev of local levels {
        local vl : value label `exposure'
        local lab : label `vl' `lev'
        if "`lab'" == "" local lab "`lev'"

        if `lev' == 1 {
            post `handle' ("`table'") ("`sample'") ("`model'") ("`exposure'") ("`lab'") (1) (.) (.) (.)
        }
        else {
            capture noisily lincom `lev'.`exposure', hr
            if _rc == 0 {
                post `handle' ("`table'") ("`sample'") ("`model'") ("`exposure'") ("`lab'") (r(estimate)) (r(lb)) (r(ub)) (r(p))
            }
        }
    }
end

********************************************************************************
* 6. TABLE 3: BMI COX MODELS, OVERALL/TRAINING/TEST SAMPLES
********************************************************************************

open_section_log TABLE3_COX_BMI
use `cox_bmi', clear
describe

postfile t3h str30 table str45 sample str45 model str40 exposure str80 category double HR LCL UCL pvalue using `table3', replace

post_cox_hr_fast, handle(t3h) table("Table3") sample("Overall") model("Unadjusted") exposure(bmi5_base)
post_cox_hr_fast, handle(t3h) table("Table3") sample("Overall") model("Adjusted full") exposure(bmi5_base) covars("$COV_FULL")

post_cox_hr_fast, handle(t3h) table("Table3") sample("Training 70%") model("Unadjusted") exposure(bmi5_base) ifcond("train70 == 1")
post_cox_hr_fast, handle(t3h) table("Table3") sample("Training 70%") model("Adjusted full") exposure(bmi5_base) covars("$COV_FULL") ifcond("train70 == 1")

post_cox_hr_fast, handle(t3h) table("Table3") sample("Test 30%") model("Unadjusted") exposure(bmi5_base) ifcond("train70 == 0")
post_cox_hr_fast, handle(t3h) table("Table3") sample("Test 30%") model("Adjusted full") exposure(bmi5_base) covars("$COV_FULL") ifcond("train70 == 0")
postclose t3h

use `table3', clear
display "Table 3 posted HR summary"
list, sepby(sample model) noobs abbreviate(24)

capture log close

********************************************************************************
* 7. TABLE 4: BMI-SPECIFIC WC COX MODELS, OVERALL/TRAINING/TEST SAMPLES
********************************************************************************

open_section_log TABLE4_COX_BMIWC
use `cox_bmiwc', clear
describe

postfile t4h str30 table str45 sample str45 model str40 exposure str80 category double HR LCL UCL pvalue using `table4', replace

post_cox_hr_fast, handle(t4h) table("Table4") sample("Overall") model("Unadjusted") exposure(bmi_wc10_base)
post_cox_hr_fast, handle(t4h) table("Table4") sample("Overall") model("Adjusted full") exposure(bmi_wc10_base) covars("$COV_FULL")

post_cox_hr_fast, handle(t4h) table("Table4") sample("Training 70%") model("Unadjusted") exposure(bmi_wc10_base) ifcond("train70 == 1")
post_cox_hr_fast, handle(t4h) table("Table4") sample("Training 70%") model("Adjusted full") exposure(bmi_wc10_base) covars("$COV_FULL") ifcond("train70 == 1")

post_cox_hr_fast, handle(t4h) table("Table4") sample("Test 30%") model("Unadjusted") exposure(bmi_wc10_base) ifcond("train70 == 0")
post_cox_hr_fast, handle(t4h) table("Table4") sample("Test 30%") model("Adjusted full") exposure(bmi_wc10_base) covars("$COV_FULL") ifcond("train70 == 0")
postclose t4h

use `table4', clear
display "Table 4 posted HR summary"
list, sepby(sample model) noobs abbreviate(24)

capture log close

********************************************************************************
* 8. TABLE 5: STRATIFIED FULLY ADJUSTED COX MODELS FOR BMI
********************************************************************************

open_section_log TABLE5_STRATIFIED_BMI
use `cox_bmi', clear
describe

postfile t5h str30 table str45 stratum str45 subgroup str40 exposure str80 category double HR LCL UCL pvalue using `table5', replace

post_cox_hr_fast, handle(t5h) table("Table5") sample("Overall") model("Overall") exposure(bmi5_base) covars("$COV_FULL")

forvalues a=1/3 {
    local lab : label agerf `a'
    post_cox_hr_fast, handle(t5h) table("Table5") sample("Age") model("`lab'") exposure(bmi5_base) covars("$COV_FULL") ifcond("AGE_BR == `a'")
}
forvalues r=1/4 {
    local lab : label racebrf `r'
    post_cox_hr_fast, handle(t5h) table("Table5") sample("Race") model("`lab'") exposure(bmi5_base) covars("$COV_NO_RACE") ifcond("RACE_BR == `r'")
}
forvalues e=0/1 {
    local lab : label ethnicbrf `e'
    post_cox_hr_fast, handle(t5h) table("Table5") sample("Ethnicity") model("`lab'") exposure(bmi5_base) covars("$COV_NO_ETHN") ifcond("ETHNICITY_BR == `e'")
}
postclose t5h

* Interaction tests for BMI by age, race, and ethnicity.
stcox ib1.bmi5_base##i.AGE_BR i.RACE_BR i.ETHNICITY_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET, vce(robust)
testparm i.bmi5_base#i.AGE_BR
post testh ("Table5") ("bmi5_base") ("Age group") (r(chi2)) (r(df)) (r(p))

stcox ib1.bmi5_base##i.RACE_BR c.AGE i.ETHNICITY_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET, vce(robust)
testparm i.bmi5_base#i.RACE_BR
post testh ("Table5") ("bmi5_base") ("Race") (r(chi2)) (r(df)) (r(p))

stcox ib1.bmi5_base##i.ETHNICITY_BR c.AGE i.RACE_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET, vce(robust)
testparm i.bmi5_base#i.ETHNICITY_BR
post testh ("Table5") ("bmi5_base") ("Ethnicity") (r(chi2)) (r(df)) (r(p))

use `table5', clear
display "Table 5 posted HR summary"
list, sepby(stratum subgroup) noobs abbreviate(24)

capture log close

********************************************************************************
* 9. TABLE 6: STRATIFIED FULLY ADJUSTED COX MODELS FOR BMI-SPECIFIC WC
********************************************************************************

open_section_log TABLE6_STRATIFIED_BMIWC
use `cox_bmiwc', clear
describe

postfile t6h str30 table str45 stratum str45 subgroup str40 exposure str80 category double HR LCL UCL pvalue using `table6', replace

post_cox_hr_fast, handle(t6h) table("Table6") sample("Overall") model("Overall") exposure(bmi_wc10_base) covars("$COV_FULL")

forvalues a=1/3 {
    local lab : label agerf `a'
    post_cox_hr_fast, handle(t6h) table("Table6") sample("Age") model("`lab'") exposure(bmi_wc10_base) covars("$COV_FULL") ifcond("AGE_BR == `a'")
}
forvalues r=1/4 {
    local lab : label racebrf `r'
    post_cox_hr_fast, handle(t6h) table("Table6") sample("Race") model("`lab'") exposure(bmi_wc10_base) covars("$COV_NO_RACE") ifcond("RACE_BR == `r'")
}
forvalues e=0/1 {
    local lab : label ethnicbrf `e'
    post_cox_hr_fast, handle(t6h) table("Table6") sample("Ethnicity") model("`lab'") exposure(bmi_wc10_base) covars("$COV_NO_ETHN") ifcond("ETHNICITY_BR == `e'")
}
postclose t6h

* Interaction tests for BMI-specific WC by age, race, and ethnicity.
stcox ib1.bmi_wc10_base##i.AGE_BR i.RACE_BR i.ETHNICITY_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET, vce(robust)
testparm i.bmi_wc10_base#i.AGE_BR
post testh ("Table6") ("bmi_wc10_base") ("Age group") (r(chi2)) (r(df)) (r(p))

stcox ib1.bmi_wc10_base##i.RACE_BR c.AGE i.ETHNICITY_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET, vce(robust)
testparm i.bmi_wc10_base#i.RACE_BR
post testh ("Table6") ("bmi_wc10_base") ("Race") (r(chi2)) (r(df)) (r(p))

stcox ib1.bmi_wc10_base##i.ETHNICITY_BR c.AGE i.RACE_BR i.MARITAL_BR i.EDUC_BR i.OCCUPATION i.INCOME_BR i.SMOKING_BR i.ALCOHOL_BR c.HEI2015_TOTAL_SCORE c.PHYSICAL_ACTIVITY_MET, vce(robust)
testparm i.bmi_wc10_base#i.ETHNICITY_BR
post testh ("Table6") ("bmi_wc10_base") ("Ethnicity") (r(chi2)) (r(df)) (r(p))

use `table6', clear
display "Table 6 posted HR summary"
list, sepby(stratum subgroup) noobs abbreviate(24)

capture log close

********************************************************************************
* 10. MODEL SELECTION, AIC/BIC, AND KM TESTS
********************************************************************************

open_section_log MODEL_DIAGNOSTICS_AND_TESTS

* Stepwise model selection is deliberately skipped by default because it is the
* slowest component and is not needed for the simplified Tables 3-6.
if "$RUN_STEPWISE" == "1" {
    use `cox_bmi', clear
    stepwise, pr(.05): stcox ib1.bmi5_base $COV_FULL
    estat ic

    use `cox_bmiwc', clear
    stepwise, pr(.05): stcox ib1.bmi_wc10_base $COV_FULL
    estat ic
}

postclose cnh
postclose testh
postclose aich

use `tests', clear
display "Interaction tests for Tables 5-6"
list, sepby(table exposure) noobs abbreviate(24)

use `aic', clear
display "AIC/BIC summary for Tables 3-6"
list, sepby(table sample model) noobs abbreviate(24)

* Kaplan-Meier log-rank tests use only the survival variables and exposures.
use `cox_km', clear
postfile kmh str30 figure str60 exposure double chi2 df pvalue using `kmtests', replace
sts test bmi5_base, logrank
post kmh ("Figure 2") ("BMI categories") (r(chi2)) (r(df)) (r(p))
sts test bmi_wc10_base, logrank
post kmh ("Figure 3") ("BMI-specific WC categories") (r(chi2)) (r(df)) (r(p))
postclose kmh

use `kmtests', clear
display "Kaplan-Meier log-rank tests"
list, noobs abbreviate(24)

capture log close

********************************************************************************
* 11. FIGURE 2: KAPLAN-MEIER / FAILURE CURVE BY BMI CATEGORY
********************************************************************************

open_section_log FIGURE2_KM_BMI
use `cox_km', clear
keep HHIDPN _st _d _t _t0 fail_diabetes bmi5_base
compress

sts graph, by(bmi5_base) failure ///
    title("WHI women: Incident diabetes by BMI category", size(small)) ///
    ytitle("Cumulative incidence of diabetes", margin(vlarge) justification(center)) ///
    xtitle("Years since WHI baseline") ///
    xlabel(0(5)25 29) ///
    xscale(range(0 29)) ///
    yscale(range(0 1.0) noextend) ///
    ylabel(0(0.1)1.0, format(%3.1f)) ///
    risktable(0(5)25 29, size(vsmall)) ///
    legend(order(1 "Normal" 2 "Overweight" 3 "Obesity 1" 4 "Obesity 2" 5 "Obesity 3") rows(2) symxsize(6) colgap(4) keygap(2) size(small) region(lstyle(none))) ///
    graphregion(margin(large)) ///
    plotregion(margin(medium))

graph save "$outdir\Figure2_WHI_KM_BMI_diabetes_truncated29yrs.gph", replace
graph export "$outdir\Figure2_WHI_KM_BMI_diabetes_truncated29yrs.png", replace width(2400)
graph export "$outdir\Figure2_WHI_KM_BMI_diabetes_truncated29yrs.tif", replace width(2400)
sts test bmi5_base, logrank

capture log close

********************************************************************************
* 12. FIGURE 3: KAPLAN-MEIER / FAILURE CURVE BY BMI-SPECIFIC WC CATEGORY
********************************************************************************

open_section_log FIGURE3_KM_BMIWC
use `cox_km', clear
keep HHIDPN _st _d _t _t0 fail_diabetes bmi_wc10_base
compress

sts graph, by(bmi_wc10_base) failure ///
    title("WHI women: Incident diabetes by BMI-specific WC category", size(small)) ///
    ytitle("Cumulative incidence of diabetes", margin(vlarge) justification(center)) ///
    xtitle("Years since WHI baseline") ///
    xlabel(0(5)25 29) ///
    xscale(range(0 29)) ///
    yscale(range(0 1.0) noextend) ///
    ylabel(0(0.1)1.0, format(%3.1f)) ///
    risktable(0(5)25 29, size(vsmall)) ///
    legend(rows(3) symxsize(5) colgap(3) keygap(2) size(vsmall) region(lstyle(none))) ///
    graphregion(margin(large)) ///
    plotregion(margin(medium))

graph save "$outdir\Figure3_WHI_KM_BMIWC_diabetes_truncated29yrs.gph", replace
graph export "$outdir\Figure3_WHI_KM_BMIWC_diabetes_truncated29yrs.png", replace width(2400)
graph export "$outdir\Figure3_WHI_KM_BMIWC_diabetes_truncated29yrs.tif", replace width(2400)
sts test bmi_wc10_base, logrank

capture log close

********************************************************************************
* 13. FINAL MESSAGE
********************************************************************************

capture log close
capture log using "$mainlog", text append
display "Completed WHI analyses. Excel workbook contains Flowchart, Table1, and Table2 only: $xlsx"
display "Logs and figures are in: $outdir"
capture log close


********************************************************************************
* 14. TABLE A.1.
********************************************************************************
capture log close
capture log using "$outdir\TABLEA1.txt", text replace

use "$outdir\WHI_ANALYTIC_AFTER_FLOWCHART_COMPACT.dta", clear


table bmi5_base train70, statistic(freq)
table bmi_wc10_base train70, statistic(freq)

capture log close

********************************************************************************
* END OF DO FILE
********************************************************************************
