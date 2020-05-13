# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_copy")

# ---- tests ----
test_that("internal copy works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- local_ss(
    me_("internal"),
    sheets = list(iris = head(iris), chickwts = head(chickwts))
  )
  sheet_copy(ss, to_sheet = "xyz", .after = 1)
  out <- sheet_names(ss)
  expect_equal(out, c("iris", "xyz", "chickwts"))
})

test_that("external copy works", {
  skip_if_offline()
  skip_if_no_token()

  ss_source <- local_ss(
    me_("source"),
    sheets = list(iris = head(iris), chickwts = head(chickwts))
  )
  ss_dest <- local_ss(me_("dest"))

  sheet_copy(
    ss_source, from_sheet = "chickwts",
    to_ss = ss_dest, to_sheet = "chicks-two", .before = 1
  )
  out <- sheet_names(ss_dest)
  expect_equal(out, c("chicks-two", "Sheet1"))
})
