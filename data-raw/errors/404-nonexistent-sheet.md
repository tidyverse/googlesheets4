404-nonexistent-sheet.R
================
jenny
Fri Mar 30 16:05:19 2018

``` r
devtools::load_all(".")
```

    ## Loading googlesheets4

``` r
req <- request_generate(
  "spreadsheets.get",
  ## ID of 'googlesheets4-design-exploration', but replaced last 2 chars w/ '-'
  list(spreadsheetId = "1xTUxWGcFLtDIHoYJ1WsjQuLmpUtBf--8Bcu5lQ302--"),
  token = NULL
)
raw_resp <- request_make(req)
response_process(raw_resp)
```

    ## Error: HTTP error 404
    ## * message: 'Requested entity was not found.'
    ## * status: 'NOT_FOUND'

``` r
ct <- httr::content(raw_resp)
str(ct)
```

    ## List of 1
    ##  $ error:List of 3
    ##   ..$ code   : int 404
    ##   ..$ message: chr "Requested entity was not found."
    ##   ..$ status : chr "NOT_FOUND"
