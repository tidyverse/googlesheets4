# col_names must be logical or character and have length

    Code
      wrapper_fun(1:3)
    Condition
      Error in `wrapper_fun()`:
      ! `col_names` must be <character>:
      x `col_names` has class <integer>.

---

    Code
      wrapper_fun(factor("a"))
    Condition
      Error in `wrapper_fun()`:
      ! `col_names` must be <character>:
      x `col_names` has class <factor>.

---

    Code
      wrapper_fun(character())
    Condition
      Error in `wrapper_fun()`:
      ! `col_names` must have length greater than zero.

# logical col_names must be TRUE or FALSE

    Code
      wrapper_fun(NA)
    Condition
      Error in `wrapper_fun()`:
      ! `col_names` must be either `TRUE` or `FALSE`.

---

    Code
      wrapper_fun(c(TRUE, FALSE))
    Condition
      Error in `wrapper_fun()`:
      ! `col_names` must be either `TRUE` or `FALSE`.

