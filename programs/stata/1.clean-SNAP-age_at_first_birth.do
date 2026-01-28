*****************************************************
*  Impact of SNAP on woman's age at first birth 
*****************************************************
clear
cls
eststo clear

// cd "C:\Users\walee\OneDrive - University of Oklahoma\Desktop\Research\State_Safety_Net\State_safety_net-Age_at_first_birth"

cd "/Users/paghosh/Dropbox/Papers_with_Coauthors/PhD_Students/Waleed/State_safety_nets-Crime/Data/source_data"

// log using "Logs/1.main_ind.smcl", replace

********************************
**#3 - HS DROPOUT ONLY
********************************
************************************************
* CHECK THE RESULTS AT THE INDIVIDUAL LEVEL
***********************************************

* Use individual level data to find out state-level median age of women at first birth

// use "C:\Users\walee\OneDrive - University of Oklahoma\Desktop\Research\State_Safety_Net\State_safety_net-Age_at_first_birth\Data\Source_data\asec9619v5_m.dta", 

clear

use asec9619v5_m.dta

* Generate education level with respect to hs graduation/dropout (low-eduction/skill)
** Drop education if educ==1 (NIU or blank)
drop if educ==1

** High school dropouts
gen hsdropout = (educ < 60)

** High school graduates 
drop hsgrad
gen hsgrad = (educ >= 71 & educ < 110)

* Identify women who have given birth
gen has_children = (nchild > 0)

* Drop if eldest child age is missing
drop if eldch == 99

* Calculate age at first birth for women who have given birth
gen age_at_first_birth = .
replace age_at_first_birth = age - eldch if has_children

* Drop observation if age is the same as age of eldest child (which means the observation is the eldest child in the household)
gen obs_is_eldch = 0
replace obs_is_eldch = 1 if age==eldch
drop if obs_is_eldch == 1

* Drop observations with negative values
drop if age_at_first_birth < 0

* Keep only female observations
keep if sex==2

* Summary statistics of age at first birth
summarize age_at_first_birth if has_children

* Drop extreme values for age at first birth (lower and upper limits both)
drop if age_at_first_birth <=8
drop if age_at_first_birth >=65

* View hhincome and drop if negative
sum hhincome
drop if hhincome < 0

cd "/Users/paghosh/Dropbox/Papers_with_Coauthors/PhD_Students/Waleed/State_safety_nets-Crime/Data/model_data"

* Save the data
save "age_at_first_birth.dta", replace


*************************************************************
* Restricting sample to HS DROPOUT single mothers
*************************************************************
* Restricting the sample size to hsgrad or hsdropout
keep if hsdropout == 1

* Identify families with single-parent (mothers only)
gen single_parent = (nchild > 0 & relate == 101 & sex ==2)

* Generate a variable to indicate the family, by serial, state, and year
egen family_single_parent = max(single_parent), by(year statefip serial)

* Sort the data according to year, state and household ID (serial)
sort year statefip serial

* Keep only single-parent families & remove those with work disabilities
by year statefip serial: keep if single_parent == 1 & disabwrk == 1 & sex ==2

* Generate log of stamp value for log of the SNAP benefit amount
gen log_stampval = log(stampval)

* Generate log of household and individual incomes
gen log_hhincome = log(hhincome)
gen log_incwage = log(incwage)

* Generate the dummy variable and initialize it to 0
gen metro_dummy = 0

* Set the dummy variable to 1 for "in central/principal city"
replace metro_dummy = 1 if metro == 2


* Create a new variable for broad occupation categories
gen occupation_category = ""

* Define categories for 1996-2002 (1990 Census Occupation Codes)
replace occupation_category = "Management_Business_Financial" if year >= 1996 & year <= 2002 & inrange(occ, 1, 95)
replace occupation_category = "Professional_Related" if year >= 1996 & year <= 2002 & inrange(occ, 100, 395)
replace occupation_category = "Service_Occupations" if year >= 1996 & year <= 2002 & inrange(occ, 400, 465)
replace occupation_category = "Sales_Office" if year >= 1996 & year <= 2002 & inrange(occ, 470, 595)
replace occupation_category = "Natural_Resources_Construction_Maintenance" if year >= 1996 & year <= 2002 & inrange(occ, 600, 695)
replace occupation_category = "Production_Transportation_Material_Moving" if year >= 1996 & year <= 2002 & inrange(occ, 700, 795)

* Define categories for 2003-2010 (2000 Census Occupation Codes)
replace occupation_category = "Management_Business_Financial" if year >= 2003 & year <= 2010 & inrange(occ, 10, 95)
replace occupation_category = "Professional_Related" if year >= 2003 & year <= 2010 & inrange(occ, 100, 395)
replace occupation_category = "Service_Occupations" if year >= 2003 & year <= 2010 & inrange(occ, 400, 465)
replace occupation_category = "Sales_Office" if year >= 2003 & year <= 2010 & inrange(occ, 470, 595)
replace occupation_category = "Natural_Resources_Construction_Maintenance" if year >= 2003 & year <= 2010 & inrange(occ, 600, 695)
replace occupation_category = "Production_Transportation_Material_Moving" if year >= 2003 & year <= 2010 & inrange(occ, 700, 795)

* Define categories for 2011-2019 (2010 Census Occupation Codes)
replace occupation_category = "Management_Business_Financial" if year >= 2011 & year <= 2019 & inrange(occ, 1000, 1999)
replace occupation_category = "Professional_Related" if year >= 2011 & year <= 2019 & inrange(occ, 2000, 3999)
replace occupation_category = "Service_Occupations" if year >= 2011 & year <= 2019 & inrange(occ, 4000, 4999)
replace occupation_category = "Sales_Office" if year >= 2011 & year <= 2019 & inrange(occ, 5000, 5999)
replace occupation_category = "Natural_Resources_Construction_Maintenance" if year >= 2011 & year <= 2019 & inrange(occ, 6000, 7999)
replace occupation_category = "Production_Transportation_Material_Moving" if year >= 2011 & year <= 2019 & inrange(occ, 8000, 9999)


* Handle unknown codes
replace occupation_category = "Unknown" if missing(occupation_category)

* Generate dummy variables based on occupation categories
tabulate occupation_category, generate(occ_dummy)

* Rename dummy variables for clarity
rename occ_dummy1 management_business_financial
rename occ_dummy2 professional_related
rename occ_dummy3 service_occupations
rename occ_dummy4 sales_office
rename occ_dummy5 natres_const_maintenance
rename occ_dummy6 prod_transp_mater_moving


// Save the results
save "hsdropout-age_at_first_birth.dta", replace


* Save the log file in a PDF format
translate "Logs/1.main_ind.smcl" "Logs/1.main_ind.pdf", translator (smcl2pdf)
		
* Close the log file
log close 




