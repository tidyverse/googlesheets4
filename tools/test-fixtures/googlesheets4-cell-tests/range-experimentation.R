devtools::load_all() # I assume we're in googlesheets4 source

googlesheets4:::sheets_auth_testing()

ss <- test_sheet_create("googlesheets4-cell-tests")
gs4_browse(ss)

df <- gs4_fodder(5)
sheet_write(df, ss, sheet = "range-experimentation")
