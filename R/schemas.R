new <- function(id, ...) {
  schema <- .tidy_schemas[[id]]
  if (is.null(schema)) {
    gs4_abort("Can't find a tidy schema with id {.field {id}}.")
  }
  dots <- list2(...)
  dots <- discard(dots, is.null)

  check_against_schema(dots, schema = schema)

  structure(
    dots,
    # explicit 'list' class is a bit icky but makes jsonlite happy
    # in various vctrs futures, this could need revisiting
    class = c(id_as_class(id), "googlesheets4_schema", "list"),
    schema = schema
  )
}

# TODO: if it proves necessary, this could do more meaningful checks
check_against_schema <- function(x, schema = NULL, id = NA_character_) {
  schema <- schema %||%
    .tidy_schemas[[id %|% id_from_class(x)]] %||%
    attr(x, "schema")
  if (is.null(schema)) {
    gs4_abort("
      Trying to check an object of class {.cls {class(x)}}, \\
      but can't get a schema.")
  }
  stopifnot(is_dictionaryish(x))
  unexpected <- setdiff(names(x), schema$property)
  if (length(unexpected) > 0) {
    gs4_abort(c(
      "Properties not recognized for the {.field {attr(schema, 'id')}} schema:",
      bulletize(gargle_map_cli(unexpected), bullet = "x")
    ))
  }
  x
}

id_as_class <- function(id) glue("googlesheets4_schema_{id}")

id_from_class <- function(x) {
  m <- grepl("^googlesheets4_schema_", class(x))
  if (!any(m)) {
    return(NA_character_)
  }
  m <- which(m)[1]
  sub("^googlesheets4_schema_", "", class(x)[m])
}

# patch ----
patch <- function(x, ...) {
  UseMethod("patch")
}

#' @export
patch.default <- function(x, ...) {
  gs4_abort("
    Don't know how to {.fun patch} an object of class {.cls {class(x)}}.")
}

#' @export
patch.googlesheets4_schema <- function(x, ...) {
  dots <- list2(...)
  dots <- discard(dots, is.null)
  x[names(dots)] <- dots
  check_against_schema(x)
}
