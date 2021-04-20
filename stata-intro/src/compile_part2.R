library(here)
library(tidyverse)
library(fs)


file_copy(here("src", "data_analysis.html"),
          here("data_analysis.html"),
          overwrite = TRUE)

do_files <- dir_ls(here(""), glob = "*.do")

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
  c("* Data Analysis", "", .)

write_lines(do_file_text, here("data_analysis.do"))


