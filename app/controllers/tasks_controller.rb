class TasksController < ApplicationController
  BOARD_COLUMNS = [
    { status: "todo", title: "To Do" },
    { status: "in_progress", title: "In Progress" },
    { status: "in_testing", title: "Review" },
    { status: "rejected", title: "Rejected" },
    { status: "done", title: "Done" }
  ].freeze

  before_action :set_project, only: [ :new, :create ]
  before_action :set_task, only: [ :move_forward, :move_backward, :edit, :update, :destroy ]

  def index
    if params[:project_id]
      @project = current_user.projects.find(params[:project_id])
      @tasks = @project.tasks
      @board_title = @project.title
    else
      @project = nil
      @tasks = Task.where(project_id: @projects.pluck(:id))
      @board_title = "All Projects"
    end

    @tasks_by_status = @tasks.group_by(&:status)
    @columns = BOARD_COLUMNS
  end

  def move_forward
    move_task(:move_forward!)
  end

  def move_backward
    move_task(:move_backward!)
  end

  def create
    @task = @project.tasks.new(task_params)

    if @task.save
      respond_to do |format|
        format.html { redirect_to root_path(project_id: @project.id), notice: "Задача создана" }
        format.turbo_stream
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @task.update(task_params)
      respond_to do |format|
        format.html { redirect_to root_path, notice: "Задача обновлена!" }
        format.turbo_stream
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to root_path, notice: "Задача удалена!" }
      format.turbo_stream
    end
  end

  private

  def move_task(method)
    if @task.public_send(method)
      redirect_back fallback_location: root_path, notice: "Task updated."
    else
      redirect_back fallback_location: root_path, alert: "Transition not allowed."
    end
  end

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_task
    @task = Task.where(project_id: current_user.project_ids).find_by(id: params[:id])

    return if @task

    redirect_back fallback_location: root_path, alert: "Task not found or access denied."
  end

  def task_params
    params.require(:task).permit(:title, :description, :status)
  end
end
