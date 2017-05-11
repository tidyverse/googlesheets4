## nothing here is exported
## where do gsheet objects come from?
## from the user-facing sheet registration functions in sheet_register.R:
## sheet_name(), sheet_title() (alias for sheet_name()),
##   sheet_id(), sheet_url(), sheet_sheet()
## in all cases, sheet-identifying info is parlayed into an id
## then as_gsheet() gets called to register the sheet
## and produce a gsheet object

gsheet <- function() {
  structure(
    list(
      ## make sense for any gfile
      id = character(),
      name = character(),  ## Drive-speak
      title = character(), ## Sheets-speak
      ## these were present in the old googlesheet object and will return
      ## not here yet because, with v4 API, would require a Drive API call
      ## gsheet needs to inherit from gfile anyway, so this is on hold
      # updated = character() %>% as.POSIXct(),
      # reg_date = character() %>% as.POSIXct(),
      # author = character(),
      # email = character(),
      # perm = character(),

      ## specific to gsheet
      n_ws = integer(),
      ws = list()
    ),
    class = c("gsheet", "gfile", "list")
  )
}

as_gsheet <- function(x, verbose = TRUE, ...) {
  UseMethod("as_gsheet")
}

## assumes x is the Drive file id
as_gsheet.character <- function(x, verbose = TRUE) {

  req <- gs_generate_request(
    "spreadsheets.get",
    params = list(spreadsheetId = x)
  )
  resp <- gs_make_request(req) %>%
    httr::stop_for_status()
  # req <- rGET(x, omit_token_if(TRUE)) %>% httr::stop_for_status()
  rc <- content_as_json_UTF8(resp)

  ss <- gsheet()

  ss$id <- x
  ss$name <- ss$title <- rc$properties$title

  ss$n_ws <- length(rc$sheets)
  ss$browser_url <- rc$spreadsheetUrl

  ss$ws <- rc$sheets %>%
    purrr::map("properties") %>% {
      tibble::tibble(
        sheetId = purrr::map_chr(., "sheetId"),
        title = purrr::map_chr(., "title"),
        index = purrr::map_chr(., "index"),
        sheetType = purrr::map_chr(., "sheetType"),
        rowCount = purrr::map_int(., c("gridProperties", "rowCount")),
        columnCount = purrr::map_int(., c("gridProperties", "columnCount"))
      )
    }
  ss

  ## all the other stuff I loaded in old googlesheets
  ## but have not reinstated yet
  ## will be reworked, since gsheet is going to inherit from gfile

  #  ss$updated <- req$headers$`last-modified` %>% httr::parse_http_date()
  #  ss$reg_date <- req$headers$date %>% httr::parse_http_date()
  #  ss$visibility <- req$url %>% dirname() %>% basename()
  #  ss$lookup <- lookup
  #  ss$is_public <- ss$visibility == "public"
  #  ss$author <- rc %>%
  #    xml2::xml_find_first("./feed:author/feed:name", ns) %>% xml2::xml_text()
  #  ss$email <- rc %>%
  #    xml2::xml_find_first("./feed:author/feed:email", ns) %>% xml2::xml_text()
  #  ss$perm <- ss$ws_feed %>%
  #    stringr::str_detect("values") %>%
  #    ifelse("r", "rw")
}
