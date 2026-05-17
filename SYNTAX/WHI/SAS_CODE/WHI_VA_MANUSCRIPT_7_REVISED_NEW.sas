/*LIBNAME STATEMENT*/

LIBNAME VA7 "/home/u51629357/WHI_2026_MANUSCRIPTS";

/*FORMATS*/

PROC FORMAT;
VALUE OBESITYF
1 =	"Underweight (< 18.5)"		
2 =	"Normal (18.5 - 24.9)"		
3 =	"Overweight (25.0 - 29.9)"		
4 =	"Obesity I (30.0 - 34.9)"		
5 =	"Obesity II (35.0 - 39.9)"		
6 =	"Extreme Obesity III (>= 40)"		
;


VALUE AGERF
  1="50-59"
  2="60-69"
  3="70-79+"
  ;

VALUE RACENIHF
		1="American Indian/Alaska Native"
		2="Asian"
		3="Native Hawaiian/Other PI"
		4="Black"
		5="White"
		6="More than one race"
		9="Unknown/Not reported";		

VALUE ETHNICNIHF
		0="Not Hispanic/Latino"
		1="Hispanic/Latino"
		9="Unknown/Not reported";
		

VALUE MARITAL_BRF
		1="MARRIED / PARTNERED"
		2="SINGLE"
		3="DIVORCED"
		4="WIDOWED"
;


VALUE EDUCBRF
		1="< HS"
		2="HS"
		3="SOME COLLEGE"
		4="COMPLETED COLLEGE OR HIGHER"
;

VALUE OCCUPF
 1="Managerial/professional" 
 2="Technical/sales/administrative"
 3="Service/labor"
 4="Homemaker"
 5="Other"
 6="Not working/Retired/Disabled"
 99="Missing"
 
 ;


VALUE INCOME_BRF
		1="<20,000"
		2="20,000-49,999"
		3="50,000-99,999"
		4="100,000+"
		99="Missing"
;


VALUE SMOKING_BRF
		1="NEVER SMOKER" 
		2="PAST SMOKER"
		3="CURRENT SMOKER"
		;

VALUE ALCOHOL_BRF
		1="NON-DRINKER"
		2="FORMER DRINKER"
		3="<1 DRINK/WEEK"
		4=">= 1 DRINK / WEEK"		
;

VALUE YESNO
		1="YES"
		0="NO"
;
VALUE WC_BMI 
  1="≥ 80 cm (normal weight)"
  2="≥ 90 cm (overweight)"
  3="≥ 105 cm (obesity-1)"
  4="≥ 115 cm (obesity-2)"
  5="≥ 115 cm (obesity-3)"
  6="< 80 cm (normal weight)"
  7="< 90 cm (overweight)"
  8="< 105 cm (obesity-1)"
  9="< 115 cm (obesity-2)"
  10="< 115 cm (obesity-3)"
;
RUN;


/* Generated Code (IMPORT) */
/* Source File: WHI_ANALYTIC_AFTER_FLOWCHART_COMPACT.xlsx */
/* Source Path: /home/u51629357/WHI_2026_MANUSCRIPTS/MANUSCRIPT_7 */
/* Code generated on: 5/4/26, 9:48 AM */

%web_drop_table(VA7.VA7COMPACT);


FILENAME REFFILE '/home/u51629357/WHI_2026_MANUSCRIPTS/MANUSCRIPT_7/WHI_ANALYTIC_AFTER_FLOWCHART_COMPACT.xlsx';

PROC IMPORT DATAFILE=REFFILE
	DBMS=XLSX
	OUT=VA7.VA7COMPACT;
	GETNAMES=YES;
RUN;

PROC CONTENTS DATA=VA7.VA7COMPACT ORDER=VARNUM; RUN;

proc freq data=VA7.VA7COMPACT; tables train70;RUN;

/*database: WHI_DATABASE_2026*/
/*WHI data dictionary: https://www.whi.org/datasets*/

/*PROC CONTENTS*/

PROC CONTENTS DATA=VA7.f20_ctos_inv order=varnum;RUN;/*161779*/ *https://www.whi.org/dataset/458;
PROC CONTENTS DATA=VA7.dem_ctos_inv order=varnum;RUN;/*161808*/ *https://www.whi.org/dataset/1025;
PROC CONTENTS DATA=VA7.f41_imputed_ctos_inv order=varnum;RUN;/*161808*/ *https://www.whi.org/dataset/811;
PROC CONTENTS DATA=VA7.f34_ctos_inv order=varnum;RUN;/*161625*/ *https://www.whi.org/dataset/1163;
PROC CONTENTS DATA=VA7.f60_hei_2015_inv order=varnum;RUN;/*378571*/ *;*https://www.whi.org/dataset/1141;
PROC CONTENTS DATA=VA7.f80_ctos_inv order=varnum;RUN;/*679883*/*https://www.whi.org/dataset/707;
PROC CONTENTS DATA=VA7.f2_ctos_inv order=varnum;RUN;/*161808*/*https://www.whi.org/dataset/1581;
PROC CONTENTS DATA=VA7.f30_ctos_inv order=varnum;RUN;/*161701*/*https://www.whi.org/dataset/894;
PROC CONTENTS DATA=VA7.f37_ctos_inv order=varnum;RUN;/*218571*/*https://www.whi.org/dataset/805;
PROC CONTENTS DATA=VA7.f44_ctos_inv order=varnum;RUN;/*1469666*/*https://www.whi.org/dataset/928;

PROC CONTENTS DATA=VA7.f134_ctos_inv ORDER=VARNUM;RUN;/*114123: F134DIAB*/ /*https://www.whi.org/dataset/457*/
PROC CONTENTS DATA=VA7.f33x_ctos_inv ORDER=VARNUM;RUN;/*3321200: https://www.whi.org/dataset/1301*/

PROC CONTENTS DATA=va7.outc_self_ctos_inv;RUN;/*161,808*/
PROC CONTENTS DATA=VA7.outc_self_x2_mrc_inv order=varnum;RUN;/*22316*/*https://www.whi.org/dataset/613;
PROC CONTENTS DATA=VA7.outc_self_x2_src_inv order=varnum;RUN;/*71251*/*https://www.whi.org/dataset/1032;

PROC CONTENTS DATA=VA7.outc_ct_os_inv order=varnum;RUN;/*161808*/*https://www.whi.org/dataset/1059;
PROC CONTENTS DATA=VA7.outc_death_all_discovered_inv order=varnum;RUN;/*161808*/*https://www.whi.org/dataset/687;
PROC CONTENTS DATA=VA7.outc_death_inv order=varnum;RUN;/*56111*/*https://www.whi.org/dataset/476;

/***DATA MANAGEMENT***/

/*BMI*/

DATA BMI;
SET VA7.f80_ctos_inv;
IF F80VTYP=1;
KEEP ID F80DAYS F80VTYP F80VY F80VCLO F80EXPC BMI BMIC;
FORMAT BMIC OBESITYF.;
RUN;

PROC CONTENTS DATA=BMI ORDER=VARNUM;RUN;

PROC MEANS DATA=BMI; VAR BMI;RUN;
PROC UNIVARIATE DATA=BMI; VAR BMI;RUN;

PROC FREQ DATA=BMI; TABLES BMIC / MISSING;RUN;


/*WC*/

DATA WC;
SET VA7.f80_ctos_inv;
IF F80VTYP=1;
KEEP ID F80DAYS F80VTYP F80VY F80VCLO F80EXPC WAIST;
RUN;

PROC CONTENTS DATA=WC ORDER=VARNUM;RUN;

PROC MEANS DATA=WC; VAR WAIST;RUN;
PROC UNIVARIATE DATA=WC; VAR WAIST;RUN;

/*WC BY BMI*/

