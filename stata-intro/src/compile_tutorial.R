library(here)
library(tidyverse)
library(fs)



# Render Rmd --------------------------------------------------------------

# Open and render manually:
#  src/basic_concepts.Rmd
# (stata engine not compatible with rmarkdown::render with output_dir arg)


# Copy html output to project directory -----------------------------------

file_copy(here("src", "basic_concepts.html"),
          here("basic_concepts.html"),
          overwrite = TRUE)


# Compile .do files -------------------------------------------------------

do_files <- dir_ls(here("src"), glob = "*.do")

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
  c("* Basic Concepts", "", .)

write_lines(do_file_text, here("basic_concepts.do"))