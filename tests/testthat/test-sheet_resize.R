# ---- nm_fun ----
me_ <- nm_fun("TEST-sheet_resize")

# ---- tests ----
test_that("sheet_resize() works", {
  skip_if_offline()
  skip_if_no_token()

  ss <- local_ss(me_())
  local_gs4_loud()

  # no resize occurs
  expect_message(sheet_resize(ss, nrow = 2, ncol = 6), "No need") %>%
    suppressMessages()

  # reduce sheet size
  suppressMessages(sheet_resize(ss, nrow = 5, ncol = 7, exact = TRUE))
  props <- sheet_properties(ss)
  expect_equal(props$grid_rows, 5)
  expect_equal(props$grid_columns, 7)
})

test_that("prepare_resize_request() works for resize & no resize", {
  n <- 3
  m <- 5
  sheet_info <- list(grid_rows = n, grid_columns = m)

  # (n - 1, n, n + 1) x (m - 1, m, m + 1) x (TRUE, FALSE)
  # 3 * 3 * 2 = 18 combinations

  # exact = FALSE
  df <- expand.grid(nrow_needed = n + -1:1, ncol_needed = m + -1:1, exact = FALSE)
  req <- pmap(df, prepare_resize_request, sheet_info = sheet_info)
  grid_properties <- purrr::map(
    req,
    c("updateSheetProperties", "properties", "gridProperties")
  )

  # sheet is big enough --> no resize request
  purrr::walk(
    grid_properties[df$nrow_needed <= n & df$ncol_needed <= m],
    expect_null
  )

  # not enough rows
  purrr::walk(
    grid_properties[df$nrow_needed > n],
    ~ expect_true(has_name(.x, "rowCount"))
  )

  # not enough columns
  purrr::walk(
    grid_properties[df$ncol_needed > m],
    ~ expect_true(has_name(.x, "columnCount"))
  )

  # exact = TRUE
  df <- expand.grid(nrow_needed = n + -1:1, ncol_needed = m + -1:1, exact = TRUE)
  req <- pmap(df, prepare_resize_request, sheet_info = sheet_info)
  grid_properties <- purrr::map(
    req,
    c("updateSheetProperties", "properties", "gridProperties")
  )

  # sheet has correct size --> no resize request
  purrr::walk(
    grid_properties[df$nrow_needed == n & df$ncol_needed == m],
    expect_null
  )

  # not enough rows or too many rows
  purrr::walk(
    grid_properties[df$nrow_needed != n],
    ~ expect_true(has_name(.x, "rowCount"))
  )

  # not enough columns or too many columns
  purrr::walk(
    grid_properties[df$ncol_needed != m],
    ~ expect_true(has_name(.x, "columnCount"))
  )
})
