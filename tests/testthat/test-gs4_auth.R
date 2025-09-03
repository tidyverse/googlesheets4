test_that("gs4_auth_configure works", {
  old_client <- gs4_oauth_client()
  old_api_key <- gs4_api_key()
  withr::defer(
    gs4_auth_configure(client = old_client, api_key = old_api_key)
  )

  expect_no_error(gs4_oauth_client())
  expect_no_error(gs4_api_key())

  expect_snapshot(
    gs4_auth_configure(client = gargle::gargle_client(), path = "PATH"),
    error = TRUE
  )

  gs4_auth_configure(client = gargle::gargle_client())
  expect_s3_class(gs4_oauth_client(), "gargle_oauth_client")

  path_to_json <- system.file(
    "extdata",
    "client_secret_installed.googleusercontent.com.json",
    package = "gargle"
  )
  gs4_auth_configure(path = path_to_json)
  expect_s3_class(gs4_oauth_client(), "gargle_oauth_client")

  gs4_auth_configure(client = NULL)
  expect_null(gs4_oauth_client())

  gs4_auth_configure(api_key = "API_KEY")
  expect_identical(gs4_api_key(), "API_KEY")

  gs4_auth_configure(api_key = NULL)
  expect_null(gs4_api_key())
})

test_that("gs4_oauth_app() is deprecated", {
  withr::local_options(lifecycle_verbosity = "warning")
  expect_snapshot(absorb <- gs4_oauth_app())
})

test_that("gs4_auth_configure(app =) is deprecated in favor of client", {
  withr::local_options(lifecycle_verbosity = "warning")
  (original_client <- gs4_oauth_client())
  withr::defer(gs4_auth_configure(client = original_client))

  client <- gargle::gargle_oauth_client_from_json(
    system.file(
      "extdata",
      "client_secret_installed.googleusercontent.com.json",
      package = "gargle"
    ),
    name = "test-client"
  )
  expect_snapshot(
    gs4_auth_configure(app = client)
  )
  expect_equal(gs4_oauth_client()$name, "test-client")
  expect_equal(gs4_oauth_client()$id, "abc.apps.googleusercontent.com")
})

# gs4_scopes() ----
test_that("gs4_scopes() reveals Sheets scopes", {
  expect_snapshot(gs4_scopes())
})

test_that("gs4_scopes() substitutes actual scope for short form", {
  expect_equal(
    gs4_scopes(c(
      "spreadsheets",
      "drive",
      "drive.readonly"
    )),
    c(
      "https://www.googleapis.com/auth/spreadsheets",
      "https://www.googleapis.com/auth/drive",
      "https://www.googleapis.com/auth/drive.readonly"
    )
  )
})

test_that("gs4_scopes() passes unrecognized scopes through", {
  expect_equal(
    gs4_scopes(c(
      "email",
      "spreadsheets.readonly",
      "https://www.googleapis.com/auth/cloud-platform"
    )),
    c(
      "email",
      "https://www.googleapis.com/auth/spreadsheets.readonly",
      "https://www.googleapis.com/auth/cloud-platform"
    )
  )
})
