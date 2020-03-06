test_that("enlist_sheets() works", {

  df1 <- data.frame(x = 1L)
  df2 <- data.frame(x = 2L)
  df_list <- list(df1 = df1, df2 = df2)
  f <- function(sheets = NULL) enlist_sheets(enquo(sheets))

  expect_null(f())
  expect_identical(
    f(c("string_1", "string_2")),
    list(name = c("string_1", "string_2"), value = list(NULL, NULL))
  )
  expect_identical(
    f(df1),
    list(name = "df1", value = list(data.frame(x = 1L)))
  )
  expect_identical(
    f(list(df1, df2)),
    list(name = list(NULL, NULL), value = list(df1, df2))
  )
  expect_identical(
    f(list(df1 = df1, df2 = df2)),
    list(name = c("df1", "df2"), value = list(df1, df2))
  )
  expect_identical(
    f(df_list),
    f(list(df1 = df1, df2 = df2))
  )
  expect_identical(
    f(data.frame(x = 1L)),
    list(name = list(NULL), value = list(data.frame(x = 1L)))
  )
})
