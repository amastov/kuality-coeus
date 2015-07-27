@proposal @wip
Feature: Permissions in a Proposal

  As a Proposal Aggregator, I want to be able to assign others permissions to a proposal,
  to allow them to work on the proposal with me, and to control what actions
  they are capable of performing with it. #https://jira.kuali.org/browse/KRAFDBCK-12063

  Background: A proposal creator user creates a proposal
    * Users exist with the following roles: Proposal Creator, unassigned
    * the Proposal Creator creates a Proposal

  Scenario: The proposal creator is automatically an aggregator
    When  the Proposal Creator visits the Proposal's Access page
    Then  the Proposal Creator user is listed as an Aggregator Document Level in the proposal permissions

  Scenario Outline: A Proposal Aggregator can assign various roles to a proposal documents permissions
    When  I assign the unassigned user as a <Role> in the proposal permissions
    Then  the unassigned user can access the Proposal
    And   their proposal permissions allow them to <Permissions>

    Examples:
    | Role                 | Permissions                          |
    | Aggregator           | edit all parts of the Proposal       |
    #| Budget Creator       | update the Budget, not the narrative |
    #| Delete Proposal      | delete the Proposal                  |
    #| Viewer               | only read the Proposal               |

  Scenario: Narrative Writers can't edit budget details
    Given the Proposal Creator user creates a Budget Version for the Proposal
    When  I assign the Unassigned user as a Narrative Writer in the proposal permissions
    Then  the unassigned user can access the Proposal
    And   their proposal permissions do not allow them to edit budget details

  Scenario Outline: Proposal permissions are not passed onto future proposals created by the same creator
    Given I assign the unassigned user as a <Role> in the proposal permissions
    When  the Proposal Creator creates a second Proposal
    Then  the unassigned user should not be listed as a <Role> in the second Proposal

  Examples:
    | Role             |
    | Viewer           |
    | Budget Creator   |
    | Narrative Writer |
    | Aggregator       |
    | approver         |
    | Delete Proposal  |

  Scenario Outline: Users who are assigned the Aggregator role cannot be assigned additional roles
    Given I assign the <Role> user as an aggregator in the proposal permissions
    When  I add an additional proposal role to the <Role> user
    Then  an error should appear that says not to select other roles alongside aggregator

  Examples:
    | Role             |
    | unassigned       |
    | Proposal Creator |

  Scenario Outline: Visit a recalled proposal as users with the permissions necessary to edit the document in varying ways
    Given I assign the unassigned user as a <Role> in the proposal permissions
    And   complete the Proposal
    And   submit the Proposal
    When  I recall the Proposal
    Then  the unassigned user can access the Proposal
    And   their proposal permissions allow them to <Permissions>

  Examples:
    | Role                | Permissions                                    |
    | Aggregator          | edit all parts of the Proposal                 |
    | Budget Creator      | update the Budget, not the narrative           |
    | Delete Proposal     | delete the Proposal                            |
    | Viewer              | only read the Proposal                         |
