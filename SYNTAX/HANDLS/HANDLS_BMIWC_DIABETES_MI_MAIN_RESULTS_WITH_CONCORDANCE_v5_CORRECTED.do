********************************************************************************
* HANDLS BMI/WC AND INCIDENT DIABETES AMONG WOMEN
* Manuscript-aligned validation analysis, harmonized with WHI and HRS analyses
*
* Purpose:
*   External validation cohort for manuscript: Central adiposity within BMI
*   categories and incident diabetes in postmenopausal/older women.
*
* Input:
*   HANDLS long-format analytic dataset with HNDwave = 1, 3, or 4
*     HNDwave==1: baseline / Visit 1, 2004-2009
*     HNDwave==3: follow-up / Visit 2, 2009-2013
*     HNDwave==4: follow-up / Visit 3, 2013-2018
*
* Key manuscript alignment:
*   1. Restrict to women at HANDLS Visit 1 baseline.
*   2. Exclude prevalent diabetes at baseline using dxDiabetes==3.
*   3. Require valid baseline BMI and waist circumference, BMI >=18.5 kg/m2.
*   4. Require observed follow-up diabetes assessment and positive follow-up time.
*   5. Multiply impute missing baseline covariates for the primary adjusted analyses.
*   6. Do not impose baseline age restriction or minimum follow-up length restriction.
*   7. Use time on study as HANDLS time scale.
*   7. Estimate exact Poisson incidence rates, Cox HRs, Harrell's c-statistics,
*      Kaplan-Meier/failure curves, log-rank observed/expected tables,
*      PH diagnostics, interaction tests, and stratified tables.
*
* Notes:
*   - This script is intentionally close to HRS/WHI table structure.
*   - HANDLS is used as an external validation sample; no training/test split.
*   - Primary adjusted analysis uses multiple imputation for missing covariates.
*   - A complete-case flag is retained for transparency and sensitivity checks.
********************************************************************************

clear all
clear mata
clear matrix
set more off
set maxvar 20000
version 18

********************************************************************************
** 0. USER OPTIONS, PATHS, AND OUTPUTS
********************************************************************************

global datadir "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\DATA\HANDLS"
global outdir  "D:\16GBBACKUPUSB\BACKUP_USB_SEPTEMBER2014\SUMMER_STUDENT_2026\HRS_WHI_HANDLS_BMIWCDIABETES\OUTPUT\HANDLS"

capture mkdir "$outdir"

* EDIT if your HANDLS long-format file has a different name.
global infile  "$datadir\2026-05-07_womenbmi.dta"
global xlsx    "$outdir\HANDLS_BMIWC_DIABETES_MI_MAIN_RESULTS.xlsx"
global mainlog "$outdir\HANDLS_BMIWC_DIABETES_MI_MAIN_RESULTS_LOG.txt"
global figdir  "$outdir\FIGURES"

capture mkdir "$figdir"
capture erase "$xlsx"

* Manuscript primary adjusted analysis uses multiple imputation for missing covariates.
local RUN_MI 1
local MI_M 20
local MI_SEED 20260509

********************************************************************************
** 1. UTILITY PROGRAMS
********************************************************************************

capture program drop open_section_log
program define open_section_log
    args section_name
    di as text _newline(2) "============================================================"
    di as text "SECTION: `section_name'"
    di as text "============================================================"
end

capture program drop assert_var_exists
program define assert_var_exists
    args vname
    capture confirm variable `vname'
    if _rc {
        di as error "Required variable `vname' not found. Update the variable mapping section."
        exit 111
    }
end

capture program drop write_note
program define write_note
    syntax, SHEET(string) CELL(string) TEXT(string)
    putexcel set "$xlsx", sheet("`sheet'") modify
    putexcel `cell' = "`text'"
end

********************************************************************************
** 2. OPEN LONG HANDLS FILE AND HARMONIZE VARIABLE NAMES
********************************************************************************

capture log close
capture log using "$mainlog", text replace
open_section_log IMPORT_AND_HARMONIZATION

use "$infile", clear

* Harmonize participant ID.
capture confirm variable HNDid
if _rc {
    capture confirm variable HNDID
    if !_rc rename HNDID HNDid
}
assert_var_exists HNDid
assert_var_exists HNDwave

* Ensure wave variable is numeric before filtering.
capture confirm numeric variable HNDwave
if _rc {
    destring HNDwave, replace ignore(" .NAnaNAN/A")
}

* Keep requested HANDLS waves.
keep if inlist(HNDwave, 1, 3, 4)

* Harmonize likely alternate variable names to manuscript/code names.
foreach pair in ///
    "Age age" ///
    "BMI bmi" ///
    "WaistSize waist" ///
    "WaistSize waist_circumference" ///
    "WaistSize wc" ///
    "dxDiabetes diabetes" ///
    "dxDiabetes diab" ///
    "Sex sex" ///
    "Race race" ///
    "EducationYr educationyr" ///
    "EducationYr educyrs" ///
    "PovStat povstat" ///
    "CigaretteStatus smoking" ///
    "CigaretteStatus smoke" ///
    "AlcStatus alcohol" ///
    "hei2010_total_score hei2010" ///
    "hei2010_total_score HEI2010" ///
 {
    gettoken target source : pair
    capture confirm variable `target'
    if _rc {
        capture confirm variable `source'
        if !_rc rename `source' `target'
    }
}

* Keep core variables used in manuscript-aligned HANDLS validation analysis.
keep HNDid HNDwave Age BMI WaistSize dxDiabetes Sex Race EducationYr PovStat ///
     CigaretteStatus AlcStatus hei2010_total_score 

********************************************************************************
** 3. CLEAN AND VALIDATE LONG VARIABLES
********************************************************************************

open_section_log CLEAN_LONG_VARIABLES

foreach v in HNDwave Age BMI WaistSize dxDiabetes Sex Race EducationYr PovStat ///
             CigaretteStatus AlcStatus hei2010_total_score  {
    capture confirm numeric variable `v'
    if _rc {
        capture destring `v', replace ignore(" .NAnaNAN/A")
    }
}

foreach v in Age BMI WaistSize EducationYr hei2010_total_score  {
    capture confirm numeric variable `v'
    if !_rc replace `v' = . if `v' < 0
}

replace Age       = . if Age < 18 | Age > 100
replace BMI       = . if BMI < 10 | BMI > 100
replace WaistSize = . if WaistSize < 40 | WaistSize > 220
replace EducationYr = . if EducationYr > 30
replace hei2010_total_score = . if hei2010_total_score < 0 | hei2010_total_score > 100

* Diabetes diagnosis code from HANDLS codebook:
*   1 = No diabetes diagnosis, 2 = prediabetes, 3 = diabetes.
* Keep the original 1/2/3 dxDiabetes coding in the long file and create
* binary diabetes indicators after reshaping. Prevalent diabetes exclusion
* at baseline is based on dxDiabetes==3.
replace dxDiabetes = . if !inlist(dxDiabetes,1,2,3,.)

* Remove duplicate person-wave rows.
duplicates report HNDid HNDwave
duplicates drop HNDid HNDwave, force

