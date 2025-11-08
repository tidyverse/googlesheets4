# List Sheets endpoints

Returns a list of selected Sheets API v4 endpoints, as stored inside the
googlesheets4 package. The names of this list (or the `id` sub-elements)
are the nicknames that can be used to specify an endpoint in
[`request_generate()`](https://googlesheets4.tidyverse.org/dev/reference/request_generate.md).
For each endpoint, we store its nickname or `id`, the associated HTTP
`method`, the `path`, and details about the parameters. This list is
derived programmatically from the Sheets API v4 Discovery Document
(`https://www.googleapis.com/discovery/v1/apis/sheets/v4/rest`).

## Usage

``` r
gs4_endpoints(i = NULL)
```

## Arguments

- i:

  The name(s) or integer index(ices) of the endpoints to return.
  Optional. By default, the entire list is returned.

## Value

A list containing some or all of the subset of the Sheets API v4
endpoints that are used internally by googlesheets4.

## Examples

``` r
str(gs4_endpoints(), max.level = 2)
#> List of 17
#>  $ sheets.spreadsheets.create                        :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.create"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets"
#>   ..$ parameters    :List of 19
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Creates a spreadsheet, returning the newly created spreadsheet."
#>   ..$ request       : chr "Spreadsheet"
#>   ..$ response      : chr "Spreadsheet"
#>   ..$ parameterOrder: list()
#>  $ sheets.spreadsheets.get                           :List of 8
#>   ..$ id            : chr "sheets.spreadsheets.get"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}"
#>   ..$ parameters    :List of 15
#>   ..$ scopes        : chr "drive, drive.file, drive.readonly, spreadsheets, spreadsheets.readonly"
#>   ..$ description   : chr "Returns the spreadsheet at the given ID. The caller must specify the spreadsheet ID. By default, data within gr"| __truncated__
#>   ..$ response      : chr "Spreadsheet"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.getByDataFilter               :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.getByDataFilter"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}:getByDataFilter"
#>   ..$ parameters    :List of 15
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Returns the spreadsheet at the given ID. The caller must specify the spreadsheet ID. This method differs from G"| __truncated__
#>   ..$ request       : chr "GetSpreadsheetByDataFilterRequest"
#>   ..$ response      : chr "Spreadsheet"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.batchUpdate                   :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.batchUpdate"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}:batchUpdate"
#>   ..$ parameters    :List of 16
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Applies one or more updates to the spreadsheet. Each request is validated before being applied. If any request "| __truncated__
#>   ..$ request       : chr "BatchUpdateSpreadsheetRequest"
#>   ..$ response      : chr "BatchUpdateSpreadsheetResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.values.get                    :List of 8
#>   ..$ id            : chr "sheets.spreadsheets.values.get"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values/{range}"
#>   ..$ parameters    :List of 16
#>   ..$ scopes        : chr "drive, drive.file, drive.readonly, spreadsheets, spreadsheets.readonly"
#>   ..$ description   : chr "Returns a range of values from a spreadsheet. The caller must specify the spreadsheet ID and a range."
#>   ..$ response      : chr "ValueRange"
#>   ..$ parameterOrder: chr [1:2] "spreadsheetId" "range"
#>  $ sheets.spreadsheets.values.update                 :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.update"
#>   ..$ httpMethod    : chr "PUT"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values/{range}"
#>   ..$ parameters    :List of 20
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Sets values in a range of a spreadsheet. The caller must specify the spreadsheet ID, range, and a valueInputOption."
#>   ..$ request       : chr "ValueRange"
#>   ..$ response      : chr "UpdateValuesResponse"
#>   ..$ parameterOrder: chr [1:2] "spreadsheetId" "range"
#>  $ sheets.spreadsheets.values.append                 :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.append"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values/{range}:append"
#>   ..$ parameters    :List of 21
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Appends values to a spreadsheet. The input range is used to search for existing data and find a \"table\" withi"| __truncated__
#>   ..$ request       : chr "ValueRange"
#>   ..$ response      : chr "AppendValuesResponse"
#>   ..$ parameterOrder: chr [1:2] "spreadsheetId" "range"
#>  $ sheets.spreadsheets.values.clear                  :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.clear"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values/{range}:clear"
#>   ..$ parameters    :List of 13
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Clears values from a spreadsheet. The caller must specify the spreadsheet ID and range. Only values are cleared"| __truncated__
#>   ..$ request       : chr "ClearValuesRequest"
#>   ..$ response      : chr "ClearValuesResponse"
#>   ..$ parameterOrder: chr [1:2] "spreadsheetId" "range"
#>  $ sheets.spreadsheets.values.batchGet               :List of 8
#>   ..$ id            : chr "sheets.spreadsheets.values.batchGet"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values:batchGet"
#>   ..$ parameters    :List of 16
#>   ..$ scopes        : chr "drive, drive.file, drive.readonly, spreadsheets, spreadsheets.readonly"
#>   ..$ description   : chr "Returns one or more ranges of values from a spreadsheet. The caller must specify the spreadsheet ID and one or more ranges."
#>   ..$ response      : chr "BatchGetValuesResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.values.batchUpdate            :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.batchUpdate"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values:batchUpdate"
#>   ..$ parameters    :List of 17
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Sets values in one or more ranges of a spreadsheet. The caller must specify the spreadsheet ID, a valueInputOpt"| __truncated__
#>   ..$ request       : chr "BatchUpdateValuesRequest"
#>   ..$ response      : chr "BatchUpdateValuesResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.values.batchClear             :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.batchClear"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values:batchClear"
#>   ..$ parameters    :List of 13
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Clears one or more ranges of values from a spreadsheet. The caller must specify the spreadsheet ID and one or m"| __truncated__
#>   ..$ request       : chr "BatchClearValuesRequest"
#>   ..$ response      : chr "BatchClearValuesResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.values.batchGetByDataFilter   :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.batchGetByDataFilter"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values:batchGetByDataFilter"
#>   ..$ parameters    :List of 16
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Returns one or more ranges of values that match the specified data filters. The caller must specify the spreads"| __truncated__
#>   ..$ request       : chr "BatchGetValuesByDataFilterRequest"
#>   ..$ response      : chr "BatchGetValuesByDataFilterResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.values.batchUpdateByDataFilter:List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.batchUpdateByDataFilter"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values:batchUpdateByDataFilter"
#>   ..$ parameters    :List of 17
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Sets values in one or more ranges of a spreadsheet. The caller must specify the spreadsheet ID, a valueInputOpt"| __truncated__
#>   ..$ request       : chr "BatchUpdateValuesByDataFilterRequest"
#>   ..$ response      : chr "BatchUpdateValuesByDataFilterResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.values.batchClearByDataFilter :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.values.batchClearByDataFilter"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/values:batchClearByDataFilter"
#>   ..$ parameters    :List of 13
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Clears one or more ranges of values from a spreadsheet. The caller must specify the spreadsheet ID and one or m"| __truncated__
#>   ..$ request       : chr "BatchClearValuesByDataFilterRequest"
#>   ..$ response      : chr "BatchClearValuesByDataFilterResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.developerMetadata.get         :List of 8
#>   ..$ id            : chr "sheets.spreadsheets.developerMetadata.get"
#>   ..$ httpMethod    : chr "GET"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/developerMetadata/{metadataId}"
#>   ..$ parameters    :List of 13
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Returns the developer metadata with the specified ID. The caller must specify the spreadsheet ID and the develo"| __truncated__
#>   ..$ response      : chr "DeveloperMetadata"
#>   ..$ parameterOrder: chr [1:2] "spreadsheetId" "metadataId"
#>  $ sheets.spreadsheets.developerMetadata.search      :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.developerMetadata.search"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/developerMetadata:search"
#>   ..$ parameters    :List of 13
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Returns all developer metadata matching the specified DataFilter. If the provided DataFilter represents a Devel"| __truncated__
#>   ..$ request       : chr "SearchDeveloperMetadataRequest"
#>   ..$ response      : chr "SearchDeveloperMetadataResponse"
#>   ..$ parameterOrder: chr "spreadsheetId"
#>  $ sheets.spreadsheets.sheets.copyTo                 :List of 9
#>   ..$ id            : chr "sheets.spreadsheets.sheets.copyTo"
#>   ..$ httpMethod    : chr "POST"
#>   ..$ path          : 'fs_path' chr "/v4/spreadsheets/{spreadsheetId}/sheets/{sheetId}:copyTo"
#>   ..$ parameters    :List of 14
#>   ..$ scopes        : chr "drive, drive.file, spreadsheets"
#>   ..$ description   : chr "Copies a single sheet from a spreadsheet to another spreadsheet. Returns the properties of the newly created sheet."
#>   ..$ request       : chr "CopySheetToAnotherSpreadsheetRequest"
#>   ..$ response      : chr "SheetProperties"
#>   ..$ parameterOrder: chr [1:2] "spreadsheetId" "sheetId"
gs4_endpoints("sheets.spreadsheets.values.get")
#> $sheets.spreadsheets.values.get
#> $sheets.spreadsheets.values.get$id
#> [1] "sheets.spreadsheets.values.get"
#> 
#> $sheets.spreadsheets.values.get$httpMethod
#> [1] "GET"
#> 
#> $sheets.spreadsheets.values.get$path
#> /v4/spreadsheets/{spreadsheetId}/values/{range}
#> 
#> $sheets.spreadsheets.values.get$parameters
#> $sheets.spreadsheets.values.get$parameters$spreadsheetId
#> $sheets.spreadsheets.values.get$parameters$spreadsheetId$description
#> [1] "The ID of the spreadsheet to retrieve data from."
#> 
#> $sheets.spreadsheets.values.get$parameters$spreadsheetId$location
#> [1] "path"
#> 
#> $sheets.spreadsheets.values.get$parameters$spreadsheetId$required
#> [1] TRUE
#> 
#> $sheets.spreadsheets.values.get$parameters$spreadsheetId$type
#> [1] "string"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$range
#> $sheets.spreadsheets.values.get$parameters$range$description
#> [1] "The [A1 notation or R1C1 notation](https://developers.google.com/workspace/sheets/api/guides/concepts#cell) of the range to retrieve values from."
#> 
#> $sheets.spreadsheets.values.get$parameters$range$location
#> [1] "path"
#> 
#> $sheets.spreadsheets.values.get$parameters$range$required
#> [1] TRUE
#> 
#> $sheets.spreadsheets.values.get$parameters$range$type
#> [1] "string"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$majorDimension
#> $sheets.spreadsheets.values.get$parameters$majorDimension$description
#> [1] "The major dimension that results should use. For example, if the spreadsheet data in Sheet1 is: `A1=1,B1=2,A2=3,B2=4`, then requesting `range=Sheet1!A1:B2?majorDimension=ROWS` returns `[[1,2],[3,4]]`, whereas requesting `range=Sheet1!A1:B2?majorDimension=COLUMNS` returns `[[1,3],[2,4]]`."
#> 
#> $sheets.spreadsheets.values.get$parameters$majorDimension$location
#> [1] "query"
#> 
#> $sheets.spreadsheets.values.get$parameters$majorDimension$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$majorDimension$enumDescriptions
#> [1] "The default value, do not use."     
#> [2] "Operates on the rows of a sheet."   
#> [3] "Operates on the columns of a sheet."
#> 
#> $sheets.spreadsheets.values.get$parameters$majorDimension$enum
#> [1] "DIMENSION_UNSPECIFIED" "ROWS"                 
#> [3] "COLUMNS"              
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$valueRenderOption
#> $sheets.spreadsheets.values.get$parameters$valueRenderOption$description
#> [1] "How values should be represented in the output. The default render option is FORMATTED_VALUE."
#> 
#> $sheets.spreadsheets.values.get$parameters$valueRenderOption$location
#> [1] "query"
#> 
#> $sheets.spreadsheets.values.get$parameters$valueRenderOption$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$valueRenderOption$enumDescriptions
#> [1] "Values will be calculated & formatted in the response according to the cell's formatting. Formatting is based on the spreadsheet's locale, not the requesting user's locale. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return `\"$1.23\"`."                                                                                                                                                                                    
#> [2] "Values will be calculated, but not formatted in the reply. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then `A2` would return the number `1.23`."                                                                                                                                                                                                                                                                                                
#> [3] "Values will not be calculated. The reply will include the formulas. For example, if `A1` is `1.23` and `A2` is `=A1` and formatted as currency, then A2 would return `\"=A1\"`. Sheets treats date and time values as decimal values. This lets you perform arithmetic on them in formulas. For more information on interpreting date and time values, see [About date & time values](https://developers.google.com/workspace/sheets/api/guides/formats#about_date_time_values)."
#> 
#> $sheets.spreadsheets.values.get$parameters$valueRenderOption$enum
#> [1] "FORMATTED_VALUE"   "UNFORMATTED_VALUE" "FORMULA"          
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$dateTimeRenderOption
#> $sheets.spreadsheets.values.get$parameters$dateTimeRenderOption$description
#> [1] "How dates, times, and durations should be represented in the output. This is ignored if value_render_option is FORMATTED_VALUE. The default dateTime render option is SERIAL_NUMBER."
#> 
#> $sheets.spreadsheets.values.get$parameters$dateTimeRenderOption$location
#> [1] "query"
#> 
#> $sheets.spreadsheets.values.get$parameters$dateTimeRenderOption$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$dateTimeRenderOption$enumDescriptions
#> [1] "Instructs date, time, datetime, and duration fields to be output as doubles in \"serial number\" format, as popularized by Lotus 1-2-3. The whole number portion of the value (left of the decimal) counts the days since December 30th 1899. The fractional portion (right of the decimal) counts the time as a fraction of the day. For example, January 1st 1900 at noon would be 2.5, 2 because it's 2 days after December 30th 1899, and .5 because noon is half a day. February 1st 1900 at 3pm would be 33.625. This correctly treats the year 1900 as not a leap year."
#> [2] "Instructs date, time, datetime, and duration fields to be output as strings in their given number format (which depends on the spreadsheet locale)."                                                                                                                                                                                                                                                                                                                                                                                                                           
#> 
#> $sheets.spreadsheets.values.get$parameters$dateTimeRenderOption$enum
#> [1] "SERIAL_NUMBER"    "FORMATTED_STRING"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$access_token
#> $sheets.spreadsheets.values.get$parameters$access_token$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $sheets.spreadsheets.values.get$parameters$access_token$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$alt
#> $sheets.spreadsheets.values.get$parameters$alt$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$alt$description
#> [1] "Data format for response."
#> 
#> $sheets.spreadsheets.values.get$parameters$alt$default
#> [1] "json"
#> 
#> $sheets.spreadsheets.values.get$parameters$alt$enum
#> [1] "json"  "media" "proto"
#> 
#> $sheets.spreadsheets.values.get$parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> $sheets.spreadsheets.values.get$parameters$alt$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$callback
#> $sheets.spreadsheets.values.get$parameters$callback$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$callback$description
#> [1] "JSONP"
#> 
#> $sheets.spreadsheets.values.get$parameters$callback$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$fields
#> $sheets.spreadsheets.values.get$parameters$fields$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $sheets.spreadsheets.values.get$parameters$fields$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$key
#> $sheets.spreadsheets.values.get$parameters$key$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> $sheets.spreadsheets.values.get$parameters$key$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$oauth_token
#> $sheets.spreadsheets.values.get$parameters$oauth_token$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> $sheets.spreadsheets.values.get$parameters$oauth_token$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$prettyPrint
#> $sheets.spreadsheets.values.get$parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $sheets.spreadsheets.values.get$parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $sheets.spreadsheets.values.get$parameters$prettyPrint$default
#> [1] "true"
#> 
#> $sheets.spreadsheets.values.get$parameters$prettyPrint$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$quotaUser
#> $sheets.spreadsheets.values.get$parameters$quotaUser$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$quotaUser$description
#> [1] "Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters."
#> 
#> $sheets.spreadsheets.values.get$parameters$quotaUser$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$upload_protocol
#> $sheets.spreadsheets.values.get$parameters$upload_protocol$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> $sheets.spreadsheets.values.get$parameters$upload_protocol$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$uploadType
#> $sheets.spreadsheets.values.get$parameters$uploadType$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $sheets.spreadsheets.values.get$parameters$uploadType$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.values.get$parameters$`$.xgafv`
#> $sheets.spreadsheets.values.get$parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.values.get$parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $sheets.spreadsheets.values.get$parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $sheets.spreadsheets.values.get$parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $sheets.spreadsheets.values.get$parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> 
#> 
#> $sheets.spreadsheets.values.get$scopes
#> [1] "drive, drive.file, drive.readonly, spreadsheets, spreadsheets.readonly"
#> 
#> $sheets.spreadsheets.values.get$description
#> [1] "Returns a range of values from a spreadsheet. The caller must specify the spreadsheet ID and a range."
#> 
#> $sheets.spreadsheets.values.get$response
#> [1] "ValueRange"
#> 
#> $sheets.spreadsheets.values.get$parameterOrder
#> [1] "spreadsheetId" "range"        
#> 
#> 
gs4_endpoints(4)
#> $sheets.spreadsheets.batchUpdate
#> $sheets.spreadsheets.batchUpdate$id
#> [1] "sheets.spreadsheets.batchUpdate"
#> 
#> $sheets.spreadsheets.batchUpdate$httpMethod
#> [1] "POST"
#> 
#> $sheets.spreadsheets.batchUpdate$path
#> /v4/spreadsheets/{spreadsheetId}:batchUpdate
#> 
#> $sheets.spreadsheets.batchUpdate$parameters
#> $sheets.spreadsheets.batchUpdate$parameters$spreadsheetId
#> $sheets.spreadsheets.batchUpdate$parameters$spreadsheetId$description
#> [1] "The spreadsheet to apply the updates to."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$spreadsheetId$location
#> [1] "path"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$spreadsheetId$required
#> [1] TRUE
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$spreadsheetId$type
#> [1] "string"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$requests
#> $sheets.spreadsheets.batchUpdate$parameters$requests$description
#> [1] "A list of updates to apply to the spreadsheet. Requests will be applied in the order they are specified. If any request is not valid, no requests will be applied."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$requests$type
#> [1] "array"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$requests$items
#> $sheets.spreadsheets.batchUpdate$parameters$requests$items$`$ref`
#> [1] "Request"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$requests$location
#> [1] "body"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$includeSpreadsheetInResponse
#> $sheets.spreadsheets.batchUpdate$parameters$includeSpreadsheetInResponse$description
#> [1] "Determines if the update response should include the spreadsheet resource."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$includeSpreadsheetInResponse$type
#> [1] "boolean"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$includeSpreadsheetInResponse$location
#> [1] "body"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseRanges
#> $sheets.spreadsheets.batchUpdate$parameters$responseRanges$description
#> [1] "Limits the ranges included in the response spreadsheet. Meaningful only if include_spreadsheet_in_response is 'true'."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseRanges$type
#> [1] "array"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseRanges$items
#> $sheets.spreadsheets.batchUpdate$parameters$responseRanges$items$type
#> [1] "string"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseRanges$location
#> [1] "body"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseIncludeGridData
#> $sheets.spreadsheets.batchUpdate$parameters$responseIncludeGridData$description
#> [1] "True if grid data should be returned. Meaningful only if include_spreadsheet_in_response is 'true'. This parameter is ignored if a field mask was set in the request."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseIncludeGridData$type
#> [1] "boolean"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$responseIncludeGridData$location
#> [1] "body"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$access_token
#> $sheets.spreadsheets.batchUpdate$parameters$access_token$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$access_token$description
#> [1] "OAuth access token."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$access_token$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$alt
#> $sheets.spreadsheets.batchUpdate$parameters$alt$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$alt$description
#> [1] "Data format for response."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$alt$default
#> [1] "json"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$alt$enum
#> [1] "json"  "media" "proto"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$alt$enumDescriptions
#> [1] "Responses with Content-Type of application/json"      
#> [2] "Media download with context-dependent Content-Type"   
#> [3] "Responses with Content-Type of application/x-protobuf"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$alt$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$callback
#> $sheets.spreadsheets.batchUpdate$parameters$callback$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$callback$description
#> [1] "JSONP"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$callback$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$fields
#> $sheets.spreadsheets.batchUpdate$parameters$fields$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$fields$description
#> [1] "Selector specifying which fields to include in a partial response."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$fields$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$key
#> $sheets.spreadsheets.batchUpdate$parameters$key$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$key$description
#> [1] "API key. Your API key identifies your project and provides you with API access, quota, and reports. Required unless you provide an OAuth 2.0 token."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$key$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$oauth_token
#> $sheets.spreadsheets.batchUpdate$parameters$oauth_token$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$oauth_token$description
#> [1] "OAuth 2.0 token for the current user."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$oauth_token$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$prettyPrint
#> $sheets.spreadsheets.batchUpdate$parameters$prettyPrint$type
#> [1] "boolean"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$prettyPrint$description
#> [1] "Returns response with indentations and line breaks."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$prettyPrint$default
#> [1] "true"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$prettyPrint$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$quotaUser
#> $sheets.spreadsheets.batchUpdate$parameters$quotaUser$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$quotaUser$description
#> [1] "Available to use for quota purposes for server-side applications. Can be any arbitrary string assigned to a user, but should not exceed 40 characters."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$quotaUser$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$upload_protocol
#> $sheets.spreadsheets.batchUpdate$parameters$upload_protocol$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$upload_protocol$description
#> [1] "Upload protocol for media (e.g. \"raw\", \"multipart\")."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$upload_protocol$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$uploadType
#> $sheets.spreadsheets.batchUpdate$parameters$uploadType$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$uploadType$description
#> [1] "Legacy upload protocol for media (e.g. \"media\", \"multipart\")."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$uploadType$location
#> [1] "query"
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$`$.xgafv`
#> $sheets.spreadsheets.batchUpdate$parameters$`$.xgafv`$type
#> [1] "string"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$`$.xgafv`$description
#> [1] "V1 error format."
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$`$.xgafv`$enum
#> [1] "1" "2"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$`$.xgafv`$enumDescriptions
#> [1] "v1 error format" "v2 error format"
#> 
#> $sheets.spreadsheets.batchUpdate$parameters$`$.xgafv`$location
#> [1] "query"
#> 
#> 
#> 
#> $sheets.spreadsheets.batchUpdate$scopes
#> [1] "drive, drive.file, spreadsheets"
#> 
#> $sheets.spreadsheets.batchUpdate$description
#> [1] "Applies one or more updates to the spreadsheet. Each request is validated before being applied. If any request is not valid then the entire request will fail and nothing will be applied. Some requests have replies to give you some information about how they are applied. The replies will mirror the requests. For example, if you applied 4 updates and the 3rd one had a reply, then the response will have 2 empty replies, the actual reply, and another empty reply, in that order. Due to the collaborative nature of spreadsheets, it is not guaranteed that the spreadsheet will reflect exactly your changes after this completes, however it is guaranteed that the updates in the request will be applied together atomically. Your changes may be altered with respect to collaborator changes. If there are no collaborators, the spreadsheet should reflect your changes."
#> 
#> $sheets.spreadsheets.batchUpdate$request
#> [1] "BatchUpdateSpreadsheetRequest"
#> 
#> $sheets.spreadsheets.batchUpdate$response
#> [1] "BatchUpdateSpreadsheetResponse"
#> 
#> $sheets.spreadsheets.batchUpdate$parameterOrder
#> [1] "spreadsheetId"
#> 
#> 
```
