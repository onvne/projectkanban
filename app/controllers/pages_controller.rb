class PagesController < ApplicationController
  before_action :authenticate_user!

  def home
    @projects = current_user.projects.order(:name)
    @selected_project = @projects.find_by(id: params[:project_id]) if params[:project_id].present?
    @tasks = @selected_project ? @selected_project.tasks : current_user.tasks
  end
end
