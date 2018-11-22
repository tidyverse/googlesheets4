.auth <- gargle::AuthState$new(
  package     = "googlesheets4",
  app         = gargle::tidyverse_app(),
  api_key     = gargle::tidyverse_api_key(),
  auth_active = TRUE,
  cred        = NULL
)
