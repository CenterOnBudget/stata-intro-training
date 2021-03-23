* ACS PUMS Cookbook
* Merged Person Household Dataset

* Check if cbppstatautils package installed, and if not, install it
capture which cbppstatautils
if _rc != 0 {
	net install cbppstatautils, from("https://raw.githubusercontent.com/CenterOnBudget/cbpp-stata-utils/master/src") replace
}

* Download both record types' datasets
get_acs_pums, year(2019) sample(1) record_type("both") state("vt")      ///
              keep_zip replace

* Merge the records together by serialno, the household record ID
use "acs_pums/2019/1_yr/psam_h50.dta", clear
merge 1:m serialno using "acs_pums/2019/1_yr/psam_p50.dta"

* Check that unmatched records are vacant housing units
count if _merge == 1
count if np == 0

* Some dataset prep
label_acs_pums, year(2019) sample(1)
generate_acs_adj_vars

* Drop vacant housing units
drop if np == 0

* Tabulating person-level variables by household-level variables

* Set the survey design using person weights
svyset_acs, record_type("person")

* Related children by household tenure
svy: total rc, over(ten)

* Disability status by household SNAP receipt
svy: proportion dis, over(fs)

* Creating and tabulating new household-level variables

* Variable indicating whether anyone in household is a child attending school
generate schkid = agep < 18 & inlist(sch, 2, 3) if !missing(sch)
egen hh_has_schkid = max(schkid), by(serialno) 

* People in households with a child attending school
svy: total hh_has_schkid

* Households with a child attending school
svyset_acs, record_type("household")
svy: total hh_has_schkid if relshipp == 20

* Check current survey settings
svyset

