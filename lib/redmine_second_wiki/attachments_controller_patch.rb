require_dependency 'attachments_controller'

class AttachmentsController

  prepend_before_action :set_attachable_options_for_documentation, only: [:show, :download, :thumbnail, :update, :destroy]

  def set_attachable_options_for_documentation
    @attachment = Attachment.find(params[:id])
    container = @attachment.container
    if container.is_a?(WikiPage)
      if container.documentation_page?
        container.class.attachable_options[:view_permission] = "view_documentation_pages".to_sym
        container.class.attachable_options[:edit_permission] = "edit_documentation_pages".to_sym
        container.class.attachable_options[:delete_permission] = "edit_documentation_pages".to_sym
      else
        container.class.attachable_options[:view_permission] = "view_wiki_pages".to_sym
        container.class.attachable_options[:edit_permission] = "edit_wiki_pages".to_sym
        container.class.attachable_options[:delete_permission] = "delete_wiki_pages_attachments".to_sym
      end
    end
  rescue ActiveRecord::RecordNotFound
    render_404
  end

end