/*Body-mass index specific waist circumference categories
  ≥ 80 cm (normal weight)
  ≥ 90 cm (overweight)
  ≥ 105 cm (obesity-1)
  ≥ 115 cm (obesity-2)
  ≥ 115 cm (obesity-3)
  < 80 cm (normal weight)
  < 90 cm (overweight)
  < 105 cm (obesity-1)
  < 115 cm (obesity-2)
  < 115 cm (obesity-3)
*/

/*2 =	"Normal (18.5 - 24.9)"		
3 =	"Overweight (25.0 - 29.9)"		
4 =	"Obesity I (30.0 - 34.9)"		
5 =	"Obesity II (35.0 - 39.9)"		
6 =	"Extreme Obesity III (>= 40)"		
*/

proc sort data=BMI; by id;run;
proc sort data=WC; by id;run;

data bmi_wc;
merge bmi wc;
by id;
run;

data bmi_wc;
set bmi_wc;
if bmic=1 then bmi_wc=88;
if bmic=. or waist=. then bmi_wc=99;
if (bmic=2 & waist>=80) then bmi_wc=1;
if (bmic=3 & waist>=90) then bmi_wc=2;
if (bmic=4 & waist>=105) then bmi_wc=3;
if (bmic=5 & waist>=115) then bmi_wc=4;
if (bmic=6 & waist>=115) then bmi_wc=5;
if (bmic=2 & waist<80 & waist ne .) then bmi_wc=6;
if (bmic=3 & waist<90 & waist ne .) then bmi_wc=7;
if (bmic=4 & waist<105 & waist ne .) then bmi_wc=8;
if (bmic=5 & waist<115 & waist ne .) then bmi_wc=9;
if (bmic=6 & waist<115 & waist ne .) then bmi_wc=10;

run;

proc freq data=bmi_wc; tables bmi_wc;run;

/*AGE*/

PROC CONTENTS DATA=VA7.dem_ctos_inv ORDER=VARNUM;RUN;

DATA AGE;
SET VA7.dem_ctos_inv;
IF AGE >= 50 & AGE < 60 THEN AGE_BR=1;
ELSE IF AGE >= 60 & AGE < 70 THEN AGE_BR=2;
ELSE IF AGE >= 70 THEN AGE_BR=3;
FORMAT AGE_BR AGERF.;
KEEP ID AGE AGE_BR;
RUN;

PROC MEANS DATA=AGE; VAR AGE;RUN;
PROC FREQ DATA=AGE; TABLES AGE_BR; RUN;


/*RACE & ETHNICITY*/

PROC CONTENTS DATA=VA7.f41_imputed_ctos_inv ORDER=VARNUM;RUN;

DATA RACE_ETHNICITY;
SET VA7.f41_imputed_ctos_inv;
RACE=RACENIH;
ETHNICITY=ETHNICNIH;
IF RACE=4 then RACE_BR=1;
ELSE IF RACE=5 then RACE_BR=2;
ELSE IF RACE IN (1,2,3) THEN RACE_BR=3;
ELSE IF RACE=6 THEN RACE_BR=4;
IF ETHNICITY IN (1,0) THEN ETHNICITY_BR=ETHNICITY; 
FORMAT RACE RACENIHF. ETHNICITY ETHNICNIHF. ;
KEEP ID RACENIH ETHNICNIH RACE ETHNICITY RACE_BR ETHNICITY_BR;
RUN;

PROC FREQ DATA=RACE_ETHNICITY; TABLES RACE ETHNICITY RACE_BR ETHNICITY_BR; RUN;


/*MARITAL STATUS*/

PROC CONTENTS DATA=VA7.f20_ctos_inv ORDER=VARNUM;RUN;

DATA MARITAL;
SET VA7.f20_ctos_inv;
IF MARITAL IN (4,5) THEN MARITAL_BR=1; /*MARRIED / PARTNERED*/
ELSE IF MARITAL = 1 THEN MARITAL_BR=2; /*SINGLE*/
ELSE IF MARITAL = 2 THEN MARITAL_BR=3; /*DIVORCED*/
ELSE IF MARITAL = 3 THEN MARITAL_BR=4; /*WIDOWED*/
FORMAT MARITAL_BR MARITAL_BRF.;
KEEP ID MARITAL MARITAL_BR;
RUN;

PROC FREQ DATA=MARITAL; TABLES MARITAL_BR; RUN;


/*EDUCATION*/

PROC CONTENTS DATA=VA7.dem_ctos_inv ORDER=VARNUM;RUN;

DATA EDUCATION;
SET VA7.dem_ctos_inv;
IF EDUC IN (1,2,3,4) THEN EDUC_BR=1; /*< HS*/
ELSE IF EDUC =5 THEN EDUC_BR=2; /*HS*/
ELSE IF EDUC IN (6,7) THEN EDUC_BR=3; /*SOME COLLEGE*/
ELSE IF EDUC IN (8, 9, 10, 11) THEN EDUC_BR=4; /*COMPLETED COLLEGE OR HIGHER*/
FORMAT EDUC_BR EDUCBRF.;
KEEP ID EDUC EDUC_BR;
RUN;

PROC FREQ DATA=EDUCATION; TABLES EDUC_BR; RUN;

/*OCCUPATION*/

PROC CONTENTS DATA=VA7.f20_ctos_inv ORDER=VARNUM;RUN;

proc freq data=VA7.f20_ctos_inv;
tables 
JOBHMMKR
JOBMANGR
JOBTECH
JOBSERV
JOBLABOR
JOBOTH
;run;

DATA OCCUPATION;
SET VA7.f20_ctos_inv;
IF EMPLOYED=1 & JOBMANGR=1 THEN OCCUPATION=1;
ELSE IF JOBTECH=1 THEN OCCUPATION=2;
ELSE IF (JOBSERV=1 or JOBLABOR=1) THEN OCCUPATION=3;
ELSE IF JOBHMMKR=1 THEN OCCUPATION=4;
ELSE IF JOBOTH=1 THEN OCCUPATION=5;
ELSE IF (NOTWRK=1 or RETIRED=1 or DISABLED=1)  THEN OCCUPATION=6;
ELSE OCCUPATION=99;
FORMAT OCCUPATION OCCUPF.;
KEEP ID OCCUPATION;
RUN;

PROC FREQ DATA=OCCUPATION; TABLES OCCUPATION;RUN;


/*HOUSEHOLD INCOME*/

PROC CONTENTS DATA=VA7.dem_ctos_inv ORDER=VARNUM;RUN;

DATA HOUSEHOLD_INCOME;
SET VA7.dem_ctos_inv;
IF INCOME IN (1,2) THEN INCOME_BR=1; /*<20,000*/
ELSE IF INCOME IN (3,4) THEN INCOME_BR=2;/*20,000-49,999*/
ELSE IF INCOME IN (5,6) THEN INCOME_BR=3;/*50,000-99,999*/
ELSE IF INCOME IN (7,8) THEN INCOME_BR=4; /*100,000+*/
ELSE IF (INCOME=. | INCOME=9) THEN INCOME_BR=99; /*Missing*/
FORMAT INCOME_BR INCOME_BRF.;
KEEP ID INCOME INCOME_BR;
RUN;

PROC FREQ DATA=HOUSEHOLD_INCOME; TABLES INCOME_BR;RUN;


/*SMOKING STATUS*/

PROC CONTENTS DATA=VA7.f34_ctos_inv ORDER=VARNUM;RUN;

DATA SMOKING_STATUS;
SET VA7.f34_ctos_inv;
SMOKING_BR=SMOKING+1; /*1=NEVER SMOKER, 2=PAST SMOKER, 3=CURRENT SMOKER*/
FORMAT SMOKING_BR SMOKING_BRF.;
KEEP ID SMOKING_BR;

RUN;

PROC FREQ DATA=SMOKING_STATUS; TABLES SMOKING_BR;RUN;


