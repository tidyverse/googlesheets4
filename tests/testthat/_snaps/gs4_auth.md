# gs4_auth_configure works

    Code
      gs4_auth_configure(client = gargle::gargle_client(), path = "PATH")
    Condition
      Error in `gs4_auth_configure()`:
      ! Must supply exactly one of `client` and `path`, not both.

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

