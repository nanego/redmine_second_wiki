require_dependency 'wikis_controller'

class DocumentationsController < WikisController

  # Delete a project's documentation
  def destroy
    if request.post? && params[:confirm] && @project.documentation
      @project.documentation.destroy
      redirect_to project_path(@project, :tab => 'documentation')
    end
  end

end
