.auth <- gargle::AuthState$new(
  app         = gargle::tidyverse_app(),
  api_key     = gargle::tidyverse_api_key(),
  auth_active = TRUE,
  cred        = NULL
)
