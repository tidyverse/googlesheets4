# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_add")

# ---- tests ----
test_that("sheet_add() rejects non-character `sheet`", {
  expect_snapshot(
    sheet_add(test_sheet("googlesheets4-cell-tests"), sheet = 3),
    error = TRUE
  )
})

test_that("sheet_add() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- local_ss(me_())

  expect_error_free(
    sheet_add(ss)
  )

  expect_error_free(
    sheet_add(ss, "apple", .after = 1)
  )

  expect_error_free(
    sheet_add(ss, "banana", .after = "apple")
  )

  expect_error_free(
    sheet_add(ss, c("coconut", "dragonfruit"))
  )

  expect_error_free(
    sheet_add(
      ss,
      sheet = "eggplant",
      .before = 1,
      gridProperties = list(
        rowCount = 3, columnCount = 6, frozenRowCount = 1
      )
    )
  )

  sheets_df <- sheet_properties(ss)

  expect_identical(
    sheets_df$name,
    c("eggplant", "Sheet1", "apple", "banana", "Sheet2", "coconut", "dragonfruit")
  )
  expect_identical(vlookup("eggplant", sheets_df, "name", "grid_rows"), 3L)
  expect_identical(vlookup("eggplant", sheets_df, "name", "grid_columns"), 6L)
})
