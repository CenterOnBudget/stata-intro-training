* Basic Concepts

/* * Uncomment the line below and define your working folder

cd "C:/Users/my_username/Documents/project_folder/"
*/

pwd

*Open Log

log using myfile.log, replace

sysuse auto, clear
describe

tabulate foreign

tabulate foreign, nolabel

label list

codebook foreign

misstable summarize

inspect rep78

summarize

summarize trunk, detail

tab trunk

tab foreign

tabulate foreign, summarize(mpg)

