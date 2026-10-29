# range styling: no redundant quotes, double quotes without color

    Code
      gs4_bullets(c(v = "Range {.range {qualified}}."))
    Message
      v Range "'Sheet1'!A1:B3".
    Code
      gs4_bullets(c(v = "Range {.range {bare}}."))
    Message
      v Range "F".

---

    Code
      gs4_bullets(c(v = "Range {.range {qualified}}."))
    Message
      [32mv[39m Range [33m'Sheet1'!A1:B3[39m.
    Code
      gs4_bullets(c(v = "Range {.range {bare}}."))
    Message
      [32mv[39m Range [33mF[39m.

# abort_unsupported_conversion() works

    Don't know how to make an instance of <target_class> from something of class <a/b/c>.

