																				/* 
Setup -------------------------------------------------------------------------

Before getting started, please set your working directory to the folder that 
contains the penguins.dta dataset.
																				*/
cd "replace/with/path/to/folder/where/penguins-dta/is"
																				/* 	
For this tutorial, we'll be using a dataset containing penguin measurements
collected by scientists at Palmer Station, Antarctica.
																				*/
use "penguins.dta", clear
notes _dta
																				/* 	
Let's pretend the penguins dataset is survey data with a complex survey design
like the ACS or CPS by generating some random weights and using the svyset 
command to set the survey design. We can then use the svy: prefix to ensure that 
estimation commands will adjust the results -- estimates and standard errors --
for survey settings identified by svyset.
																				*/
generate weight = round(runiform(100, 1000))
forvalues r = 1/80 {
	generate weight`r' = round(runiform(100, 1000))
}

svyset [iw=weight], vce(sdr) sdrweight(weight1-weight80) mse
																				/* 
Let's make some estimates! What is the average bill length by species?
We'll specify level(90) to indicate that we want to use a 90% confidence level.
																				*/
svy: mean bill_length_mm, over(species) level(90)
																				/* 
Tip: If your .do file has multiple estimation commands, include the line 
"set level 90" at the top of the .do file. Every subsequent estimation command 
will use a 90% confidence level without needing to specify the level(90) option
to each individual estimation command. 


Returned results --------------------------------------------------------------

See the table Stata prints to the Results pane? Behind the scenes, Stata has 
stored the information in that table (plus some other stuff) in special places 
in its memory. The information is known as "returned results".

To see what Stata has stored, we can look in two places where Stata keeps 
returned results.

e() is for returned results for estimation commands, like total and mean.
r() is for returned results for general commands, like summarize. Estimation 
commands store some results in r() as well as e().

There's a section in each command's help file that lists all the returned 
results the command stores. Pull up the help file for mean and scroll down to 
"Stored results".
																				*/
help mean
																				/*	
Now that we've run mean, we can see a list of everything it has stored in e() by
running:
																				*/
ereturn list		
																				/* 	
Going back to the help file for mean, recall that the matrix e(b) is a "vector 
of mean estimates". That's the first column in the table shown by the mean 
command. We can print the matrix e(b) to the Results pane with the matlist 
command.
																				*/
matlist e(b)
																				/*	
Since our data is from a survey, we need to access not only the estimated means, 
but the standard errors and/or confidence interval as well so that we can gauge 
the estimates' reliability. This information -- in fact all the contents of the 
table that mean printed to the Results pane -- can be found in r(). 
(Unfortunately, the help file for mean doesn't mention this!)

We can see what mean has stored in r() by running:
																				*/
return list
																				/* 	
Notice r(table), and appreciate it because it is extremely useful! Let's print 
r(table) to the Results pane.
																				*/ 
matrix list r(table)

																				/*
Manipulating returned results -------------------------------------------------

Notice that r(table) is transposed from the table that mean printed to the 
Results pane. r(table) has one column for each level of the variable species, 
whereas the table that mean printed had one row for each level of species. We 
can flip r(table) around to match the printed table by using the ' operator for 
transposing matrices. Let's name this new, flipped matrix "mean_bill_length".
																				*/
matrix mean_bill_length = r(table)'
matlist mean_bill_length
																				/* 	
Most users will be interested in the estimate, standard error, and confidence
interval. These are columns "b", "se", "ll" (lower limit of the confidence 
interval), and "ul" (upper limit of the confidence interval).

We can modify mean_bill_length to include only the columns we're interested in. 
We do that by using "submatrix extraction", which is a way of selecting certain 
rows or columns in a matrix.

When selecting certain rows or columns from a matrix, you can select either a 
single row/column or a range or rows/colums -- but you can't mix and match.

While "b" and "se" are next to each other, and so are "ll" and "ul", all four 
columns we are interested in aren't don't form a single range; there are other
columns in between. So, we'll have to pluck each pair of columns out into new
matrices, and then combine them by putting the first matrix to the right of the 
second matrix using the , matrix operator.
																				*/	
matrix bill_length_b_se = mean_bill_length[1..., "b".."se"]
matrix bill_length_ll_ul = mean_bill_length[1..., "ll".."ul"]

matrix mean_bill_length = bill_length_b_se, bill_length_ll_ul

matlist mean_bill_length
																				/*	
We could have referred to the columns by their numbers instead of their names 
(e.g. "mean_bill_length[1..., 1..2]"), but it's generally better to use names 
instead of numbers in order to make code more readable.

You may have noticed that the row names of mean_bill_length aren't the same as 
the row names of the table that mean printed to the Results pane, which were the 
value labels of species. Instead, the row names of mean_bill_length (previously,
the column names of r(table)) are factor variable operators. It's not important 
to know much about factor variable operators right now, but if you're 
interested, run "help factor variable" to learn more. 
	
These factor variable row names aren't what we'll want in our Excel spreadsheet. 
We can either add the row names to our spreadsheet manually, and not include the 
row names when exporting mean_bill_length to Excel; or we can rename the rows of
mean_bill_length now in Stata, and include the row names when exporting to 
Excel. Which option to choose depends on your preferences.

Let's proceed with the second option. We can rename the rows of mean_bill_length 
by typing the list of row names we want to the matrix rownames command. 
																				*/
matrix rownames mean_bill_length = "Adelie" "Chinstrap" "Gentoo"
matlist mean_bill_length
																				/* 	
Note that if we change the original mean command later as we refine the 
analysis, we may need to change the line of code above and set different row 
names. For instance, if we were to change the mean command to 
"svy, subpop(if island == 2): mean bill_length_mm, over(species)", the 
estimation sample would contain only two distinct levels of species, and 
mean_bill_length would have two rows rather than three. That's because our 
dataset has no observations of Gentoo penguins on the Dream island 
(island == 2). You can verify this by running "tabulate species island".
	
At this point, our matrix mean_bill_length has nice row names, and columns for
the estimated mean, the standard error, and upper and lower limits of the 
confidence interval. 

We could stop here and proceed to putting this matrix into our Excel 
spreadsheet, but it's helpful to demonstrate that one can calcuate a new column 
for a matrix just as one generates a new variable for a dataset.

For instance, we can add a column to mean_bill_length containing the margin of 
error of the estimated mean. We can do this by multiplying the standard error 
column of mean_bill_length by 1.645, which is the z-score (rounded to the 
nearest thousandth) for our confidence level of 90%. Or, we can compute the 
margin of error from the two confidence interval columns of mean_bill_length, 
since a margin of error is the confidence interval divided by two. 

We'll first compute the margin of error column in a new, one-column matrix, then 
join it to mean_bill_length.

Tip: To add a column to mean_bill_length containing coefficients of variation, 
we can take advantage of the "estat cv" command, which can be run after survey 
estimation commands and stores coefficients of variation in the matrix r(cv).
																				*/
// compute MOE from SE and the z-score for a 90% confidence level
matrix mean_bill_length_moe = mean_bill_length[1..., "se"] * 1.645

// or, compute MOE from confidence interval
matrix mean_bill_length_moe = 												///
		((mean_bill_length[1..., "ul"] - mean_bill_length[1..., "ll"]) / 2)
		
matrix colnames mean_bill_length_moe = "moe"

matrix mean_bill_length = mean_bill_length, mean_bill_length_moe
matlist mean_bill_length
																				/*	
Looks good! Now let's name the columns of mean_bill_length.
																				*/
matrix colnames mean_bill_length = 									///
		"Mean" "Std. Err." "CI Lower" "CI Upper" "Margin of Err."
matlist mean_bill_length

																				/*
Exporting results with putexcel -----------------------------------------------

We are now ready to export the matrix mean_bill_length to an Excel spreadsheet 
using the putexcel command. 
																				*/
help putexcel

putexcel set "mean_bill_length_by_species.xlsx", modify
putexcel A1 = matrix(mean_bill_length), names
																				/* 	
If we had opted to not worry about the row and column names of mean_bill_length 
and instead enter then in the spreadsheet manually, we'd have entered the row 
names in column A starting at A2, and the column names in row 1 starting at B1. 
So we'd run putexcel placing the matrix in B2, and leave out the "names" option:
"putexcel B2 = matrix(mean_bill_length)"

We could also use putexcel to place some notes about the analysis in the Excel 
sheet below the table. 
																				*/
putexcel A5 = "Source: penguins dataset"
putexcel A6 = "Version: `c(current_date)'"
																				/*
Done! We now have a nice table in mean_bill_length_by_species.xlsx.	We could now
open the file in Excel and manually customize the font and number formatting. 

You may be thinking that it might have been easier to copy the table from the 
Results pane and paste it into Excel. It's true that automating the export of 
estimation results from Stata to Excel requires some up-front work. But there 
are some big advantages that make it worthwhile. 

First, there is much less risk of human error, like typos or copying the wrong 
table or to the wrong place in a spreadsheet. 

Second, if we tweak the original mean command as we refine our analysis, we need 
to make only minor  adjustments to this code, and then can simply run it again 
to update the spreadsheet with our new results -- no copy-pasting needed. And 
because putexcel doesn't overwrite a spreadsheet's existing content when the 
modify option is specified, any manual formatting changes we'd made would be 
preserved.
																				*/
																				
																				/*
Bonus tip: Matrix "subheaders" ------------------------------------------------

Set matrix row and column name "subheaders" using matrix equation names. (Note 
that matrix row names cannot contain periods, but matrix column names can.)
																				*/
help matrix rownames

svy: mean bill_length_mm, over(species sex) level(90)
matrix by_species_sex = r(table)'
matrix by_species_sex = by_species_sex[1..., "b".."se"]
matrix rownames by_species_sex = 							///
					"Adelie:Female" "Adelie:Male"			///
					"Chinstrap:Female" "Chinstrap:Male" 	///
					"Gentoo:Female" "Gentoo:Male" 
matrix colnames by_species_sex = 							///
					"Mean bill length:Estimate" 			///
					"Mean bill length:Std. Err."					
matlist by_species_sex
																				/*
If you were to export the by_species_sex matrix to Excel by running:
	putexcel A1 = matrix(by_species_sex), names
the resulting spreadsheet would have two row name columns and two column name 
rows, one containing the first half of the row/column names (before the ":") and 
the other containing the second half (after the ":"). 

For instance, column A would contain the species name and column B would contain
the sex. Row 1 would contain the measure, "Mean bill length", and row 2 would 
contain the statistic, "Estimate" or "Std. Err.".

This of course could be done manually in Excel if that's your preference.
																				*/

