schema_rectangle <- function(s) {
  if (!"tidyverse" %in% .packages()) {
    stop("Attach the tidyverse package before using schema_rectangle()")
  }
  schema <- pluck(.schemas, s)
  if (schema$type != "object") {
    msg <- glue::glue(
      "Schema must be of type {sq('object')}, not {sq(schema$type)}"
    )
    stop(msg)
  }

  properties <- pluck(schema, "properties")
  scaffold <- list(
    description      = "Just a placeholder",
    type             = "scaffold",
    "$ref"           = "SCHEMA",
    items            = list("$ref" = "SCHEMA"),
    format           = "FORMAT",
    enum             = letters[1:3],
    enumDescriptions = LETTERS[1:3]
  )
  df <- tibble(properties = c(scaffold = list(scaffold), properties))

  df <- df %>%
    mutate(property = names(properties)) %>%
    select(property, everything()) %>%
    unnest_wider(properties) %>%
    select(-description) %>%
    mutate(type = replace_na(type, "object")) %>%
    rename(instance_of = "$ref")

  # workaround for https://github.com/tidyverse/tidyr/issues/806
  repair <- function(x) {
    map_if(x, ~ inherits(.x, "vctrs_unspecified"), ~ vctrs::unspecified(0))
  }
  df <- modify_if(df, is_list, repair)

  df <- df %>%
    hoist(items, array_of = "$ref")

  df <- df %>%
    mutate(new = map2(enum, enumDescriptions, ~ tibble(enum = .x, enumDesc = .y))) %>%
    select(-starts_with("enum")) %>%
    rename(enum = new) %>%
    mutate(type = if_else(map_lgl(enum, ~ nrow(.x) > 0), "enum", type))

  attr(df, "id") <- s

  df %>%
    filter(property != "scaffold") %>%
    arrange(property)
}
