																				/* 
Setup -------------------------------------------------------------------------

Before getting started, please set your working directory to the folder that 
contains this .do file.
																				*/
cd "replace/with/path/to/folder/where/this-do-file/is"
																				/* 	
For this tutorial, we'll be using a dataset containing penguin measurements
collected by scientists at Palmer Station, Antarctica.
																				*/
use "https://github.com/CenterOnBudget/stata-trainings/raw/master/penguins-dta/penguins.dta", clear
notes _dta

																				/*
collapse ----------------------------------------------------------------------

- Replaces data in memory
- No limit on combinations of variables and statistics/frequencies
- No limit on number of grouping variables	
- Excludes missing combinations of grouping variables
- aweights, fweights, iweights, and pweights are allowed
- Standard error only available with fweights and aweights, of mean
																				*/
preserve
collapse (mean)   mean_bill_length = bill_length_mm      ///
                  mean_bill_depth  = bill_depth_mm       ///
         (median) med_bill_length  = bill_length_mm      ///
                  med_bill_depth   = bill_depth_mm,      ///
         by(species island sex)
browse
// optionally reshape table with reshape command
export excel "penguin_measures.xlsx", sheet("collapse", replace) firstrow(varlabels)
restore

																				/*
contract ----------------------------------------------------------------------

- Replaces data in memory
- Frequencies only, no statistics
- No limit on number of grouping variables
- Missing combinations of grouping variables may be included
- fweights are allowed
																				*/
preserve
contract species island sex, freq(n_observations) percent(pct_observations) zero
browse
// optionally reshape table with reshape command
export excel "penguin_measures.xlsx", sheet("contract", replace) firstrow(varlabels)
restore

																				/*
table, replace ----------------------------------------------------------------

- Replaces data in memory
- Up to 5 combinations of variables and statistics/frequencies
- Up to 4 grouping variables
- Row and/or column subtotals
- fweights, iweights, and pweights are allowed
- Standard error only available with fweights and of mean 
																				*/
preserve
table sex island species, row column scolum 				///
						  name(measure) replace  			///
                          contents(mean   bill_depth_mm     ///
                                   median bill_depth_mm		///
								   mean	  bill_length_mm	///
								   median bill_length_mm)                            
rename (measure1 measure2 measure3 measure4)                 ///
       (mean_bill_depth median_bill_depth mean_bill_length median_bill_length)
order species island sex 
sort species island sex
browse
// optionally reshape table with reshape command and/or recode subtotals
export excel "penguin_measures.xlsx", sheet("table-replace", replace) firstrow(varlabels)
restore

																				/* 
tabstat, save -----------------------------------------------------------------

- Does not replace data in memory
- Saves elements of the table in returned results	
- No limit on number of combinations of variables and statistics/frequencies
- Allows 1 grouping variable
- aweights and fweights are allowed
- Standard error only available of mean
																				*/
tabstat bill_depth_mm bill_length_mm flipper_length_mm body_mass_g, 	///
		statistics(n mean median min max)								///
		by(species) columns(statistics) save
return list
// option 1: add species to rownames of returned results, compile, and putexcel
forvalues s = 1/3 {
	matrix species_`s' = r(Stat`s')
	matrix roweq species_`s' = "`r(name`s')'"
}
matrix species_overall = r(StatTotal)
matrix roweq species_overall = "Overall"
matrix species_all = species_1 \ species_2 \ species_3 \ species_overall
matlist species_all
putexcel set "penguin_measures.xlsx", modify sheet("tabstat-1", replace)
putexcel A1 = matrix(species_all), names
// option 2: putexcel each returned result, and enter species name column into 
// spreadsheet manually 
putexcel set "penguin_measures.xlsx", modify sheet("tabstat-2", replace)
putexcel B1 = matrix(r(Stat1)), names
putexcel B7 = matrix(r(Stat2)), rownames
putexcel B12 = matrix(r(Stat3)), rownames
putexcel B17 = matrix(r(StatTotal)), rownames

																				/* 
estimation results ------------------------------------------------------------

- Does not replace data in memory
- Saves elements of the table in returned results	
- No limit on number of grouping variables
- Total and mean 
- Use factor variables to get frequency and percent frequency tables
- Standard errors, confidence intervals, coefficients of variation, and more
- fweights, iweights, and pweights are allowed
- Use svy: prefix to adjust estimation results for a complex survey design

  A tutorial can be found in exporting_estimation_results.do.
																				*/

																		
																				