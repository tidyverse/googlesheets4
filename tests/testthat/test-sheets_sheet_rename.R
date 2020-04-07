# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_sheet_rename")

# ---- tests ----
test_that("internal copy works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- scoped_temporary_ss(
    me_(),
    sheets = list(iris = head(iris), chickwts = head(chickwts))
  )
  ss %>%
    sheets_sheet_rename(2, new_name = "poultry") %>%
    sheets_sheet_rename(1, new_name = "flowers")
  out <- sheets_sheet_names(ss)
  expect_equal(out, c("flowers", "poultry"))
})
