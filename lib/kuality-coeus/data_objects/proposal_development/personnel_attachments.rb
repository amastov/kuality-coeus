class PersonnelAttachmentObject < DataFactory

  include StringFactory, Utilities

  attr_reader :person, :type, :file_name, :description, :document_id, :doc_type

  def initialize(browser, opts={})
    @browser = browser
    defaults = {
        person:      '::random::',
        type:        '::random::',
        description: random_alphanums_plus(30)
    }
    set_options defaults.merge(opts)
    requires :file_name, :navigate
  end

  def create
    view
    on AbstractsAndAttachments do |attach|
      attach.expand_all
      fill_out attach, :person
      attach.personnel_attachment_description.fit @description
      attach.personnel_attachment_type.fit @type
      attach.personnel_attachment_file_name.set($file_folder+@file_name)
      attach.add_personnel_attachment
    end
  end

  def view
    @navigate.call
    on(Proposal).abstracts_and_attachments unless on_page?(on(AbstractsAndAttachments).proposal_attachment_type)
  end

  def update_from_parent(navigation_lambda)
    @navigate=navigation_lambda
  end

end

class PersonnelAttachmentsCollection < CollectionsFactory

  contains PersonnelAttachmentObject

end