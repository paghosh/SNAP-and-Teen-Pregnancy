*****************************************************
*  Impact of SNAP on woman's age at first birth 
*****************************************************
clear
cls
eststo clear

// cd "C:\Users\walee\OneDrive - University of Oklahoma\Desktop\Research\State_Safety_Net\State_safety_net-Teen_birth"

cd "/Users/paghosh/Dropbox/Papers_with_Coauthors/PhD_Students/Waleed/Teenage_Pregnancy"

log using "Logs/2.est.smcl", replace

// Use the cleaned data
use "Data/Model_data/hsdropout-teen_birth.dta", clear



***************************************************
* Check the results for births for teenage girls
***************************************************

eststo clear
* Regression 1 (With just the ind variable)
eststo: regress teen_births log_stampval, vce(cluster statefip)

* Regression 2 (With controls)
eststo: regress teen_births log_stampval married black empstat log_hhincome famsize metro_dummy, vce(cluster statefip)

* Regression 3 (With state FE & controls)
eststo: regress teen_births log_stampval married black empstat log_hhincome famsize metro_dummy i.statefip, vce(cluster statefip)

* Regression 4 (With controls, year FE)
eststo: regress teen_births log_stampval married black empstat log_hhincome famsize metro_dummy i.year, vce(cluster statefip)

* Regression 5 (With controls, year FE, state FE)
eststo: regress teen_births log_stampval married black empstat log_hhincome famsize metro_dummy i.year i.statefip, vce(cluster statefip)

esttab using "Tables/teenbirth_hsdrop_logstampval.csv", replace

eststo clear

regress teen_births log_stampval married black empstat log_hhincome famsize metro_dummy i.year i.statefip i.occupation_category, vce(cluster statefip)

*****************************************************
* IV 2sls regression 
*****************************************************

* First (with the "first" option at the end) and Second stage
eststo: ivregress 2sls teen_births (log_stampval = cashfood log_elig_criteria) married black empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) first
*/

// ivregress 2sls teen_births (log_stampval = cashfood log_elig_criteria) married black empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip)
//
// predict prd_log_stampval
//
// logit  teen_births prd_log_stampval married black empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) 
//
// margins, dydx(prd_log_stampval)




eststo clear
* Run logistic regression with log (SNAP value) as independent variables
logit  teen_births log_stampval married black empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) 

* Store the results of the logistic regression
eststo model1

* Find out the marginal effect of log (SNAP value)
margins, dydx(log_stampval)

* Use the predicted value of log (SNAP value) as the main independent variable in the logistic regression
logit teen_births pred_log_stampval married black empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) 

eststo model2

* Export the result to Excel
esttab model1 model2 using "Tables/logit_results.xls", replace

* Find out the marginal effect of predicted log (SNAP value) on teen birth
margins, dydx(pred_log_stampval)


* 2SLS: find out how the interaction of the black race with log(SNAP value) explains teen births via the two IVs
eststo: ivregress 2sls teen_births (int_black_stampval = cashfood log_elig_criteria) married black log_stampval empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) first
*/


eststo clear
* 2SLS: find out how the interaction of the black race with log(SNAP value) explains teen births via the two IVs
eststo: ivregress 2sls teen_births (int_black_predstampval = cashfood log_elig_criteria) married black log_stampval empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) first
*/


**********************************************
* Logistic regressions - interaction of different race subgroups with predicted log (SNAP value)
**********************************************

* Logistic regression with interaction of black race with log(SNAP value) as the main independent variable
logit teen_births int_black_predstampval log_stampval married black empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip) 
* Save the results of this model as model1
eststo model1

* Marginal effect of black interacted with log(SNAP value)
margins, dydx(int_black_predstampval) 


* Logistic with interaction of white race with predicted log(SNAP value)
logit teen_births int_white_predstampval log_stampval married white empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip)  
* Save the results of this model as model2
eststo model2

* Marginal effect of interaction of white with predicted log (SNAP value)
margins, dydx(int_white_predstampval) 


* Logistic with interaction of hispanic race with predicted log(SNAP value)
logit teen_births int_hispanic_predstampval log_stampval married hispanic empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip)  
* Save the results of this model as model3
eststo model3

* Marginal effect of interaction of hispanic with predicted log (SNAP value)
margins, dydx(int_hispanic_predstampval) 


