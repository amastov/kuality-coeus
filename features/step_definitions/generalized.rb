And /saves the document$/ do
  $current_page.save
end

And /closes the document$/ do
  $current_page.close
  on(Confirmation).yes
end