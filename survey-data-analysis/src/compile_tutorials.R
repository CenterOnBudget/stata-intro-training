library(here)
library(tidyverse)
library(fs)
library(glue)
library(snakecase)


# Render Rmd --------------------------------------------------------------

# (1) In Stata, run src/part-2/tables_for_rmd.do
# (2) Open and render manually:
#     src/part-1/part_1_survey_estimation.Rmd 
#     src/part-2/part_2_exporting_estimation_results.Rmd 
#     (The Stata markdown engine is not compatible with rmarkdown::render)



# Compile tutorial materials ----------------------------------------------

compile_tutorial <- function(part){
  
  # Copy html output to project directory -----------------------------------
  
  html_output <- dir_ls(here("src", glue("part-{part}")), glob = "*.html")
  file_copy(html_output, here(path_file(html_output)), overwrite = TRUE)
  
  part_title <- html_output %>%
    path_file() %>%
    path_ext_remove() %>%
    str_remove(., "part_\\d_") %>%
    to_title_case()
  
  # Compile .do files -------------------------------------------------------
  
  do_files <- dir_ls(here("src", glue("part-{part}")), glob = "*.do")
  
  do_file_text <- tibble(file = do_files) %>%
    filter(!(path_file(file) %in% c("profile.do", "tables_for_rmd.do"))) %>%
    mutate(order = file %>%
             path_file() %>%
             str_extract("[:digit:]{1,2}") %>%
             str_pad(width = 2, pad = "0")) %>%
    arrange(order) %>%
    pull(file) %>%
    map( ~ read_lines(.x) %>%
           c(., "")) %>%
    flatten_chr %>%
    c("* Survey Data Analysis with Stata", 
      glue("* Part {part}: {part_title}"), 
      "", 
      .)
  
  if (part == 2){
    do_file_text <- do_file_text %>%
      str_replace("putexcel A2 = \"\"", "putexcel A2 = etable")
  }
  
  write_lines(do_file_text, 
              here(html_output %>%
                     path_file %>%
                     path_ext_set(".do")))
  
}

walk(c(1, 2), compile_tutorial)


