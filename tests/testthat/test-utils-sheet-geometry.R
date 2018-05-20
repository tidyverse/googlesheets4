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
  cell_limits(c(min(df$row), min(df$col)), c(max(df$row), max(df$col)))
}

expect_shim <- function(rg) {
  expect_identical(
    limitize(insert_shims(cell_df, as_cell_limits(rg))),
    as_cell_limits(rg)
  )
}

test_that("observed data occupies range rectangle --> no shim needed", {
  expect_identical(
    insert_shims(cell_df, cell_limits = as_cell_limits("B2:D3")),
    cell_df
  )
})

test_that("can shim a single side", {
  ## up
  expect_shim("B1:D3")
  ## down
  expect_shim("B2:D4")
  ## left
  expect_shim("A2:D3")
  ## right
  expect_shim("B2:E3")
})

test_that("can shim two opposing sides", {
  ## row direction
  expect_shim("B1:D4")
  ## col direction
  expect_shim("A2:E3")
})

test_that("can shim on two perpendicular sides", {
  ## up and left
  expect_shim("A1:D3")
  ## up and right
  expect_shim("B1:E3")
  # down and left
  expect_shim("A2:D4")
  # down and right
  expect_shim("B2:E4")
})

test_that("can shim three sides", {
  ## all but bottom
  expect_shim("A1:E3")
  ## all but left
  expect_shim("B1:E4")
  ## all but top
  expect_shim("A2:E4")
  ## all but right
  expect_shim("A1:D4")
})

test_that("can shim four sides", {
  expect_shim("A1:E4")
})
