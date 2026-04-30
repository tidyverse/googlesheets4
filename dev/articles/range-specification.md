# Range specification

This is article serves mostly as internal documentation of how various
representations of cell ranges relate to each other in googlesheets4.

``` r

library(tidyverse)
library(googlesheets4)

gs4_deauth()
```

## User-specified range

Several googlesheets4 functions allow the user to specify which cells to
read or write. This range specification comes via the `sheet`, `range`,
and (possibly) `skip` arguments. Examples of functions with this
interface:
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md),
[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md),
and
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md).

- `range` is the primary and most powerful argument and takes precedence
  over all others. `range` can be:
  - an [A1-style spreadsheet
    range](https://developers.google.com/sheets/api/guides/concepts#a1_notation),
    with or without a sheet name, such as “A3:D7” or “arts!A5:F15”
  - a (work)sheet name, such as “arts”
  - a named range, such as “arts_data”
  - a `cell_limits` object made with helpers from the cellranger package
- `sheet` can be used to specify a (work)sheet by name, such as “arts”,
  or by position, such as 3
- `skip` is an optional argument that appears in
  [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  and
  [`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md),
  to be compatible with functions like
  [`read.table()`](https://rdrr.io/r/utils/read.table.html),
  [`readr::read_delim()`](https://readr.tidyverse.org/reference/read_delim.html),
  and
  [`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html).

(You might think `n_max` should also be mentioned here, but for
technical reasons, in general, `n_max` can only be enforced after we’ve
read data. So it’s not part of the range ingest problem.)

Loose ends and hangnails:

- The story around (work)sheet visibility is muddy. But I’m letting that
  be, because I have yet to have a user interaction that had anything to
  do with sheet (in)visibility.
- The problem of a completely unspecified range. In a very hand-wavy
  sense, “no range” means “all cells” or “all non-empty cells” or “all
  non-empty cells in the first (visible?) sheet”. That is obviously very
  imprecise, which means that I have to think about how to handle “no
  range” for each individual endpoint or function. Sometimes I inject
  some info (such as the first visible worksheet), so we don’t retrieve
  data that we will just throw away. This is all very special case-y
  right now.
- `cell_limits` objects can hold sheet information and I have made no
  arrangements for that.
- Should
  [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
  have a skip argument, just for internal consistency?

## Range spec

`range_spec` is an internal S3 class that is typically used inside any
function that accepts the `(sheet, range, skip)` trio.

We need some sort of intermediate storage, in order to translate between
the various ways the user can express their range and the requirements
of different Sheets API endpoints (which differ more than you’d
expect!). We generally require metadata about the associated Sheet in
order to form a `range_spec`, because we potentially need to lookup the
(work)`sheet` by position or determine whether a name refers to a named
range or a (work)`sheet`.

The internal generic `as_range_spec()` dispatches on primary argument
`x`, which maps to `range`. Its job is to transform user-supplied
`(sheet, range, skip)` into:

- `sheet_name`: (Work)sheet name, can be `NULL`.
- `named_range`: Name of range, can be `NULL`. But if not `NULL`, then
  this is the complete specification of the range, i.e. it cannot be
  combined with any other information.
- `cell_range` and/or `cell_limits`: Ways to specify a rectangle of
  cells, can be `NULL`. If user specifies `skip`, that is re-expressed
  as `cell_limits`. At intake, at most one of `cell_range` and
  `cell_limits` is populated. But internally, we might populate one from
  the other, as we prepare the range to meet the requirements of a
  specific API endpoint.
- `shim`: indicates whether the user specified a specific cell rectangle
  (`shim = TRUE`) or we filled in some specifics pragmatically
  (`shim = FALSE`), which is necessary to express some partially open
  rectangles in A1-notation. This aspect of the user-supplied data needs
  to be retained to inform downstream post-processing.
- (`sheets_df` and `nr_df` are retained in a `range_spec`, if they were
  provided to `as_range_spec()`.)
- Loose end: I wonder if `range_spec` should have a field for
  (work)sheet id.

Here’s how various user-specified ranges are stored as a `range_spec`.

[TABLE]

### Cell rectangles

When a `range_spec` is first formed, it may hold specifics for a cell
rectangle, although it does not have to. This info appears in one of
these fields:

- `cell_range`: an [A1-style spreadsheet
  range](https://developers.google.com/sheets/api/guides/concepts#a1_notation),
  with NO sheet information
  - Examples: “A4”, “D:G”, “3:7”, “B3:H”, “C4:G16”
- a `cell_limits` object, in the cellranger sense
  - Example: `cell_limits(ul = c(2, 3), lr = c(NA, 5)))`

A `cell_limits` object is, overall, a much more sane way to hold this
information, because explicit `NA`s can be used to convey unboundedness.
Some types of unboundedness simply can’t be conveyed in A1 notation,
even though those partially open rectangles are as legitimate as those
that can be recorded in A1 notation.

In any case, between user expectations and API idiosyncrasies, we have
to be able to translate between `cell_range` and `cell_limits`.

#### A1 range from `cell_limits`

The reading functions
[`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
and
[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md)
hit the `sheets.spreadsheets.get` endpoint. Bizarrely, this endpoint
requires the range to be specified in A1-notation. If the user specifies
the cell rectangle in A1-notation, things are easy and we essentially
just pass that along. But users can describe certain partially open cell
rectangles via `cell_limits` that can’t be literally expressed in
A1-notation. The table below shows how all possible combinations of row
and cell limits are translated into an A1-style range, using technical
limits on the number of rows and columns in a Google Sheet.

| start_col | start_row | end_col | end_row | naive_range | range      |
|----------:|----------:|--------:|--------:|:------------|:-----------|
|         2 |         2 |       4 |       4 | B2:D4       | B2:D4      |
|         2 |         2 |       4 |      NA | B2:D?       | B2:D       |
|         2 |         2 |      NA |       4 | B2:?4       | B2:4       |
|         2 |         2 |      NA |      NA | B2:??       | B2:ZZZ     |
|         2 |        NA |       4 |       4 | B?:D4       | B1:D4      |
|         2 |        NA |       4 |      NA | B?:D?       | B:D        |
|         2 |        NA |      NA |       4 | B?:?4       | B1:4       |
|         2 |        NA |      NA |      NA | B?:??       | B:ZZZ      |
|        NA |         2 |       4 |       4 | ?2:D4       | A2:D4      |
|        NA |         2 |       4 |      NA | ?2:D?       | A2:D       |
|        NA |         2 |      NA |       4 | ?2:?4       | 2:4        |
|        NA |         2 |      NA |      NA | ?2:??       | 2:10000000 |
|        NA |        NA |       4 |       4 | ??:D4       | A1:D4      |
|        NA |        NA |       4 |      NA | ??:D?       | A:D        |
|        NA |        NA |      NA |       4 | ??:?4       | 1:4        |
|        NA |        NA |      NA |      NA | ??:??       | \<NULL\>   |

#### `cell_limits` from A1 range

When editing a sheet, we send an
[`UpdateCellsRequest`](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#updatecellsrequest),
which takes the location of the write via a *union field*. We must send
one of the following:

- `start`: An instance of `GridCoordinate` which identifies one cell.
  This is where the write starts and the cells hit are determined by the
  structure of the accompanying `RowData`. Think of `start` as
  specifying the upper left corner of a target rectangle. Fields:

  - `sheetId`: ID of the (work)sheet. The only required field.
  - `rowIndex`: Zero-based row index. Unspecified means 0.
  - `columnIndex`: Zero-based column index. Unspecified means 0.

- `range`: An instance of `GridRange` which identifies a rectangle of
  cells. Fields:

  - `sheetId`: ID of the (work)sheet. The only required field.
  - `startRowIndex`: Zero-based inclusive start row. Unspecified means
    0.
  - `endRowIndex`: Zero-based exclusive end row. Unspecified means
    unbounded.
  - `startColumnIndex`: Zero-based inclusive start column. Unspecified
    means
    0.  
  - `endColumnIndex`: Zero-based exclusive end column. Unspecified means
    unbounded.

  All the start/end row/column indices are optional. If omitted, it
  means the rectangle is unbounded on that side. Unbounded on the left
  or top is boring, because that just amounts to starting at the first
  row or column. But unbounded on the right or bottom is a more
  interesting scenario because of this:

  If the `RowData` doesn’t cover the entire `range` rectangle, the
  targetted cells that don’t receive new data are cleared, according to
  the accompanying field mask in `fields`.

[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
is the only writing function in googlesheets4 that lets the user target
a specific range. This function is why we need the ability to convert
A1-notation to `cell_limits` and to decide whether user’s range should
be sent via `start` or `range`.
[`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md),
and
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
all offer a higher-level API, focused on the holistic management of
(work)sheets that hold a single data table.

Here’s a table that translates the A1-style ranges created above into
`cell_limits`. Some scenarios are covered more than once in this input,
because above we were tackling a different (harder) problem. But that’s
harmless and these inputs are good, in terms of covering all relevant
scenarios. Note I dropped the row corresponding to “no input”.

| range      | cell_limits                            |
|:-----------|:---------------------------------------|
| B2:D4      | \<cell_limits (2, 2) x (4, 4)\>        |
| B2:D       | \<cell_limits (2, 2) x (-, 4)\>        |
| B2:4       | \<cell_limits (2, 2) x (4, -)\>        |
| B2:ZZZ     | \<cell_limits (2, 2) x (-, 18278)\>    |
| B1:D4      | \<cell_limits (1, 2) x (4, 4)\>        |
| B:D        | \<cell_limits (-, 2) x (-, 4)\>        |
| B1:4       | \<cell_limits (1, 2) x (4, -)\>        |
| B:ZZZ      | \<cell_limits (-, 2) x (-, 18278)\>    |
| A2:D4      | \<cell_limits (2, 1) x (4, 4)\>        |
| A2:D       | \<cell_limits (2, 1) x (-, 4)\>        |
| 2:4        | \<cell_limits (2, -) x (4, -)\>        |
| 2:10000000 | \<cell_limits (2, -) x (10000000, -)\> |
| A1:D4      | \<cell_limits (1, 1) x (4, 4)\>        |
| A:D        | \<cell_limits (-, 1) x (-, 4)\>        |
| 1:4        | \<cell_limits (1, -) x (4, -)\>        |

How to decide whether to send user’s range via `start` or `range`?
Possible scenarios for `(sheet, range)` (remember: so far,
[`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
doesn’t offer `skip`):

- `sheet` not given: populate with first (visible) sheet.
- No `range`: Send sheet ID as `GridCoordinate` via `start`. We will
  overwrite data (and usually formats) in cells covered by the
  accompanying `data`. But we don’t touch the rest of the sheet. Why not
  send as `range`? That feels too aggressive because it clears the data
  (and usually formats) of any cells in the sheet that are not covered
  by the `data`. But if user wants that, there’s always
  [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md).
- `range` as A1 notation: Re-express it as `cell_limits`.
- `range` as `cell_limits` breaks down into a couple scenarios:
  - `cell_limits` contains at least 1 `NA`: send as `GridRange` via
    `range`. Analysis of the “all `NA`” edge case: we send just the
    sheet ID as a `GridRange`, so we will clear the targeted fields for
    the whole sheet. This seems OK here, because no one can do this by
    accident, i.e. you have to go out of your way to make an explicit
    `cell_limits` object containing only `NA`s. Why would you do this
    instead of
    [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)?
    Maybe you need to suppress the inclusion of `col_names` or you don’t
    like the table formatting applied by
    [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md).
  - `cell_limits` has no `NA`s: If rectangle includes more than 1 cell,
    send as `GridRange` via `range`. If rectangle is exactly 1 cell,
    send as `GridCoordinate` via `start`.
