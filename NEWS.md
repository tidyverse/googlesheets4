# googlesheets4 (development version)

### Function naming scheme

The universal `sheets_` prefix has been replaced by a scheme that conveys more information about the scope of the function, e.g., a whole spreadsheet vs. a whole worksheet vs. a cell range. We've added many functions since the initial CRAN release and it became clear the original scheme wasn't serving us well. There is a new article about conventions for function names and classes, [Function and class names](https://googlesheets4.tidyverse.org/articles/articles/function-class-names.html).

Any function present in the previous CRAN release, v0.1.1, still works, but triggers a warning with strong encouragement to call it via its current name.

### Write Sheets

These functions are ready for use but are still considered experimental and may see more refinements to their interface and capabilities:

  * `gs4_create()` is a new function to create a new Google Sheet and,
    optionally, write one or more data frames into it (#61).
  * `sheet_write()` (also available as `write_sheet()`) is a new function to
    write a data frame into a new or existing (work)sheet, inside a new or
    existing (spread)Sheet.
  * `sheet_append()` adds rows to the data in an existing sheet.
  * `range_write()` writes to a range.
  * `range_flood()` "floods" all cells in a range with the same content.
    `range_clear()` is a wrapper around `range_flood()` for the special case
     of clearing cell values.
  * `range_delete()` deletes a range of cells.
  
### Other new functions and arguments

The `sheet_*()` family of functions operate on the (work)sheets inside an existing (spread)Sheet:
  
  * `sheet_properties()` returns a tibble of metadata with one row per
     sheet.
  * `sheet_names()` returns sheet names.
  * `sheet_add()` adds one or more sheets.
  * `sheet_copy()` copies a sheet.
  * `sheet_delete()` deletes one or more sheets.
  * `sheet_relocate()` moves sheets around.  
  * `sheet_rename()` renames one sheet.
  * `sheet_resize()` changes the number of rows or columns in a sheet.
  
`range_speedread()` provides a quick-and-dirty method for reading a Sheet using its "export=csv" URL.

`range_read_cells()` (formerly known as `sheets_cells()`) gains two new arguments that make it possible to get more data on more cells. By default, we get only the fields needed to parse cells that contain values. But `range_read_cells(cell_data = "full", discard_empty = FALSE)` is now available if you want full cell data, including formatting, even for cells that have no value (#4).

`range_autofit()` causes column width or row height to fit the data. It only affects the display of a sheet and does not change values or dimensions.

`gs4_fodder()` is a convenience function that creates a filler data frame you can use to make toy sheets you're using to practice on or for a reprex.

### Renamed functions and classes

* The S3 class `sheets_Spreadsheet` is renamed to `googlesheets4_spreadsheet`, a consequence of rationalizing all internal and external classes. `googlesheets4_spreadsheet` is the class that holds metadata for a Sheet and it is connected to the API's [`Spreadsheet`](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#resource:-spreadsheet) schema. The return value of `gs4_get()` has this class.

### Printing a Sheet ID

The print method for `sheets_id` objects now attempts to reveal the current Sheet metadata available via `gs4_get()`. The means that printing can lead to an attempt to initiate auth, unless `gs4_deauth()` has been called. However, `sheets_id` printing should never lead to an actual error condition, although it may reveal information from caught errors.

### Bug fixes

* `read_sheet()` passes its `na` argument down to the helpers that parse cells, so that `na` actually has the documented effect (#73).

# googlesheets4 0.1.1

* Patch release to modify a test fixture, to be compatible with tibble v3.0.
  Related to tibble's increased type strictness.

# googlesheets4 0.1.0

* Added a `NEWS.md` file to track changes to the package.
