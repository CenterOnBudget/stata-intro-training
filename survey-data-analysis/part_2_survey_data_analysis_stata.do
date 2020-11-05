* Survey Data Analysis with Stata, Part 2

use "https://github.com/CenterOnBudget/stata-trainings/raw/master/penguins-dta/penguins.dta", clear

generate weight = round(runiform(100, 1000))
forvalues r = 1/80 {
  generate weight`r' = round(runiform(100, 1000))
}

set level 90

svyset [pw=weight], vce(sdr) sdrweight(weight1-weight80) mse

svy: mean bill_length_mm, over(species)

help putexcel

putexcel set "results_asis.xlsx", modify
putexcel A2 = etable

putexcel A1 = "Mean bill length (mm) by species"

svy: mean bill_length_mm, over(species)

return list

matlist r(table)

help matrix operators

matrix mean_bill_length = r(table)'
matlist mean_bill_length, twidth(26)

help matrix extraction

matrix bill_length_b_se = mean_bill_length[1..., "b".."se"]
matrix bill_length_ll_ul = mean_bill_length[1..., "ll".."ul"]

matrix mean_bill_length = bill_length_b_se, bill_length_ll_ul

matlist mean_bill_length, twidth(26)

estat cv

matrix mean_bill_length_cv = r(cv)'
matrix mean_bill_length = mean_bill_length, mean_bill_length_cv
matlist mean_bill_length, twidth(26)

// option 1
matrix mean_bill_length_moe = mean_bill_length[1..., "se"] * 1.645
// option 2
matrix mean_bill_length_moe = ((mean_bill_length[1..., "ul"] - mean_bill_length[1..., "ll"]) / 2)

matrix mean_bill_length = mean_bill_length, mean_bill_length_moe

matlist mean_bill_length, twidth(26)

matrix rownames mean_bill_length = "Adelie" "Chinstrap" "Gentoo"
matlist mean_bill_length

matrix colnames mean_bill_length = "Mean" "Std Err." "CI Lower" "CI Upper" "Coef Var" "Margin of Err"
matlist mean_bill_length

putexcel set "results_custom.xlsx", replace
putexcel A2 = matrix(mean_bill_length), names
putexcel A1 = "Mean bill length (mm) by species"

svy: mean body_mass_g, over(species sex)

help matrix rownames

matrix mean_body_mass = r(table)'
matrix mean_body_mass = mean_body_mass[1..., "b".."se"]
matrix colnames mean_body_mass = "Mean" "Std Err"
matrix rownames mean_body_mass =                          ///
                    "Adelie:Female"     "Adelie:Male"     ///
                    "Chinstrap:Female"  "Chinstrap:Male"  ///
                    "Gentoo:Female"     "Gentoo:Male"
	
matlist mean_body_mass

svy, subpop(if species == 2 & year == 2009): mean flipper_length_mm, over(sex) 

putexcel set "results_with_significance.xlsx", replace
putexcel A1 = "Mean flipper length by sex, Gentoo penguins in 2009"
putexcel A2 = etable

test _b[flipper_length_mm@1.sex] = _b[flipper_length_mm@2.sex]

return list

local significant_diff = cond(`r(p)' <= 0.1, "significant", "not significant")
display "`significant_diff'"

putexcel A7 = "Difference is `significant_diff' at a 10% confidence level."

