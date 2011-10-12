class AddFieldsToProjects < ActiveRecord::Migration
  def self.up
    add_column :projects, :bundle_install, :boolean, :default => true
    add_column :projects, :continuous_deployment, :boolean, :default => false
  end

  def self.down
    remove_column :projects, :bundle_install
    remove_column :projects, :continuous_deployment
  end
end
