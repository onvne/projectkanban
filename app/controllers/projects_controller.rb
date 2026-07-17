class ProjectsController < ApplicationController
  before_action :set_project, only: [ :edit, :update, :destroy ]

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
    title = @project.title
    @project.destroy
    redirect_to root_path, notice: "Project '#{title}' was deleted."
  end

  private

  def set_project
    @project = current_user.projects.find(params[:id])
  end

  def project_params
    params.require(:project).permit(:title, :description)
  end
end
