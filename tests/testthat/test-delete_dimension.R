
test_that("delete dimension deletes appropriate rows", {
  skip_if_offline()
  skip_if_no_token()

  .sheet <<- "delete_dimension_tests"
  .ssid <- sheets_create(.sheet, sheets = .sheet)
  ss <<- sheets_get(.ssid)
  .example <<- tibble::as_tibble(setNames(data.frame(matrix(rep(as.double(2:10), times = 10), nrow = 9)), LETTERS[1:10]))
  write_sheet(.example, ss, .sheet)

  expect_error_free(
    delete_dimension(ss, .sheet, "r", c(2, 4:5, 7:9))
  )

  expect_identical(object = {
        .data <- read_sheet(ss, .sheet)
      },
      expected = {
        .example[- (c(2, 4:5, 7:9) - 1),]
      }
  )
})


test_that("delete dimension delete appropriate numeric columns", {
  skip_if_offline()
  skip_if_no_token()

  write_sheet(.example, ss, .sheet)

  expect_error_free(
    delete_dimension(ss, .sheet, "c", c(2, 4:5, 7:9))
  )

  expect_identical(object = {
    .data <- read_sheet(ss, .sheet)
  },
  expected = {
    .example[- c(2, 4:5, 7:9)]
  }
  )
})


test_that("delete dimension delete appropriate character columns", {
  skip_if_offline()
  skip_if_no_token()

  write_sheet(.example, ss, .sheet)

  expect_error_free(
    delete_dimension(ss, .sheet, "c", c("B", "D:E", "G:I"))
  )

  expect_identical(object = {
    .data <- read_sheet(ss, .sheet)
  },
  expected = {
    .example[- c(2, 4:5, 7:9)]
  }
  )
})
