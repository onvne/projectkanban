require "test_helper"

class TasksControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one)
    @project = projects(:one)
    @task = tasks(:one)
    sign_in @user
  end

  test "should get index for all projects" do
    get root_url
    assert_response :success
    assert_select "h1.board-title", "All Projects"
  end

  test "should get index for single project" do
    get project_tasks_url(@project)
    assert_response :success
    assert_select "h1.board-title", @project.title
    assert_select "button.btn-delete-project", text: /Delete Project/
  end

  test "should not show delete project button on all projects board" do
    get root_url
    assert_response :success
    assert_select "button.btn-delete-project", count: 0
  end

  test "should create task" do
    assert_difference -> { @project.tasks.count }, 1 do
      post project_tasks_url(@project), params: {
        task: { title: "New task", description: "Details", status: "todo" }
      }
    end

    assert_redirected_to root_path(project_id: @project.id)
  end

  test "should update task" do
    patch task_url(@task), params: {
      task: { title: "Updated title", description: "Updated", status: "in_progress" }
    }

    assert_redirected_to root_path
    @task.reload
    assert_equal "Updated title", @task.title
    assert_equal "in_progress", @task.status
  end

  test "should destroy task" do
    assert_difference -> { Task.count }, -1 do
      delete task_url(@task)
    end

    assert_redirected_to root_path
  end

  test "should move task forward" do
    patch move_forward_task_url(@task)

    assert_redirected_to root_path
    assert_equal "in_progress", @task.reload.status
  end

  test "should move task backward" do
    task = tasks(:two)

    patch move_backward_task_url(task)

    assert_redirected_to root_path
    assert_equal "todo", task.reload.status
  end

  test "should not access another users task" do
    other_task = tasks(:three)

    delete task_url(other_task)
    assert_redirected_to root_path
    assert_equal "Task not found or access denied.", flash[:alert]
  end

  test "requires authentication" do
    sign_out @user

    get root_url
    assert_redirected_to new_user_session_path
  end
end
