cd "${ghpath}/stata-trainings/survey-data-analysis/src/part-2"

use "https://github.com/CenterOnBudget/stata-trainings/raw/master/penguins-dta/penguins.dta", clear

generate weight = round(runiform(100, 1000))
forvalues r = 1/80 {
  generate weight`r' = round(runiform(100, 1000))
}

set level 90
svyset [pw=weight], vce(sdr) sdrweight(weight1-weight80) mse
svy: mean bill_length_mm, over(species)

putexcel set "results_asis_for_rmd.xlsx", modify
putexcel A2 = etable
putexcel A1 = "Mean bill length (mm) by species"

svy, subpop(if species == 2 & year == 2009): mean flipper_length_mm, over(sex) 
putexcel set "results_with_significance_for_rmd.xlsx", replace
putexcel A1 = "Mean flipper length by sex, Gentoo penguins in 2009"
putexcel A2 = etable
test _b[flipper_length_mm@1.sex] = _b[flipper_length_mm@2.sex]
local significant_diff = cond(`r(p)' <= 0.1, "significant", "not significant")
putexcel A7 = "Difference is `significant_diff' at a 10% confidence level."
