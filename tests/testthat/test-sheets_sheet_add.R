# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_sheet_add")

# ---- tests ----
test_that("sheets_sheet_add() rejects non-character `sheet`", {
  expect_error(
    sheets_sheet_add(test_sheet("googlesheets4-cell-tests"), sheet = 3),
    "must be character"
  )
})

test_that("sheets_sheet_add() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- scoped_temporary_ss(me_())

  expect_error_free(
    sheets_sheet_add(ss)
  )

  expect_error_free(
    sheets_sheet_add(ss, "apple", .after = 1)
  )

  expect_error_free(
    sheets_sheet_add(ss, "banana", .after = "apple")
  )

  expect_error_free(
    sheets_sheet_add(
      ss,
      sheet = "coconut",
      gridProperties = list(
        rowCount = 3, columnCount = 6, frozenRowCount = 1
      )
    )
  )

  sheets_df <- sheets_sheet_data(ss)

  expect_identical(
    sheets_df$name,
    c("Sheet1", "apple", "banana", "Sheet2", "coconut")
  )
  expect_identical(vlookup("coconut", sheets_df, "name", "grid_rows"), 3L)
  expect_identical(vlookup("coconut", sheets_df, "name", "grid_columns"), 6L)
})
