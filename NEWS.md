# googlesheets4 (development version)

* The S3 class `sheets_Spreadsheet` is renamed to `googlesheets4_spreadsheet`, a consequence of rationalizing all internal and external classes. `googlesheets4_spreadsheet` is the class that holds metadata for a Sheet and it is connected to the API's [`Spreadsheet`](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#resource:-spreadsheet) schema. The return value of `sheets_get()` has this class.

* `sheets_write()` (also available as `write_sheet()`) is a new function to write a data frame into an existing (work)sheet, inside an existing (spread)Sheet.  *caution: function still under development*

* `sheets_create()` is a new function to create a new Sheet and, optionally, write one or more data frames into it (#61). *caution: function still under development*

# googlesheets4 0.1.0

* Added a `NEWS.md` file to track changes to the package.
