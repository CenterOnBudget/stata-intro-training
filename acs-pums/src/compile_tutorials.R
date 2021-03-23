library(here)
library(tidyverse)
library(fs)
library(glue)
library(snakecase)



# Render Rmd --------------------------------------------------------------

# Open and render manually all .Rmd files in the src/ subdirectories
# (The Stata markdown engine is not compatible with rmarkdown::render)


# Compile tutorial materials ----------------------------------------------

dir_names <- dir_ls(here("src"), type = "directory") %>%
  map_chr(basename)

compile_tutorial <- function(dir_name){
  
  # Copy html output to project directory -----------------------------------
  
  html_output <- dir_ls(here("src", dir_name), glob = "*.html")
  file_copy(html_output, here(path_file(html_output)), overwrite = TRUE)
  
  title <- html_output %>%
    path_file() %>%
    path_ext_remove() %>%
    str_replace("hhld", "household") %>%
    to_title_case()
  
  # Compile .do files -------------------------------------------------------
  
  do_files <- dir_ls(here("src", dir_name), glob = "*.do")
  
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
    c("* ACS PUMS Cookbook", 
      glue("* {title}"), 
      "", 
      .)
  
  write_lines(do_file_text, 
              here(html_output %>%
                     path_file %>%
                     path_ext_set(".do")))
  
}

walk(dir_names, compile_tutorial)



