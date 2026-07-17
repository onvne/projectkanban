class TasksController < ApplicationController
  before_action :set_project, only: [ :new, :create ]
  before_action :set_task, only: [ :move_forward, :move_backward, :edit, :update, :destroy ]

  def new
    @task = @project.tasks.build(status: params[:status] || :todo)
  end
  def index
    if params[:project_id]
      # Если передан project_id — мы на доске конкретного проекта
      @project = current_user.projects.find(params[:project_id])
      @tasks = @project.tasks
      @board_title = @project.title
    else
      # Если id нет — мы на общей доске "All Projects"
      @project = nil
      @tasks = Task.where(project_id: @projects.pluck(:id))
      @board_title = "All Projects"
    end


  @tasks_by_status = @tasks.group_by(&:status)
  @columns = [
      { status: "todo", title: "To Do" },
      { status: "in_progress", title: "In Progress" },
      { status: "in_testing", title: "Review" }, # По твоему скриншоту третья колонка называется Review
      { status: "rejected", title: "Rejected" },  # Добавляем колонку для rejected-тасок
      { status: "done", title: "Done" }
  ]
  end
  def move_forward
    if @task.move_forward!
      # Редиректим назад. Так как вьюха в Turbo Frame, обновится только сама доска!
      redirect_back fallback_location: root_path, notice: "Task updated."
    else
      redirect_back fallback_location: root_path, alert: "Transition not allowed."
    end
  end

  # Движение задачи назад по цепочке статусов
  def move_backward
    if @task.move_backward!
      redirect_back fallback_location: root_path, notice: "Task updated."
    else
      redirect_back fallback_location: root_path, alert: "Transition not allowed."
    end
  end
  def create
  @task = @project.tasks.new(task_params)

  if @task.save
    respond_to do |format|
      format.html { redirect_to root_path(project_id: @project.id), notice: "Задача создана" } # [cite: 5]
      format.turbo_stream
    end
  else
    render :new, status: :unprocessable_entity # [cite: 5]
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
      # Turbo Stream мгновенно сотрет карточку из колонки
      format.turbo_stream
    end
  end

  private

  def set_project
    @project = current_user.projects.find(params[:project_id])
  end

  def set_task
  # Находим задачу через проекты текущего пользователя, используя params[:id]
  @task = Task.where(project_id: current_user.project_ids).find_by(id: params[:id])

  # Если задача не найдена (например, принадлежит чужому пользователю), предотвращаем падение с nil
  if @task.nil?
    redirect_back fallback_location: root_path, alert: "Task not found or access denied."
  end
  end
  def task_params
    params.require(:task).permit(:title, :description, :status)
  end
end
