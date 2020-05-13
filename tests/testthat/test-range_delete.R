# ---- nm_fun ----
me_ <- nm_fun("TEST-range_delete")

# ---- tests ----
test_that("range_delete() works", {
  skip_if_offline()
  skip_if_no_token()

  df <- gs4_fodder(4)
  ss <- local_ss(me_(), sheets = list(df))

  range_delete(ss, range = "2:3")
  range_delete(ss, range = "B")
  range_delete(ss, range = "B2", shift = "left")

  out <- range_read(ss)

  expect_match(sub("[A-Z](\\d)", "\\1", out[2, ]), "5")
  expect_equal(names(out), c("A", "C", "D"))
  expect_equal(out[[1, 2]], "D4")
})

# helpers ----

test_that("determine_shift() 'works' for ranges where user input is required", {
  sheets_df <- tibble::tibble(name = "Sheet1", index = 0)

  # these are all essentially true rectangles and the user will have to tell
  # us how to shift cells into the deleted region
  bounded_bottom_and_right <- list(
    cell_limits(c(NA, NA), c(3, 5)),
    cell_limits(c( 1, NA), c(3, 5)),
    cell_limits(c(NA,  3), c(3, 5)),
    cell_limits(c( 1,  3), c(3, 5))
  )

  out <- purrr::map(
    bounded_bottom_and_right,
    ~ determine_shift(as_GridRange(as_range_spec(.x, sheets_df = sheets_df)))
  )
  purrr::map(out, expect_null)
})

test_that("determine_shift() detects ranges where we shift ROWS up", {
  sheets_df <- tibble::tibble(name = "Sheet1", index = 0)

  # these are bounded on the bottom, but not the on the right
  bounded_bottom <- list(
    cell_limits(c(NA, NA), c(3, NA)),
    cell_limits(c( 1, NA), c(3, NA)),
    cell_limits(c(NA,  3), c(3, NA)),
    cell_limits(c( 1,  3), c(3, NA))
  )

  out <- purrr::map_chr(
    bounded_bottom,
    ~ determine_shift(as_GridRange(as_range_spec(.x, sheets_df = sheets_df)))
  )
  expect_match(out, "ROWS")
})

test_that("determine_shift() detects ranges where we shift COLUMNS left", {
  sheets_df <- tibble::tibble(name = "Sheet1", index = 0)

  # these are bounded on the bottom, but not the on the right
  bounded_right <- list(
    cell_limits(c(NA, NA), c(NA, 5)),
    cell_limits(c( 1, NA), c(NA, 5)),
    cell_limits(c(NA,  3), c(NA, 5)),
    cell_limits(c( 1,  3), c(NA, 5))
  )

  out <- purrr::map_chr(
    bounded_right,
    ~ determine_shift(as_GridRange(as_range_spec(.x, sheets_df = sheets_df)))
  )
  expect_match(out, "COLUMNS")
})

test_that("determine_shift() detects ranges where we must error", {
  sheets_df <- tibble::tibble(name = "Sheet1", index = 0)

  # these are not bounded at on either the bottom or the right
  not_bounded <- list(
    cell_limits(c(NA, NA), c(NA, NA)),
    cell_limits(c( 1, NA), c(NA, NA)),
    cell_limits(c(NA,  3), c(NA, NA)),
    cell_limits(c( 1,  3), c(NA, NA))
  )

  expect_bad_range <- function(x) {
    grid_range <- as_GridRange(as_range_spec(x, sheets_df = sheets_df))
    expect_error(determine_shift(grid_range), "must be bounded")
  }

  purrr::walk(not_bounded, expect_bad_range)
})
