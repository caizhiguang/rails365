class AddVisitCountToSofts < ActiveRecord::Migration
  def change
    add_column :softs, :visit_count, :integer, default: 0
  end
end
