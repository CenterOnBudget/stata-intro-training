# Exorting Stata Results to Excel

[![Project Status: WIP - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

An accurate, efficient, and reproducible data analysis in Stata will automatically export the results into an appropriate format for communicating those results -- typically, an Excel spreadsheet.  

Unfortunately, figuring out how to do this for a given analysis can be less than straightforward. Stata has many commands that creating frequency tables, summary statistics, and other results. Many of these commands are primarily geared toward printing information to the Results pane, so users must first identify where the results that were printed are stored, and then extract and manipulate them for export to Excel. Other commands replace the data in memory with the results. 

The tutorials in this folder aim to demystify the process of automatically exporting Stata results to Excel. 

### Prerequisites

Users will find it helpful to skim [Chapter 14: Matrix expressions](https://www.stata.com/manuals/u14.pdf) in the Stata User Guide prior to running the tutorials.

### Contents

__`1_overview_of_options.do`__ presents the options for creating summary tables in Stata, and demonstrates how to export the results of each command. 

__`2_exporting_estimation_results.do`__ demonstates how to gather, manipulate, and export the results from estimation commands `[svy:] total` and `[svy:] mean`.

__`penguins.dta`__ example dataset used in the tutorial. Adapted from [palmerpenguins](https://allisonhorst.github.io/palmerpenguins/).

__`penguin_measures.xlsx`__ example Excel spreadsheet where results are collected.


### Stata Version

Written in Stata 16/MP.


