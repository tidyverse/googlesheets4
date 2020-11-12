range_format_fill_gradient <- function(
  ss,
  range,
  min_type = "MIN",
  min_color = "#57bb8a",
  max_type = "MAX",
  max_color = "white",
  min_value = NULL,
  max_value = NULL,
  mid_type = NULL,
  mid_value = NULL,
  mid_color = "white"
) {
  allowed_types <- c("MIN", "MAX", "NUMBER", "PERCENT", "PERCENTILE")
  min_type <- toupper(min_type)
  min_type <- rlang::arg_match(min_type, allowed_types)
  assertthat::assert_that(min_type != "MAX")
  max_type <- toupper(max_type)
  assertthat::assert_that(max_type != "MIN")
  max_type <- rlang::arg_match(max_type, allowed_types)
  if (!is.null(mid_type)) {
    mid_type <- toupper(mid_type)
    mid_type <- rlang::arg_match(mid_type, allowed_types)
    assertthat::assert_that(!mid_type %in% c("MIN", "MAX"))
  }

  ssid <- as_sheets_id(ss)
  maybe_sheet(sheet)
  check_range(range)

  x <- gs4_get(ssid)

  # determine targeted sheet ---------------------------------------------------
  range_spec <- as_range_spec(
    range,
    sheet = sheet,
    sheets_df = x$sheets, nr_df = x$named_ranges
  )
  range_spec$sheet_name <- range_spec$sheet_name %||% first_visible_name(x$sheets)
  s <- lookup_sheet(range_spec$sheet_name, sheets_df = x$sheets)

  # form request ---------------------------------------------------------------
  range_req <- as_GridRange(range_spec)

  min_color <- color_as_gsheet_rgb(min_color)
  mid_color <- color_as_gsheet_rgb(mid_color)
  max_color <- color_as_gsheet_rgb(max_color)

  gradient_req <- list(
    minpoint = list(
      color = list(
        red = min_color$red,
        green = min_color$green,
        blue = min_color$blue
      ),
      type = min_type,
      value = as.character(min_value)
    ),
    maxpoint = list(
      color = list(
        red = max_color$red,
        green = max_color$green,
        blue = max_color$blue
      ),
      type = max_type,
      value = as.character(max_value)
    )
  )

  if (!is.null(mid_type)) {
    midpoint = list(
      color = list(
        red = mid_color$red,
        green = mid_color$green,
        blue = mid_color$blue
      ),
      type = mid_type,
      value = as.character(mid_value)
    )

    gradient_req <- append(gradient_req, list(midpoint = midpoint))
  }

  # remove null / empty
  for (i in seq_along(gradient_req)) {
    gradient_req[[i]] <- Filter(function(x) length(x) > 0, gradient_req[[i]])
    for (j in seq_along(gradient_req[[i]])) {
      gradient_req[[i]][[j]] <- Filter(function(x) length(x) > 0,
                                       gradient_req[[i]][[j]])
    }
  }

  # do it ----------------------------------------------------------------------
  req <- request_generate(
    "sheets.spreadsheets.batchUpdate",
    params = list(
      spreadsheetId = ssid,
      requests = list(
        addConditionalFormatRule = list(
          rule = list(
            ranges = range_req,
            gradientRule = gradient_req
          ),
          index = 0 # this sets formatting priority, hard code for now
        )
      )
    )
  )
  resp_raw <- request_make(req)
  gargle::response_process(resp_raw)

  invisible(ssid)
}

#' @param color Character. An R color (eg "red") or 6 digit hex color code
color_as_gsheet_rgb <- function(color) {
  if (is.null(color)) return(NULL)
  grDevices::col2rgb(color)[ ,1] %>%
    magrittr::divide_by(256) %>% # scale 0 -> 1 instead of 0 -> 256
    as.list() # return as named list
}
