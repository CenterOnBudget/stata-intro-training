library(here)
library(tidyverse)
library(fs)



# Render Rmd --------------------------------------------------------------

# Open and render manually:
#  src/export_stata_tables_to_excel.Rmd
# (stata engine not compatible with rmarkdown::render with output_dir arg)


# Copy html output to project directory -----------------------------------

file_copy(here("src", "export_stata_tables_to_excel.html"),
          here("export_stata_tables_to_excel.html"),
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
  c("* Exporting Stata Tables to Excel", "", .)

write_lines(do_file_text, here("export_stata_tables_to_excel.do"))


