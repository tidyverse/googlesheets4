test_that("constructors return length-0 vector when called with no arguments", {
  expect_length(new_googlesheets4_formula(), 0)
  expect_length(googlesheets4_formula(), 0)
})

test_that("low-level constructor errors for non-character input", {
  expect_error(
    new_googlesheets4_formula(1:3),
    class = "vctrs_error_assert_ptype"
  )
})

test_that("user-friendly constructor works for coercible input", {
  expect_s3_class(
    googlesheets4_formula(factor("=sum(A:A)")),
    "googlesheets4_formula"
  )
})

test_that("common type of googlesheets4_formula and character is character", {
  expect_identical(
    vctrs::vec_ptype2(character(), googlesheets4_formula()),
    character()
  )
  expect_identical(
    vctrs::vec_ptype2(googlesheets4_formula(), character()),
    character()
  )
})

test_that("googlesheets4_formula and character are coercible", {
  expect_identical(
    vctrs::vec_cast("=sum(A:A)", googlesheets4_formula()),
    googlesheets4_formula("=sum(A:A)")
  )
  expect_identical(
    vctrs::vec_cast(googlesheets4_formula("=sum(A:A)"), character()),
    "=sum(A:A)"
  )
  expect_identical(
    vctrs::vec_cast(googlesheets4_formula("=sum(A:A)"), googlesheets4_formula()),
    googlesheets4_formula("=sum(A:A)")
  )
})

test_that("can concatenate googlesheets4_formula", {
  expect_identical(
    vctrs::vec_c(
      googlesheets4_formula("=sum(A:A)"),
      googlesheets4_formula("=sum(B:B)")
    ),
    googlesheets4_formula(c("=sum(A:A)", "=sum(B:B)"))
  )
})
