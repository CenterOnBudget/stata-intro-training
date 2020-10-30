library(here)
library(tidyverse)
library(fs)
library(glue)



# Render Rmd --------------------------------------------------------------

# Open and render manually:
#  src/part-1/part_1_survey_data_analysis_stata.Rmd 
#  src/part-2/part_2_data_analysis_stata.Rmd 
# (stata engine not compatible with rmarkdown::render with output_dir arg)


# Compile tutorial materials ----------------------------------------------

compile_tutorial <- function(part){
  
  # Copy html output to project directory -----------------------------------

  file_copy(here("src", 
                 glue("part-{part}"), 
                 glue("part_{part}_survey_data_analysis_stata.html")),
            here(glue("part_{part}_survey_data_analysis_stata.html")),
            overwrite = TRUE)
  
  
  # Compile .do files -------------------------------------------------------

  do_files <- dir_ls(here("src", glue("part-{part}")), glob = "*.do")
  
  do_file_text <- tibble(file = do_files) %>%
    filter(path_file(file) != "profile.do") %>%
    mutate(order = file %>%
             path_file() %>%
             str_extract("[:digit:]{1,2}") %>%
             str_pad(width = 2, pad = "0")) %>%
    arrange(order) %>%
    pull(file) %>%
    map( ~ read_lines(.x) %>%
           c(., "")) %>%
    flatten_chr %>%
    c(glue("* Survey Data Analysis with Stata, Part {part}"), "", .)
  
  if (part == 2){
    do_file_text <- do_file_text %>%
      str_replace("putexcel A2 = \"\"", "putexcel A2 = etable")
  }
  
  write_lines(do_file_text, 
              here(glue("part_{part}_survey_data_analysis_stata.do")))
  
}

walk(c(1, 2), compile_tutorial)

