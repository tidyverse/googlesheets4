# col_names must be logical or character and have length

    Code
      check_col_names(1:3)
    Condition
      Error in `check_character()`:
      ! `col_names` must be <character>:
      x `col_names` has class <integer>.

---

    Code
      check_col_names(factor("a"))
    Condition
      Error in `check_character()`:
      ! `col_names` must be <character>:
      x `col_names` has class <factor>.

---

    Code
      check_col_names(character())
    Condition
      Error in `check_has_length()`:
      ! `col_names` must have length greater than zero.

# logical col_names must be TRUE or FALSE

    Code
      check_col_names(NA)
    Condition
      Error in `check_bool()`:
      ! `col_names` must be either `TRUE` or `FALSE`.

---

    Code
      check_col_names(c(TRUE, FALSE))
    Condition
      Error in `check_bool()`:
      ! `col_names` must be either `TRUE` or `FALSE`.

