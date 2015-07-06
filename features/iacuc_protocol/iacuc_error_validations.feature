Feature: Error Validations in IACUC Protocols

  As a Protocol Creator, I would like to know when I have entered
  invalid Protocol information, so that I know I need to correct it.

  Background:
    * Users exist with the following roles: IACUC Protocol Creator

  Scenario: IACUC Protocol overview is missing a required field
    When the IACUC Protocol Creator creates an IACUC Protocol but misses a required field
    Then an error should appear saying the field is required