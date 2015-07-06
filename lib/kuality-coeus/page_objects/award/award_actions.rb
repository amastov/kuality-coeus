class AwardActions < KCAwards

  route_log
  validation_elements

  # Hierarchy Actions
  action(:expand_tree) { |b| b.frm.link(title: 'Expand the entire tree below').click }
  action(:show_award_details_panel) { |number, b| b.frm.link(class: 'awardHierarchy', text: /#{number}/).click }

  p_action(:award_div) { |award, b| b.frm.div(id: "details#{award}") }
  p_action(:copy_descendents) { |award, b| b.award_div(award).checkbox(id: /copyDescendants/) }
  p_action(:copy_as_new) { |award, b| b.award_div(award).radio(name: /copyAwardRadio/, value: 'a').set }
  p_action(:copy_as_child_of) { |award, b| b.award_div(award).radio(name: /copyAwardRadio/, value: 'd').set }
  p_action(:child_of_target_award) { |award, b| b.award_div(award).select(name: /copyAwardPanelTargetAward/) }
  p_action(:copy_award) { |award, b| b.award_div(award).button(title: 'Copy').click; b.loading }
  p_action(:based_on_new) { |award, b| b.award_div(award).radio(value: 'a', name: /createNewChildRadio/).set }
  p_action(:based_on_parent) { |award, b| b.award_div(award).radio(value: 'b', name: /createNewChildRadio/).set }
  p_action(:based_on_award) { |award, b| b.award_div(award).radio(value: 'c', name: /createNewChildRadio/).set }
  p_action(:based_on_target_award) { |award, b| b.award_div(award).select(name: /newChildPanelTargetAward/) }
  p_action(:create_new_child) { |award, b| b.award_div(award).button(title: 'Create').click; b.loading }

  # This creates an array that contains the ids of the descendants of the specified Award...
  action(:descendants) { |award, b|
    b.frm.li(id: "li#{award}").lis.map { |li| li.id[/\d+-\d+/] }
  }

  element(:award_hierarchy_link) { |b| b.frm.link(class: 'awardHierarchy') }

  undefine :notification
  value(:notification) { |b| b.noko.div(class: 'msg-excol').div(class: 'kul-error').text }

end