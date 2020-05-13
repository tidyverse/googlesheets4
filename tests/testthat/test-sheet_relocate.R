# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_relocate")

# ---- tests ----
test_that("relocation works", {
  skip_if_offline()
  skip_if_no_token()

  sheet_names <- c("alfa", "bravo", "charlie", "delta", "echo", "foxtrot")
  ss <- local_ss(me_(), sheets = sheet_names)

  sheet_relocate(ss, "echo", .before = "bravo")
  sheet_relocate(ss, list("foxtrot", 4))
  sheet_relocate(ss, c("bravo", "alfa", "echo"), .after = 10)
  expect_equal(
    sheet_names(ss),
    c("foxtrot", "charlie", "delta", "bravo", "alfa", "echo")
  )
})
