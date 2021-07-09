# sheet_add() rejects non-character `sheet`

    Code
      sheet_add(test_sheet("googlesheets4-cell-tests"), sheet = 3)
    Error <googlesheets4_error>
      `sheet` must be <character>:
      x `sheet` has class <numeric>.