/*ALCOHOL CONSUMPTION*/

PROC CONTENTS DATA=VA7.f34_ctos_inv ORDER=VARNUM;RUN;

DATA ALCOHOL;
SET VA7.f34_ctos_inv;
IF ALCOHOL=1 THEN ALCOHOL_BR=1; /*NON-DRINKER*/
ELSE IF ALCOHOL=2 THEN ALCOHOL_BR=2; /*FORMER DRINKER*/
ELSE IF ALCOHOL IN (3,4) THEN ALCOHOL_BR=3; /*<1 DRINK/WEEK*/
ELSE IF ALCOHOL IN (5,6) THEN ALCOHOL_BR=4; /*>= 1 DRINK / WEEK*/
FORMAT ALCOHOL_BR ALCOHOL_BRF.;
KEEP ID ALCOHOL ALCOHOL_BR;
RUN;

PROC FREQ DATA=ALCOHOL; TABLES ALCOHOL_BR;RUN;


/*HEALTHY EATING INDEX - 2015*/

PROC CONTENTS DATA=VA7.f60_hei_2015_inv;RUN;
PROC FREQ DATA=VA7.f60_hei_2015_inv; TABLES F60VY;RUN;

DATA HEI_15;
SET VA7.f60_hei_2015_inv;
KEEP ID HEI2015_TOTAL_SCORE;
IF F60VY=0;
RUN;

PROC CONTENTS DATA=HEI_15;RUN;

PROC MEANS DATA=HEI_15; VAR HEI2015_TOTAL_SCORE;RUN;


/*PHYSICAL ACTIVITY*/

PROC CONTENTS DATA=VA7.f34_ctos_inv ORDER=VARNUM;RUN;

DATA PHYSICAL_ACTIVITY;
SET VA7.f34_ctos_inv;
PHYSICAL_ACTIVITY_MET=TEXPWK;
KEEP ID TEXPWK PHYSICAL_ACTIVITY_MET;
RUN;

PROC MEANS DATA=PHYSICAL_ACTIVITY; VAR PHYSICAL_ACTIVITY_MET;RUN;


/*PREVALENT DIABETES*/

PROC CONTENTS DATA=VA7.f2_ctos_inv ORDER=VARNUM;RUN;
/*DIAB
DIABAGE
DIABCOMA
DIABNW
DIABPILL
DIABTRT
*/

proc freq data=VA7.f2_ctos_inv; tables DIAB
DIABAGE
DIABCOMA
DIABNW
DIABPILL
DIABTRT
;run;

PROC CONTENTS DATA=VA7.f134_ctos_inv;RUN;/*114123: F134DIAB*/

PROC FREQ DATA=VA7.f134_ctos_inv; TABLES F134DIAB;RUN;
PROC MEANS DATA=VA7.f134_ctos_inv; VAR F134DAYS;RUN;

PROC SORT DATA=VA7.f2_ctos_inv; BY ID;RUN;
PROC SORT DATA=VA7.f134_ctos_inv; BY ID;RUN;

DATA PREVALENT_DIABETES;
MERGE VA7.f2_ctos_inv VA7.f134_ctos_inv;
BY ID;

/* Corrected baseline prevalent diabetes definition.
   The prior code required diabetes medication variables, but DIABPILL/DIABTRT
   are not usable for identifying all baseline prevalent cases here, which led to
   PREVALENT_DIABETES being zero for everyone. For baseline exclusion, use
   baseline F2 self-report indicators. Keep F134DIAB only for checking, not for
   baseline prevalent exclusion unless you confirm it is a baseline form. */
IF DIAB=1 OR DIABCOMA=1 OR DIABNW=1 OR DIABPILL=1 OR DIABTRT=1 THEN PREVALENT_DIABETES=1;
ELSE PREVALENT_DIABETES=0;

KEEP ID PREVALENT_DIABETES
DIAB
DIABAGE
DIABCOMA
DIABNW
DIABPILL
DIABTRT
F134DIAB;
RUN;

proc freq data=PREVALENT_DIABETES; tables PREVALENT_DIABETES;run;

/*INCIDENT DIABETES*/

PROC CONTENTS DATA=va7.outc_self_ctos_inv;RUN;/*161,808*/

/*F33DIABTX= "F33 Diabetes Treated"
F33DIABTXDY= "Days enrollment to F33 Diabetes Treated"
F33DIABINSULIN= "F33 Diabetes Insulin"
F33DIABINSULINDY= "Days enrollment to F33 Diabetes Insulin"
F33DIABPILLS= "F33 Diabetes Pills"
F33DIABPILLSDY= "Days enrollment to F33 Diabetes Pills"
*/

PROC FREQ DATA=va7.outc_self_ctos_inv; TABLES F33DIABINSULIN F33DIABPILLS F33DIABDIETEX  F33DIABTX;RUN;
PROC MEANS DATA=va7.outc_self_ctos_inv; VAR F33DIABINSULINDY F33DIABPILLSDY F33DIABDIETEXDY F33DIABTXDY;RUN;

DATA DIAB_SELF;
SET va7.outc_self_ctos_inv;

KEEP ID F33DIABINSULIN F33DIABPILLS F33DIABDIETEX  F33DIABTX
F33DIABINSULINDY F33DIABPILLSDY F33DIABDIETEXDY F33DIABTXDY;

RENAME

F33DIABINSULIN = F33DIABINSULIN_SELF
F33DIABPILLS = F33DIABPILLS_SELF
F33DIABDIETEX = F33DIABDIETEX_SELF 
F33DIABTX = F33DIABTX_SELF
F33DIABINSULINDY = F33DIABINSULINDY_SELF 
F33DIABPILLSDY = F33DIABPILLSDY_SELF
F33DIABDIETEXDY = F33DIABDIETEXDY_SELF
F33DIABTXDY = F33DIABTXDY_SELF;
RUN;

proc contents data=DIAB_SELF;run;

proc contents data=PREVALENT_DIABETES;run;/*161,808*/

proc contents DATA=VA7.outc_self_x2_mrc_inv;RUN;/*22,316*/
/*F33DIABDIEX F33DIABDIEXDY*/
/*F33DIABINSULIN F33DIABINSULINDY*/
/*F33DIABPILLS F33DIABPILLSDY*/
/*F33DIABTX F33DIABTXDY*/

PROC FREQ DATA=VA7.outc_self_x2_mrc_inv; TABLES F33DIABDIEX F33DIABINSULIN F33DIABPILLS F33DIABTX;RUN;
PROC MEANS DATA=VA7.outc_self_x2_mrc_inv; VAR F33DIABDIEXDY F33DIABINSULINDY F33DIABPILLSDY F33DIABTXDY;RUN;

PROC contents DATA=VA7.outc_self_x2_src_inv;RUN;/*71,251*/
/*F33DIABDIEX F33DIABDIEXDY*/
/*F33DIABINSULIN F33DIABINSULINDY*/
/*F33DIABPILLS F33DIABPILLSDY*/
/*F33DIABTX F33DIABTXDY*/

PROC FREQ DATA=VA7.outc_self_x2_src_inv; TABLES F33DIABDIEX F33DIABINSULIN F33DIABPILLS F33DIABTX;RUN;
PROC MEANS DATA=VA7.outc_self_x2_src_inv; VAR F33DIABDIEXDY F33DIABINSULINDY F33DIABPILLSDY F33DIABTXDY;RUN;

 

PROC contents DATA=VA7.outc_ct_os_inv; RUN;/*ENDFOLLOWDY
DEATH
DEATHDY*//*161808*/

/* Rename MRC and SRC diabetes variables before merging.
   Without renaming, variables with identical names from the later dataset can
   overwrite the earlier dataset during MERGE. */

