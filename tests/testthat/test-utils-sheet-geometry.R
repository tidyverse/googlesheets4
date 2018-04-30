context("utils-sheet-geometry")

# x = empty cell = not sent back by API
# O = occupied cell = present in API payload
#    A  B  C  D  E
# 1  x  x  x  x  x
# 2  x  O  O  O  x
# 3  x  O  O  x  x  <-- yes, it is intentional that D3 is empty
# 4  x  x  x  x  x

cell_df <- tibble::tribble(
  ~ row, ~ col, ~ cell,
      2,     2,   "B2",
      2,     3,   "C2",
      2,     4,   "D2",
      3,     2,   "B3",
      3,     3,   "C3"
)

limitize <- function(df) {
  c(
    min_row = min(df$row), max_row = max(df$row),
    min_col = min(df$col), max_col = max(df$col)
  )
}

test_that("observed data occupies range rectangle --> no shim needed", {
  expect_identical(insert_shims(cell_df, range = "B2:D3"), cell_df)
})

test_that("can shim a single side", {
  ## up
  expect_identical(
    limitize(insert_shims(cell_df, range = "B1:D3")),
    c(min_row = 1, max_row = 3, min_col = 2, max_col = 4)
  )
  ## down
  expect_identical(
    limitize(insert_shims(cell_df, range = "B2:D4")),
    c(min_row = 2, max_row = 4, min_col = 2, max_col = 4)
  )
  ## left
  expect_identical(
    limitize(insert_shims(cell_df, range = "A2:D3")),
    c(min_row = 2, max_row = 3, min_col = 1, max_col = 4)
  )
  ## right
  expect_identical(
    limitize(insert_shims(cell_df, range = "B2:E3")),
    c(min_row = 2, max_row = 3, min_col = 2, max_col = 5)
  )
})

test_that("can shim two opposing sides", {
  ## row direction
  expect_identical(
    limitize(insert_shims(cell_df, range = "B1:D4")),
    c(min_row = 1, max_row = 4, min_col = 2, max_col = 4)
  )
  ## col direction
  expect_identical(
    limitize(insert_shims(cell_df, range = "A2:E3")),
    c(min_row = 2, max_row = 3, min_col = 1, max_col = 5)
  )
})

test_that("can shim on two perpendicular sides", {
  ## up and left
  expect_identical(
    limitize(insert_shims(cell_df, range = "A1:D3")),
    c(min_row = 1, max_row = 3, min_col = 1, max_col = 4)
  )
  ## up and right
  expect_identical(
    limitize(insert_shims(cell_df, range = "B1:E3")),
    c(min_row = 1, max_row = 3, min_col = 2, max_col = 5)
  )
  # down and left
  expect_identical(
    limitize(insert_shims(cell_df, range = "A2:D4")),
    c(min_row = 2, max_row = 4, min_col = 1, max_col = 4)
  )
  # down and right
  expect_identical(
    limitize(insert_shims(cell_df, range = "B2:D4")),
    c(min_row = 2, max_row = 4, min_col = 2, max_col = 4)
  )
})

test_that("can shim three sides", {
  expect_identical(
    limitize(insert_shims(cell_df, range = "B1:E4")),
    c(min_row = 1, max_row = 4, min_col = 2, max_col = 5)
  )
})

test_that("can shim four sides", {
  expect_identical(
    limitize(insert_shims(cell_df, range = "A1:E4")),
    c(min_row = 1, max_row = 4, min_col = 1, max_col = 5)
  )
})
