# ---- nm_fun ----
me_ <- nm_fun("TEST-sheets_append")

# ---- tests ----
test_that("sheets_append() works", {
  dat <- tibble::tibble(x = as.numeric(1:10), y = LETTERS[1:10])
  ss <- scoped_temporary_ss(me_(), sheets = list(test = dat[0, ]))

  sheets_append(dat[1, ], ss, sheet = "test")
  out <- sheets_read(ss, sheet = "test")
  expect_equal(out, dat[1, ])

  sheets_append(dat[2:10, ], ss, sheet = "test")
  out <- sheets_read(ss, sheet = "test")
  expect_equal(out, dat)
})
