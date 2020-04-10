## TODO: consult remote key-value store for these? in case they change?
.gs4_examples <- googledrive::as_id(c(
                   "mini-gap" = "1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU",
                  "gapminder" = "1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY",
                     "deaths" = "1tuYKzSbLukDLe5ymf_ZKdQA8SfOyeMM7rmf6D6NJpxg",
              "chicken-sheet" = "1ct9t1Efv8pAGN9YO5gC2QfRq2wT4XjNoTMXpVeUghJU",
       "formulas-and-formats" = "1wPLrWOxxEjp3T1nv2YBxn63FX70Mz5W5Tm4tGc-lRms",
  "cell-contents-and-formats" = "1peJXEeAp5Qt3ENoTvkhvenQ36N3kLyq6sq9Dh2ufQ6E"
))

.test_sheets <- googledrive::as_id(c(
  "googlesheets4-cell-tests" = "1WRFIb11PJsNwx2tYBRn3uq8uHwWSI5ziSgbGjkOukmE",
   "googlesheets4-col-types" = "1q-iRi1L3JugqHTtcjQ3DQOmOTuDnUsWi2AiG2eNyQkU"
))

test_sheet <- function(matches = "googlesheets4-cell-tests") {
  one_sheet(
    needle    = matches,
    haystack  = .test_sheets,
    adjective = "test"
  )
}

test_sheet_create <- function(name = "googlesheets4-cell-tests") {
  stopifnot(is_string(name))

  user <- sheets_user()
  if (!grepl("^googlesheets4-testing", user)) {
    user <- sub("@.+$", "", user)
    stop_glue("Must be auth'd as {sq('googlesheets4-testing')}, not {sq(user)}")
  }

  existing <- gs4_find()
  m <- match(name, existing$name)
  if (is.na(m)) {
    message_glue("Creating {dq(name)}")
    ss <- gs4_create(name)
  } else {
    message_glue("Testing sheet named {dq(name)} already exists ... using that")
    ss <- existing$id[[m]]
  }
  ssid <- as_sheets_id(ss)

  # it's fiddly to check current sharing status, so just re-share
  message_glue("Making sure anyone with a link can read {dq(name)}")
  sheets_share(ssid)
  ssid
}

many_sheets <- function(needle, haystack, adjective) {
  out <- haystack

  if (!missing(needle)) {
    check_string(needle)
    sel <- grepl(needle, names(out), ignore.case = TRUE)
    if (!any(sel)) {
      stop_glue("Can't find {adjective} Sheet that matches {dq(needle)}")
    }
    out <- googledrive::as_id(out[sel])
  }

  out
}

one_sheet <- function(needle, haystack, adjective) {
  check_string(needle)
  out <- many_sheets(needle = needle, haystack = haystack, adjective = adjective)
  if (length(out) > 1) {
    bullets <- glue_collapse(glue("  * {names(out)}"), last = "\n")
    stop_glue("
      Found multiple matching {adjective} Sheets:
      {bullets}
      Make the {bt('matches')} regular expression more specific.
      ")
  }
  new_sheets_id(out)
}

#' File IDs of example Sheets
#'
#' googlesheets4 ships with static IDs for some world-readable example Sheets
#' for use in examples and documentation. These functions make them easy to
#' access by their nicknames.
#'
#' @param matches A regular expression that matches the nickname of the desired
#'   example Sheet(s). This argument is optional for `gs4_examples()` and, if
#'   provided, multiple matches are allowed. `gs4_example()` requires
#'   this argument and requires that there is exactly one match.
#'
#' @return
#' * `gs4_example()`: a single [sheets_id] object
#' * `gs4_examples()`: a named vector of all built-in examples, with class
#'   [`drive_id`][googledrive::as_id]
#'
#' @export
#' @examples
#' gs4_examples()
#' gs4_examples("gap")
#' gs4_example("gapminder")
gs4_example <- function(matches) {
  one_sheet(
    needle    = matches,
    haystack  = .gs4_examples,
    adjective = "example"
  )
}

#' @rdname gs4_example
#' @export
gs4_examples <- function(matches) {
  many_sheets(
    needle    = matches,
    haystack  = .gs4_examples,
    adjective = "example"
  )
}
