# currently just for development
# I'm generally auth'd as:
#  * as a service acct (which means I can't look at anything in the browser)
#  * with Drive and Sheets scope
#  * with googlesheets4 and googledrive
# so this is helpful for quickly granting anyone or myself specifically
# permission to read or write a Sheet I'm fiddling with in the browser or the
# API explorer
#
# Note defaults: role = "reader", type = "anyone"
# --> "anyone with the link" can view
#
# examples:
# sheets_share()
# sheets_share(type = "user", emailAddress = "jane@example.com")
# sheets_share(type = "user", emailAddress = "jane@example.com", role = "writer")
sheets_share <- function(ss,
                         ...,
                         role = c(
                           "reader", "commenter", "writer",
                           "owner", "organizer"
                         ),
                         type = c("anyone", "user", "group", "domain")) {
  role <- match.arg(role)
  type <- match.arg(type)
  googledrive::drive_share(
    file = googledrive::as_id(as_sheets_id(ss)),
    role = role,
    type = type,
    ...
  )
}
