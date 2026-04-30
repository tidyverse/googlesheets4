# Function and class names

This article explains conventions in googlesheets4 around:

- Function names
- Classes

## Prefixes: gs4, sheet, range

Almost all functions in googlesheets4 have one of these prefixes:

- `gs4_`, referring variously to the googlesheets4 package, v4 of the
  Google Sheets API, or to operations on one or more (spread)Sheets
- `sheet_`, referring to an operation on one or more (work)sheets
- `range_`, referring to an operation on a range of cells

This table summarizes what the `gs4_`, `sheet_`, `range_` mean
conceptually and which arguments you can expect to see in the function
signature.

| prefix  | `ss` | `sheet` | `range` | scope            |
|---------|------|---------|---------|------------------|
| gs4\_   | yes  | no      | no      | a (spread)Sheet  |
| sheet\_ | yes  | yes     | no      | a (work)sheet    |
| range\_ | yes  | yes     | yes     | a range of cells |

Take this table with a grain of salt. There are a few violations of it
in function signatures, when justified, but it’s true in broad strokes.
And remember that `gs4_` is also used for general, package-level
functions.

## Previous use of `sheets_` prefix

When googlesheets4 first appeared on CRAN and up to v0.1.1 (released
2020-03-21), it had a nearly universal `sheets_` prefix. In version
0.2.0 (released 2020-05-08), googlesheets4 gained a tremendous amount of
writing and editing functionality. At that time, it became clear that
the `sheets_` scheme was an impediment to generating descriptive,
predictable function names. For example, you can delete a (spread)Sheet,
a (work)sheet, or a cell range. Which one of these functions will be
named `sheets_delete()`? How do we name the others? There is no good
answer to this, which is why we adopted the 3 prefix strategy.

Any function that existed in v0.1.1 was formally deprecated in v0.2.0
and was removed in v1.0.0. Below are tables documenting the name
changes, that also cover functions that only existed in dev versions,
but that may have seen use in the community. As time goes on, this
article becomes more of historical note.

The dev version of googlesheets4 was bumped from 0.1.1.9000 to
0.1.1.9100 when the `sheets_` naming scheme was abandoned. The last
commit under the old scheme was also tagged as “v0.1.1.9000”, which
means one can install from that specific state via
`devtools::install_github("tidyverse/googlesheets4@v0.1.1.9000")`.

### Auth and the Sheet API v4 surface

| \<= v0.1.1.9000 | \>= v0.1.1.9100 |
|:---|:---|
| `sheets_api_key()` (\*) | [`gs4_api_key()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md) |
| `sheets_auth()` (\*) | [`gs4_auth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth.md) |
| `sheets_auth_configure()` (\*) | [`gs4_auth_configure()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_auth_configure.md) |
| `sheets_deauth()` (\*) | [`gs4_deauth()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_deauth.md) |
| `sheets_endpoints()` (\*) | [`gs4_endpoints()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_endpoints.md) |
| `sheets_has_token()` (\*) | [`gs4_has_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_has_token.md) |
| `sheets_oauth_app()` (\*) | [`gs4_oauth_app()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_oauth_app.md) |
| `sheets_token()` (\*) | [`gs4_token()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_token.md) |
| `sheets_user()` (\*) | [`gs4_user()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_user.md) |

(\*) indicates functions in the CRAN versions \<= v0.1.1.

### (Spread)sheet scope

| \<= v0.1.1.9000 | \>= v0.1.1.9100 |
|:---|:---|
| `sheets_browse()` (\*) | [`gs4_browse()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_browse.md) |
| `sheets_create()` | [`gs4_create()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_create.md) |
| `sheets_find()` (\*) | [`gs4_find()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_find.md) |
| `sheets_fodder()` | [`gs4_fodder()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_fodder.md) |
| `sheets_formula()` | [`gs4_formula()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_formula.md) |
| `sheets_example()` (\*) | [`gs4_example()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md) |
| `sheets_examples()` (\*) | [`gs4_examples()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_examples.md) |
| `sheets_get()` (\*) | [`gs4_get()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_get.md) |
| `sheets_random()` | [`gs4_random()`](https://googlesheets4.tidyverse.org/dev/reference/gs4_random.md) |

(\*) indicates functions in the CRAN versions \<= v0.1.1.

### (Work)sheet scope

| \<= v0.1.1.9000 | \>= v0.1.1.9100 |
|:---|:---|
| `sheets_append()` | [`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md) |
| `sheets_sheet_add()` | [`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md) |
| `sheets_sheet_copy()` | [`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md) |
| `sheets_sheet_delete()` | [`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md) |
| `sheets_sheet_names()` | [`sheet_names()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md) |
| `sheets_sheet_properties()` | [`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md) |
| `sheets_sheet_relocate()` | [`sheet_relocate()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_relocate.md) |
| `sheets_sheet_rename()` | [`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md) |
| `sheets_sheet_resize()` | [`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md) |
| `sheets_sheets()` (\*) | [`sheet_names()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md) |
| `sheets_write()` | [`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md) |

(\*) indicates functions in the CRAN versions \<= v0.1.1.

### Range scope

| \<= v0.1.1.9000 | \>= v0.1.1.9100 |
|:---|:---|
| `sheets_auto_resize_dims()` | [`range_autofit()`](https://googlesheets4.tidyverse.org/dev/reference/range_autofit.md) |
| `sheets_cells()` (\*) | [`range_read_cells()`](https://googlesheets4.tidyverse.org/dev/reference/range_read_cells.md) |
| `sheets_clear()` | [`range_clear()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md) |
| `sheets_edit()` | [`range_write()`](https://googlesheets4.tidyverse.org/dev/reference/range_write.md) |
| `sheets_flood()` | [`range_flood()`](https://googlesheets4.tidyverse.org/dev/reference/range_flood.md) |
| `sheets_read()` (\*) | [`range_read()`](https://googlesheets4.tidyverse.org/dev/reference/range_read.md) |
| `sheets_speedread()` | [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md) |

(\*) indicates functions in the CRAN versions \<= v0.1.1.

Note: “range” can mean two things in the Sheets API:

- An A1-style range, given as a string. Examples: `A1:B3` (a cell
  range), `Africa` (a worksheet name), `Africa!A1:B3` (a sheet-qualified
  cell range), `arts_data` (a named range). Some API endpoints require
  this, believe it or not.
- A cell rectangle described by start/end row/column, packaged as an
  instance of a schema, such as `GridRange`. Most API endpoints use
  this.

Fun fact: The “cell rectangle” type of range is almost a sub-case of the
A1-style range, except there are rectangles open on one or more sides
that can be described via `GridRange` that cannot be expressed as an
A1-range string. The mostly-developer-facing article [Range
specification](https://googlesheets4.tidyverse.org/articles/articles/range-specification.html)
documents all this and how I approach it internally.

The `range_` prefix encompasses both types of ranges and each function
has to indicate what sorts of `range` it supports, which is determined
by the behaviour of the associated API endpoint.

## Classes

Any user facing class that is related to a schema should be named like
`googlesheets4_schema_name`, where the schema name is in
lower_snake_case.

The internal schema-derived classes should be like
`googlesheets4_schema_SchemaName` / `googlesheets4_schema` / `list`. Use
the `googlesheets4_schema` prefix and retain the API’s UpperCamelCase.
