# Changelog for Redmine Table Calculation Inheritance

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## 1.0.0 - 2023-04-06

### Added

* Support for Redmine 5
* migrations related to spreadsheet_row_results table
* further default columns for SpreadsheetRowResult to increase the control over
the current state of a result

### Changes

* associate object calculation if not enabled to be hidden
* data models to be compatible to redmine_table_calculation 2.0.0

## 0.2.4 - 2022-10-19

### Fixed

* several failing tests

## 0.2.3 - 2022-06-25

### Fixed

* failing SpreadsheetRowResultControllerTests

### Added

* SpreadsheetRow#visible? to support changes in Redmine 4.2.7

## 0.2.2 - 2022-05-18

### Changed

* README template to the latest version
* copyright year

## 0.2.1 - 2021-12-03

### Added

* translations comming from redmine_table_calculation

## 0.2.0 - 2021-10-11

### Deleted

* spreadsheet description from aggregated results
* card view hook

### Added

* wikitoolbar to spreadsheet result row comment field
* prefilled spreadsheet result row data fields
* colored badges for custom field enumerations

## 0.1.1 - 2021-07-13

### Added

* wiki formatting to spreadsheet description
* inheritation button for accepting the current calculated result as final result

### Fixed

* nil class error for missing table of spreadsheets

## 0.1.0 - 2021-05-01

### Added

* almost all files related to inheritance calculation

## 0.0.1 - 2021-04-27

### Added

* initial Redmine plugin structure
