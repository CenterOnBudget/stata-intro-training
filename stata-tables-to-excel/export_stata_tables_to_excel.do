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

ssc install xtable

help xtable

xtable sex island species, filename("penguin_measures.xlsx") modify sheet("freq_xtable", replace)

help table

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

help tabstat

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

putexcel set "penguin_measures.xlsx", modify sheet("stats_tabstat", replace)
putexcel A1 = matrix(statistics_by_species), names

help xtable

xtable sex island species, contents(mean bill_length_mm)              ///
                           filename("penguin_measures.xlsx") modify   ///
                           sheet("stats_xtable", replace)

help tabstat

tabstat bill_depth_mm bill_length_mm flipper_length_mm body_mass_g,        ///
        statistics(n mean median min max)                                  ///
        by(species) columns(statistics) save

ssc install tabstatmat
tabstatmat statistics_by_species

putexcel set "penguin_measures.xlsx", modify sheet("stats_tabstat", replace)
putexcel A1 = matrix(statistics_by_species), names

* first table
preserve
contract species sex, freq(n_obs) percent(pct_obs) 
export excel "penguin_measures.xlsx", firstrow(variables)                 ///
                                      sheet("bonus", modify) cell("A2")
restore

* second table
preserve
contract species island, freq(n_obs) percent(pct_obs) 
export excel "penguin_measures.xlsx", firstrow(variables)                 ///
                                      sheet("bonus", modify) cell("F2")
restore

* third table
tabstat bill_depth_mm bill_length_mm,          ///
        statistics(n mean median min max)      ///
        by(species) columns(statistics) save
tabstatmat statistics_by_species2
putexcel set "penguin_measures.xlsx", modify sheet("bonus")
putexcel A14 = matrix(statistics_by_species), names