DATA DIAB_MRC;
SET VA7.outc_self_x2_mrc_inv;
KEEP ID F33DIABDIEX F33DIABDIEXDY F33DIABINSULIN F33DIABINSULINDY
        F33DIABPILLS F33DIABPILLSDY F33DIABTX F33DIABTXDY;
RENAME
    F33DIABDIEX     = F33DIABDIEX_MRC
    F33DIABDIEXDY   = F33DIABDIEXDY_MRC
    F33DIABINSULIN  = F33DIABINSULIN_MRC
    F33DIABINSULINDY= F33DIABINSULINDY_MRC
    F33DIABPILLS    = F33DIABPILLS_MRC
    F33DIABPILLSDY  = F33DIABPILLSDY_MRC
    F33DIABTX       = F33DIABTX_MRC
    F33DIABTXDY     = F33DIABTXDY_MRC;
RUN;

DATA DIAB_SRC;
SET VA7.outc_self_x2_src_inv;
KEEP ID F33DIABDIEX F33DIABDIEXDY F33DIABINSULIN F33DIABINSULINDY
        F33DIABPILLS F33DIABPILLSDY F33DIABTX F33DIABTXDY;
RENAME
    F33DIABDIEX     = F33DIABDIEX_SRC
    F33DIABDIEXDY   = F33DIABDIEXDY_SRC
    F33DIABINSULIN  = F33DIABINSULIN_SRC
    F33DIABINSULINDY= F33DIABINSULINDY_SRC
    F33DIABPILLS    = F33DIABPILLS_SRC
    F33DIABPILLSDY  = F33DIABPILLSDY_SRC
    F33DIABTX       = F33DIABTX_SRC
    F33DIABTXDY     = F33DIABTXDY_SRC;
RUN;

PROC SORT DATA=PREVALENT_DIABETES; BY ID;RUN;
PROC SORT DATA=DIAB_MRC; BY ID;RUN;
PROC SORT DATA=DIAB_SRC; BY ID;RUN;
PROC SORT DATA=DIAB_SELF; BY ID;RUN;
PROC SORT DATA=VA7.outc_ct_os_inv; BY ID;RUN;

DATA INCIDENT_DIABETES;
MERGE PREVALENT_DIABETES DIAB_MRC DIAB_SRC DIAB_SELF VA7.outc_ct_os_inv;
BY ID;

/* Use the first diabetes diagnosis or treatment date.
   The previous code used insulin/pill treatment only, which made the earliest
   diabetes event appear around 12 years after enrollment. */
DIAB_EVENT_DAY = MIN(
    F33DIABDIEXDY_SELF, F33DIABINSULINDY_SELF, F33DIABPILLSDY_SELF, F33DIABTXDY_SELF,
    F33DIABDIEXDY_MRC, F33DIABINSULINDY_MRC, F33DIABPILLSDY_MRC, F33DIABTXDY_MRC,
    F33DIABDIEXDY_SRC, F33DIABINSULINDY_SRC, F33DIABPILLSDY_SRC, F33DIABTXDY_SRC
);

CENSOR_DAY = MIN(DEATHDY, ENDFOLLOWDY);

IF PREVALENT_DIABETES THEN DELETE;

IF DIAB_EVENT_DAY NE . AND DIAB_EVENT_DAY <= CENSOR_DAY THEN DO;
    INCIDENT_DIABETES = 1;
    TTE_DIABETES_DAYS = DIAB_EVENT_DAY;
END;
ELSE DO;
    INCIDENT_DIABETES = 0;
    TTE_DIABETES_DAYS = CENSOR_DAY;
END;

/* Analysis time in years since WHI baseline. */
TTE_DIABETES_YRS = TTE_DIABETES_DAYS / 365.25;
PY = TTE_DIABETES_YRS;

/* Keep legacy name but make it explicitly years for downstream models. */
TTE_DIABETES = TTE_DIABETES_YRS;

KEEP ID INCIDENT_DIABETES TTE_DIABETES TTE_DIABETES_DAYS TTE_DIABETES_YRS PY
     DIAB_EVENT_DAY CENSOR_DAY DEATHDY ENDFOLLOWDY
     F33DIABDIEXDY_SELF F33DIABINSULINDY_SELF F33DIABPILLSDY_SELF F33DIABTXDY_SELF
     F33DIABDIEXDY_MRC F33DIABINSULINDY_MRC F33DIABPILLSDY_MRC F33DIABTXDY_MRC
     F33DIABDIEXDY_SRC F33DIABINSULINDY_SRC F33DIABPILLSDY_SRC F33DIABTXDY_SRC;
RUN;

PROC FREQ DATA=INCIDENT_DIABETES; TABLES INCIDENT_DIABETES;RUN;
PROC MEANS DATA=INCIDENT_DIABETES MIN P1 P5 MEDIAN MEAN MAX;
VAR DIAB_EVENT_DAY CENSOR_DAY TTE_DIABETES_DAYS TTE_DIABETES_YRS PY;
RUN;

/**MERGED DATASET**/

proc sort data=BMI; by id;run;
proc sort data=WC; by id;run;
proc sort data=bmi_wc; by id;run;
proc sort data=AGE; by id;run;
proc sort data=RACE_ETHNICITY; by id;run;
proc sort data=MARITAL; by id;run;
proc sort data=EDUCATION; by id;run;
proc sort data=OCCUPATION; by id;run;
proc sort data=HOUSEHOLD_INCOME; by id;run;
proc sort data=SMOKING_STATUS; by id;run;
proc sort data=ALCOHOL; by id;run;
proc sort data=HEI_15; by id;run;
proc sort data=PHYSICAL_ACTIVITY; by id;run;
proc sort data=PREVALENT_DIABETES; by id;run;
proc sort data=INCIDENT_DIABETES; by id;run;

data VA7.MERGED_MAN7;
MERGE
BMI
WC
bmi_wc
AGE
RACE_ETHNICITY
MARITAL
EDUCATION
OCCUPATION
HOUSEHOLD_INCOME
SMOKING_STATUS
ALCOHOL
HEI_15
PHYSICAL_ACTIVITY
PREVALENT_DIABETES
INCIDENT_DIABETES
; by id;run;


ODS OUTPUT CLOSE;

title "descriptives";

/*DESCRIPTIVE STATISTICS*/

PROC FREQ DATA=VA7.MERGED_MAN7;
TABLES AGE_BR
RACE_BR ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
PREVALENT_DIABETES
INCIDENT_DIABETES
;RUN;

PROC MEANS DATA=VA7.MERGED_MAN7 MEAN STD Q1 Q3 MIN MAX; VAR AGE HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET TTE_DIABETES;RUN;

/**DATA ANALYSIS**/

title "figure 1";

/*Figure 1. Study flowchart*/

/*Women’s Health Initiative Clinical Trials and Observation Study*/

PROC CONTENTS DATA=VA7.MERGED_MAN7;RUN;/*161,808*/

/*No self-reported history of diabetes at WHI enrollment (1993—1998)*/

DATA A;
SET VA7.MERGED_MAN7;
IF PREVALENT_DIABETES=0;
RUN;

/*152,190*/

/*No missing data on exposures at WHI enrollment (1993—1998)*/

DATA B;
SET A;
IF BMI_WC NOTIN (.,99);
RUN;

/*150,428*/

/*Body Mass Index ≥ 18.5 kg/m2 at WHI enrollment (1993—1998)
*/

PROC FREQ DATA=B; TABLES BMIC;RUN;

DATA C;
SET B;
IF BMIC > 1;
RUN; 

/*150,428*/

/*No missing data on covariates at WHI enrollment (1993—1998)*/

DATA D;
SET C;
IF 
AGE_BR NE . &
RACE_BR NE . & 
ETHNICITY_BR NOTIN (99,.) &
MARITAL_BR NE . &
EDUC_BR NE . &
OCCUPATION NE . &
INCOME_BR NE . &
SMOKING_BR NE . &
ALCOHOL_BR NE . &
HEI2015_TOTAL_SCORE NE . &
PHYSICAL_ACTIVITY_MET NE .;
RUN;

