# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_sheet_delete")

# ---- tests ----
test_that("sheets_sheet_delete() rejects invalid `sheet`", {
  expect_error(
    sheets_sheet_delete(as_sheets_id("123"), sheet = TRUE),
    "must be either"
  )
})

test_that("sheets_sheet_delete() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- scoped_temporary_ss(me_())

  sheets_sheet_add(ss, c("alpha", "beta", "gamma", "delta"))

  expect_error_free(
    sheets_sheet_delete(ss, 1)
  )
  expect_error_free(
    sheets_sheet_delete(ss, "gamma")
  )
  expect_error_free(
    sheets_sheet_delete(ss, list("alpha", 2))
  )

  sheets_df <- sheets_sheet_data(ss)

  expect_identical(sheets_df$name, "delta")
})
