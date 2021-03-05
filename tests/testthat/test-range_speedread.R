test_that("range_spreadread() works", {
  skip_if_offline()
  skip_if_no_token()
  skip_if_not_installed("readr")

  # specify a sheet-qualified cell range
  read <- range_read(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B:D"
  )
  speedread <- range_speedread(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B:D",
    col_types = readr::cols() # suppress col spec printing
  )
  expect_equal(read, speedread, ignore_attr = TRUE)

  # specify col_types
  read <- range_read(
    gs4_example("deaths"),
    sheet = "other",
    range = "A5:F15",
    col_types = "??i?DD"
  )
  speedread <- range_speedread(
    gs4_example("deaths"),
    sheet = "other",
    range = "A5:F15",
    col_types = readr::cols(
      Age = readr::col_integer(),
      `Date of birth` = readr::col_date("%m/%d/%Y"),
      `Date of death` = readr::col_date("%m/%d/%Y")
    )
  )
  expect_equal(read, speedread, ignore_attr = TRUE)
})