/*135,109*/

/*Follow-up > 12 months. TTE_DIABETES is now in years. */

DATA VA7.MERGED_MAN7_FINAL;
SET D;
IF TTE_DIABETES_DAYS > 364.25;
RUN;

/*133,649*/

PROC MEANS DATA=VA7.MERGED_MAN7_FINAL MEAN STD Q1 Q3 MIN MAX; VAR TTE_DIABETES; 
WHERE INCIDENT_DIABETES=0;RUN;
PROC MEANS DATA=VA7.MERGED_MAN7_FINAL MEAN STD Q1 Q3 MIN MAX; VAR TTE_DIABETES; 
WHERE INCIDENT_DIABETES=1;RUN;

DATA VA7COMPACTID;
SET VA7.VA7COMPACT;
ID=HHIDPN;
KEEP ID train70;
RUN;

PROC CONTENTS DATA=VA7COMPACTID ORDER=VARNUM;RUN;

PROC SORT DATA=VA7.MERGED_MAN7_FINAL; BY ID;RUN;
PROC SORT DATA=VA7COMPACTID; BY ID;RUN;

DATA VA7.MERGED_MAN7_VF;
MERGE VA7.MERGED_MAN7_FINAL VA7COMPACTID (IN=A);
BY ID;
IF A;
RUN;


/*133,620*/

/*WHI TRAINING AND TEST DATASETS*/

DATA VA7.train_vf;
SET VA7.MERGED_MAN7_VF;
IF train70=1;
RUN;

DATA VA7.validation_vf;
SET VA7.MERGED_MAN7_VF;
IF train70=0;
RUN;


title "figure 2";

/*
Figure 2. Kaplan-Meier curve for diabetes risk by body mass index categories

A = WHI
B = HANDLS
C = HRS

*/

ods select survivalplot;


proc lifetest data=VA7.MERGED_MAN7_VF plots=survival(atrisk);
strata BMIC;
time TTE_DIABETES*INCIDENT_DIABETES(0);
LABEL TTE_DIABETES="Time to event";
LABEL INCIDENT_DIABETES="Incident diabetes";
LABEL BMIC = "BMI (kg/m2)";
format BMIC OBESITYF.;
run;

ODS SELECT CLOSE;


title "figure 3";

/*
Figure 3. Kaplan-Meier curve for diabetes risk by body mass index-specific waist circumference thresholds

A = WHI
B = HANDLS
C = HRS

*/

ods select survivalplot;

proc lifetest data=VA7.MERGED_MAN7_VF plots=survival(atrisk);
strata BMI_WC;
time TTE_DIABETES*INCIDENT_DIABETES(0);
LABEL TTE_DIABETES="Time to event";
LABEL INCIDENT_DIABETES="Incident diabetes";
LABEL BMI_WC = "WC-BMI categories";
format BMI_WC WC_BMI.;
run;

ODS SELECT CLOSE;


ODS OUTPUT;

title "table 1";

/*Table 1. Demographic and lifestyle characteristics by body mass index in the WHI analytic sample (n=)*/


PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES 
(AGE_BR
RACE_BR ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
)*BMIC / CHISQ;RUN;

PROC MEANS DATA=VA7.MERGED_MAN7_VF; CLASS BMIC;
VAR AGE HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET;
RUN;

PROC GLM DATA=VA7.MERGED_MAN7_VF; CLASS BMIC; MODEL AGE=BMIC;RUN;
PROC GLM DATA=VA7.MERGED_MAN7_VF; CLASS BMIC; MODEL HEI2015_TOTAL_SCORE=BMIC;RUN;
PROC GLM DATA=VA7.MERGED_MAN7_VF; CLASS BMIC; MODEL PHYSICAL_ACTIVITY_MET=BMIC;RUN;

title "table 2";

/*Table 2. Incident diabetic cases, person-years of follow-up, and incidence rates of diabetes by body mass index categories and body mass index-specific waist circumference categories in the WHI analytic sample (n=)*/

PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES INCIDENT_DIABETES;RUN;
PROC MEANS DATA=VA7.MERGED_MAN7_VF SUM; VAR TTE_DIABETES;RUN;


PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES bmic BMI_WC;RUN;

proc sort data=VA7.MERGED_MAN7_VF; by bmic;run;
PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES INCIDENT_DIABETES;by bmic;RUN;
PROC MEANS DATA=VA7.MERGED_MAN7_VF SUM; VAR TTE_DIABETES;by bmic;RUN;

proc sort data=VA7.MERGED_MAN7_VF; by BMI_WC;run;
PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES INCIDENT_DIABETES;by BMI_WC;RUN;
PROC MEANS DATA=VA7.MERGED_MAN7_VF SUM; VAR TTE_DIABETES;by BMI_WC;RUN;

/* Calculate Table 2 rates directly from the corrected analytic dataset.
   Rates are per 10,000 person-years. */

PROC SUMMARY DATA=VA7.MERGED_MAN7_VF NWAY;
CLASS BMIC;
VAR INCIDENT_DIABETES PY;
OUTPUT OUT=RATE_BMI_RAW(DROP=_TYPE_ _FREQ_)
    N=SAMPLE_SIZE
    SUM(INCIDENT_DIABETES)=CASES
    SUM(PY)=PERSON_YEARS;
RUN;

DATA RATE_BMI;
SET RATE_BMI_RAW;
LENGTH EXPOSURE_TYPE $12 CATEGORY $80;
EXPOSURE_TYPE='BMI';
CATEGORY=PUT(BMIC, OBESITYF.);
RATE_10000PY = CASES / PERSON_YEARS * 10000;
LCL_EXACT = CINV(0.025, 2*CASES) / 2 / PERSON_YEARS * 10000;
UCL_EXACT = CINV(0.975, 2*(CASES+1)) / 2 / PERSON_YEARS * 10000;
RUN;

PROC SUMMARY DATA=VA7.MERGED_MAN7_VF NWAY;
CLASS BMI_WC;
VAR INCIDENT_DIABETES PY;
OUTPUT OUT=RATE_BMIWC_RAW(DROP=_TYPE_ _FREQ_)
    N=SAMPLE_SIZE
    SUM(INCIDENT_DIABETES)=CASES
    SUM(PY)=PERSON_YEARS;
RUN;

DATA RATE_BMIWC;
SET RATE_BMIWC_RAW;
LENGTH EXPOSURE_TYPE $12 CATEGORY $80;
EXPOSURE_TYPE='BMI_WC';
CATEGORY=PUT(BMI_WC, WC_BMI.);
RATE_10000PY = CASES / PERSON_YEARS * 10000;
LCL_EXACT = CINV(0.025, 2*CASES) / 2 / PERSON_YEARS * 10000;
UCL_EXACT = CINV(0.975, 2*(CASES+1)) / 2 / PERSON_YEARS * 10000;
RUN;

DATA RATE_TABLE2;
SET RATE_BMI RATE_BMIWC;
RATE_CI = CATX(' ', PUT(RATE_10000PY, 8.2),
               CATS('(', PUT(LCL_EXACT, 8.2), ', ', PUT(UCL_EXACT, 8.2), ')'));
RUN;

PROC PRINT DATA=RATE_TABLE2 LABEL NOOBS;
VAR EXPOSURE_TYPE CATEGORY CASES SAMPLE_SIZE PERSON_YEARS RATE_CI;
LABEL PERSON_YEARS='Person-years'
      RATE_CI='Rate per 10,000 person-years (95% CI)';
FORMAT PERSON_YEARS COMMA12.1;
RUN;

title "table 3";

