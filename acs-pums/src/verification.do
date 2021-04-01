
load_data acs, year(2018) clear

matrix drop _all

// population
generate pop_total = !missing(sporder)
recode relp (0/15 = 1 "Housing unit population")			///
			(16/17 = 2 "GQ population"),					///
			generate(pop_type)
recode relp (16 = 1 "GQ institutional population")			///
			(17 = 2 "GQ noninstitutional population")		///
			(nonmissing = .),								///
			generate(pop_gq_type)
categorize agep, generate(pop_age) breaks(5(5)24, 25(10)59, 60, 65(10)85)
svyset_acs, record_type("pers")
set level 90
foreach var of varlist pop_total pop_type pop_gq_type sex pop_age {
	svy: total i.`var' if st == 1
	tempname varmat
	matrix `varmat' = r(table)'
	matrix pop_verif = nullmat(pop_verif) \ `varmat'
}
matrix pop_verif = pop_verif[1..., "b".."se"]
tempname moe
matrix `moe' = pop_verif[1..., "se"] * 1.645
matrix pop_verif = pop_verif, `moe'
matlist pop_verif



// housing unit
generate hous_total = type == 1
generate hous_occ = type == 1 & missing(vacs)
recode type (1/2 = "Owner occupied units") 			///
			(3/4 = "Renter occupied units"), 		///
			generate(hous_ten)
generate hous_vac = !missing(vacs)
recode vacs (1 = 1 "For rent")						///
			(3 = 2 "For sale")						///
			(nonmissing = 3 "All other vacant"),
			generate(hous_vac_type)
			
			
			