********************************************************************************
** 4. RESHAPE LONG TO WIDE PERSON-LEVEL FILE
********************************************************************************

open_section_log RESHAPE_WIDE

reshape wide Age BMI WaistSize dxDiabetes Sex Race EducationYr PovStat ///
             CigaretteStatus AlcStatus hei2010_total_score , i(HNDid) j(HNDwave)

rename Age1 age_bl
rename BMI1 bmi_bl
rename WaistSize1 waist_bl
rename dxDiabetes1 dxDiabetes_bl
rename Sex1 sex_bl
rename Race1 race_bl
rename EducationYr1 educ_bl
rename PovStat1 pov_bl
rename CigaretteStatus1 smoke_bl
rename AlcStatus1 alcohol_bl
rename hei2010_total_score1 hei_bl

capture rename Age3 age_v2
capture rename BMI3 bmi_v2
capture rename WaistSize3 waist_v2
capture rename dxDiabetes3 dxDiabetes_v2
capture rename PovStat3 pov_v2
capture rename CigaretteStatus3 smoke_v2
capture rename AlcStatus3 alcohol_v2
capture rename hei2010_total_score3 hei_v2

capture rename Age4 age_v3
capture rename BMI4 bmi_v3
capture rename WaistSize4 waist_v3
capture rename dxDiabetes4 dxDiabetes_v3
capture rename PovStat4 pov_v3
capture rename CigaretteStatus4 smoke_v3
capture rename AlcStatus4 alcohol_v3
capture rename hei2010_total_score4 hei_v3

* Create binary diabetes indicators from HANDLS dxDiabetes codebook.
* 1 = NoDx, 2 = preDiabetes, 3 = Diabetes.
capture drop diab_bl diab_v2 diab_v3
gen byte diab_bl = .
replace diab_bl = 0 if inlist(dxDiabetes_bl,1,2)
replace diab_bl = 1 if dxDiabetes_bl==3
label var diab_bl "Baseline diabetes indicator from dxDiabetes==3"

capture confirm variable dxDiabetes_v2
if !_rc {
    gen byte diab_v2 = .
    replace diab_v2 = 0 if inlist(dxDiabetes_v2,1,2)
    replace diab_v2 = 1 if dxDiabetes_v2==3
    label var diab_v2 "Visit 2 diabetes indicator from dxDiabetes==3"
}
else {
    gen byte diab_v2 = .
}

capture confirm variable dxDiabetes_v3
if !_rc {
    gen byte diab_v3 = .
    replace diab_v3 = 0 if inlist(dxDiabetes_v3,1,2)
    replace diab_v3 = 1 if dxDiabetes_v3==3
    label var diab_v3 "Visit 3 diabetes indicator from dxDiabetes==3"
}
else {
    gen byte diab_v3 = .
}

********************************************************************************
** 5. BASELINE ELIGIBILITY FLAGS AND FLOWCHART COUNTS
********************************************************************************

open_section_log ELIGIBILITY_FLAGS

* HANDLS codebook Sex coding: 1 = Women, 2 = Men.
capture drop female
gen byte female = .
replace female = 1 if sex_bl == 1
replace female = 0 if sex_bl == 2
label define femalelbl 0 "Men" 1 "Women", replace
label values female femalelbl
label var female "Female indicator based on Sex==1"

capture drop step0 step1 step2 step3 step4 step5 step6 step7 step8

gen byte step0 = !missing(HNDid)
gen byte step1 = step0 == 1 & female == 1
gen byte step2 = step1 == 1 & !missing(bmi_bl, waist_bl)
gen byte step3 = step2 == 1 & bmi_bl >= 18.5
gen byte step4 = step3 == 1 & diab_bl == 0

********************************************************************************
** 6. TIME-TO-EVENT VARIABLES: INCIDENT DIABETES AT VISIT 2 OR VISIT 3
********************************************************************************

open_section_log TIME_TO_EVENT

capture drop fail_diabetes event_age exit_age fu_yrs event_wave censor_wave has_followup

gen fail_diabetes = 0
gen event_wave = .
gen event_age = .

* First observed incident diabetes at visit 2, otherwise visit 3.
replace fail_diabetes = 1 if diab_v2 == 1 & !missing(age_v2)
replace event_wave = 3    if diab_v2 == 1 & !missing(age_v2)
replace event_age = age_v2 if diab_v2 == 1 & !missing(age_v2)

replace fail_diabetes = 1 if fail_diabetes == 0 & diab_v3 == 1 & !missing(age_v3)
replace event_wave = 4    if fail_diabetes == 1 & missing(event_wave) & diab_v3 == 1 & !missing(age_v3)
replace event_age = age_v3 if fail_diabetes == 1 & missing(event_age) & diab_v3 == 1 & !missing(age_v3)

* Censor at last observed diabetes assessment.
gen censor_wave = .
replace censor_wave = 4 if !missing(diab_v3) & !missing(age_v3)
replace censor_wave = 3 if missing(censor_wave) & !missing(diab_v2) & !missing(age_v2)

gen exit_age = .
replace exit_age = event_age if fail_diabetes == 1 & !missing(event_age)
replace exit_age = age_v3 if missing(exit_age) & censor_wave == 4
replace exit_age = age_v2 if missing(exit_age) & censor_wave == 3

gen fu_yrs = exit_age - age_bl
replace fu_yrs = . if fu_yrs <= 0

gen has_followup = !missing(fu_yrs)
gen byte step5 = step4 == 1 & has_followup == 1
* No minimum follow-up length restriction is applied.
gen byte step6 = step5 == 1

label var fail_diabetes "Incident diabetes at HANDLS follow-up"
label var fu_yrs "Follow-up time, years since Visit 1 baseline"
label var event_wave "Wave of incident diabetes"

********************************************************************************
** 7. EXPOSURES: BMI, BMI-SPECIFIC WC THRESHOLDS, AND JOINT CATEGORIES
********************************************************************************

open_section_log EXPOSURES

capture drop bmi5_bl wc80_bl wc_high_bmi_bl bmi_wc10_bl

gen bmi5_bl = .
replace bmi5_bl = 1 if bmi_bl >= 18.5 & bmi_bl < 25
replace bmi5_bl = 2 if bmi_bl >= 25   & bmi_bl < 30
replace bmi5_bl = 3 if bmi_bl >= 30   & bmi_bl < 35
replace bmi5_bl = 4 if bmi_bl >= 35   & bmi_bl < 40
replace bmi5_bl = 5 if bmi_bl >= 40   & bmi_bl < .
label define bmi5lbl 1 "Normal" 2 "Overweight" 3 "Obesity 1" 4 "Obesity 2" 5 "Obesity 3", replace
label values bmi5_bl bmi5lbl
label var bmi5_bl "Baseline BMI category"

gen wc80_bl = .
replace wc80_bl = 0 if waist_bl < 80
replace wc80_bl = 1 if waist_bl >=80 & waist_bl < .
label define wc80lbl 0 "WC <80 cm" 1 "WC >=80 cm", replace
label values wc80_bl wc80lbl
label var wc80_bl "High waist circumference using 80 cm threshold"