/*Table 3. Cox regression models for body mass index as a predictor of diabetes risk, before and after adjustment for a priori confounders, in the training (WHI), validation (WHI), and test samples (HANDLS and HRS)*/

/*SPLIT WHI DATASET INTO TRAINING AND VALIDATION DATASETS*/

proc sort data=VA7.MERGED_MAN7_VF; by id;run;

/* 1. Select 70% of the data for training */
proc surveyselect data=VA7.MERGED_MAN7_VF 
     out=split_data outall 
     samprate=0.7 seed=1234; 
run;

/* 2. Split the output into two datasets based on the 'selected' flag */
data VA7.train VA7.validation;
    set split_data;
        if selected = 1 then output VA7.train;
    else output VA7.validation;
    drop selected;
run;

proc contents data=VA7.train;run;
proc contents data=VA7.validation;run;

/*UNADJUSTED*/

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
 / rl; 
RUN;

PROC PHREG DATA=VA7.train_vf concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
 / rl; 
RUN;

PROC PHREG DATA=VA7.validation_vf concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
 / rl; 
RUN;

/*ADJUSTED -- FULL MODEL*/

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET

 / rl; 
RUN;


PROC PHREG DATA=VA7.train_vf concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl; 
RUN;

PROC PHREG DATA=VA7.validation_vf concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl; 
RUN;

/*ADJUSTED -- REDUCED MODEL*/

/*EXAMPLE*/

/*1. Perform Backward Selection on Training Data*/
/*proc phreg data=training_set outest=model_params outmodel=model_file;
   model time*status(0) = var1 var2 var3 var4 / selection=backward slstay=0.05;
run;
*/

/*2. Apply (Score) the Model to the Test Data*/

/*proc phreg inmodel=model_file;
   proc phreg data=test_set;
   model time*status(0) = var1 var2 var3 var4;
   output out=test_results xbeta=risk_score survival=surv_prob;
run;
*/

/*3. Calculate Concordance on the Test Set */
/*proc phreg data=test_set;
   model time*status(0) = var1 var2 var3 / concordance;run;
   /* Note: Use only the variables selected in the final model here */

PROC  phreg DATA=VA7.train_vf concordance outest=model_params out=model_file; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET 
  / rl selection=forward slstay=0.05;
  output out=test_results1 xbeta=risk_score survival=surv_prob;
run;   

/*AIC: 443752.86*/

PROC  phreg DATA=VA7.train_vf concordance outest=model_params out=model_file; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET 
  / rl selection=backward slstay=0.05;
  output out=test_results2 xbeta=risk_score survival=surv_prob;
run;   

/*AIC: 443752.86 -- SELECT -- REMOVE AGE*/   

PROC  phreg DATA=VA7.train_vf concordance outest=model_params out=model_file; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET 
  / rl selection=stepwise slstay=0.05;
  output out=test_results3 xbeta=risk_score survival=surv_prob;
run;   

/*AIC: 443752.86*/

proc phreg data=VA7.validation_vf concordance;
CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER");
model TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR 
HEI2015_TOTAL_SCORE
/ rl;run;

proc phreg data=test_results2 concordance;
CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER");
model TTE_DIABETES*INCIDENT_DIABETES(0) = risk_score / rl;run;

title "table 4";
  
/*Table 4. Cox regression models for body mass index-specific waist circumference categories as predictors of diabetes risk, before and after adjustment for a priori confounders in the training (WHI), validation (WHI), and test samples (HANDLS and HRS)*/

/*UNADJUSTED*/

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
 / rl; 
 format BMI_WC WC_BMI.;
RUN;

PROC PHREG DATA=VA7.train_vf concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
 / rl; 
 format BMI_WC WC_BMI.;
RUN;

PROC PHREG DATA=VA7.validation_vf concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
 / rl; 
 format BMI_WC WC_BMI.;
RUN;


/*ADJUSTED -- FULL MODEL*/

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET 
 / rl;
 format BMI_WC WC_BMI.;
RUN;

PROC PHREG DATA=VA7.train_vf concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET 
 / rl;
 format BMI_WC WC_BMI.;
RUN;

PROC PHREG DATA=VA7.validation_vf concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET 
 / rl;
 format BMI_WC WC_BMI.;
RUN;

/*ADJUSTED -- REDUCED MODEL*/

/*EXAMPLE*/

/*1. Perform Backward Selection on Training Data*/
/*proc phreg data=training_set outest=model_params outmodel=model_file;
   model time*status(0) = var1 var2 var3 var4 / selection=backward slstay=0.05;
run;
*/

/*2. Apply (Score) the Model to the Test Data*/

/*proc phreg inmodel=model_file;
   proc phreg data=test_set;
   model time*status(0) = var1 var2 var3 var4;
   output out=test_results xbeta=risk_score survival=surv_prob;
run;
*/

/*3. Calculate Concordance on the Test Set */
/*proc phreg data=test_set;
   model time*status(0) = var1 var2 var3 / concordance;run;
   /* Note: Use only the variables selected in the final model here */


PROC  phreg DATA=VA7.train_vf outest=model_params out=model_file; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET  
  / rl selection=forward slstay=0.05;
  output out=test_results1 xbeta=risk_score survival=surv_prob;
   format BMI_WC WC_BMI.;
run;  

/*AIC: 443241.88*/

PROC  phreg DATA=VA7.train_vf concordance outest=model_params out=model_file; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET  
  / rl selection=backward slstay=0.05;
  output out=test_results2 xbeta=risk_score survival=surv_prob;
   format BMI_WC WC_BMI.;
run;  

/*AIC: 443241.88 -- SELECT*/

PROC  phreg DATA=VA7.train_vf outest=model_params out=model_file; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET  
  / rl selection=stepwise slstay=0.05;
  output out=test_results3 xbeta=risk_score survival=surv_prob;
   format BMI_WC WC_BMI.;
run;  

/*AIC: 443241.88*/
   
proc phreg data=VA7.validation_vf concordance;
CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER");
model TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR / rl;
 format BMI_WC WC_BMI.;run;

proc phreg data=test_results2 concordance;
CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER");
model TTE_DIABETES*INCIDENT_DIABETES(0) = risk_score / rl;
format BMI_WC WC_BMI.;run; 

title "table 5";

/*Table 5. Multivariable Cox regression models for body mass index categories as predictors of diabetes risk by age, race, and ethnicity groups, in the WHI analytic sample*/

/*OVERALL*/

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
RUN;



/*BY AGE GROUP*/

proc freq data=VA7.MERGED_MAN7_VF; tables AGE_BR BMIC;run;

data interact1;
set VA7.MERGED_MAN7_VF;
if AGE_BR=2 then age_6069=1; else age_6069=0;
if AGE_BR=3 then age_7079=1; else age_7079=0;
if BMIC=2 then overweight=1; else overweight=0; 
if BMIC=3 then obesity1=1; else obesity1=0; 
if BMIC=4 then obesity2=1; else obesity2=0;
if BMIC=5 then obesity3=1; else obesity3=0;
age_6069overweight=age_6069*overweight;
age_7079overweight=age_7079*overweight;
age_6069obesity1=age_6069*obesity1;
age_7079obesity1=age_7079*obesity1;
age_6069obesity2=age_6069*obesity2;
age_7079obesity2=age_7079*obesity2;
age_6069obesity3=age_6069*obesity3;
age_7079obesity3=age_7079*obesity3;

PROC PHREG DATA=interact1 concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
age_6069overweight
age_7079overweight
age_6069obesity1
age_7079obesity1
age_6069obesity2
age_6069obesity3
age_7079obesity3

 / rl;
 test 
age_6069overweight,
age_7079overweight,
age_6069obesity1,
age_7079obesity1,
age_6069obesity2,
age_6069obesity3,
age_7079obesity3
;
RUN;


