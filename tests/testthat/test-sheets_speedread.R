test_that("sheets_spreadread() works", {
  skip_if_offline()
  skip_if_no_token()
  skip_if_not_installed("readr")

  # specify a sheet-qualified cell range
  read <- sheets_read(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B:D"
  )
  speedread <- sheets_speedread(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B:D"
  )
  expect_equivalent(read, speedread)

  # specify col_types
  read <- sheets_read(
    sheets_example("deaths"),
    sheet = "other",
    range = "A5:F15",
    col_types = "??i?DD"
  )
  speedread <- sheets_speedread(
    sheets_example("deaths"),
    sheet = "other",
    range = "A5:F15",
    col_types = readr::cols(
      Age = readr::col_integer(),
      `Date of birth` = readr::col_date("%m/%d/%Y"),
      `Date of death` = readr::col_date("%m/%d/%Y")
    )
  )
  expect_equivalent(read, speedread)
})
