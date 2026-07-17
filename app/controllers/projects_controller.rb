# app/controllers/projects_controller.rb
class ProjectsController < ApplicationController
  before_action :authenticate_user!
  # Мы удалили before_action :set_projects, так как метод теперь в родительском классе!

  def index
  end

  def new
    @project = current_user.projects.build
  end

  def create
    @project = current_user.projects.build(project_params)
    if @project.save
      redirect_to root_path, notice: "Project '#{@project.title}' was successfully created."
    else
      redirect_to root_path, alert: "Failed to create project: #{@project.errors.full_messages.join(', ')}"
    end
  end

  def edit
  end

  def update
  end

  def destroy
  end

  private

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