PROC SORT DATA=VA7.MERGED_MAN7_VF; BY AGE_BR;RUN;

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 BY AGE_BR;
RUN;


/*BY RACE*/

proc freq data=VA7.MERGED_MAN7_VF; tables RACE_BR BMIC;run;

data interact2;
set VA7.MERGED_MAN7_VF;
if RACE_BR=2 then race2=1; else race2=0;
if RACE_BR=3 then race3=1; else race3=0;
if RACE_BR=4 then race4=1; else race4=0;
if BMIC=2 then overweight=1; else overweight=0; 
if BMIC=3 then obesity1=1; else obesity1=0; 
if BMIC=4 then obesity2=1; else obesity2=0;
if BMIC=5 then obesity3=1; else obesity3=0;
race2overweight=race2*overweight;
race3overweight=race3*overweight;
race4overweight=race4*overweight;
race2obesity1=race2*obesity1;
race3obesity1=race3*obesity1;
race4obesity1=race4*obesity1;
race2obesity2=race2*obesity2;
race3obesity2=race3*obesity2;
race4obesity2=race4*obesity2;
race2obesity3=race2*obesity3;
race3obesity3=race3*obesity3;
race4obesity3=race4*obesity3;
run;

PROC PHREG DATA=interact2 concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
race2overweight
race3overweight
race4overweight
race2obesity1
race3obesity1
race4obesity1
race2obesity2
race3obesity2
race4obesity2
race2obesity3
race3obesity3
/*race4obesity3*/


 / rl;

 test
 race2overweight,
race3overweight,
race4overweight,
race2obesity1,
race3obesity1,
race4obesity1,
race2obesity2,
race3obesity2,
race4obesity2,
race2obesity3,
race3obesity3
/*race4obesity3*/
 ;
RUN;



PROC SORT DATA=VA7.MERGED_MAN7_VF; BY RACE_BR;RUN;

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 BY RACE_BR;
RUN;


/*BY ETHNICITY*/

proc freq data=VA7.MERGED_MAN7_VF; tables ETHNICITY_BR BMIC;run;

data interact3;
set VA7.MERGED_MAN7_VF;
if BMIC=2 then overweight=1; else overweight=0; 
if BMIC=3 then obesity1=1; else obesity1=0; 
if BMIC=4 then obesity2=1; else obesity2=0;
if BMIC=5 then obesity3=1; else obesity3=0;
hispanicoverweight=ETHNICITY_BR*overweight;
hispanicobesity1=ETHNICITY_BR*obesity1;
hispanicobesity2=ETHNICITY_BR*obesity2;
hispanicobesity3=ETHNICITY_BR*obesity3;
run;

PROC PHREG DATA=interact3 concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
hispanicoverweight
hispanicobesity1
hispanicobesity2
hispanicobesity3 / rl;
test
hispanicoverweight,
hispanicobesity1,
hispanicobesity2,
hispanicobesity3;
RUN;


PROC SORT DATA=VA7.MERGED_MAN7_VF; BY ETHNICITY_BR;RUN;

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMIC (ref="Normal (18.5 - 24.9)")
RACE_BR (ref="1")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMIC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 BY ETHNICITY_BR;
RUN;

title "table 6";

/*Table 6. Multivariable Cox regression models for body mass index-specific waist circumference categories as predictors of diabetes risk by age, race, and ethnicity groups, in the WHI analytic sample*/

/*OVERALL*/

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 FORMAT BMI_WC WC_BMI.;
RUN;


/*Body-mass index specific waist circumference categories
  ≥ 80 cm (normal weight)
  ≥ 90 cm (overweight)
  ≥ 105 cm (obesity-1)
  ≥ 115 cm (obesity-2)
  ≥ 115 cm (obesity-3)
  < 80 cm (normal weight)
  < 90 cm (overweight)
  < 105 cm (obesity-1)
  < 115 cm (obesity-2)
  < 115 cm (obesity-3)
*/

/*BY AGE GROUP*/

proc freq data=VA7.MERGED_MAN7_VF; tables AGE_BR BMI_WC;run;

data interact4;
set VA7.MERGED_MAN7_VF;
if AGE_BR=2 then age_6069=1; else age_6069=0;
if AGE_BR=3 then age_7079=1; else age_7079=0;
if BMI_WC=1 then BMI_WC1=1; else BMI_WC1=0; 
if BMI_WC=2 then BMI_WC2=1; else BMI_WC2=0; 
if BMI_WC=3 then BMI_WC3=1; else BMI_WC3=0; 
if BMI_WC=4 then BMI_WC4=1; else BMI_WC4=0;
if BMI_WC=5 then BMI_WC5=1; else BMI_WC5=0;
if BMI_WC=7 then BMI_WC7=1; else BMI_WC7=0;
if BMI_WC=8 then BMI_WC8=1; else BMI_WC8=0;
if BMI_WC=9 then BMI_WC9=1; else BMI_WC9=0;
if BMI_WC=10 then BMI_WC10=1; else BMI_WC10=0;

age_6069bmiwc1=age_6069*BMI_WC1;
age_7079bmiwc1=age_7079*BMI_WC1;
age_6069bmiwc2=age_6069*BMI_WC2;
age_7079bmiwc2=age_7079*BMI_WC2;
age_6069bmiwc3=age_6069*BMI_WC3;
age_7079bmiwc3=age_7079*BMI_WC3;
age_6069bmiwc4=age_6069*BMI_WC4;
age_7079bmiwc4=age_7079*BMI_WC4;
age_6069bmiwc5=age_6069*BMI_WC5;
age_7079bmiwc5=age_7079*BMI_WC5;
age_6069bmiwc7=age_6069*BMI_WC7;
age_7079bmiwc7=age_7079*BMI_WC7;
age_6069bmiwc8=age_6069*BMI_WC8;
age_7079bmiwc8=age_7079*BMI_WC8;
age_6069bmiwc9=age_6069*BMI_WC9;
age_7079bmiwc9=age_7079*BMI_WC9;
age_6069bmiwc10=age_6069*BMI_WC10;
age_7079bmiwc10=age_7079*BMI_WC10;
run;

PROC PHREG DATA=interact4 concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET

age_6069bmiwc1
age_7079bmiwc1
age_6069bmiwc2
age_7079bmiwc2
age_6069bmiwc3
age_7079bmiwc3
age_6069bmiwc4
age_7079bmiwc4
age_6069bmiwc5
age_7079bmiwc5
age_6069bmiwc7
age_7079bmiwc7
age_6069bmiwc8
age_7079bmiwc8
age_6069bmiwc9
age_7079bmiwc9
age_6069bmiwc10
age_7079bmiwc10

 / rl;
 
 test
 
age_6069bmiwc1,
age_7079bmiwc1,
age_6069bmiwc2,
age_7079bmiwc2,
age_6069bmiwc3,
age_7079bmiwc3,
age_6069bmiwc4,
age_7079bmiwc4,
age_6069bmiwc5,
age_7079bmiwc5,
age_6069bmiwc7,
age_7079bmiwc7,
age_6069bmiwc8,
age_7079bmiwc8,
age_6069bmiwc9,
age_7079bmiwc9,
age_6069bmiwc10,
age_7079bmiwc10
 ;
 FORMAT BMI_WC WC_BMI.;
RUN;


PROC SORT DATA=VA7.MERGED_MAN7_VF; BY AGE_BR;RUN;

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 BY AGE_BR;
 FORMAT BMI_WC WC_BMI.;
RUN;


/*BY RACE*/

