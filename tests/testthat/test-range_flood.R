# ---- nm_fun ----
me_ <- nm_fun("TEST-range_flood")

# ---- tests ----
test_that("range_flood() works", {
  skip_if_offline()
  skip_if_no_token()

  dat <- tibble::tibble(x = rep(1, 3), y = rep(2, 3), z = rep(3, 3))
  ss <- local_ss(me_(), sheets = list(dat))

  # clear values and format
  range_flood(ss, range = "A:A")

  # reset values and reformat
  range_flood(ss, range = "B:B", cell = "hi")

  # reset values, leave format unchanged
  range_flood(ss, range = "C:C", cell = "bye", reformat = FALSE)

  out <- range_read_cells(ss, cell_data = "full", discard_empty = FALSE)

  expect_equal(
    purrr::map_chr(out$cell, "formattedValue", .default = ""),
    rep(c("", "hi", "bye"), 4)
  )

  column_A <- out[out$col == 1, ]
  fmts <- purrr::map(column_A$cell, "effectiveFormat")
  expect_true(all(purrr::map_lgl(fmts, is.null)))

  column_B <- out[out$col == 2, ]
  fmts <- purrr::map(column_B$cell, c("effectiveFormat", "backgroundColor"))
  expect_true(all(unlist(fmts) == 1))

  column_C_header <- out[out$col == 3 & out$row == 1, ]
  fmt <- purrr::pluck(column_C_header, "cell", 1, "effectiveFormat", "backgroundColor")
  expect_true(all(unlist(fmt) < 1))
})
