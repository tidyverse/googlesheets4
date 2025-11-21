# Relocate one or more (work)sheets

Move (work)sheets around within a (spread)Sheet. The outcome is most
predictable for these common and simple use cases:

- Reorder and move one or more sheets to the front.

- Move a single sheet to a specific (but arbitrary) location.

- Move multiple sheets to the back with `.after = 100` (`.after` can be
  any number greater than or equal to the number of sheets).

If your relocation task is more complicated and you are puzzled by the
result, break it into a sequence of simpler calls to `sheet_relocate()`.

## Usage

``` r
sheet_relocate(ss, sheet, .before = if (is.null(.after)) 1, .after = NULL)
```

## Arguments

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

  Sheet to relocate, in the sense of "worksheet" or "tab". You can
  identify a sheet by name, with a string, or by position, with a
  number. You can pass a vector to move multiple sheets at once or even
  a list, if you need to mix names and positions.

- .before, .after:

  Specification of where to locate the sheets(s) identified by `sheet`.
  Exactly one of `.before` and `.after` must be specified. Refer to an
  existing sheet by name (via a string) or by position (via a number).

## Value

The input `ss`, as an instance of
[`sheets_id`](https://googlesheets4.tidyverse.org/dev/reference/sheets_id.md)

## See also

Constructs a batch of `UpdateSheetPropertiesRequest`s (one per sheet):

- <https://developers.google.com/sheets/api/reference/rest/v4/spreadsheets/request#UpdateSheetPropertiesRequest>

Other worksheet functions:
[`sheet_add()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_add.md),
[`sheet_append()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_append.md),
[`sheet_copy()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_copy.md),
[`sheet_delete()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_delete.md),
[`sheet_properties()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_properties.md),
[`sheet_rename()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_rename.md),
[`sheet_resize()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_resize.md),
[`sheet_write()`](https://googlesheets4.tidyverse.org/dev/reference/sheet_write.md)

## Examples

``` r
sheet_names <- c("alfa", "bravo", "charlie", "delta", "echo", "foxtrot")
ss <- gs4_create("sheet-relocate-demo", sheets = sheet_names)
#> ✔ Creating new Sheet: sheet-relocate-demo.
sheet_names(ss)
#> [1] "alfa"    "bravo"   "charlie" "delta"   "echo"    "foxtrot"

# move one sheet, forwards then backwards
ss %>%
  sheet_relocate("echo", .before = "bravo") %>%
  sheet_names()
#> ✔ Relocating sheets in sheet-relocate-demo.
#> [1] "alfa"    "echo"    "bravo"   "charlie" "delta"   "foxtrot"
ss %>%
  sheet_relocate("echo", .after = "delta") %>%
  sheet_names()
#> ✔ Relocating sheets in sheet-relocate-demo.
#> [1] "alfa"    "bravo"   "charlie" "delta"   "echo"    "foxtrot"

# reorder and move multiple sheets to the front
ss %>%
  sheet_relocate(list("foxtrot", 4)) %>%
  sheet_names()
#> ✔ Relocating sheets in sheet-relocate-demo.
#> [1] "foxtrot" "delta"   "alfa"    "bravo"   "charlie" "echo"   

# put the sheets back in the original order
ss %>%
  sheet_relocate(sheet_names) %>%
  sheet_names()
#> ✔ Relocating sheets in sheet-relocate-demo.
#> [1] "alfa"    "bravo"   "charlie" "delta"   "echo"    "foxtrot"

# reorder and move multiple sheets to the back
ss %>%
  sheet_relocate(c("bravo", "alfa", "echo"), .after = 10) %>%
  sheet_names()
#> ✖ Request 1 failed [429: RESOURCE_EXHAUSTED, per user quota].
#> ℹ Will retry in 61.3s.
#> ⠙ Retry happens in  1m
#> ⠹ Retry happens in  1m
#> ⠸ Retry happens in  1m
#> ⠼ Retry happens in  1m
#> ⠴ Retry happens in 50s
#> ⠦ Retry happens in 47s
#> ⠧ Retry happens in 44s
#> ⠇ Retry happens in 41s
#> ⠏ Retry happens in 38s
#> ⠋ Retry happens in 35s
#> ⠙ Retry happens in 32s
#> ⠹ Retry happens in 29s
#> ⠸ Retry happens in 26s
#> ⠼ Retry happens in 23s
#> ⠴ Retry happens in 20s
#> ⠦ Retry happens in 17s
#> ⠧ Retry happens in 14s
#> ⠇ Retry happens in 11s
#> ⠏ Retry happens in  8s
#> ⠋ Retry happens in  5s
#> ⠙ Retry happens in  2s
#> ✖ Request 2 failed [429: RESOURCE_EXHAUSTED, per user quota].
#> ⠙ Retry happens in  2s
#> ℹ Will retry in 6s.
#> ⠙ Retry happens in  2s
#> ⠙ Retry happens in  0s
#> ⠙ Retry happens in  5s
#> ⠹ Retry happens in  2s
#> ✔ Request 3 successful!
#> ⠹ Retry happens in  2s
#> ⠹ Retry happens in  0s
#> ✔ Relocating sheets in sheet-relocate-demo.
#> [1] "charlie" "delta"   "foxtrot" "bravo"   "alfa"    "echo"   

# clean up
gs4_find("sheet-relocate-demo") %>%
  googledrive::drive_trash()
#> File trashed:
#> • sheet-relocate-demo
#>   <id: 1SjpXB1M-NMUr3OxVtGcFqBlrFx8coPgjKvPlC-7syNo>
```
