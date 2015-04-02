Feature: Adding a large number of key persons to a Proposal

  As a Proposal Creator, I want to be able to add a large number
  of key persons to my proposal without error

  Scenario: Adding many key persons to a Proposal Document
    Given a User exists with the role: 'Proposal Creator'
    When  the Proposal Creator creates a Proposal
    Then  89 key persons can be added to the Proposal