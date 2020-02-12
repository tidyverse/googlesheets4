# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_sheet_copy")

# ---- tests ----

test_that("sheets_sheet_copy() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- scoped_temporary_ss(me_())
  sheets_sheet_rename(ss,1,"apply")

  expect_error_free(
    sheets_sheet_copy(ss,"apple",destination_sheet = "banana")
  )

  sheets_df <- sheets_sheet_data(ss)

  expect_identical(
    sheets_df$name,
    c("apple","banana")
  )
})
