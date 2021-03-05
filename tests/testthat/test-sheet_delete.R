# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_delete")

# ---- tests ----
test_that("sheet_delete() rejects invalid `sheet`", {
  expect_error(
    sheet_delete(as_sheets_id("123"), sheet = TRUE),
    "must be either"
  )
})

test_that("sheet_delete() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- local_ss(me_())

  sheet_add(ss, c("alpha", "beta", "gamma", "delta"))

  # the suppressMessages() calls are targetting googledrive
  # when it gets a UI overhaul and knows to be silent during testing
  # they can be removed
  suppressMessages(expect_error_free(
    sheet_delete(ss, 1)
  ))
  suppressMessages(expect_error_free(
    sheet_delete(ss, "gamma")
  ))
  suppressMessages(expect_error_free(
    sheet_delete(ss, list("alpha", 2))
  ))

  sheets_df <- sheet_properties(ss)

  expect_identical(sheets_df$name, "delta")
})
