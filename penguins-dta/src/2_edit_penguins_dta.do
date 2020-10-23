
cd "${ghpath}/stata-trainings/penguins-dta/"

use "penguins.dta", clear

// replace extending missing values with .
foreach v of varlist _all {
    replace `v' = . if missing(`v')
}

// add random missings
set seed 1000
local num_vars "bill_length_mm bill_depth_mm flipper_length_mm body_mass_g sex"
forvalues n = 1/5 {
    generate temp_`n' = runiform()
	local v : word `n' of `num_vars'
	replace `v' = . if temp_`n' >= 0.98
}
drop temp_*

// acknowledge source
label data "Source: palmerpenguins R package https://allisonhorst.github.io/palmerpenguins/"
notes : Source: Horst AM, Hill AP, Gorman KB (2020). palmerpenguins: Palmer Archipelago (Antarctica) penguin data. R package version 0.1.0. https://allisonhorst.github.io/palmerpenguins/

save "penguins.dta", replace