data interact5;
set VA7.MERGED_MAN7_VF;
if RACE_BR=2 then race2=1; else race2=0;
if RACE_BR=3 then race3=1; else race3=0;
if RACE_BR=4 then race4=1; else race4=0;
if BMI_WC=1 then BMI_WC1=1; else BMI_WC1=0; 
if BMI_WC=2 then BMI_WC2=1; else BMI_WC2=0; 
if BMI_WC=3 then BMI_WC3=1; else BMI_WC3=0; 
if BMI_WC=4 then BMI_WC4=1; else BMI_WC4=0;
if BMI_WC=5 then BMI_WC5=1; else BMI_WC5=0;
if BMI_WC=7 then BMI_WC7=1; else BMI_WC7=0;
if BMI_WC=8 then BMI_WC8=1; else BMI_WC8=0;
if BMI_WC=9 then BMI_WC9=1; else BMI_WC9=0;
if BMI_WC=10 then BMI_WC10=1; else BMI_WC10=0;

race2bmiwc1=race2*BMI_WC1;
race3bmiwc1=race3*BMI_WC1;
race4bmiwc1=race4*BMI_WC1;
race2bmiwc2=race2*BMI_WC2;
race3bmiwc2=race3*BMI_WC2;
race4bmiwc2=race4*BMI_WC2;
race2bmiwc3=race2*BMI_WC3;
race3bmiwc3=race3*BMI_WC3;
race4bmiwc3=race4*BMI_WC3;
race2bmiwc4=race2*BMI_WC4;
race3bmiwc4=race3*BMI_WC4;
race4bmiwc4=race4*BMI_WC4;
race2bmiwc5=race2*BMI_WC5;
race3bmiwc5=race3*BMI_WC5;
race4bmiwc5=race4*BMI_WC5;
race2bmiwc7=race2*BMI_WC7;
race3bmiwc7=race3*BMI_WC7;
race4bmiwc7=race4*BMI_WC7;
race2bmiwc8=race2*BMI_WC8;
race3bmiwc8=race3*BMI_WC8;
race4bmiwc8=race4*BMI_WC8;
race2bmiwc9=race2*BMI_WC9;
race3bmiwc9=race3*BMI_WC9;
race4bmiwc9=race4*BMI_WC9;
race2bmiwc10=race2*BMI_WC10;
race3bmiwc10=race3*BMI_WC10;
race4bmiwc10=race4*BMI_WC10;
run;

PROC PHREG DATA=interact5 concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET

race2bmiwc1
race3bmiwc1
race4bmiwc1
race2bmiwc2
race3bmiwc2
race4bmiwc2
race2bmiwc3
race3bmiwc3
race4bmiwc3
race2bmiwc4
race3bmiwc4
race4bmiwc4
race2bmiwc5
race3bmiwc5
race4bmiwc5
race2bmiwc7
race3bmiwc7
race4bmiwc7
race2bmiwc8
race3bmiwc8
race4bmiwc8
race2bmiwc9
race3bmiwc9
race4bmiwc9
race2bmiwc10
race3bmiwc10
race4bmiwc10

 / rl;
 
 test
race2bmiwc1,
race3bmiwc1,
race4bmiwc1,
race2bmiwc2,
race3bmiwc2,
race4bmiwc2,
race2bmiwc3,
race3bmiwc3,
race4bmiwc3,
race2bmiwc4,
race3bmiwc4,
race4bmiwc4,
race2bmiwc5,
race3bmiwc5,
race4bmiwc5,
race2bmiwc7,
race3bmiwc7,
race4bmiwc7,
race2bmiwc8,
race3bmiwc8,
race4bmiwc8,
race2bmiwc9,
race3bmiwc9,
race4bmiwc9,
race2bmiwc10,
race3bmiwc10,
race4bmiwc10
 ;
  FORMAT BMI_WC WC_BMI.;
RUN;


PROC SORT DATA=VA7.MERGED_MAN7_VF; BY RACE_BR;RUN;

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
ETHNICITY_BR (ref="0")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 BY RACE_BR;
 FORMAT BMI_WC WC_BMI.;
RUN;


/*BY ETHNICITY*/

data interact6;
set VA7.MERGED_MAN7_VF;
if ETHNICITY_BR=1 then ethnicity=1; else ethnicity=0;
if BMI_WC=1 then BMI_WC1=1; else BMI_WC1=0; 
if BMI_WC=2 then BMI_WC2=1; else BMI_WC2=0; 
if BMI_WC=3 then BMI_WC3=1; else BMI_WC3=0; 
if BMI_WC=4 then BMI_WC4=1; else BMI_WC4=0;
if BMI_WC=5 then BMI_WC5=1; else BMI_WC5=0;
if BMI_WC=7 then BMI_WC7=1; else BMI_WC7=0;
if BMI_WC=8 then BMI_WC8=1; else BMI_WC8=0;
if BMI_WC=9 then BMI_WC9=1; else BMI_WC9=0;
if BMI_WC=10 then BMI_WC10=1; else BMI_WC10=0;

ethnicitybmiwc1=ethnicity*BMI_WC1;
ethnicitybmiwc2=ethnicity*BMI_WC2;
ethnicitybmiwc3=ethnicity*BMI_WC3;
ethnicitybmiwc4=ethnicity*BMI_WC4;
ethnicitybmiwc5=ethnicity*BMI_WC5;
ethnicitybmiwc7=ethnicity*BMI_WC7;
ethnicitybmiwc8=ethnicity*BMI_WC8;
ethnicitybmiwc9=ethnicity*BMI_WC9;
ethnicitybmiwc10=ethnicity*BMI_WC10;
run;

PROC PHREG DATA=interact6 concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET

ethnicitybmiwc1
ethnicitybmiwc2
ethnicitybmiwc3
ethnicitybmiwc4
ethnicitybmiwc5
ethnicitybmiwc7
ethnicitybmiwc8
ethnicitybmiwc9
ethnicitybmiwc10

 / rl;
 test
ethnicitybmiwc1,
ethnicitybmiwc2,
ethnicitybmiwc3,
ethnicitybmiwc4,
ethnicitybmiwc5,
ethnicitybmiwc7,
ethnicitybmiwc8,
ethnicitybmiwc9,
ethnicitybmiwc10
 ;
FORMAT BMI_WC WC_BMI.;
RUN;


PROC SORT DATA=VA7.MERGED_MAN7_VF; BY ETHNICITY_BR;RUN;

PROC PHREG DATA=VA7.MERGED_MAN7_VF concordance plots=roc; CLASS 
BMI_WC (ref="< 80 cm (normal weight)")
RACE_BR (ref="1")
MARITAL_BR (ref="MARRIED / PARTNERED")
EDUC_BR (ref="< HS")
OCCUPATION (ref="Managerial/professional")
INCOME_BR (ref="100,000+")
SMOKING_BR (ref="NEVER SMOKER")
ALCOHOL_BR (ref="NON-DRINKER"); 
MODEL TTE_DIABETES*INCIDENT_DIABETES(0) = BMI_WC 
AGE
RACE_BR 
ETHNICITY_BR
MARITAL_BR
EDUC_BR
OCCUPATION
INCOME_BR
SMOKING_BR
ALCOHOL_BR
HEI2015_TOTAL_SCORE
PHYSICAL_ACTIVITY_MET
 / rl;
 BY ETHNICITY_BR;
 FORMAT BMI_WC WC_BMI.;
RUN;

title "table A.1";

/*Table A.1. Sample size of training, test, and validation datasets by exposure variables*/


PROC FREQ DATA=VA7.train_vf; TABLES bmic BMI_WC;RUN;
PROC FREQ DATA=VA7.validation_vf; TABLES bmic BMI_WC;RUN;

/*ADDITIONAL ANALYSES*/

PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES  INCIDENT_DIABETES AGE_BR RACE ETHNICITY;RUN;
PROC MEANS DATA=VA7.MERGED_MAN7_VF mean std median q1 q3; VAR AGE TTE_DIABETES;RUN;
PROC FREQ DATA=VA7.MERGED_MAN7_VF; TABLES BMIC BMI_WC;RUN;
