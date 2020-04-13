test_that("constructors return length-0 vector when called with no arguments", {
  expect_length(new_formula(), 0)
  expect_length(gs4_formula(), 0)
})

test_that("low-level constructor errors for non-character input", {
  expect_error(new_formula(1:3), class = "vctrs_error_assert_ptype")
})

test_that("user-friendly constructor works for coercible input", {
  expect_s3_class(
    gs4_formula(factor("=sum(A:A)")),
    "googlesheets4_formula"
  )
})

test_that("common type of googlesheets4_formula and character is character", {
  expect_identical(
    vctrs::vec_ptype2(character(), gs4_formula()),
    character()
  )
  expect_identical(
    vctrs::vec_ptype2(gs4_formula(), character()),
    character()
  )
})

test_that("googlesheets4_formula and character are coercible", {
  expect_identical(
    vctrs::vec_cast("=sum(A:A)", gs4_formula()),
    gs4_formula("=sum(A:A)")
  )
  expect_identical(
    vctrs::vec_cast(gs4_formula("=sum(A:A)"), character()),
    "=sum(A:A)"
  )
  expect_identical(
    vctrs::vec_cast(gs4_formula("=sum(A:A)"), gs4_formula()),
    gs4_formula("=sum(A:A)")
  )
})

test_that("can concatenate googlesheets4_formula", {
  expect_identical(
    vctrs::vec_c(
      gs4_formula("=sum(A:A)"),
      gs4_formula("=sum(B:B)")
    ),
    gs4_formula(c("=sum(A:A)", "=sum(B:B)"))
  )
})

test_that("googlesheets4_formula can have missing elements", {
  out <- vctrs::vec_c(
    gs4_formula("=sum(A:A)"),
    NA,
    gs4_formula("=min(B2:G7"),
    NA
  )
  expect_s3_class(out, "googlesheets4_formula")
  expect_true(all(is.na(out[c(2, 4)])))
})
