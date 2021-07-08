# executed interactively
# think of this as notes, in the form of code

# transferring ownership of the offical example and test Sheets to the
# sheet keeper service account
# and revoking write permission for myself and the docs service account

# objective is to make it impossible for development and checking mishaps to
# delete example Sheets

library(tidyverse)
library(googledrive)
library(googlesheets4)

sheet_keeper_email <-
  "googlesheets4-sheet-keeper@gargle-169921.iam.gserviceaccount.com"

# example Sheets started out as owned by the docs service account
# test Sheets started out as owned by the testing service account
# one of my personal Google identities had the 'write' role on each, as well
#googlesheets4:::gs4_auth_docs()
googlesheets4:::gs4_auth_testing()
gs4_find()

#target_sheets <- googlesheets4:::.gs4_examples
target_sheets <- googlesheets4:::.test_sheets

dat <- target_sheets %>%
  as_id() %>%
  drive_get() %>%
  drive_reveal("permissions")

# purely for exploration
dat_explore <- dat %>%
  hoist(permissions_resource, perms = list("permissions")) %>%
  select(-ends_with("_resource")) %>%
  unnest_auto(perms) %>%
  rename(drive_id = id) %>%
  unnest_wider(perms)
View(dat_explore)
dat_explore %>%
  select(name, id, type, role, emailAddress, displayName) %>%
  View()

# determine which Sheets are not yet owned by sheet keeper
to_transfer <- dat_explore %>%
  filter(role == "owner", displayName != "googlesheets4-sheet-keeper") %>%
  #select(name, displayName)
  pull(name)

# transfer ownership to sheet keeper
dat %>%
  filter(name %in% to_transfer) %>%
  drive_share(
    role = "owner",
    type = "user",
    emailAddress = sheet_keeper_email,
    transferOwnership = TRUE
  )

# revoking write access from the docs or testing account and my personal
# account
# must auth as sheet keeper now
gs4_auth(
  path = "~/.R/gargle/googlesheets4-sheet-keeper.json",
  scopes = "https://www.googleapis.com/auth/drive"
)
gs4_user()
drive_auth(token = gs4_token())
drive_user()

dat <- gs4_find() %>%
  filter(name %in% names(target_sheets)) %>%
  drive_reveal("permissions")

View(dat$drive_resource)

dat_explore <- dat %>%
  hoist(permissions_resource, perms = list("permissions")) %>%
  select(-permissions_resource) %>%
  unnest_auto(perms) %>%
  rename(drive_id = id) %>%
  unnest_wider(perms) %>%
  rename(permission_id = id)
View(dat_explore)
dat_explore %>%
  filter(role == "writer", type == "user") %>%
  select(name, type, role, emailAddress, drive_id, permission_id) %>%
  View()

delete_one_permission <- function(drive_id, permission_id) {
  request <- googledrive::request_generate(
    endpoint = "drive.permissions.delete",
    params = list(fileId = drive_id, permissionId = permission_id)
  )
  response <- googledrive::request_make(request, encode = "json")
  gargle::response_process(response)
}

to_delete <- dat_explore %>%
  filter(role == "writer", type == "user") %>%
  select(drive_id, permission_id)

out <- map2(to_delete$drive_id, to_delete$permission_id, delete_one_permission)


# 2021-06-05 I decided to publish some sheets, so they could be embedded in a
# distill website
drive_user()
deaths <- drive_get("deaths")
deaths %>%
  drive_reveal("published")
deaths <- deaths %>%
  drive_publish()
View(deaths$revision_resource)


ff <- drive_get("formulas-and-formats")
ff %>%
  drive_reveal("published")
ff <- ff %>%
  drive_publish()
