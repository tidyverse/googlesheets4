# (Over)write new data into a Sheet

This is one of the main ways to write data with googlesheets4. This
function writes a data frame into a (work)sheet inside a (spread)Sheet.
The target sheet is styled as a table:

- Special formatting is applied to the header row, which holds column
  names.

- The first row (header row) is frozen.

- The sheet's dimensions are set to "shrink wrap" the `data`.

If no existing Sheet is specified via `ss`, this function delegates to
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
and the new Sheet's name is randomly generated. If that's undesirable,
call
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
directly to get more control.

If no `sheet` is specified or if `sheet` doesn't identify an existing
sheet, a new sheet is added to receive the `data`. If `sheet` specifies
an existing sheet, it is effectively overwritten! All pre-existing
values, formats, and dimensions are cleared and the targeted sheet gets
new values and dimensions from `data`.

This function goes by two names, because we want it to make sense in two
contexts:

- `write_sheet()` evokes other table-writing functions, like
  [`readr::write_csv()`](https://readr.tidyverse.org/reference/write_delim.html).
  The `sheet` here technically refers to an individual (work)sheet (but
  also sort of refers to the associated Google (spread)Sheet).

- `sheet_write()` is the right name according to the naming convention
  used throughout the googlesheets4 package.

`write_sheet()` and `sheet_write()` are equivalent and you can use
either one.

## Usage

``` r
sheet_write(data, ss = NULL, sheet = NULL)

write_sheet(data, ss = NULL, sheet = NULL)
```

## Arguments

- data:

  A data frame. If it has zero rows, we send one empty pseudo-row of
  data, so that we can apply the usual table styling. This empty row
  goes away (gets filled, actually) the first time you send more data
  with
  [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md).

- ss:

  Something that identifies a Google Sheet:

  - its file id as a string or
    [`drive_id`](https://googledrive.tidyverse.org/reference/drive_id.html)

  - a URL from which we can recover the id

  - a one-row
    [`dribble`](https://googledrive.tidyverse.org/reference/dribble.html),
    which is how googledrive represents Drive files

  - an instance of `googlesheets4_spreadsheet`, which is what
    [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
    returns

  Processed through
  [`as_sheets_id()`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md).

- sheet:

  Sheet to write into, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number.

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Other write functions:
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md),
[`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md),
[`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md),
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)

Other worksheet functions:
[`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md),
[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md),
[`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md),
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md)

## Examples

``` r
df <- data.frame(
  x = 1:3,
  y = letters[1:3]
)

# specify only a data frame, get a new Sheet, with a random name
ss <- write_sheet(df)
#> ✔ Creating new Sheet: heartsick-sealion.
read_sheet(ss)
#> ✔ Reading from heartsick-sealion.
#> ✔ Range df.
#> # A tibble: 3 × 2
#>       x y    
#>   <dbl> <chr>
#> 1     1 a    
#> 2     2 b    
#> 3     3 c    

# clean up
googledrive::drive_trash(ss)
#> File trashed:
#> • heartsick-sealion <id: 1QV-OMP50ZBWCwTE0F388H92HBDbw0VoAmhDU8tj6bnw>

# create a Sheet with some initial, placeholder data
ss <- gs4_create(
  "sheet-write-demo",
  sheets = list(alpha = data.frame(x = 1), omega = data.frame(x = 1))
)
#> ✔ Creating new Sheet: sheet-write-demo.

# write df into its own, new sheet
sheet_write(df, ss = ss)
#> ✔ Writing to sheet-write-demo.
#> ✔ Writing to sheet df.

# write mtcars into the sheet named "omega"
sheet_write(mtcars, ss = ss, sheet = "omega")
#> ✔ Writing to sheet-write-demo.
#> ✔ Writing to sheet omega.

# get an overview of the sheets
sheet_properties(ss)
#> # A tibble: 3 × 8
#>   name  index         id type  visible grid_rows grid_columns data  
#>   <chr> <int>      <int> <chr> <lgl>       <int>        <int> <list>
#> 1 alpha     0 2141134405 GRID  TRUE            2            1 <NULL>
#> 2 omega     1 1250658344 GRID  TRUE           33           11 <NULL>
#> 3 df        2 1771925797 GRID  TRUE            4            2 <NULL>

# view your magnificent creation in the browser
gs4_browse(ss)

# clean up
gs4_find("sheet-write-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheet-write-demo <id: 1Hx8b54UxvTkCI4xbj844dLZd7UNhELM0fDSGHKEUBUM>
```
