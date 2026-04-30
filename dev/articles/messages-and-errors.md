# Messages and errors in googlesheets4

``` r

library(googlesheets4)
```

*In a hidden chunk here, I “export” the internal helpers covered below.*

## User-facing messages

Everything should be emitted by helpers in `utils-ui.R`: specifically,
`gs4_bullets()` and, for errors, `gs4_abort()`. These helpers are
wrappers around
[`cli::cli_inform()`](https://cli.r-lib.org/reference/cli_abort.html)
and
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html),
respectively.

``` r

gs4_bullets(c(
        "noindent",
  " " = "indent",
  "*" = "bullet",
  ">" = "arrow",
  "v" = "Doing good stuff for YOU the user",
  "x" = "Nope nope nope",
  "!" = "You might want to know about this",
  "i" = "The more you know!"
))
#> noindent
#>   indent
#> • bullet
#> → arrow
#> ✔ Doing good stuff for YOU the user
#> ✖ Nope nope nope
#> ! You might want to know about this
#> ℹ The more you know!
```

The helpers encourage consistent styling and make it possible to
selectively silence messages coming from googlesheets4. The
googlesheets4 message helpers:

- Use the [cli package](https://cli.r-lib.org/index.html) to get
  interpolation, inline markup, and pluralization.
- Use googlesheets4’s custom theme, which has styles for Sheet name,
  worksheet name, and range.
- Eventually route through
  [`rlang::inform()`](https://rlang.r-lib.org/reference/abort.html),
  which is important because `inform()` prints to standard output in
  interactive sessions. This means that informational messages won’t
  have the same “look” as errors and can generally be more stylish, at
  least in IDEs like RStudio.
- Are under the control of the `"googlesheets4_quiet"` option. If it’s
  unset, the default is to show messages (unless we’re testing, i.e. the
  environment variable `TESTTHAT` is `"true"`).
  `googlesheets4_quiet = TRUE` will suppress messages. There are
  withr-style convenience helpers:
  [`local_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md)
  and
  [`with_gs4_quiet()`](https://googlesheets4.tidyverse.org/dev/reference/googlesheets4-configuration.md).

### Inline styling

How we use the inline classes:

- `.s_sheet` for the name of Google Sheet (custom)
- `.w_sheet` for the name of a worksheet (custom)
- `.range` for an A1-style range or named range (custom)
- `.code` for a column in a data frame and for reserved words, such as
  `NULL`, `TRUE`, and `NA`
- `.arg`, `.fun`, `.path`, `.cls`, `.url`. `.email` for their usual
  purpose

*These may not demo well via pkgdown, but the interactive experience is
nice.*

``` r

nm <- "name-of-a-Google-Sheet"
gs4_bullets(c(v = "Creating new Sheet: {.s_sheet {nm}}"))
#> ✔ Creating new Sheet: name-of-a-Google-Sheet

nm <- "name-of-a-worksheet"
gs4_bullets(c(v = "Protecting cells on sheet: {.w_sheet {nm}}"))
#> ✔ Protecting cells on sheet: name-of-a-worksheet

rg <- "A3:B20"
gs4_bullets(c(v = "Writing to the range: {.range {rg}}"))
#> ✔ Writing to the range: A3:B20
```

Above, I don’t include a period (`.`) at the end of a message with the
form: `Description of thing: THING`. I view it as a special case of a
bullet list of simple items, which also don’t get periods.
(`bulletize()` comes from gargle.)

``` r

gs4_bullets(c(
  "We're going to list some things:",
  bulletize(gargle::gargle_map_cli(month.abb[1:4]))
))
#> We're going to list some things:
#> • Jan
#> • Feb
#> • Mar
#> • Apr
```

Other messages that are complete sentence, or at least aspire to be,
**do** get a period.

``` r

gs4_bullets("Doing the stuff you asked me to do.")
#> Doing the stuff you asked me to do.

gs4_bullets(c(
  "You probably need to do one of these things:",
  "*" = "Call {.fun some_function}.",
  "*" = "Provide more specific input via {.arg some_argument}."
))
#> You probably need to do one of these things:
#> • Call `some_function()`.
#> • Provide more specific input via `some_argument`.
```

Most relevant cli docs:

- [CLI inline
  markup](https://cli.r-lib.org/reference/inline-markup.html)
- [Building a Semantic
  CLI](https://cli.r-lib.org/articles/semantic-cli.html)

### Pluralization

[cli’s pluralization](https://cli.r-lib.org/articles/pluralization.html)
is awesome!

``` r

nm <- "name-of-a-Google-Sheet"
n_new <- 1
gs4_bullets(c(v = "Adding {n_new} sheet{?s} to {.s_sheet {nm}}"))
#> ✔ Adding 1 sheet to name-of-a-Google-Sheet

n_new <- 3
gs4_bullets(c(v = "Adding {n_new} sheet{?s} to {.s_sheet {nm}}"))
#> ✔ Adding 3 sheets to name-of-a-Google-Sheet
```

### Collapsing

[Collapsing lists of
things](https://cli.r-lib.org/articles/semantic-cli.html#inline-lists-of-items)
is great! Also more pluralization.

``` r

new_sheet_names <- c("apple", "banana", "cherry")
gs4_bullets(c("New sheet{?s}: {.w_sheet {new_sheet_names}}"))
#> New sheets: apple, banana, and cherry

new_sheet_names <- "kumquat"
gs4_bullets(c("New sheet{?s}: {.w_sheet {new_sheet_names}}"))
#> New sheet: kumquat
```

### Tricky stuff

If you want to see some tricky examples of building up a message from
parts, look here:

- [`range_speedread()`](https://googlesheets4.tidyverse.org/dev/reference/range_speedread.md)

## Errors

Use `gs4_abort()` instead of
[`rlang::abort()`](https://rlang.r-lib.org/reference/abort.html) or
[`stop()`](https://rdrr.io/r/base/stop.html). So far, I’m not really
using `...` to put data in the condition, but I could start when/if
there’s a reason to.

`abort_unsupported_conversion()` is a wrapper around `gs4_abort()`.

``` r

x <- structure(1, class = c("a", "b", "c"))
abort_unsupported_conversion(x, to = "SheetThing")
#> Error in `abort_unsupported_conversion()`:
#> ! Don't know how to make an instance of <SheetThing> from
#>   something of class <a/b/c>.
```

`abort_unsupported_conversion()` exists to standardize a recurring type
of error message, usually encountered during development, not by
end-users. I use it a lot in the default method of an `as_{to}()`
generic.

There’s not much to add here re: errors, now that
[`cli::cli_abort()`](https://cli.r-lib.org/reference/cli_abort.html)
exists. Error messages are formed just like informational messages now.
