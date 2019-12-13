# googlesheets4 (development version)

* `sheets_cells()` gains two new arguments that make it possible to get more data on more cells. By default, we get only the fields needed to parse cells that contain values. But `sheets_cells(cell_data = "full", discard_empty = FALSE)` is now available if you want full cell data, including formatting, even for cells that have no value (#4).

* The S3 class `sheets_Spreadsheet` is renamed to `googlesheets4_spreadsheet`, a consequence of rationalizing all internal and external classes. `googlesheets4_spreadsheet` is the class that holds metadata for a Sheet and it is connected to the API's [`Spreadsheet`](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#resource:-spreadsheet) schema. The return value of `sheets_get()` has this class.

* `sheets_write()` (also available as `write_sheet()`) is a new function to write a data frame into an existing (work)sheet, inside an existing (spread)Sheet.  *caution: function still under development*

* `sheets_create()` is a new function to create a new Sheet and, optionally, write one or more data frames into it (#61). *caution: function still under development*

### Bug fixes

* `read_sheet()` passes its `na` argument down to the helpers that parse cells, so that `na` actually has the documented effect (#73).

# googlesheets4 0.1.0

* Added a `NEWS.md` file to track changes to the package.
