## helpers ---------------------------------------------------------------------
expect_empty_cell <- function(object) {
  expect_equal(object[["userEnteredValue"]], NA)
}

expect_cell_value <- function(object, nm, val) {
  expect_equal(
    object[["userEnteredValue"]],
    list2(!!nm := val)
  )
}

expect_cell_format <- function(object, fmt) {
  expect_equal(object[["userEnteredFormat"]], fmt)
}

## tests -----------------------------------------------------------------------
test_that("expect_empty_cell() is synced with empty_cell()", {
  expect_empty_cell(empty_cell())
})

test_that("as_CellData() treats NULL as empty cell", {
  expect_empty_cell(as_CellData(NULL)[[1]])
})

test_that("as_CellData() works for logical", {
  out <- as_CellData(c(TRUE, NA, FALSE, NA))
  expect_cell_value(out[[1]], "boolValue", TRUE)
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "boolValue", FALSE)
  expect_empty_cell(out[[4]])
})

test_that("as_CellData() works for character and factor", {
  out <- as_CellData(c("a", NA, "c", NA))
  expect_cell_value(out[[1]], "stringValue", "a")
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "stringValue", "c")
  expect_empty_cell(out[[4]])

  out <- as_CellData(factor(c("a", NA, "c", NA)))
  expect_cell_value(out[[1]], "stringValue", "a")
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "stringValue", "c")
  expect_empty_cell(out[[4]])
})

test_that("as_CellData() works for integer or double", {
  out <- as_CellData(c(1L, NA, 3L, NA))
  expect_cell_value(out[[1]], "numberValue", 1L)
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "numberValue", 3L)
  expect_empty_cell(out[[4]])

  out <- as_CellData(c(1.5, NA, 3.5, NA))
  expect_cell_value(out[[1]], "numberValue", 1.5)
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "numberValue", 3.5)
  expect_empty_cell(out[[4]])
})

test_that("as_CellData() works for googlesheets4_schema_CellData", {
  out <- as_CellData("a")[[1]]
  expect_identical(out, as_CellData(out))

  out <- as_CellData(list("a", TRUE, 1.5))
  expect_identical(out, as_CellData(out))
})

test_that("as_CellData() works for Date", {
  input <- as.Date(c("2003-06-06", NA, "1982-12-05"))
  naked_input <- unclass(input)
  out <- as_CellData(input)
  # 25569 = DATEVALUE("1970-01-01), i.e. Unix epoch as a serial date, when the
  # date origin is December 30th 1899
  expect_cell_value(out[[1]], "numberValue", naked_input[[1]] + 25569)
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "numberValue", naked_input[[3]] + 25569)

  fmt <- list(numberFormat = list(type = "DATE", pattern = "yyyy-mm-dd"))
  expect_cell_format(out[[1]], fmt)
  expect_cell_format(out[[2]], fmt)
  expect_cell_format(out[[3]], fmt)
})

test_that("as_CellData() works for POSIXct", {
  input <- as.POSIXct(c("1978-05-31 04:24:32", NA, "2006-07-19 23:27:37"))
  naked_input <- unclass(input)
  attributes(naked_input) <- NULL

  out <- as_CellData(input)
  # 86400 = 60 * 60 * 24 = number of seconds in a day
  # 25569 = DATEVALUE("1970-01-01), i.e. Unix epoch as a serial date, when the
  # date origin is December 30th 1899
  expect_cell_value(
    out[[1]],
    "numberValue",
    (naked_input[[1]] / 86400) + 25569
  )
  expect_empty_cell(out[[2]])
  expect_cell_value(
    out[[3]],
    "numberValue",
    (naked_input[[3]] / 86400) + 25569
  )

  fmt <- list(numberFormat = list(
    type = "DATE_TIME", pattern = "yyyy-mm-dd hh:mm:ss"
  ))
  expect_cell_format(out[[1]], fmt)
  expect_cell_format(out[[2]], fmt)
  expect_cell_format(out[[3]], fmt)
})

test_that("as_CellData() works for list", {
  input <- list(TRUE, NA, "a", 1.5, factor("a"), 4L)
  out <- as_CellData(input)
  expect_cell_value(out[[1]], "boolValue", TRUE)
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "stringValue", "a")
  expect_cell_value(out[[4]], "numberValue", 1.5)
  expect_cell_value(out[[5]], "stringValue", "a")
  expect_cell_value(out[[6]], "numberValue", 4L)
})

test_that("as_CellData() works for formula", {
  hyperlink <- "=HYPERLINK(\"http://www.google.com/\",\"Google\")"
  image <- "=IMAGE(\"https://www.google.com/images/srpr/logo3w.png\")"
  out <- as_CellData(gs4_formula(c(hyperlink, NA, image)))
  expect_cell_value(out[[1]], "formulaValue", hyperlink)
  expect_empty_cell(out[[2]])
  expect_cell_value(out[[3]], "formulaValue", image)
})

test_that("as_CellData() doesn't add extra nesting to list-cols", {
  expect_identical(
    as_CellData(c("a", "b")),
    as_CellData(list("a", "b"))
  )
})
