# new() rejects data not expected for schema

    Code
      new("Spreadsheet", foofy = "blah")
    Error <googlesheets4_error>
      Properties not recognized for the Spreadsheet schema:
      * foofy

---

    Code
      new("Spreadsheet", foofy = "blah", foo = "bar")
    Error <googlesheets4_error>
      Properties not recognized for the Spreadsheet schema:
      * foofy
      * foo

# check_against_schema() errors when no schema can be found

    Code
      check_against_schema(x)
    Error <googlesheets4_error>
      Trying to check an object of class
      <googlesheets4_schema_SomeThing/googlesheets4_schema/list>, but can't get a
      schema.

