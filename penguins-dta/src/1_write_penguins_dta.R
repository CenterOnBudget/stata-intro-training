library(here)
library(foreign)
library(palmerpenguins)

write.dta(penguins, 
          here("penguins.dta"),
          version = 10,
          convert.factors = "labels")

citation("palmerpenguins")