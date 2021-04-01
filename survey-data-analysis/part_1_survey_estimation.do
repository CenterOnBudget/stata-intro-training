* Survey Data Analysis with Stata
* Part 1: Survey Estimation

* Setup

use "https://github.com/CenterOnBudget/stata-trainings/raw/master/penguins-dta/penguins.dta", clear

* Generate random weight variables
generate weight = round(runiform(100, 1000))
forvalues r = 1/80 {
  generate weight`r' = round(runiform(100, 1000))
}

* Setting the survey design with svyset

help svyset##description

svyset [pw=weight], vce(sdr) sdrweight(weight1-weight80) mse

* Setting the confidence interval

set level 90                        

* Estimation commands: Continuous variables

svy: mean bill_length_mm

svy: total body_mass_g

* Estimation commands: Categorical variables

svy: proportion species

help factor variable

svy: proportion species#island

svy: proportion species##island

svy: mean i.species
svy: mean i.species#i.island
svy: mean i.species##i.island

svy: total i.species

* The svy: tabulate command

help svy: tabulate

* Estimating multiple variables in one command

svy: mean bill_length_mm bill_depth_mm body_mass_g

misstable patterns bill_length_mm bill_depth_mm body_mass_g, frequency asis 

* Subpopulation estimation

svy: mean bill_length_mm, over(species)

svy: mean bill_length_mm, over(species island)

codebook sex
generate female = sex == 1 if !missing(sex)
svy, subpop(female): mean bill_length_mm

svy, subpop(if species == 2 & year == 2009): mean bill_length_mm

svy, subpop(female): mean bill_length_mm, over(species)

* Coefficients of variation

svy: mean bill_length_mm, over(species)
estat cv

* Statistical testing

help test

svy, subpop(if species == 2 & year == 2009): mean flipper_length_mm, over(sex) coeflegend

test _b[c.flipper_length_mm@1bn.sex] = _b[c.flipper_length_mm@2.sex]

