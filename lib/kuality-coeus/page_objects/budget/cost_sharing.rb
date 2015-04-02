class CostSharing < BasePage

  document_buttons

  element(:add_cost_sharing) { |b| b.button(text: 'Add Cost Sharing').click; b.span(text: 'Add Line').wait_until_present }

  p_value(:row_amount) { |row, b| b.cs_rows[row.to_i-1].text_field(name: /shareAmount/).value }

  p_element(:period) { |source, amount, b| b.target_item(source, amount).select(name: /projectPeriod/) }
  p_element(:percentage) { |source, amount, b| b.target_item(source, amount).text_field(name: /sharePercentage/) }
  p_element(:source_account) { |source, amount, b| b.target_item(source, amount).text_field(name: /sourceAccount/) }
  p_element(:amount) { |source, amount, b| b.target_item(source, amount).text_field(name: /shareAmount/) }

  private

  element(:cs_rows) { |b| b.section(id: 'PropBudget-CostSharingPage-CollectionGroup').table.tbody.rows }
  p_element(:target_item) { |source, amount, b|
    row = b.cs_rows.find { |row|
      row.text_field(name: /sourceAccount/).value==source &&
          row.text_field(name: /shareAmount/).value==amount
    }
    raise "No row exists matching provided source and amount ('#{source}', '#{amount}')" if row.nil?
    row
  }

end