gen wc_high_bmi_bl = .
replace wc_high_bmi_bl = 0 if bmi5_bl == 1 & waist_bl <  80
replace wc_high_bmi_bl = 1 if bmi5_bl == 1 & waist_bl >= 80 & waist_bl < .
replace wc_high_bmi_bl = 0 if bmi5_bl == 2 & waist_bl <  90
replace wc_high_bmi_bl = 1 if bmi5_bl == 2 & waist_bl >= 90 & waist_bl < .
replace wc_high_bmi_bl = 0 if bmi5_bl == 3 & waist_bl < 105
replace wc_high_bmi_bl = 1 if bmi5_bl == 3 & waist_bl >=105 & waist_bl < .
replace wc_high_bmi_bl = 0 if bmi5_bl == 4 & waist_bl < 115
replace wc_high_bmi_bl = 1 if bmi5_bl == 4 & waist_bl >=115 & waist_bl < .
replace wc_high_bmi_bl = 0 if bmi5_bl == 5 & waist_bl < 115
replace wc_high_bmi_bl = 1 if bmi5_bl == 5 & waist_bl >=115 & waist_bl < .
label define wchighlbl 0 "Lower WC within BMI" 1 "Higher WC within BMI", replace
label values wc_high_bmi_bl wchighlbl
label var wc_high_bmi_bl "BMI-specific high waist circumference"

gen bmi_wc10_bl = .
replace bmi_wc10_bl = 1  if bmi5_bl == 1 & wc_high_bmi_bl == 0
replace bmi_wc10_bl = 2  if bmi5_bl == 1 & wc_high_bmi_bl == 1
replace bmi_wc10_bl = 3  if bmi5_bl == 2 & wc_high_bmi_bl == 0
replace bmi_wc10_bl = 4  if bmi5_bl == 2 & wc_high_bmi_bl == 1
replace bmi_wc10_bl = 5  if bmi5_bl == 3 & wc_high_bmi_bl == 0
replace bmi_wc10_bl = 6  if bmi5_bl == 3 & wc_high_bmi_bl == 1
replace bmi_wc10_bl = 7  if bmi5_bl == 4 & wc_high_bmi_bl == 0
replace bmi_wc10_bl = 8  if bmi5_bl == 4 & wc_high_bmi_bl == 1
replace bmi_wc10_bl = 9  if bmi5_bl == 5 & wc_high_bmi_bl == 0
replace bmi_wc10_bl = 10 if bmi5_bl == 5 & wc_high_bmi_bl == 1
label define bmiwc10lbl 1 "Normal, WC <80" 2 "Normal, WC >=80" ///
                        3 "Overweight, WC <90" 4 "Overweight, WC >=90" ///
                        5 "Obesity 1, WC <105" 6 "Obesity 1, WC >=105" ///
                        7 "Obesity 2, WC <115" 8 "Obesity 2, WC >=115" ///
                        9 "Obesity 3, WC <115" 10 "Obesity 3, WC >=115", replace
label values bmi_wc10_bl bmiwc10lbl
label var bmi_wc10_bl "Joint BMI and BMI-specific WC categories"

********************************************************************************
** 8. COVARIATE RECODING, MI-ELIGIBLE SAMPLE, AND MULTIPLE IMPUTATION
********************************************************************************

open_section_log COVARIATES_AND_MULTIPLE_IMPUTATION

capture drop race_cat agecat_bl educ_cat pov_cat smoke_cat alcohol_cat

* HANDLS race is generally African American/White. Preserve observed coding but group if needed.
egen race_cat = group(race_bl), label
label var race_cat "Race category"

* Age groups for interaction/stratified descriptions; no baseline age restriction is applied.
gen agecat_bl = .
replace agecat_bl = 1 if age_bl <50
replace agecat_bl = 2 if age_bl >=50 & age_bl <60
replace agecat_bl = 3 if age_bl >=60 & age_bl <70
replace agecat_bl = 4 if age_bl >=70 & age_bl < .
label define agecatlbl 1 "<50" 2 "50-59" 3 "60-69" 4 "70+", replace
label values agecat_bl agecatlbl
label var agecat_bl "Baseline age category"

gen educ_cat = .
replace educ_cat = 1 if educ_bl < 12
replace educ_cat = 2 if educ_bl == 12
replace educ_cat = 3 if educ_bl > 12 & educ_bl < 16
replace educ_cat = 4 if educ_bl >= 16 & educ_bl < .
label define educlbl 1 "Less than high school" 2 "High school" 3 "Some college" 4 "College+", replace
label values educ_cat educlbl
label var educ_cat "Education category"

egen pov_cat     = group(pov_bl), label
egen smoke_cat   = group(smoke_bl), label
egen alcohol_cat = group(alcohol_bl), label
label var pov_cat     "Poverty status category"
label var smoke_cat   "Smoking category"
label var alcohol_cat "Alcohol category"

* HANDLS does not include a baseline physical activity covariate in this analytic file.
* Fully adjusted models use demographics, SES, smoking, alcohol, and HEI-2010 diet quality.
global COV_FULL c.age_bl i.race_cat i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl
global COV_RACE_STRAT c.age_bl i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl
global COV_AGE_STRAT c.age_bl i.race_cat i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl

capture drop nmiss_covars complete_covars complete_exposures complete_survival mi_eligible analytic_cc analytic_mi step7 step8
egen nmiss_covars = rowmiss(age_bl race_cat educ_cat pov_cat smoke_cat alcohol_cat hei_bl)
gen complete_covars = (nmiss_covars == 0)

gen complete_exposures = !missing(bmi_bl, waist_bl, bmi5_bl, wc_high_bmi_bl, bmi_wc10_bl)
gen complete_survival  = !missing(fu_yrs, fail_diabetes)

* MI-eligible primary analytic sample: exclusions are based on design, exposures, and observed outcome/follow-up.
* Missing covariates are retained and imputed below. analytic_cc is kept only as a comparator.
gen mi_eligible = step6 == 1 & complete_exposures == 1 & complete_survival == 1
gen analytic_mi = mi_eligible
gen analytic_cc = mi_eligible == 1 & complete_covars == 1
gen byte step7 = mi_eligible
gen byte step8 = analytic_cc

* Keep all records until flowchart exported; after imputation, descriptive counts use _mi_m==0.

