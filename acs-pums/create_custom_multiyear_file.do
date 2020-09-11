
// Creating a custom multi-year ACS PUMS file ---------------------------------

// This example .do file will create a two-year (2017-2018) household-level file 
// for Vermont.

// Check the Readmes of each one-year sample for variable changes:
// https://www2.census.gov/programs-surveys/acs/tech_docs/pums/ACS2017_PUMS_README.pdf
// https://www2.census.gov/programs-surveys/acs/tech_docs/pums/ACS2018_PUMS_README.pdf


// Check if the cbppstatautils package is installed, and if not, install it
capture which cbppstatautils
if _rc != 0 {
	net install cbppstatautils, from("https://raw.githubusercontent.com/CenterOnBudget/cbpp-stata-utils/master/src") replace
}

// For each year in the desired custom multi-year file:

forvalues year = 2017/2018 {
	
	// Obtain the one-year sample file
	get_acs_pums, year(`year') sample(1) record_type("hhld") state("vt") 	///
				  keep_zip replace
	
	use "acs_pums/`year'/1_yr/psam_h50.dta", clear
	
	// Adjust variables for inflation within the one-year sample
	generate_acs_adj_vars
	
	// Create a variable for the sample year
	generate year = `year'
	
	// serialno is a string variable starting in 2018; destring it so that files 
	// from 2018 and later can be appended to earlier files
	if `year' >= 2018 {
		replace serialno = ustrregexra(serialno, "HU", "00")
		replace serialno = ustrregexra(serialno, "GQ", "01")
		destring serialno, replace
	}
	
	// Save the edited one-year sample file
	save "vt_hhld_1yr_`year'.dta", replace
}


// Append the one-year files together
clear
forvalues year = 2017/2018 {
	append using "vt_hhld_1yr_`year'.dta"
}

// Adjust dollar-denominated variables for inflation to equal 2018 dollars (the
// last sample year in the custom multi-year file)
get_cpiu, rs merge base_year(2018) use_cache
foreach var of varlist *_adj {
	if "`var'" != "cpiu_rs_2018_adj" {
		replace `var' = `var' * cpiu_rs_2018_adj
	}
}

// Create multi-year average weights by dividing all weight variables by the 
// number of sample years in the custom multi-year file
foreach weight of varlist wgtp* {
	generate `weight'_2yr = `weight' / 2
}

// Set the survey design using the multi-year average weights
svyset [iw=wgtp_2yr], vce(sdr) sdrweight(wgtp1_2yr-wgtp80_2yr) mse

// Save the custom multi-year file
save "vt_hhld_2017-18.dta", replace

// Proceed to analysis!


