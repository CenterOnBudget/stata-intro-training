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