* Multiple imputation of baseline covariates only. Exposures, outcome, follow-up time, sex, race,
* BMI/WC categories, and diabetes status are not imputed.
*
* IMPORTANT FIX, 09 May 2026:
* The imputation model is restricted to mi_eligible==1. Without this restriction,
* mi impute chained tries to impute covariates for records excluded from the analytic
* survival sample, where BMI/WC exposure categories, follow-up time, or outcome fields
* may be missing. That can produce the Stata error:
*     educ_bl: missing imputed values produced, r(498)
*
* Education is imputed as the model covariate educ_cat rather than as continuous
* educ_bl, because Cox models use i.educ_cat. The observed continuous educ_bl is
* retained as a regular variable for Table 1 descriptive summaries at _mi_m==0.
if `RUN_MI' == 1 {
    mi set mlong
    mi register regular HNDid female diab_bl fail_diabetes fu_yrs bmi_bl waist_bl educ_bl ///
        bmi5_bl wc80_bl wc_high_bmi_bl bmi_wc10_bl race_cat agecat_bl ///
        complete_exposures complete_survival complete_covars mi_eligible analytic_mi analytic_cc ///
        step0 step1 step2 step3 step4 step5 step6 step7 step8 nmiss_covars
    mi register imputed age_bl hei_bl educ_cat pov_cat smoke_cat alcohol_cat

    * Sanity check: all non-imputed predictors must be observed in the MI-eligible sample.
    foreach v in fail_diabetes fu_yrs bmi5_bl wc_high_bmi_bl bmi_wc10_bl race_cat {
        count if mi_eligible==1 & missing(`v')
        if r(N)>0 {
            di as error "MI predictor `v' has " r(N) " missing values among mi_eligible==1."
            di as error "Review eligibility coding before running mi impute chained."
            exit 459
        }
    }

   mi impute chained ///
    (regress) age_bl hei_bl ///
    (ologit) educ_cat ///
    (mlogit) pov_cat smoke_cat alcohol_cat ///
    = i.race_cat i.bmi5_bl i.wc_high_bmi_bl i.bmi_wc10_bl fail_diabetes fu_yrs ///
    if mi_eligible==1, add(`MI_M') rseed(`MI_SEED') burnin(10) augment noisily

* MI completed successfully
mi describe

label values educ_cat educlbl

mi stset fu_yrs if mi_eligible==1, ///
    failure(fail_diabetes==1) id(HNDid)


}


********************************************************************************
** 9. EXCEL README AND FLOWCHART
********************************************************************************

open_section_log EXCEL_README_FLOWCHART

putexcel set "$xlsx", sheet("README") replace
putexcel A1 = "HANDLS BMI/WC and incident diabetes MI main-results workbook"
putexcel A2 = "Primary adjusted Cox models use multiple imputation for missing baseline covariates."
putexcel A3 = "Workbook includes MI main Cox results, Table 1, rates, flowchart, and KM/log-rank outputs."
putexcel A4 = "No complete-case Cox result sheets are exported in this MI-primary version."
putexcel A5 = "Kaplan-Meier/failure curves and log-rank summaries use observed m=0 MI-eligible data."
putexcel A6 = "Final text log is saved as:"
putexcel A7 = "$mainlog"
putexcel A8 = "Excel workbook is saved as:"
putexcel A9 = "$xlsx"
putexcel A10 = "Kaplan-Meier figure files are saved under:"
putexcel A11 = "$figdir"

putexcel set "$xlsx", sheet("Flowchart") modify
putexcel A1 = "Figure 1C. HANDLS analytic sample flowchart counts"
putexcel A3 = "Step" B3 = "Definition" C3 = "N at m=0"
local r = 4
foreach s in step0 step1 step2 step3 step4 step5 step6 step7 step8 {
    count if _mi_m==0 & `s' == 1
    local n = r(N)
    local txt ""
    if "`s'"=="step0" local txt "Records/persons after reshaping to one row per participant"
    if "`s'"=="step1" local txt "Women"
    if "`s'"=="step2" local txt "Valid/nonmissing baseline BMI and waist circumference"
    if "`s'"=="step3" local txt "BMI >=18.5 kg/m2"
    if "`s'"=="step4" local txt "Diabetes-free at baseline based on dxDiabetes != 3"
    if "`s'"=="step5" local txt "Observed follow-up diabetes assessment and positive follow-up time"
    if "`s'"=="step6" local txt "No additional age or minimum follow-up-length restriction applied"
    if "`s'"=="step7" local txt "MI-eligible analytic sample: valid exposures plus observed follow-up/outcome"
    if "`s'"=="step8" local txt "Complete covariates before imputation; descriptive comparator only"
    putexcel A`r' = "`s'" B`r' = "`txt'" C`r' = `n'
    local ++r
}

preserve
    mi extract 0, clear
    keep if mi_eligible==1
    contract bmi5_bl
    export excel using "$xlsx", sheet("TableA1_BMI_counts", replace) firstrow(variables)
restore

preserve
    mi extract 0, clear
    keep if mi_eligible==1
    contract bmi_wc10_bl
    export excel using "$xlsx", sheet("TableA1_BMIWC_counts", replace) firstrow(variables)
restore

********************************************************************************
** 10. TABLE 1: BASELINE CHARACTERISTICS BY BMI CATEGORY
********************************************************************************

open_section_log TABLE1

putexcel set "$xlsx", sheet("Table1") modify
putexcel A1 = "Table 1. HANDLS baseline characteristics by BMI category"
putexcel A2 = "Descriptive statistics use observed m=0 MI-eligible data; adjusted models use MI."
putexcel A4 = "Characteristic" B4 = "Normal" C4 = "Overweight" D4 = "Obesity 1" E4 = "Obesity 2" F4 = "Obesity 3" G4 = "P value"

local cols B C D E F
local row = 5
putexcel A`row' = "N"
forvalues b = 1/5 {
    count if _mi_m==0 & mi_eligible==1 & bmi5_bl==`b'
    local n_b = r(N)
    local col : word `b' of `cols'
    putexcel `col'`row' = `n_b'
}
local ++row

putexcel A`row' = "Continuous variables, mean +/- SD"
local ++row

foreach v in age_bl bmi_bl waist_bl educ_bl hei_bl fu_yrs {
    capture confirm variable `v'
    if !_rc {
        local vlabel : variable label `v'
        if "`vlabel'" == "" local vlabel "`v'"
        putexcel A`row' = "`vlabel'"

        forvalues b = 1/5 {
            summarize `v' if _mi_m==0 & mi_eligible==1 & bmi5_bl==`b'
            local nobs = r(N)
            local col : word `b' of `cols'
            if `nobs' > 0 {
                local mean_v = string(r(mean), "%9.2f")
                local sd_v   = string(r(sd), "%9.2f")
                putexcel `col'`row' = "`mean_v' +/- `sd_v'"
            }
        }

        capture noisily regress `v' i.bmi5_bl if _mi_m==0 & mi_eligible==1
        if _rc == 0 {
            capture noisily testparm i.bmi5_bl
            if _rc == 0 {
                local pval = r(p)
                putexcel G`row' = `pval'
            }
        }
        local ++row
    }
}

