class AddTypeToReport < ActiveRecord::Migration[7.1]
  def change
    add_column :reports, :report_type, :integer
  end
end
