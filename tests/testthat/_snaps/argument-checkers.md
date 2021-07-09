# col_names must be logical or character and have length

    Code
      check_col_names(1:3)
    Error <googlesheets4_error>
      `col_names` must be <character>:
      x `col_names` has class <integer>.

---

    Code
      check_col_names(factor("a"))
    Error <googlesheets4_error>
      `col_names` must be <character>:
      x `col_names` has class <factor>.

---

    Code
      check_col_names(character())
    Error <googlesheets4_error>
      `col_names` must have length greater than zero.

# logical col_names must be TRUE or FALSE

    Code
      check_col_names(NA)
    Error <googlesheets4_error>
      `col_names` must be either `TRUE` or `FALSE`.

---

    Code
      check_col_names(c(TRUE, FALSE))
    Error <googlesheets4_error>
      `col_names` must be either `TRUE` or `FALSE`.