local ++row
putexcel A`row' = "Categorical variables, n (%)"
local ++row

foreach v in race_cat agecat_bl educ_cat pov_cat smoke_cat alcohol_cat wc80_bl wc_high_bmi_bl fail_diabetes {
    capture confirm variable `v'
    if !_rc {
        local vlabel : variable label `v'
        if "`vlabel'" == "" local vlabel "`v'"
        putexcel A`row' = "`vlabel'"
        capture noisily tab `v' bmi5_bl if _mi_m==0 & mi_eligible==1, chi2
        if _rc == 0 {
            capture local pcat = r(p)
            if "`pcat'" != "" putexcel G`row' = `pcat'
        }
        local ++row

        levelsof `v' if _mi_m==0 & mi_eligible==1, local(levels)
        local vallab : value label `v'
        foreach lev of local levels {
            local levtxt "`lev'"
            if "`vallab'" != "" {
                local levtxt : label `vallab' `lev'
            }
            putexcel A`row' = "    `levtxt'"
            forvalues b = 1/5 {
                count if _mi_m==0 & mi_eligible==1 & bmi5_bl==`b' & `v'==`lev'
                local ncell = r(N)
                count if _mi_m==0 & mi_eligible==1 & bmi5_bl==`b' & !missing(`v')
                local denom = r(N)
                local col : word `b' of `cols'
                if `denom' > 0 {
                    local pct = 100*`ncell'/`denom'
                    local cell = string(`ncell', "%9.0f") + " (" + string(`pct', "%9.1f") + ")"
                    putexcel `col'`row' = "`cell'"
                }
            }
            local ++row
        }
    }
}

********************************************************************************
** 11. TABLE 2: INCIDENT CASES, PERSON-YEARS, AND EXACT POISSON RATES
********************************************************************************

open_section_log TABLE2

