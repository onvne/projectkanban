require "test_helper"

class TaskTest < ActiveSupport::TestCase
  test "requires title" do
    task = Task.new(project: projects(:one), status: :todo)
    assert_not task.valid?
    assert_includes task.errors[:title], "can't be blank"
  end

  test "move_forward advances allowed status" do
    task = tasks(:one)
    assert task.move_forward!
    assert_equal "in_progress", task.status
  end

  test "move_backward returns to previous status" do
    task = tasks(:two)
    assert task.move_backward!
    assert_equal "todo", task.status
  end

  test "cannot move forward from done" do
    task = tasks(:one)
    task.update_columns(status: "done")

    assert_not task.can_move_forward?
    assert_not task.move_forward!
  end

  test "rejects invalid status transition" do
    task = tasks(:one)

    assert_not task.update(status: :done)
    assert_includes task.errors[:status].first, "cannot change from 'todo' to 'done'"
  end

  test "allowed_transitions_for_select formats options" do
    task = tasks(:two)

    assert_equal [ [ "In Testing", "in_testing" ], [ "Todo", "todo" ] ], task.allowed_transitions_for_select
  end
end
