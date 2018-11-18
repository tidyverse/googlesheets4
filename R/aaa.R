# environment to store credentials
.state <- new.env(parent = emptyenv())

.onLoad <- function(libname, pkgname) {

  .state[["tidyverse_app"]] <- gargle::tidyverse_app()
  .state[["tidyverse_api_key"]] <- gargle::tidyverse_api_key()

  set_auth_active(TRUE)
  set_api_key(.state[["tidyverse_api_key"]])
  set_oauth_app(.state[["tidyverse_app"]])

  invisible()
}
