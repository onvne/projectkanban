class Task < ApplicationRecord
  belongs_to :project
  enum :status, { todo: "todo", in_progress: "in_progress", done: "done" }, default: :todo
end
