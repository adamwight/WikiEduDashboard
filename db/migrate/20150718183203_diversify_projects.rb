class DiversifyProjects < ActiveRecord::Migration
  def change
    # TODO:
    # * What is the best practice for storing this reference data?  The
    # interwiki table has hardcoded language subdomains, so: not that.
    #
    # * Populate with default reference data.
    #
    # * Default existing data to enwiki.

    create_table :wiki_projects do |t|
      t.column :domain, :string, {limit: 64}
      t.column :article_path, :string, {limit: 255}
      t.column :script_path, :string, {limit: 255}
      t.column :has_language_subdomains, :boolean
    end

    add_column :articles, :wiki_project_id, :integer
    add_column :courses, :wiki_project_id, :integer
    add_column :users, :wiki_project_id, :integer

    add_column :articles, :language, :string, {limit: 16}
    add_column :courses, :language, :string, {limit: 16}
    add_column :users, :language, :string, {limit: 16}
  end
end
