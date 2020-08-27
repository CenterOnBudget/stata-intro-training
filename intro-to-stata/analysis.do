
* Set working directory -------------------------------------------------------

cd "${ghpath}/stata-intro-training"


* Retrieve data ---------------------------------------------------------------

help copy

* Download state higher education funding data from SHEEO.
copy "https://shef.sheeo.org/wp-content/uploads/2020/04/SHEEO_SHEF_FY19_Report_Data.xlsx"	///
	 "data-raw/sheeo_shef_fy19_data.xlsx", replace

* Download inflation data from the BLS.
copy "https://www.bls.gov/cpi/research-series/allitems.xlsx"	///
	 "data-raw/bls_cpi_u_rs.xlsx", replace


* Import inflation data -------------------------------------------------------

help import excel 

import excel "data-raw\bls_cpi_u_rs.xlsx",			///
	   cellrange(A6) firstrow case(lower) clear

browse


* Clean inflation data --------------------------------------------------------

* Keep only the variables we'll need for this analysis.
keep year avg
	   
* Rename the 'avg' variable to a more descriptive name.
rename avg cpi_u_rs

browse

/*	Calculate a new variable, an inflation adjustment factor to 2019 dollars.
	Later, we'll join this variable into the SHEEO data and use it to adjust the
	dollar amounts for inflation.
	
	To do this, we'll first use the 'egen' command to create a new variable 
	that is equal to the maximum value of 'cpi_u_rs' in our dataset. 
	Every row will have the same value. 
	
	(We'll assume the row with the maximum value of 'cpi_u_rs' 
	is the 2019 row, because the CPI-U-RS almost always increases every year).
	
	We need to use the 'egen' command instead of 'generate' because we want to 
	set the value of our new variable based on information in multiple rows. 
	The 'generate' command only operates on information in a single row. 
*/

egen cpi_u_rs_2019 = max(cpi_u_rs)

browse

* Next, create the inflation adjustment factor.
generate cpi_u_rs_2019_adj = cpi_u_rs_2019 / cpi_u_rs

* Again, keep only the variables we'll need.
keep year cpi_u_rs_2019_adj

* The SHEEO dataSET goes back to 1980, but the inflation dataset goes back to 1977.
* Let's keep only the rows in the dataset where the year is 1980 or later.
keep if year >= 1980


* Export inflation data -------------------------------------------------------

* Save our cleaned inflation dataset. We'll join it with the SHEEO dataset later.
save "data/inflation.dta", replace

	 
* Import SHEEO data -----------------------------------------------------------

import excel "data-raw\sheeo_shef_fy19_data.xlsx", 	///
	   sheet("SHEF Report Data") 					///
	   firstrow case(lower) clear

browse


* Clean SHEEO data ------------------------------------------------------------

* Keep only the variables we'll need for this analysis.
keep state fy totalstatesupport netfteenrollment

* Rename the variables to shorter names.
rename totalstatesupport support
rename netfteenrollment fte


* Join the inflation dataset with the SHEEO dataset ---------------------------

* To merge datasets, they must share a variable with the same name.
* Let's rename 'fy' to 'year', which is what the year variable is named in the
* inflation dataset we created earlier.

rename fy year

help merge

merge m:1 year using "data/inflation.dta"

browse

tabulate _merge


* Verify data -----------------------------------------------------------------

/*	Now that we have created a clean, merged dataset, we're almost ready to 
	conduct our analysis.
	But first, we need to examine our dataset to make sure everything looks like
	we expect it to.
	We expect that:
		(1) Numeric variables don't have any missing or negative values.
		(2) There is an observation for each state and the U.S. total for each 
			year.
		(3) All values of 'support' and 'fte' are plausible compared to other 
			values in the dataset (there are no outliers or impossible values).
	Let's check these one by one.
*/

* (1) Numeric variables don't have any missing or negative values.

* The 'inspect' and 'misstable summarize' commands give information on missing
* values.
help inspect
inspect support fte cpi_u_rs_2019_adj
help misstable summarize
misstable summarize, all

* (2) There is an observation for each state and the U.S. total for each year.

* First, confirm how many years are in our dataset.
* The 'summarize' command gives summary statistics including the minimum and 
* maximum.
help summarize
summarize year

* But there might be gaps between the min and max. We need to see how many 
* unique values of 'year' are in the dataset. Let's use 'inspect' again.
inspect year

* There are 40 years (1980 to 2019), so each state should have 40 observations. 
* Let's create a frequency table to see.
help tabulate
tabulate state

* D.C has only 9 years of data. Let's see which years they are.
tabulate year if state == "District of Columbia"

* (3) All values of 'support' and 'fte' are plausible compared to other values 
*	  in the dataset (there are no outliers or impossible values).

* Let's look at the 1st and 99th percentiles of each variable to check for outliers.
summarize fte, detail
summarize support, detail


* Analyze data ----------------------------------------------------------------

* We're ready to conduct our analysis.

* Adjust 'support' for inflation by multiplying it by 'cpi_u_rs'.
* ("Real" means inflation-adusted).
generate real_support = support * cpi_u_rs_2019_adj

* Calculate real state support per FTE.
generate real_support_per_fte = real_support / fte

browse


* Create a presentation-ready table -------------------------------------------

/*	Our dataset has each year-state combination in a row. For presentation 
	purposes, we might instead want a table where each state is a row, each year 
	is a column, and the cells contain the value of 'real_support_per_fte'.
	
	The 'reshape' command can "pivot" or "transpose" a datset.
	
	Before we do this, let's save a copy of our dataset in case we want to
	return to it later for more analysis.
*/

save "data/higher_ed_data.dta", replace

help reshape

keep state year real_support_per_fte

reshape wide real_support_per_fte, i(state) j(year)

browse

/*	We want the names of each column in our table to be the year. But Stata's
	'reshape' command automatically prefixes the column names with the name of 
	the variable in the cells. 
	We can't rename the variables to the year, since Stata variables can't 
	start with a number. 
	So we'll keep the variable names the way they are and put the year in the
	variable labels. Later, we'll choose to export the table to Excel using the
	variable labels as the names of the columns.
*/

help label variable

/*	We need to label all 40 year columns in the dataset. Instead of typing out 
	40 lines of code that label each column, we can use a 'for' loop. A 'for' 
	loop works by repeating an action for all elements in a list. 
	In this case, we can think of this as the loop writing the code for us.
*/

help forvalues

forvalues year = 1980/2019 {
    label variable real_support_per_fte`year' "`year'"
}

/*	The first iteration of this loop will run:
		label variable real_support_per_fte1980 "1980"
	The second iteration will run:
		label variable real_support_per_fte1981 "1981"
	and so on.
*/


* Export table ----------------------------------------------------------------

help export excel 

export excel using "results/real_support_per_fte.xlsx",	///
	   firstrow(varlabels) replace

	   
