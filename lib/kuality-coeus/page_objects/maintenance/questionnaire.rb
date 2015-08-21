class Questionnaire < BasePage

  description_field
  tab_buttons
  global_buttons

  # Returns an array containing the text of all the questions...
  value(:questions) { |b| b.noko_question_table.links(id: /listcontrol\d+/).map{ |l| l.text } }

  value(:noko_question_table) { |b| b.noko.table(id: 'question-table') }
  element(:question_table) { |b| b.frm.table(id: 'question-table') }

  action(:add_question) { |b| b.frm.button(name: 'rootSearch').click; b.use_new_tab }
  p_action(:remove_question) { |question, b| b.frm.
      link(id: "remove#{b.noko_question_table.link(text: question).name[/\d+$/]}" ).
      click }
  p_action(:update_version) { |question, b| b.frm.
      link(id: "update#{b.noko_question_table.link(text: question).name[/\d+$/]}" ).
      click }

  p_action(:expand_question) { |question, b| b.frm.link(text: question).click }
  alias_method :collapse_question, :expand_question

end