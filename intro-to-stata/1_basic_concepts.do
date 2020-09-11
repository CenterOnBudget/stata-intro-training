
* Working directories ---------------------------------------------------------

/*	Almost every Stata script begins with setting the working directory. 
	The working directory is the place where Stata will look for any files you
	reference later in the script. You set your working directory with the 
	command 'cd'.
	
	There are two advantages of using working directories:
	
	(1) Once you set it, you won't need to write out the full file path of any 
		file inside the working directory.
	
		Without setting the working directory:
		
			use "C:/Users/my_username/Documents/project_folder/data-raw/my_data.dta"
			* a bunch of code here *
			save "C:/Users/my_username/Documents/project_folder/data/my_final_data.dta"
		
		With setting the working directory:
		
			cd "C:/Users/my_username/Documents/project_folder/"
			use "data-raw/my_data.dta"
			* a bunch of code here *
			save "data/my_final_data.dta"
		
	(2) If you move your project files from one folder to another, or rename the
		folder, you only need to change one line of code.
		
		For instance, if you renamed project_folder to new_project_folder, you'd
		simply change the first line above to 
		
			cd "C:/Users/my_username/Documents/new_project_folder/
			
		and the rest of your code would still work fine.
		
*/

cd "${ghpath}/stata-intro-training"

pwd


* Load example dataset --------------------------------------------------------

sysuse auto, clear


* Data types and metadata -----------------------------------------------------

* The 'describe' command is an easy way to get acquainted with your dataset.
* It lists all the variables in the dataset, along with their types and variable
* labels.
describe

* Browsing (viewing) the dataset is another way to examine it.
browse

/*	From browsing, we see that the values for the 'foreign' variable are blue.
	That means the values of the variable are labeled. Value labels are a 
	helpful way to convey the meaning of logical or categorical variables.
	
	In the first row, 'foreign' appears as 'Domestic', but if we click the cell 
	to view the underlying value, it's '0'
	
	There are several ways to reveal value labels.
*/
tabulate foreign
tabulate foreign, nolabel
label list
codebook foreign

* For information on how to create variable and value labels, see:
help label


* Stata syntax ----------------------------------------------------------------

/*	Every Stata command has syntax: what you type, and in what order, to tell
	the command what you want to do. 
	Each Stata command has a help file that can be accessed by typing 'help' and
	then the name of the command. 
	For instance, if I wanted to learn about the 'generate' command -- which 
	creates new variables, I would run
		help generate
	
	The help file shows that the syntax for 'generate' is
	
		generate [type] newvar[:lblname] =exp [if] [in] [, before(varname) | after(varname)]	

	Each thing that you type after the command name is called an argument. 
	Arguments in brackets are optional. Let's ignore the optional arguments for
	now and focus on the required syntax for 'generate':
	
		generate newvar =exp
		
	'=exp' means an expression. An expression is simply the right-hand of an
	equation. Expressions can contain numbers, variable names, and more.
	
	Let's try out the 'generate' command. 
*/


* Generate examples -----------------------------------------------------------

* A numeric variable calculated from another variable
generate length_ft = length / 12
browse length length_ft

* A numeric variable calculated from two other variables
generate weight_per_length_ft = weight / length_ft
browse weight length_ft weight_per_length_ft

* A logical variable is equal to 1 in rows where the expression is true, 
* and 0 in rows where it is false
generate headroom_3 = headroom == 3
browse headroom headroom_3

* Logical variables can have many criteria.
generate ideal_car = price <= 4000 & mpg > 20 & make != "Chev. Nova"
browse price mpg make ideal_car
/*	In Stata syntax, an exclamation point means 'not'. 
	'!=' is an operator that means not equal to.
	'!' can also be used to negate an expression or part of an expression.
	The 'generate' command above could also have been written:
		generate ideal_car = price <= 4000 & mpg > 30 & !(make == "Chev. Nova")
*/

* In Stata, missing values are infinitely large. 
* What would 'rep78_gt_4' be if 'rep78' is missing?
generate rep78_gt_4 = rep78 > 4
browse rep78 rep78_gt_4

* Use the optional 'if' argument, the '!' operator, and the 'missing' operator 
* to ensure that 'rep78_gt_4_nomiss' is missing if 'rep78' is mising.
generate rep78_gt_4_nomiss = rep78 > 4 if !missing(rep78)
browse rep78 rep78_gt_4 rep78_gt_4_nomiss