* Logistic with interaction of asian race with predicted log(SNAP value)
logit teen_births int_asian_predstampval log_stampval married asian empstat steitc PovertyRate StateMinimumWage Unemploymentrate metro_dummy i.year i.statefip, vce (cluster statefip)  
* Save the results of this model as model4
eststo model4

* Marginal effect of interaction of asian with predicted log (SNAP value)
margins, dydx(int_asian_predstampval) 


* Export the result to Excel
esttab model1 model2 model3 model4 using "Tables/logit_byrace_results.xls", replace



********************************************
* Possible channels
*******************************************

eststo clear
*  Second stage
eststo: ivregress 2sls inlabforce (log_stampval = cashfood log_elig_criteria) married black steitc PovertyRate StateMinimumWage metro_dummy i.year i.statefip, vce (cluster statefip) first
*/
esttab using "Tables/iv_lfp_stampval.xls", replace


* Regress log (SNAP value) on to LFP to find out the possible channel
regress inlabforce log_stampval married black steitc PovertyRate StateMinimumWage metro_dummy i.year i.statefip, vce (cluster statefip)

eststo clear
* Logit with LFP as the main dep var and log (SNAP value) as the main independent variable
logit inlabforce log_stampval married black steitc PovertyRate StateMinimumWage metro_dummy i.year i.statefip, vce (cluster statefip) 
eststo model1

* Marginal effect of log (SNAP value) on LFP
margins, dydx(log_stampval) 


* Logit with married as the main dep var and log(SNAP value) as the main ind var
logit married log_stampval black steitc PovertyRate StateMinimumWage metro_dummy Unemploymentrate i.year i.statefip, vce (cluster statefip) 
eststo model2

* Marginal effect of log (SNAP value) on marriage
margins, dydx(log_stampval) 

* Logit with unemployed as the main dep var and log (SNAP) value as the main independent variable
logit unemployed log_stampval married black steitc PovertyRate StateMinimumWage metro_dummy i.year i.statefip, vce (cluster statefip) 
eststo model3

* Marginal effect of log (SNAP value) on unemployed
margins, dydx(log_stampval) 


* Export the result to Excel
esttab model1 model2 model3 using "Tables/logit_channels.xls", replace


eststo clear

/*
******************************************
* Possible channels impacting age of first birth
*****************************************

***************************************************
* Run regressions for the possible channels: LFP, Married, Divorced, separated, never married, number of children, unemployed 
*****************************************************
eststo clear

* LFP as the main DV
eststo: reg inlabforce log_stampval married black log_hhincome famsize management_business_financial professional_related nchild service_occupations sales_office natres_const_maintenance prod_transp_mater_moving metro_dummy i.year i.statefip, vce(cluster statefip)

* Married as the main DV
eststo: reg married log_stampval nchild unemprate black management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving empstat log_hhincome famsize metro_dummy i.year i.statefip i.year i.statefip, vce(cluster statefip)

* Divorced as the main DV
eststo: reg divorced log_stampval nchild unemprate black management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving empstat log_hhincome famsize metro_dummy i.year i.statefip, vce(cluster statefip)

* Separated
eststo: reg separated log_stampval nchild unemprate black management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving empstat log_hhincome famsize metro_dummy i.year i.statefip, vce(cluster statefip)

* Never married as the main DV
eststo: reg never_married log_stampval nchild unemprate black management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving empstat log_hhincome famsize metro_dummy i.year i.statefip, vce(cluster statefip)

* Number of children as the main DV
eststo: reg nchild log_stampval unemprate black management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving empstat log_hhincome famsize metro_dummy i.year i.statefip, vce(cluster statefip)

* Unemployed as the main DV
eststo: reg unemployed log_stampval black married nchild management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving log_hhincome famsize metro_dummy i.year i.statefip, vce(cluster statefip)



* Migration as the main DV
eststo: reg mig_dummy log_stampval black married nchild management_business_financial professional_related service_occupations sales_office natres_const_maintenance prod_transp_mater_moving log_hhincome empstat famsize metro_dummy i.year i.statefip, vce(cluster statefip)

esttab using "Tables/channels_stampval.xls", replace


*/


// Save the data
save "Data/Model_data/hsdropout-teen-birthv2.dta", replace


* Save the log file in a PDF format
translate "Logs/2.est.smcl" "Logs/2.est.pdf", translator (smcl2pdf)
		
* Close the log file
log close 




