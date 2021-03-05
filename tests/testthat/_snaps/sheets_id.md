# sheets_id print method reveals metadata

    Code
      print(gs4_example("gapminder"))
    Output
       Spreadsheet name: gapminder
                     ID: 1U6Cf_qEOhiR9AZqTqS3mbMF3zt2db48ZP5v3rkrAEJY
                 Locale: en_US
              Time zone: America/Los_Angeles
            # of sheets: 5
      # of named ranges: 1
      
      (Sheet name): (Nominal extent in rows x columns)
            Africa: 625 x 6
          Americas: 301 x 6
              Asia: 397 x 6
            Europe: 361 x 6
           Oceania: 25 x 6
      
      (Named range): (A1 range)        
             canada: 'Americas'!A38:F49

# sheets_id print method doesn't error for nonexistent ID

    Code
      as_sheets_id("12345")
    Output
      Spreadsheet name: <unknown>
                    ID: 12345
                Locale: <unknown>
             Time zone: <unknown>
           # of sheets: <unknown>
      
      Unable to get metadata for this Sheet. Error details:
      Client error: (404) NOT_FOUND
        * A specified resource is not found, or the request is rejected by undisclosed reasons, such as whitelisting.
        * Requested entity was not found.

# can print public sheets_id if deauth'd

    Code
      print(gs4_example("mini-gap"))
    Output
      Spreadsheet name: mini-gap
                    ID: 1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU
                Locale: en_US
             Time zone: America/Los_Angeles
           # of sheets: 5
      
      (Sheet name): (Nominal extent in rows x columns)
            Africa: 6 x 6
          Americas: 6 x 6
              Asia: 6 x 6
            Europe: 6 x 6
           Oceania: 6 x 6

# sheets_id print does not error for lack of cred

    Code
      print(gs4_example("mini-gap"))
    Output
      Spreadsheet name: <unknown>
                    ID: 1k94ZVVl6sdj0AXfK9MQOuQ4rOhd1PULqpAu2_kr9MAU
                Locale: <unknown>
             Time zone: <unknown>
           # of sheets: <unknown>
      
      Unable to get metadata for this Sheet. Error details:
      Can't get Google credentials.
      Are you running googlesheets4 in a non-interactive session? Consider:
        * `gs4_deauth()` to prevent the attempt to get credentials.
        * Call `gs4_auth()` directly with all necessary specifics.
      See gargle's "Non-interactive auth" vignette for more details:
      https://gargle.r-lib.org/articles/non-interactive-auth.html

