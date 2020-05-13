# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_append")

# ---- tests ----
test_that("sheet_append() works", {
  skip_if_offline()
  skip_if_no_token()

  dat <- tibble::tibble(x = as.numeric(1:10), y = LETTERS[1:10])
  ss <- local_ss(me_(), sheets = list(test = dat[0, ]))

  sheet_append(ss, dat[1, ], sheet = "test")
  out <- range_read(ss, sheet = "test")
  expect_equal(out, dat[1, ])

  sheet_append(ss, dat[2:10, ], sheet = "test")
  out <- range_read(ss, sheet = "test")
  expect_equal(out, dat)
})
