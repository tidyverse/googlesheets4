#' Convert character column specifications to groups of numeric indices.
#'
#' This differs from cellranger::letter_to_num in that it accounts for series of columns ie B:D and the output is a list.
#' @param indexes The character column specification ex. C:F
#' @return \code{(numeric)} A  numeric vector with the corresponding column index numbers. If a series of column numbers the starting and ending index are returned.
#' @examples
#' \donttest{
#' indexes <- c("a")
#' letter_to_num2(indexes)
#' indexes <- c("c:f", "R:S", "AB:AC")
#' letter_to_num2(indexes)
#' }

letter_to_num2 <- function(indexes) {
indexes <- toupper(indexes)
purrr::map(indexes, ~{
  # if its C:C format else if it's a single letter
  if (grepl("\\:", .x)) {
    .ind <- strsplit(.x, "\\:", perl = T)[[1]]
  } else {
    .ind <- .x
  }
    # translate letters to numeric indexes
  .ind_num <- purrr::map_dbl(.ind, cellranger::letter_to_num)
})
}

#' Convert non-consecutive indexes to consecutive groupings
#' @param indexes \code{(numeric)} The numeric vector to group
#' @return \code{(list)} A list of consecutive groupings of integer indexes
#' @examples
#' \donttest{
#' split_consecutive(c(1:2, 5:6))
#' }

split_consecutive <- function(indexes) {
  .gaps <- which(diff(sort(unique(indexes))) > 1)
  .seq <- list()
  .seq[[1]] <- 1:.gaps[1]

  for (i in seq_along(.gaps) + 1) {
    if (i == length(.gaps) + 1)
      .seq[[length(.gaps) + 1]] <- (.gaps[i - 1] + 1):length(indexes)
    else
      .seq[[i]] <- c((.gaps[i - 1] + 1):.gaps[i])
  }
  split(indexes, unlist(purrr::imap(.seq,~{rep(.y, length(.x))})))
}

#' Delete rows or columns of a sheet.
#'
#' @description
#' \lifecycle{experimental}
#'
#' Delete rows or columns of a specified sheet given a vector of row numbers, column names, or column numbers.
#'
#' @template ss
#' @param sheet \code{(character/numeric)} The name of the sheet (case-sensitive) or the index (where the first sheet is 1.)
#' @param dimension \code{(character)} The dimension to delete ROWS or COLUMNS. Can be shorthand: ex. 'r' or 'c'
#' @param indexes \code{(character/numeric)} The row numbers, column numbers or column names (in C:F format) to delete.
#' @return Returns the supplied spreadsheet object invisibly
#' @examples
#' \dontrun{
#' ss <- sheets_get("YOUR SPREADSHEET ID HERE")
#' example_data <- data.frame(matrix(rep(as.double(2:10), times = 10), nrow = 9))
#' example_data <- tibble::as_tibble(setNames(.example, LETTERS[1:10]))
#' sheet <- "YOUR SHEET NAME HERE"
#' write_sheet(example_data, ss, sheet)
#' delete_dimension(ss, sheet, "c", c("A", "D:E"))
#' delete_dimension(ss, sheet, "r", c(1, 3:5))
#' }
#' @importFrom magrittr "%>%"
#' @export

delete_dimension <- function(ss = NULL,
                             sheet = NULL,
                             dimension = c("ROWS", "COLUMNS"),
                             indexes = NULL) {
  # Validate ss:  Mon Jan 20 16:33:32 2020 ----

  if (!inherits(ss, "googlesheets4_spreadsheet")) {
    stop("Please supply googlesheets4_spreadsheet. See ?sheets_get")
  } else {
    .ssid <- as_sheets_id(ss)
    message_glue("Deleting from: \n Spreadsheet: {ss$name}")
  }

  #Validate sheet and prepare as parameter to request:  Mon Jan 20 16:54:02 2020 ----

  if (is.character(sheet)) {
    .sheet <- try(ss$sheets$id[grep(sheet, ss$sheets$name)])
  } else if (is.numeric(sheet)) {
    .sheet <- try({ss$sheets$id[sheet]})
  }

  if (class(.sheet) == "try-error" || is.null(.sheet) || length(.sheet) == 0) {
    stop("Please check the sheet parameter provided.")
  } else {
    message_glue("sheet: {ss$sheets$name[ss$sheets$id == .sheet]}")
  }

  # ensure correct parameter syntax:  Tue Jan 21 16:29:12 2020 ----
  # dimension
  if (grepl("^[Rr]", dimension)) {
    .dimension <- "ROWS"
  } else {
    .dimension <- "COLUMNS"
  }


  # indexes
  if (is.character(indexes)) {
    # convert column character indices to numeric indices
    .indexes <- letter_to_num2(indexes)
  } else if (is.numeric(indexes) && any(diff(sort(unique(indexes))) > 1)) {
    # if it's numeric and non-consecutive, split into groups of consecutive indices
    .indexes <- split_consecutive(indexes)
  } else {
    .indexes <- indexes
  }
  # deletion of non-consecutive groups is sequential, so input of indexes A:B and D:E translated to raw indexes would actually delete columns 1,2 and 6,7 from the user's perspective.
  # To account for this the value of the indexes must be reduced by the number of preceding columns deleted.
  if (length(.indexes) > 1) {
    if (is.character(indexes)) {
      # case when indexes supplied are characters

      .cs <- purrr::map(.indexes, ~{
        if (length(.x) > 1) {
          # if it's a series
          abs(Reduce(`-`, .x)) + 1
        } else {
          # if it's a single column
          1
        }
        }) %>%
        cumsum()

    } else {
      # case when indexes supplied are numeric
      .cs <- cumsum(purrr::map_int(.indexes, length))
    }
    .indexes <- purrr::imap(.indexes, .cs = .cs, function(.x, .y, .cs) {
      .y <- as.numeric(.y)
      if (.y == 1) {
        return(.x)
      } else {
        .x - .cs[.y - 1]
      }
    })
  }



  # create request(s) to delete dimensions ------------------------------
  # https://developers.google.com/sheets/api/samples/rowcolumn
  .requests <- purrr::map(.indexes, ~ {
    .startIndex <- .x[1] - 1
    .endIndex <- .x[length(.x)]
    requests = list(deleteDimension = list(
      range = list(
        sheetId = .sheet,
        dimension = .dimension,
        startIndex = .startIndex,
        endIndex = .endIndex)))
  })


  # do it ----------------------------------------------------------------------
  purrr::walk(.requests, ~{
    .req <- request_generate(
      "sheets.spreadsheets.batchUpdate",
      params = list(
        spreadsheetId = .ssid,
        requests = .x
      )
    )
    .resp_raw <- request_make(.req)
    .resp <- gargle::response_process(.resp_raw)
  })

  purrr::walk(indexes, ~ {message_glue("Deleting {.dimension} {.x}")})

  invisible(ss)
}

