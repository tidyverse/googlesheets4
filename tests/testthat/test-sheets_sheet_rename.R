# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_sheet_rename")

# ---- tests ----
test_that("sheets_sheet_rename() rejects duplicate name for destination `sheet`", {
  skip_if_offline()
  skip_if_no_token()

  ss <- scoped_temporary_ss(me_())
  sheets_sheet_add(ss,"banana")

  expect_error(
    sheets_sheet_rename(ss,1,"banana"),
    "A sheet with the name \"banana\" already exists. Please enter another name.",
    class = "gargle_error_request_failed"
  )
})

test_that("sheets_sheet_rename() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- scoped_temporary_ss(me_())

  expect_error_free(
    sheets_sheet_rename(ss,1,"banana")
  )

  sheets_df <- sheets_sheet_data(ss)

  expect_identical(
    sheets_df$name,
    c("banana")
  )
})
