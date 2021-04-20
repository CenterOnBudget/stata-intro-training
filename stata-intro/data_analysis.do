* Data Analysis

clear
set more off
set matsize 11000


* Set working directory ----------------------

* Uncomment the line below and define your working folder

* cd "C:/Users/my_username/Documents/project_folder/"


log using higher_ed, replace

help copy

* Download state higher education funding data from SHEEO.
copy "https://shef.sheeo.org/wp-content/uploads/2020/04/SHEEO_SHEF_FY19_Report_Data.xlsx"	///
	 "data-raw/sheeo_shef_fy19_data.xlsx", replace

* Download inflation data from the BLS.
copy "https://www.bls.gov/cpi/research-series/allitems.xlsx"	///
	 "data-raw/bls_cpi_u_rs.xlsx", replace

* Import inflation data -----------------
help import excel 

import excel "data-raw/bls_cpi_u_rs.xlsx", sheet("Table 1") cellrange(A6:N49) firstrow case(lower) clear

* Keep only the variables we will need for this analysis and check for missing values
  
keep year avg
codebook year avg

drop if year == 1977

* Rename the avg variable to a more descriptive name

rename avg cpi_u_rs

egen cpi_u_rs_2019 = max(cpi_u_rs)

* Next, create the inflation adjustment factor

generate cpi_u_rs_2019_adj = cpi_u_rs_2019 / cpi_u_rs

* Again, keep only the variables we will need

keep year cpi_u_rs_2019_adj

* Keep only the rows in the dataset where the year is 1980 or later

keep if year >= 1980

* Save our cleaned inflation dataset

save "data/inflation.dta" , replace

* Import SHEEO data --------------
  
import excel "data-raw\sheeo_shef_fy19_data.xlsx", 	///
	   sheet("SHEF Report Data") 					///
	   firstrow case(lower) clear

* Keep only the variables we will need 

keep state fy totalstatesupport netfteenrollment
summarize

* Rename the variables to shorter names.

rename totalstatesupport support
rename netfteenrollment fte

* Join the inflation dataset with the SHEEO dataset ---------------

rename fy year

save "data/higher_edu_data.dta", replace

merge m:1 year using "data/inflation.dta"

inspect support fte cpi_u_rs_2019_adj
misstable summarize, all

summarize year

inspect year

tabulate state

tabulate year if state == "District of Columbia"

summarize fte, detail
summarize support, detail

generate real_support = support * cpi_u_rs_2019_adj

generate real_support_per_fte = real_support / fte

save "data/higher_edu_data.dta", replace

keep state year real_support_per_fte

reshape wide real_support_per_fte, i(state) j(year)

forvalues year = 1980/2019 {
    label variable real_support_per_fte`year' "`year'"
}

label variable real_support_per_fte1980 "1980"

label variable real_support_per_fte1981 "1981"

export excel using "results/real_support_per_fte.xlsx",	///
	   firstrow(varlabels) replace

