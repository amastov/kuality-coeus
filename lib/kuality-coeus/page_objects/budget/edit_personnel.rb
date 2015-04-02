class EditPersonnel < BasePage
  
  buttons 'Save Changes'
  
  element(:job_code) { |b| b.text_field(name: 'addProjectPersonnelHelper.editBudgetPerson.jobCode') }
  element(:appointment_type) { |b| b.select(name: 'addProjectPersonnelHelper.editBudgetPerson.appointmentTypeCode') }
  element(:salary_effective_date) { |b| b.text_field(name: 'addProjectPersonnelHelper.editBudgetPerson.effectiveDate') }
  element(:salary_anniversary_date) { |b| b.text_field(name: 'addProjectPersonnelHelper.editBudgetPerson.salaryAnniversaryDate') }
  element(:base_salary) { |b| b.text_field(name: 'addProjectPersonnelHelper.editBudgetPerson.calculationBase') }
  
end