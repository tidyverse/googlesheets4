This is a resubmission.

Original submission: 2018-10-18
First CRAN Review: 2019-10-22

Second submission: 2019-10-22
Second CRAN Review: 2019-10-28

The second reviewer brings up new things:

> Please add small files needed for the examples in the inst/extdata
> subfolder of your package and use system.file() to get the correct
> package path. e.g. sheets_auth_configure.Rd
>
> \dontrun{} should be only used if the example really cannot be executed
> (e.g. because of missing additional software, missing API keys, ...) by
> the user. That's why wrapping examples in \dontrun{} adds the comment
> ("# Not run:") as a warning for the user.
> Does not seem necessary.
> Please replace \dontrun with \donttest.

I have added the requested file, below inst/extdata/, even though it must be
filled with fake data. We cannot ship an actual OAuth client ID and secret
inside a CRAN package this way. As documented for sheets_auth_configure(), the
user has to obtain this JSON for themselves from Google Cloud Platform Console.
But this JSON has valid structure and eliminates a \dontrun{}.

---

Response to the first review:

The reviewer asked for more details in the description and to explain all acronyms. I have added:

  * An explanation that API = "application programming interface" and a
    description of what that means.
  * An explanation that v4 = "version 4" of the Sheets API.
  * A statement that googlesheets4 lets a user retrieve metadata and data
    out of a Google Sheet.

## Test environments

* local macOS 10.14 Mojave, R 3.6.0
* local Windows 10 VM, R 3.6.0
* win-builder (devel)
* Windows Server 2008 R2 SP1, R-devel, 32/64 bit, r-hub
* Windows Server 2012 R2 x64 (on appveyor), R 3.6.1 Patched
* Ubuntu 16.04 (on travis-ci), R devel through 3.2
* Ubuntu Linux 16.04 LTS, R-release, GCC on r-hub
* Fedora Linux, R-devel, clang, gfortran on r-hub

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new submission.
