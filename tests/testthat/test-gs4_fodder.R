test_that("gs4_fodder() works", {
  dat <- gs4_fodder(3, 5)
  expect_named(dat, LETTERS[1:5])
  ltrs <- rep(LETTERS[1:5], each = 3)
  nbrs <- rep(1:3, 5) + 1
  expect_equal(
    as.vector(as.matrix(dat)),
    paste0(ltrs, nbrs)
  )
})
