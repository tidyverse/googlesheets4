## TODO: consult remote key-value store for these? in case they change?
.sheets_examples <- googledrive::as_id(c(
                  "gapminder" = "1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY",
                   "mini-gap" = "1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU",
       "formulas-and-formats" = "1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms",
  "cell-contents-and-formats" = "1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E",
                     "deaths" = "1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg",
              "chicken-sheet" = "1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU"
))

.test_sheets <- googledrive::as_id(c(
  "googlesheets4-cell-tests" = "1XZFE6wdLNK0iXCOv22GOR0BJMd7hWxQ1-aGl1HMuhrI",
   "googlesheets4-col-types" = "1q-iRi1L3JugqHTtcjQ3DQOmOTuDnUsWi2AiG2eNyQkU"
))

test_sheet <- function(name = "googlesheets4-cell-tests") {
  stopifnot(is_string(name))
  m <- match(name, names(.test_sheets))
  if (is.na(m)) {
    stop_glue("Unrecognized test sheet: {sq('name')}")
  }
  new_sheets_id(.test_sheets[[m]])
}

test_sheet_create <- function(name = "googlesheets4-cell-tests") {
  stopifnot(is_string(name))

  user <- sheets_user()
  if (!grepl("^googlesheets4-testing", user)) {
    user <- sub("@.+$", "", user)
    stop_glue("Must be auth'd as {sq('googlesheets4-testing')}, not {sq(user)}")
  }

  existing <- sheets_find()
  m <- match(name, existing$name)
  if (is.na(m)) {
    message_glue("Creating {sq(name)}")
    ss <- sheets_create(name)
  } else {
    message_glue("Testing sheet named {sq(name)} already exists ... using that")
    ss <- existing$id[[m]]
  }
  ssid <- as_sheets_id(ss)

  # it's fiddly to check current sharing status, so just re-share
  message_glue("Making sure anyone with a link can read {sq(name)}")
  sheets_share(ssid)
  ssid
}


#' File IDs of example Sheets
#'
#' googlesheets4 ships with static IDs for some world-readable example Sheets
#' for use in examples and documentation. These functions make them easy to
#' access by a nickname.
#'
#' @param name Nickname of an example Sheet.
#'
#' @return
#'   * `sheets_example()`: a single [sheets_id] object
#'   * `sheets_examples()`: a named character vector of all built-in examples
#'
#' @export
#' @examples
#' sheets_examples()
#'
#' sheets_example("gapminder")
sheets_example <- function(name = names(sheets_examples())) {
  if (missing(name)) {
    stop_glue("`name` is a required argument")
  }
  name <- match.arg(name)
  new_sheets_id(.sheets_examples[[name]])
}


#' @rdname sheets_example
#' @export
sheets_examples <- function() .sheets_examples
