test_that("can coerce simple strings and drive_id's to sheets_id", {
  expect_s3_class(as_sheets_id("123"), "sheets_id")
  expect_identical(as_sheets_id(as_sheets_id("123")), as_sheets_id("123"))
  expect_identical(as_sheets_id(as_id("123")), as_sheets_id("123"))
})

test_that("string with invalid character is rejected", {
  expect_snapshot(as_sheets_id("abc&123"), error = TRUE)
})

test_that("invalid inputs are caught", {
  expect_error(as_sheets_id(NULL))
  expect_error(as_sheets_id(1))
  expect_snapshot(as_sheets_id(letters[1:2]), error = TRUE)
})

test_that("id can be dug out of a URL", {
  expect_identical(
    as_sheets_id("https://docs.google.com/spreadsheets/d/abc123/"),
    as_sheets_id("abc123")
  )
  expect_identical(
    as_sheets_id("https://docs.google.com/spreadsheets/d/abc123/edit#gid=123"),
    as_sheets_id("abc123")
  )
})

test_that("invalid URL is interpreted as filepath, results in NA", {
  out <- as_sheets_id("https://www.r-project.org")
  expect_equal(vec_data(NA), NA)
})

# how I created the reference dribble, which represents two files:
#   * one Google Sheet
#   * one non-Google Sheet
# dat <- googledrive::drive_examples_remote()
# dat <- dat[dat$name %in% c("chicken.txt", "chicken_sheet"), ]
# saveRDS(dat, file = test_path("ref/dribble.rds"), version = 2)

test_that("multi-row dribble is rejected", {
  d <- readRDS(test_path("ref/dribble.rds"))
  expect_snapshot(as_sheets_id(d), error = TRUE)
})

test_that("dribble with non-Sheet file is rejected", {
  d <- readRDS(test_path("ref/dribble.rds"))
  d <- googledrive::drive_reveal(d, what = "mime_type")
  d <- d[d$mime_type == "text/plain", ]
  expect_snapshot(as_sheets_id(d), error = TRUE)
})

test_that("dribble with one Sheet can be coerced", {
  d <- readRDS(test_path("ref/dribble.rds"))
  d <- googledrive::drive_reveal(d, what = "mime_type")
  d <- d[d$mime_type == "application/vnd.google-apps.spreadsheet", ]
  expect_s3_class(as_sheets_id(d), "sheets_id")
})

test_that("a googlesheets4_spreadsheet can be coerced", {
  x <- new("Spreadsheet", spreadsheetId = "123")
  out <- as_sheets_id(new_googlesheets4_spreadsheet(x))
  expect_s3_class(out, "sheets_id")
  expect_identical(out, as_sheets_id("123"))
})

test_that("as_id.googlesheets4_spreadsheet works", {
  x <- new_googlesheets4_spreadsheet(list(spreadsheetId = "123"))
  expect_identical(as_id(x), as_id("123"))
})

## sheets_id print method ----

test_that("sheets_id print method reveals metadata", {
  skip_if_offline()
  skip_if_no_token()

  expect_snapshot(print(gs4_example("gapminder")))
})

test_that("sheets_id print method doesn't error for nonexistent ID", {
  skip_if_offline()
  skip_if_no_token()

  expect_error_free(format(as_sheets_id("12345")))
  expect_snapshot(as_sheets_id("12345"))
})

test_that("can print public sheets_id if deauth'd", {
  skip_if_offline()
  skip_on_cran()

  local_deauth()
  expect_snapshot(print(gs4_example("mini-gap")))
})

test_that("sheets_id print does not error for lack of cred", {
  skip_if_offline()
  skip_on_cran()

  local_deauth()
  local_interactive(FALSE)
  withr::local_options(list(gargle_oauth_cache = FALSE))

  # typical initial state: auth_active, but no token yet
  .auth$clear_cred()
  .auth$set_auth_active(TRUE)

  expect_error_free(format(gs4_example("mini-gap")))
  expect_snapshot(print(gs4_example("mini-gap")))
})

## low-level helpers ----
test_that("new_sheets_id() handles 0-length input and NA", {
  expect_error_free(
    out <- new_sheets_id(character())
  )
  expect_length(out, 0)
  expect_s3_class(out, "sheets_id")

  expect_error_free(
    out <- new_sheets_id(NA_character_)
  )
  expect_true(is.na(out))
  expect_s3_class(out, "sheets_id")
})

test_that("combining 2 sheets_id yields drive_id", {
  id1 <- as_sheets_id("abc")
  id2 <- as_sheets_id("def")
  expect_s3_class(c(id1, id2), class(new_drive_id()))
})
