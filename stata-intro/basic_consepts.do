/* 
* Introduction to Stata

* Uncomment the line below and define your working folder

cd "C:/Users/my_username/Documents/project_folder/"
*/

pwd

*Open Log

log using myfile.log, replace

* Examining the dataset

sysuse auto, clear
describe

* Ways to reveal value labels:
  
tabulate foreign
tabulate foreign, nolabel
label list
codebook foreign

* For information on how to create variable and value labels, see:
* help label

* Exploring missing values

misstable summarize

inspect rep78

* Descriptive statistics

summarize

summarize trunk, detail

tab trunk

tab foreign

tabulate foreign, summarize(mpg)

* Creating new variables

* Generate examples ----------------

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


generate rep78_gt_4 = rep78 > 4
browse rep78 rep78_gt_4

generate rep78_gt_4_nomiss = rep78 > 4 if !missing(rep78)
browse rep78 rep78_gt_4 rep78_gt_4_nomiss
