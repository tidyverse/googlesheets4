# Changelog

## googlesheets4 (development version)

## googlesheets4 1.1.2

CRAN release: 2025-09-03

- No significant user-facing changes. Release motivated by documentation
  updates to support HTML reference manuals on CRAN.

## googlesheets4 1.1.1

CRAN release: 2023-06-11

- `gs4_auth(subject =)` is a new argument that can be used with
  `gs4_auth(path =)`, i.e. when using a service account. The `path` and
  `subject` arguments are ultimately processed by
  [`gargle::credentials_service_account()`](https://gargle.r-lib.org/reference/credentials_service_account.html)
  and support the use of a service account to impersonate a normal user.

- [`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)
  is a new function to access scopes relevant to the Sheets and Drive
  APIs. When called without arguments,
  [`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)
  returns a named vector of scopes, where the names are the associated
  short aliases.
  [`gs4_scopes()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_scopes.md)
  can also be called with a character vector; any element that’s
  recognized as a short alias is replaced with the associated full scope
  ([\#291](https://github.com/tidyverse/googlesheets4/issues/291)).

- Various internal changes to sync up with gargle v1.5.0.

## googlesheets4 1.1.0

CRAN release: 2023-03-23

### Syncing up with gargle

Version 1.3.0 of gargle introduced some changes around OAuth and
googlesheets4 is syncing with up that:

- [`gs4_oauth_client()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  is a new function to replace the now-deprecated
  [`gs4_oauth_app()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_oauth_app.md).
- The new `client` argument of
  [`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  replaces the now-deprecated `app` argument.
- The documentation of
  [`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md)
  emphasizes that the preferred way to “bring your own OAuth client” is
  by providing the JSON downloaded from Google Developers Console.

### Other

[`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md)
now warns if the user specifies both `email` and `path`, because this is
almost always an error.

## googlesheets4 1.0.1

CRAN release: 2022-08-13

The mere existence of an invalid named range no longer prevents
googlesheets4 from dealing with a Sheet
([\#175](https://github.com/tidyverse/googlesheets4/issues/175)).

googlesheets4 now understands that Google Sheets can have 10 million
cells (up from 5 million)
([\#257](https://github.com/tidyverse/googlesheets4/issues/257)).

### Internal matters

Help files below `man/` have been re-generated, so that they give rise
to valid HTML5. (This is the impetus for this release, to keep the
package safely on CRAN.)

Examples now use `@examplesIf` to express when a token or an interactive
session is required for successful execution.

Errors have been revised to (more often) reveal the most appropriate
call, i.e. the high-level function called by the user as opposed to an
internal helper
([\#255](https://github.com/tidyverse/googlesheets4/issues/255)).

Informative messages now route through
[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html),
instead of
[`cli::cli_bullets()`](https://cli.r-lib.org/reference/cli_bullets.html).

## googlesheets4 1.0.0

CRAN release: 2021-07-21

### User interface

The user interface has gotten more stylish, thanks to the cli package
(<https://cli.r-lib.org>).

All informational messages, warnings, and errors are now emitted via
cli, which uses rlang’s condition functions under-the-hood.
googlesheets4 now throws errors with class `"googlesheets4_error"`
([\#12](https://github.com/tidyverse/googlesheets4/issues/12)).

`googlesheets4_quiet` is a new option to suppress informational messages
from googlesheets4
([\#163](https://github.com/tidyverse/googlesheets4/issues/163)). Unless
it’s explicitly set to `TRUE`, the default is to message.

[`local_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
and
[`with_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
are [withr-style](https://withr.r-lib.org) convenience helpers for
setting `googlesheets4_quiet = TRUE`.

### Other changes

The deprecated `sheets_*()` functions have now been removed, as promised
in the warning they have been throwing for over a year. No functionality
has been removed, this is just the result of the function (re-)naming
scheme adopted in googlesheets4 \>= 0.2.0. More details are in [this
developer
documentation](https://googlesheets4.tidyverse.org/articles/articles/function-class-names.html#previous-use-of-sheets-prefix).

The `na` argument of
[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
has become more capable and more consistent with readr. Specifically,
`na = character()` (or the general lack of `""` among the `na` strings)
results in cells with no data appearing as the empty string `""` within
a character vector, as opposed to `NA`
([\#174](https://github.com/tidyverse/googlesheets4/issues/174)).

Explicit `NULL`s are now written properly, i.e. as an empty cell
([\#203](https://github.com/tidyverse/googlesheets4/issues/203)).

[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
no longer touches any aspect of cell formatting other than
`numberFormat`
([\#204](https://github.com/tidyverse/googlesheets4/issues/204)).

[`gs4_example()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
and
[`gs4_examples()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md)
now learn the example Sheet ids from a Google Sheet. This should not
change anything for users, but it means there is an API call the first
time either of these functions is called.

### Dependency changes

- cli is new in Imports.

- googlesheets4 Suggests testthat \>= 3.0.0 and, specifically, uses
  third edition features.

R 3.4 is now the oldest version that is explicitly supported and tested,
as per the [tidyverse
policy](https://www.tidyverse.org/blog/2019/04/r-version-support/).

## googlesheets4 0.3.0

CRAN release: 2021-03-04

All requests are now made with retry capability. Specifically, when a
request fails due to a `429 RESOURCE_EXHAUSTED` error, it is retried a
few times, with suitable delays. Note that if it appears that you
*personally* have exhausted your quota (more than 100 requests in 100
seconds), the initial waiting time is 100 seconds and this indicates you
need to get your own OAuth app or service account.

When googlesheets4 and googledrive are used together in the same
session, we alert you if you’re logged in to these package with
different Google identities.

[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
retrieves information about protected ranges.

## googlesheets4 0.2.0

CRAN release: 2020-05-08

googlesheets4 can now write and modify Sheets.

Several new articles are available at
[googlesheets4.tidyverse.org](https://googlesheets4.tidyverse.org/articles/index.html).

### Function naming scheme

The universal `sheets_` prefix has been replaced by a scheme that
conveys more information about the scope of the function. There are
three prefixes:

- `gs4_`: refers variously to the googlesheets4 package, v4 of the
  Google Sheets API, or to operations on one or more (spread)Sheets
- `sheet_`: operations on one or more (work)sheets
- `range_`: operations on a range of cells

The addition of write/edit functionality resulted in many new functions
and the original naming scheme proved to be problematic. The article
[Function and class
names](https://googlesheets4.tidyverse.org/articles/articles/function-class-names.html)
contains more detail.

Any function present in the previous CRAN release, v0.1.1, still works,
but triggers a warning with strong encouragement to switch to the
current name.

### Write Sheets

googlesheets4 now has very broad capabilities around Sheet creation and
modification. These functions are ready for general use but are still
marked experimental, as they may see some refinement based on user
feedback.

- [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md)
  creates a new Google Sheet and, optionally, writes one or more data
  frames into it
  ([\#61](https://github.com/tidyverse/googlesheets4/issues/61)).
- [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  (also available as
  [`write_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md))
  writes a data frame into a new or existing (work)sheet, inside an
  existing (or new) (spread)Sheet.
- [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  adds rows to an existing data table.
- [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md)
  writes to a cell range.
- [`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  “floods” all cells in a range with the same content.
  [`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  is a wrapper around
  [`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md)
  for the special case of clearing cell values.
- [`range_delete()`](https://googlesheets4.tidyverse.org/dev/reference/range_delete.md)
  deletes a range of cells.

### (Work)sheet operations

The `sheet_*()` family of functions operate on the (work)sheets inside
an existing (spread)Sheet:

- ([`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)
  and
  [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md)
  are described above.)
- [`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
  returns a tibble of metadata with one row per sheet.
- [`sheet_names()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md)
  returns sheet names.
- [`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md)
  adds one or more sheets.
- [`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md)
  copies a sheet.
- [`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md)
  deletes one or more sheets.
- [`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md)
  moves sheets around.  
- [`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md)
  renames one sheet.
- [`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md)
  changes the number of rows or columns in a sheet.

### Range operations

[`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)
reads from a Sheet using its “export=csv” URL and, therefore, uses
readr-style column type specification. It still supports fairly general
range syntax and auth. For very large Sheets, this can be substantially
faster than
[`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md).

[`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md)
(formerly known as `sheets_cells()`) gains two new arguments that make
it possible to get more data on more cells. By default, we get only the
fields needed to parse cells that contain values. But
`range_read_cells(cell_data = "full", discard_empty = FALSE)` is now
available if you want full cell data, including formatting, even for
cells that have no value
([\#4](https://github.com/tidyverse/googlesheets4/issues/4)).

[`range_autofit()`](https://googlesheets4.tidyverse.org/dev/reference/range_autofit.md)
adjusts column width or row height to fit the data. This only affects
the display of a sheet and does not change values or dimensions.

### Printing a Sheet ID

The print method for `sheets_id` objects now attempts to reveal the
current Sheet metadata available via
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md),
i.e. it makes an API call (but it should never error).

### Other changes and additions

`gs_formula()` implements a vctrs S3 class for storing Sheets formulas.

[`gs4_fodder()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_fodder.md)
is a convenience function that creates a filler data frame you can use
to make toy sheets you’re using to practice on or for a reprex.

### Renamed classes

The S3 class `sheets_Spreadsheet` is renamed to
`googlesheets4_spreadsheet`, a consequence of rationalizing all internal
and external classes (detailed in the article [Function and class
names](https://googlesheets4.tidyverse.org/articles/articles/function-class-names.html)).
`googlesheets4_spreadsheet` is the class that holds metadata for a Sheet
and it is connected to the API’s
[`Spreadsheet`](https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets#resource:-spreadsheet)
schema. The return value of
[`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md)
has this class.

### Bug fixes

- [`read_sheet()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md)
  passes its `na` argument down to the helpers that parse cells, so that
  `na` actually has the documented effect
  ([\#73](https://github.com/tidyverse/googlesheets4/issues/73)).

## googlesheets4 0.1.1

CRAN release: 2020-03-21

- Patch release to modify a test fixture, to be compatible with tibble
  v3.0. Related to tibble’s increased type strictness.

## googlesheets4 0.1.0

CRAN release: 2019-11-04

- Added a `NEWS.md` file to track changes to the package.