capture program drop incidence_table_putexcel
program define incidence_table_putexcel
    syntax, GROUPVAR(name) SHEET(string) [STARTROW(integer 4)]

    putexcel set "$xlsx", sheet("`sheet'") modify
    putexcel A1 = "Incident diabetes cases, person-years, and rates per 10,000 person-years"
    putexcel A2 = "Rates are descriptive and use observed m=0 MI-eligible data."
    putexcel A3 = "Exposure" B3 = "Category" C3 = "Cases" D3 = "N" E3 = "Person-years" F3 = "Rate per 10,000 PY" G3 = "Lower 95% CI" H3 = "Upper 95% CI"
    local row = `startrow'
    levelsof `groupvar' if _mi_m==0 & mi_eligible==1, local(levels)
    foreach lev of local levels {
        count if _mi_m==0 & mi_eligible==1 & `groupvar'==`lev'
        local n = r(N)
        count if _mi_m==0 & mi_eligible==1 & `groupvar'==`lev' & fail_diabetes==1
        local cases = r(N)
        summarize fu_yrs if _mi_m==0 & mi_eligible==1 & `groupvar'==`lev', meanonly
        local py = r(sum)
        local rate = .
        local ll = .
        local ul = .
        if `py' > 0 {
            local rate = 10000*`cases'/`py'
            if `cases' == 0 {
                local ll = 0
                local ul = 10000*0.5*invchi2(2*(`cases'+1), .975)/`py'
            }
            else {
                local ll = 10000*0.5*invchi2(2*`cases', .025)/`py'
                local ul = 10000*0.5*invchi2(2*(`cases'+1), .975)/`py'
            }
        }
        local vl : value label `groupvar'
        if "`vl'" == "" local cat "`lev'"
        else local cat : label `vl' `lev'
        putexcel A`row' = "`groupvar'" B`row' = "`cat'" C`row' = `cases' D`row' = `n' E`row' = `py' F`row' = `rate' G`row' = `ll' H`row' = `ul'
        local ++row
    }
end

incidence_table_putexcel, groupvar(bmi5_bl) sheet("Table2_BMI_rates")
incidence_table_putexcel, groupvar(bmi_wc10_bl) sheet("Table2_BMIWC_rates")
incidence_table_putexcel, groupvar(wc80_bl) sheet("Table2_WC80_rates")

********************************************************************************
** 12. STSET FOR MI COX MODELS
********************************************************************************

open_section_log STSET_MI

mi stset fu_yrs if mi_eligible==1, failure(fail_diabetes==1) id(HNDid)
mi describe
stsum if _mi_m==0
stsum if _mi_m==0, by(bmi5_bl)
stsum if _mi_m==0, by(bmi_wc10_bl)

********************************************************************************
** 13. TABLES 3-4: MI-POOLED MAIN COX MODELS
********************************************************************************

capture program drop make_mi_cox_table
program define make_mi_cox_table
    syntax, EXPOSURE(name) SHEET(string)

    tempfile results
    postfile handle str24 table str30 model str40 exposure str100 category ///
        double HR LCL UCL P N_EVENTS N_SUBJECTS using `results', replace

    * Unadjusted MI Cox model
    capture noisily mi estimate, hr dots post: stcox ib1.`exposure'
    if _rc == 0 {
        count if _mi_m==0 & mi_eligible==1 & fail_diabetes==1
        local nevents = r(N)

        count if _mi_m==0 & mi_eligible==1
        local nsubjects = r(N)

        estimates store unadj_`exposure'

        levelsof `exposure' if _mi_m==0 & mi_eligible==1, local(levels)

        foreach lev of local levels {
            if `lev' != 1 {
                capture noisily lincom `lev'.`exposure', hr
                if _rc == 0 {
                    local vl : value label `exposure'
                    if "`vl'" == "" local cat "`lev'"
                    else local cat : label `vl' `lev'

                    post handle ("`sheet'") ("unadjusted_mi") ("`exposure'") ("`cat'") ///
                        (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`nevents') (`nsubjects')
                }
            }
        }
    }

    * Fully adjusted MI Cox model
    capture noisily mi estimate, hr dots post: stcox ib1.`exposure' $COV_FULL
    if _rc == 0 {
        count if _mi_m==0 & mi_eligible==1 & fail_diabetes==1
        local nevents = r(N)

        count if _mi_m==0 & mi_eligible==1
        local nsubjects = r(N)

        estimates store full_`exposure'

        levelsof `exposure' if _mi_m==0 & mi_eligible==1, local(levels)

        foreach lev of local levels {
            if `lev' != 1 {
                capture noisily lincom `lev'.`exposure', hr
                if _rc == 0 {
                    local vl : value label `exposure'
                    if "`vl'" == "" local cat "`lev'"
                    else local cat : label `vl' `lev'

                    post handle ("`sheet'") ("full_mi") ("`exposure'") ("`cat'") ///
                        (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`nevents') (`nsubjects')
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

open_section_log TABLE3_BMI_MI_COX
make_mi_cox_table, exposure(bmi5_bl) sheet("Table3_BMI_MI_Cox")

open_section_log TABLE4_BMIWC_MI_COX
make_mi_cox_table, exposure(bmi_wc10_bl) sheet("Table4_BMIWC_MI_Cox")


********************************************************************************
** 13B. CONCORDANCE FOR UNADJUSTED AND FULLY ADJUSTED MI COX MODELS
********************************************************************************

open_section_log CONCORDANCE_MI_MAIN_MODELS

capture program drop mi_concordance_summary
program define mi_concordance_summary
    syntax , MODELTAG(string) EXPOSURE(name) SHEET(string) NIMP(integer) [COVARS(string)]

    tempfile mi_master
    save `mi_master', replace

    putexcel set "$xlsx", sheet("`sheet'_ByImp") modify
    putexcel A1=("Model")
    putexcel B1=("Exposure")
    putexcel C1=("Imputation")
    putexcel D1=("Harrell_C")
    putexcel E1=("N_EVENTS")
    putexcel F1=("N_SUBJECTS")
    putexcel G1=("Status")

    local row = 2
    local sum_c = 0
    local sum_c2 = 0
    local min_c = .
    local max_c = .
    local n_imp_c = 0
    local sum_events = 0
    local n_events_ok = 0
    local sum_subjects = 0
    local n_subjects_ok = 0

    forvalues mm = 1/`nimp' {

        use `mi_master', clear
        mi extract `mm', clear

        local cval = .
        local nevents = .
        local nsubjects = .
        local status "Not run"

        capture noisily stset fu_yrs if mi_eligible==1, ///
            failure(fail_diabetes==1) id(HNDid)

        if _rc==0 {
            capture noisily stcox ib1.`exposure' `covars'

            if _rc==0 {
                count if e(sample) & fail_diabetes==1
                local nevents = r(N)

                count if e(sample)
                local nsubjects = r(N)

                capture noisily estat concordance

                if _rc==0 {
                    capture confirm scalar r(C)
                    if !_rc local cval = r(C)

                    if missing(`cval') {
                        capture confirm scalar r(c)
                        if !_rc local cval = r(c)
                    }

                    if missing(`cval') {
                        capture confirm scalar r(concordance)
                        if !_rc local cval = r(concordance)
                    }

                    local status "OK"
                }
                else {
                    local status "estat concordance failed"
                }
            }
            else {
                local status "stcox failed"
            }
        }
        else {
            local status "stset failed"
        }

        putexcel A`row'=("`modeltag'")
        putexcel B`row'=("`exposure'")
        putexcel C`row'=(`mm')
        putexcel D`row'=(`cval')
        putexcel E`row'=(`nevents')
        putexcel F`row'=(`nsubjects')
        putexcel G`row'=("`status'")

        if !missing(`cval') {
            local sum_c = `sum_c' + `cval'
            local sum_c2 = `sum_c2' + (`cval' * `cval')
            local n_imp_c = `n_imp_c' + 1

            if missing(`min_c') local min_c = `cval'
            if missing(`max_c') local max_c = `cval'
            if `cval' < `min_c' local min_c = `cval'
            if `cval' > `max_c' local max_c = `cval'
        }

        if !missing(`nevents') {
            local sum_events = `sum_events' + `nevents'
            local n_events_ok = `n_events_ok' + 1
        }

        if !missing(`nsubjects') {
            local sum_subjects = `sum_subjects' + `nsubjects'
            local n_subjects_ok = `n_subjects_ok' + 1
        }

        local row = `row' + 1
    }

    local mean_c = .
    local sd_c = .
    local mean_events = .
    local mean_subjects = .

    if `n_imp_c' > 0 {
        local mean_c = `sum_c' / `n_imp_c'
    }

    if `n_imp_c' > 1 {
        local var_c = (`sum_c2' - (`sum_c' * `sum_c' / `n_imp_c')) / (`n_imp_c' - 1)
        if `var_c' < 0 local var_c = 0
        local sd_c = sqrt(`var_c')
    }

    if `n_events_ok' > 0 {
        local mean_events = `sum_events' / `n_events_ok'
    }

    if `n_subjects_ok' > 0 {
        local mean_subjects = `sum_subjects' / `n_subjects_ok'
    }

    putexcel set "$xlsx", sheet("`sheet'_Summary") modify
    putexcel A1=("Model")
    putexcel B1=("Exposure")
    putexcel C1=("Imputations with concordance")
    putexcel D1=("Mean Harrell C")
    putexcel E1=("SD Harrell C")
    putexcel F1=("Minimum Harrell C")
    putexcel G1=("Maximum Harrell C")
    putexcel H1=("Mean events")
    putexcel I1=("Mean subjects")
    putexcel J1=("Note")

    putexcel A2=("`modeltag'")
    putexcel B2=("`exposure'")
    putexcel C2=(`n_imp_c')
    putexcel D2=(`mean_c')
    putexcel E2=(`sd_c')
    putexcel F2=(`min_c')
    putexcel G2=(`max_c')
    putexcel H2=(`mean_events')
    putexcel I2=(`mean_subjects')
    putexcel J2=("Concordance summarized across imputed datasets; not Rubin-pooled.")

    use `mi_master', clear
end

summarize _mi_m if _mi_m > 0, meanonly
local NIMP = r(max)

di as txt "Number of imputations used for concordance = `NIMP'"


* BMI: unadjusted concordance
mi_concordance_summary, ///
    modeltag("BMI unadjusted MI model") ///
    exposure(bmi5_bl) ///
    sheet("Conc_BMI_MI_Unadj") ///
    nimp(`NIMP')

* BMI: fully adjusted concordance
mi_concordance_summary, ///
    modeltag("BMI fully adjusted MI model") ///
    exposure(bmi5_bl) ///
    sheet("Conc_BMI_MI_Full") ///
    nimp(`NIMP') ///
    covars("$COV_FULL")


* BMI-WC: unadjusted concordance
mi_concordance_summary, ///
    modeltag("BMI-WC unadjusted MI model") ///
    exposure(bmi_wc10_bl) ///
    sheet("Conc_BMIWC_MI_Unadj") ///
    nimp(`NIMP')

* BMI-WC: fully adjusted concordance
mi_concordance_summary, ///
    modeltag("BMI-WC fully adjusted MI model") ///
    exposure(bmi_wc10_bl) ///
    sheet("Conc_BMIWC_MI_Full") ///
    nimp(`NIMP') ///
    covars("$COV_FULL")
	
********************************************************************************
** 14. TABLES 5-6: MI-POOLED STRATIFIED MAIN COX MODELS AND INTERACTIONS
********************************************************************************

capture program drop post_mi_stratified_cox
program define post_mi_stratified_cox
    syntax, EXPOSURE(name) SHEET(string)

    tempfile results
    postfile handle str24 table str30 stratum str80 subgroup str100 category ///
        double HR LCL UCL P N_EVENTS N_SUBJECTS using `results', replace

    capture noisily mi estimate, hr dots post: stcox ib1.`exposure' $COV_FULL
    if _rc==0 {
        count if _mi_m==0 & mi_eligible==1 & fail_diabetes==1
        local nevents=r(N)
        count if _mi_m==0 & mi_eligible==1
        local nsubjects=r(N)
        levelsof `exposure' if _mi_m==0 & mi_eligible==1, local(levels)
        foreach lev of local levels {
            if `lev' != 1 {
                capture noisily lincom `lev'.`exposure', hr
                if _rc==0 {
                    local vl : value label `exposure'
                    if "`vl'" == "" local cat "`lev'"
                    else local cat : label `vl' `lev'
                    post handle ("`sheet'") ("Overall_MI") ("All women") ("`cat'") ///
                        (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`nevents') (`nsubjects')
                }
            }
        }
    }

    levelsof agecat_bl if _mi_m==0 & mi_eligible==1, local(agelevels)
    foreach s of local agelevels {
        local sl : label agecatlbl `s'
        capture noisily mi estimate, hr dots post: stcox ib1.`exposure' $COV_AGE_STRAT if agecat_bl==`s'
        if _rc==0 {
            count if _mi_m==0 & mi_eligible==1 & agecat_bl==`s' & fail_diabetes==1
            local nevents=r(N)
            count if _mi_m==0 & mi_eligible==1 & agecat_bl==`s'
            local nsubjects=r(N)
            levelsof `exposure' if _mi_m==0 & mi_eligible==1 & agecat_bl==`s', local(levels)
            foreach lev of local levels {
                if `lev' != 1 {
                    capture noisily lincom `lev'.`exposure', hr
                    if _rc==0 {
                        local vl : value label `exposure'
                        if "`vl'" == "" local cat "`lev'"
                        else local cat : label `vl' `lev'
                        post handle ("`sheet'") ("Age_MI") ("`sl'") ("`cat'") ///
                            (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`nevents') (`nsubjects')
                    }
                }
            }
        }
    }

    levelsof race_cat if _mi_m==0 & mi_eligible==1, local(racelevels)
    foreach r of local racelevels {
        local vlrace : value label race_cat
        if "`vlrace'" == "" local rl "race_cat=`r'"
        else local rl : label `vlrace' `r'
        capture noisily mi estimate, hr dots post: stcox ib1.`exposure' $COV_RACE_STRAT if race_cat==`r'
        if _rc==0 {
            count if _mi_m==0 & mi_eligible==1 & race_cat==`r' & fail_diabetes==1
            local nevents=r(N)
            count if _mi_m==0 & mi_eligible==1 & race_cat==`r'
            local nsubjects=r(N)
            levelsof `exposure' if _mi_m==0 & mi_eligible==1 & race_cat==`r', local(levels)
            foreach lev of local levels {
                if `lev' != 1 {
                    capture noisily lincom `lev'.`exposure', hr
                    if _rc==0 {
                        local vl : value label `exposure'
                        if "`vl'" == "" local cat "`lev'"
                        else local cat : label `vl' `lev'
                        post handle ("`sheet'") ("Race_MI") ("`rl'") ("`cat'") ///
                            (r(estimate)) (r(lb)) (r(ub)) (r(p)) (`nevents') (`nsubjects')
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

open_section_log TABLE5_BMI_MI_STRATIFIED
post_mi_stratified_cox, exposure(bmi5_bl) sheet("Table5_BMI_MI_Strat")

putexcel set "$xlsx", sheet("Table5_MI_Interactions") modify
putexcel A1 = "Table 5. MI-pooled interaction tests: fully adjusted BMI models"
putexcel A3 = "Modifier" B3 = "df" C3 = "Wald statistic" D3 = "P value"
local row = 4
capture noisily mi estimate, hr dots post: stcox ib1.bmi5_bl##i.agecat_bl i.race_cat i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl
if _rc==0 {
    capture noisily testparm i.bmi5_bl#i.agecat_bl
    if _rc==0 {
        local t_df = r(df)
        local t_stat = .
        capture local t_stat = r(chi2)
        if missing(`t_stat') capture local t_stat = r(F)
        local t_p = r(p)
        putexcel A`row' = "Age group" B`row' = `t_df' C`row' = `t_stat' D`row' = `t_p'
    }
    local ++row
}
capture noisily mi estimate, hr dots post: stcox ib1.bmi5_bl##i.race_cat c.age_bl i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl
if _rc==0 {
    capture noisily testparm i.bmi5_bl#i.race_cat
    if _rc==0 {
        local t_df = r(df)
        local t_stat = .
        capture local t_stat = r(chi2)
        if missing(`t_stat') capture local t_stat = r(F)
        local t_p = r(p)
        putexcel A`row' = "Race" B`row' = `t_df' C`row' = `t_stat' D`row' = `t_p'
    }
}

open_section_log TABLE6_BMIWC_MI_STRATIFIED
post_mi_stratified_cox, exposure(bmi_wc10_bl) sheet("Table6_BMIWC_MI_Strat")

putexcel set "$xlsx", sheet("Table6_MI_Interactions") modify
putexcel A1 = "Table 6. MI-pooled interaction tests: fully adjusted BMI-specific WC models"
putexcel A3 = "Modifier" B3 = "df" C3 = "Wald statistic" D3 = "P value"
local row = 4
capture noisily mi estimate, hr dots post: stcox ib1.bmi_wc10_bl##i.agecat_bl i.race_cat i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl
if _rc==0 {
    capture noisily testparm i.bmi_wc10_bl#i.agecat_bl
    if _rc==0 {
        local t_df = r(df)
        local t_stat = .
        capture local t_stat = r(chi2)
        if missing(`t_stat') capture local t_stat = r(F)
        local t_p = r(p)
        putexcel A`row' = "Age group" B`row' = `t_df' C`row' = `t_stat' D`row' = `t_p'
    }
    local ++row
}
capture noisily mi estimate, hr dots post: stcox ib1.bmi_wc10_bl##i.race_cat c.age_bl i.educ_cat i.pov_cat i.smoke_cat i.alcohol_cat c.hei_bl
if _rc==0 {
    capture noisily testparm i.bmi_wc10_bl#i.race_cat
    if _rc==0 {
        local t_df = r(df)
        local t_stat = .
        capture local t_stat = r(chi2)
        if missing(`t_stat') capture local t_stat = r(F)
        local t_p = r(p)
        putexcel A`row' = "Race" B`row' = `t_df' C`row' = `t_stat' D`row' = `t_p'
    }
}

********************************************************************************
** 15. KAPLAN-MEIER / FAILURE CURVES AND LOG-RANK OUTPUTS
********************************************************************************

open_section_log KM_LOGRANK_FIGURES

preserve
    mi extract 0, clear
    keep if mi_eligible==1

    stset fu_yrs, failure(fail_diabetes==1) id(HNDid)

    *------------------------------------------------------------
    * Figure 2C. BMI categories
    *------------------------------------------------------------
    sts graph, by(bmi5_bl) failure ///
        title("HANDLS women: Incident diabetes by BMI category", size(small)) ///
        ytitle("Cumulative incidence of diabetes") ///
        xtitle("Years since Visit 1 baseline") ///
        xlabel(0(2)14) xscale(range(0 14)) ///
        risktable(0(2)14, size(vsmall)) ///
        legend(order(1 "Normal" 2 "Overweight" 3 "Obesity 1" 4 "Obesity 2" 5 "Obesity 3") ///
            rows(2) size(small) region(lstyle(none))) ///
        graphregion(margin(large)) plotregion(margin(medium))

    graph save "$figdir\Figure2C_HANDLS_KM_BMI_diabetes.gph", replace
    graph export "$figdir\Figure2C_HANDLS_KM_BMI_diabetes.png", replace width(2400)
    graph export "$figdir\Figure2C_HANDLS_KM_BMI_diabetes.tif", replace width(2400)

    capture noisily sts test bmi5_bl, logrank

    putexcel set "$xlsx", sheet("Figure2_Logrank_BMI") modify
    putexcel A1 = ("Figure 2C log-rank test: HANDLS BMI categories")
    putexcel A2 = ("Observed m=0 MI-eligible data; not pooled by MI.")
    putexcel A4 = ("Statistic")
    putexcel B4 = ("Value")

    if _rc==0 {
        local lr_chi2 = r(chi2)
        local lr_df   = r(df)
        local lr_p    = r(p)

        putexcel A5 = ("Chi-square")
        putexcel B5 = (`lr_chi2')
        putexcel A6 = ("df")
        putexcel B6 = (`lr_df')
        putexcel A7 = ("P value")
        putexcel B7 = (`lr_p')
    }
    else {
        putexcel A5 = ("Log-rank test failed")
        putexcel B5 = (_rc)
    }

    * Optional descriptive counts by BMI category
    putexcel A10 = ("BMI category")
    putexcel B10 = ("N")
    putexcel C10 = ("Events")

    levelsof bmi5_bl if !missing(bmi5_bl), local(bmilevels)
    local row = 11

    foreach g of local bmilevels {
        count if bmi5_bl==`g'
        local n_g = r(N)

        count if bmi5_bl==`g' & fail_diabetes==1
        local e_g = r(N)

        local glab : label (bmi5_bl) `g'
        if "`glab'"=="" local glab "`g'"

        putexcel A`row' = ("`glab'")
        putexcel B`row' = (`n_g')
        putexcel C`row' = (`e_g')

        local row = `row' + 1
    }

    *------------------------------------------------------------
    * Figure 3C. BMI-specific waist circumference categories
    *------------------------------------------------------------
    sts graph, by(bmi_wc10_bl) failure ///
        title("HANDLS women: Incident diabetes by BMI-specific WC category", size(small)) ///
        ytitle("Cumulative incidence of diabetes") ///
        xtitle("Years since Visit 1 baseline") ///
        xlabel(0(2)14) xscale(range(0 14)) ///
        risktable(0(2)14, size(vsmall)) ///
        legend(cols(1) size(vsmall) position(3) ring(1) region(lstyle(none))) ///
        graphregion(margin(large)) plotregion(margin(medium))

    graph save "$figdir\Figure3C_HANDLS_KM_BMIWC_diabetes.gph", replace
    graph export "$figdir\Figure3C_HANDLS_KM_BMIWC_diabetes.png", replace width(2800)
    graph export "$figdir\Figure3C_HANDLS_KM_BMIWC_diabetes.tif", replace width(2800)

    capture noisily sts test bmi_wc10_bl, logrank

    putexcel set "$xlsx", sheet("Figure3_Logrank_BMIWC") modify
    putexcel A1 = ("Figure 3C log-rank test: HANDLS BMI-specific WC categories")
    putexcel A2 = ("Observed m=0 MI-eligible data; not pooled by MI.")
    putexcel A4 = ("Statistic")
    putexcel B4 = ("Value")

    if _rc==0 {
        local lr_chi2 = r(chi2)
        local lr_df   = r(df)
        local lr_p    = r(p)

        putexcel A5 = ("Chi-square")
        putexcel B5 = (`lr_chi2')
        putexcel A6 = ("df")
        putexcel B6 = (`lr_df')
        putexcel A7 = ("P value")
        putexcel B7 = (`lr_p')
    }
    else {
        putexcel A5 = ("Log-rank test failed")
        putexcel B5 = (_rc)
    }

    * Optional descriptive counts by BMI-WC category
    putexcel A10 = ("BMI-specific WC category")
    putexcel B10 = ("N")
    putexcel C10 = ("Events")

    levelsof bmi_wc10_bl if !missing(bmi_wc10_bl), local(bmiwclevels)
    local row = 11

    foreach g of local bmiwclevels {
        count if bmi_wc10_bl==`g'
        local n_g = r(N)

        count if bmi_wc10_bl==`g' & fail_diabetes==1
        local e_g = r(N)

        local glab : label (bmi_wc10_bl) `g'
        if "`glab'"=="" local glab "`g'"

        putexcel A`row' = ("`glab'")
        putexcel B`row' = (`n_g')
        putexcel C`row' = (`e_g')

        local row = `row' + 1
    }

restore

********************************************************************************
** 16. MI NOTES
********************************************************************************

open_section_log MI_NOTES

putexcel set "$xlsx", sheet("MI_Imputation_Guide") modify

putexcel A1  = ("Multiple imputation guide")
putexcel A3  = ("Primary adjusted analyses use mi estimate after chained-equations imputation.")
putexcel A4  = ("Only baseline covariates are imputed.")
putexcel A5  = ("Imputed covariates: age, education category, HEI-2010, poverty status, smoking, and alcohol.")
putexcel A6  = ("Not imputed: BMI, waist circumference, BMI/WC categories, sex, race.")
putexcel A7  = ("Not imputed: baseline diabetes status, follow-up time, and incident diabetes outcome.")
putexcel A8  = ("Flowchart step 7 is the MI-eligible sample.")
putexcel A9  = ("Flowchart step 8 is the complete-covariate comparator before imputation.")

putexcel A11 = ("MI settings")
putexcel A12 = ("Number of imputations")
putexcel A13 = ("Random seed")

putexcel A15 = ("Interpretation")
putexcel A16 = ("The MI-eligible sample is the primary adjusted analytic sample.")
putexcel A17 = ("Complete-case Cox model sheets are intentionally not exported in this MI-primary version.")
putexcel A18 = ("Concordance is summarized across imputed datasets and is not Rubin-pooled.")

********************************************************************************
** 17. SAVE FINAL ANALYTIC DATASET AND CLOSE
********************************************************************************

open_section_log SAVE_FINAL

compress
save "$datadir\HANDLS_BMIWCDIABETES_MI_ANALYTIC_WOMEN_FINAL_MANUSCRIPT_ALIGNED.dta", replace

preserve
    mi extract 0, clear
    keep if mi_eligible==1
    compress
    save "$datadir\HANDLS_BMIWCDIABETES_M0_MI_ELIGIBLE_WOMEN_FINAL_MANUSCRIPT_ALIGNED.dta", replace
restore

putexcel set "$xlsx", sheet("README") modify

putexcel A13 = ("Final output files")
putexcel A14 = ("Main MI text log")
putexcel B14 = ("$mainlog")
putexcel A15 = ("Main MI Excel workbook")
putexcel B15 = ("$xlsx")
putexcel A16 = ("Figure directory")
putexcel B16 = ("$figdir")
putexcel A17 = ("Saved MI dataset")
putexcel B17 = ("$datadir\HANDLS_BMIWCDIABETES_MI_ANALYTIC_WOMEN_FINAL_MANUSCRIPT_ALIGNED.dta")
putexcel A18 = ("Saved m=0 MI-eligible dataset")
putexcel B18 = ("$datadir\HANDLS_BMIWCDIABETES_M0_MI_ELIGIBLE_WOMEN_FINAL_MANUSCRIPT_ALIGNED.dta")
putexcel A20 = ("Concordance output")
putexcel B20 = ("Concordance_BMI_MI and Concordance_BMIWC_MI sheets")

capture noisily log close
exit, clear

********************************************************************************
* END OF HANDLS MI-PRIMARY MAIN RESULTS ANALYSIS
********************************************************************************