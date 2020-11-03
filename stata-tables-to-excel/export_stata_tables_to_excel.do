* Exporting Stata Tables to Excel

use "https://github.com/CenterOnBudget/stata-trainings/raw/master/penguins-dta/penguins.dta", clear

help preserve

help export excel

help putexcel

help contract

preserve
contract species island sex, freq(n_obs) percent(pct_obs) 
export excel "penguin_measures.xlsx", firstrow(variables) sheet("freq_contract", replace) 
restore

help table

preserve
table sex island species, row column scolumn replace
order species island sex 
sort species island sex
export excel "penguin_measures.xlsx", firstrow(varlabels) sheet("freq_table", replace)
restore

help collapse

preserve
collapse (count)  n_obs_bill_length = bill_length_mm    ///
         (mean)   mean_bill_length  = bill_length_mm    ///
         (median) med_bill_length   = bill_length_mm    ///
         (count)  n_obs_bill_depth  = bill_depth_mm     ///
         (mean)   mean_bill_depth   = bill_depth_mm     ///
         (median) med_bill_depth    = bill_depth_mm,    ///
         by(species island sex)
export excel "penguin_measures.xlsx", firstrow(variables) sheet("stats_collapse", replace)
restore

help table

preserve
table sex island species, row column scolumn replace        ///
                          contents(mean    bill_length_mm   ///
                                   median  bill_length_mm   ///
                                   mean    bill_depth_mm    ///
                                   median  bill_depth_mm)
rename (table1 table2 table3 table4)                        ///
       (mean_bill_length med_bill_length mean_bill_depth med_bill_depth)
order species island sex 
sort species island sex
export excel "penguin_measures.xlsx", firstrow(variables) sheet("stats_table", replace)
restore

help tabstat

tabstat bill_depth_mm bill_length_mm flipper_length_mm body_mass_g,        ///
        statistics(n mean median min max)                                  ///
        by(species) columns(statistics) save

return list

display "`r(name1)'"
matlist r(Stat1)

putexcel set "penguin_measures.xlsx", modify sheet("stats_tabstat", replace)

putexcel B1 = matrix(r(Stat1)), names
putexcel A2:A6 = "`r(name1)'"
putexcel B7 = matrix(r(Stat2)), rownames
putexcel A7:A11 = "`r(name2)'"
putexcel B12 = matrix(r(Stat3)), rownames
putexcel A12:A16 = "`r(name3)'"
putexcel B17 = matrix(r(StatTotal)), rownames
putexcel A17:A21 = "Overall"

forvalues s = 1/3 {
	matrix species_`s' = r(Stat`s')
	matrix roweq species_`s' = "`r(name`s')'"
	matrix species = nullmat(species) \  species_`s'
}
matrix species_overall = r(StatTotal)
matrix roweq species_overall = "Overall"
matrix species = species \ species_overall
matlist species

putexcel A1 = matrix(species), names

