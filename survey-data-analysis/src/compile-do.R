library(here)
library(tidyverse)
library(fs)
library(rmarkdown)



# Render Rmd --------------------------------------------------------------

# Open src/survey_data_analysis_stata.Rmd and render manually. 
# rmarkdown::render not compatible with stata engine


# Copy html output to project directory -----------------------------------

file_copy(here("src", "survey_data_analysis_stata.html"),
          here("survey_data_analsis_stata.html"))


# Compile .do files -------------------------------------------------------


do_files <- dir_ls(here("src"), regexp = "unnamed-chunk")

do_file_text <- tibble(files = do_files) %>%
  mutate(order = files %>%
           str_extract("[:digit:]{1,2}") %>%
           str_pad(width = 2, pad = "0")) %>%
  arrange(order) %>%
  pull(files) %>%
  map( ~ read_lines(.x) %>%
         c(., "")) %>%
  flatten_chr %>%
  c("* Survey Data Analysis with Stata", "", .)

write_lines(do_file_text, here("survey_data_analysis_stata.do"))


