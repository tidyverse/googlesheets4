test_that("slightly tricky `range`s work", {
  skip_if_offline()
  skip_if_no_token()

  out <- sheets_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B:D"
  )
  expect_true(all(grepl("^[BCD]", out$loc)))

  out <- sheets_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!2:3"
  )
  expect_true(all(grepl("[23]$", out$loc)))

  out <- sheets_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B3:C"
  )
  expect_true(all(grepl("^[BC]", out$loc)))
  expect_true(all(grepl("[3-9]$", out$loc)))

  out <- sheets_cells(
    test_sheet("googlesheets4-cell-tests"),
    range = "'range-experimentation'!B3:5"
  )
  expect_true(all(grepl("^[BCDE]", out$loc)))
  expect_true(all(grepl("[345]$", out$loc)))
})
