devtools::load_all() # I assume we're in googlesheets4 source

googlesheets4:::sheets_auth_testing()

ss <- test_sheet_create("googlesheets4-cell-tests")
sheets_browse(ss)

df <- sheets_fodder(5)
sheets_write(df, ss, sheet = "range-experimentation")
w
