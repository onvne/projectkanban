class RenameNameToTitleInProjects < ActiveRecord::Migration[8.1]
  def change
     rename_column :projects, :name, :title
  end
end
