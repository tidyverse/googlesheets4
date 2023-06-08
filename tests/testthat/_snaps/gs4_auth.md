# gs4_auth_configure works

    Code
      gs4_auth_configure(client = gargle::gargle_client(), path = "PATH")
    Condition
      Error in `gs4_auth_configure()`:
      ! Must supply exactly one of `client` and `path`, not both.

# gs4_oauth_app() is deprecated

    Code
      absorb <- gs4_oauth_app()
    Condition
      Warning:
      `gs4_oauth_app()` was deprecated in googlesheets4 1.1.0.
      i Please use `gs4_oauth_client()` instead.

# gs4_auth_configure(app =) is deprecated in favor of client

    Code
      gs4_auth_configure(app = client)
    Condition
      Warning:
      The `app` argument of `gs4_auth_configure()` is deprecated as of googlesheets4 1.1.0.
      i Please use the `client` argument instead.

# gs4_scopes() reveals Sheets scopes

    Code
      gs4_scopes()
    Output
                                                 spreadsheets 
               "https://www.googleapis.com/auth/spreadsheets" 
                                        spreadsheets.readonly 
      "https://www.googleapis.com/auth/spreadsheets.readonly" 
                                                        drive 
                      "https://www.googleapis.com/auth/drive" 
                                               drive.readonly 
             "https://www.googleapis.com/auth/drive.readonly" 
                                                   drive.file 
                 "https://www.googleapis.com/auth/drive.file" 

