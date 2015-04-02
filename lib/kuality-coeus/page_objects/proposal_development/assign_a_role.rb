class AssignARole < BasePage
  
  buttons 'Go back', 'Add Person'
  
  element(:pi_contact) { |b| b.frm.radio(id: 'PropDev-PersonnelPage-WizardPage3-personRoleRadio_control_0') }
  element(:pi_multiple) { |b| b.frm.radio(id: 'PropDev-PersonnelPage-WizardPage3-personRoleRadio_control_1') }
  element(:co_investigator) { |b| b.frm.radio(id: 'PropDev-PersonnelPage-WizardPage3-personRoleRadio_control_2') }
  element(:key_person) { |b| b.frm.radio(id: 'PropDev-PersonnelPage-WizardPage3-personRoleRadio_control_3') }
  
end