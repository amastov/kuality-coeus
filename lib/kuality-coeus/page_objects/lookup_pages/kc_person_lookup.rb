# coding: UTF-8
class KcPersonLookup < Lookups

  old_ui

  ID        = 1
  FULL_NAME = 2
  USER_NAME = 3

  expected_element :kcperson_id

  element(:kcperson_id) { |b| b.frm.text_field(name:'personId') }

  p_value(:user_name_of) { |name, b| b.results_table.rows.find{ |row| row[FULL_NAME].text==name }[USER_NAME].text }
  p_value(:person_id_of) { |name, b| b.results_table.rows.find{ |row| row[FULL_NAME].text==name }[ID].text }

  # Please note the 'space' in the .delete_if clause is NOT a space. It's some
  # unknown whitespace character. Don't screw with it or else this method will
  # stop working properly.
  value(:returned_full_names) { |b| b.noko.table(id: 'row').rows.collect{ |row| row[FULL_NAME].text }.tap(&:shift).delete_if{ |name| name==" " } }
  value(:returned_user_names) { |b| b.noko.table(id: 'row').rows.collect{ |row| row[USER_NAME].text }.tap(&:shift) }

end