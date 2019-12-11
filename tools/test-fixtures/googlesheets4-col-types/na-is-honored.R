# https://github.com/tidyverse/googlesheets4/issues/73
devtools::load_all() # I assume we're in googlesheets4 source
library(googledrive)

googlesheets4:::sheets_auth_testing()

# TODO: come back to this when googlesheets4 has the capability to write this sheet!
# for now, I'm copying the Sheet provided by OP

(ss <- drive_get(as_id("1D98U_4wx2pm2-0hUuOOJNM0NKDv-WouP2IRuBFnWrRg")))
ss <- drive_cp(ss, name = "googlesheets4-col-types")
(ss <- sheets_find("googlesheets4-col-types"))
sheets_share(as_sheets_id(ss))
