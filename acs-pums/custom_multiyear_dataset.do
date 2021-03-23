* ACS PUMS Cookbook
* Custom Multiyear Dataset

* Check if cbppstatautils package installed, and if not, install it
capture which cbppstatautils
if _rc != 0 {
	net install cbppstatautils, from("https://raw.githubusercontent.com/CenterOnBudget/cbpp-stata-utils/master/src") replace
}

* Download and modify each one-year sample
  
forvalues year = 2017/2018 {
	
	* Download one-year sample dataset
	get_acs_pums, year(`year') sample(1) record_type("hhld") state("vt") 	///
				        keep_zip replace
	
	use "acs_pums/`year'/1_yr/psam_h50.dta", clear
	
	* Create a variable for the sample year
	generate year = `year'
	
	* Adjust variables for inflation within the one-year sample
	generate_acs_adj_vars
	
	* serialno is a string variable starting in 2018; destring it so that files 
	* from 2018 and later can be appended to earlier files
	if `year' >= 2018 {
		replace serialno = ustrregexra(serialno, "HU", "00")
		replace serialno = ustrregexra(serialno, "GQ", "01")
		destring serialno, replace
	}
	
	* Save the edited one-year sample dataset
	save "vt_hhld_1yr_`year'.dta", replace
}

* Append the one-year datasets together
use "vt_hhld_1yr_2017.dta"
append using "vt_hhld_1yr_2018.dta"

* Adjust dollar-denominated variables for inflation
get_cpiu, rs merge base_year(2018) use_cache
foreach var of varlist *_adj {
	if "`var'" != "cpiu_rs_2018_adj" {
		replace `var' = `var' * cpiu_rs_2018_adj
	}
}

* Create multi-year average weights
foreach weight of varlist wgtp* {
	generate `weight'_2yr = `weight' / 2
}

save "vt_hhld_2017-18.dta", replace

* Before analyzing the dataset, set the survey design using the multi-year average weights
svyset [iw=wgtp_2yr], vce(sdr) sdrweight(wgtp1_2yr-wgtp80_2yr) mse

