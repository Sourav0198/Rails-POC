# frozen_string_literal: true

class AddPasswordHistoryToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :password_history, :text

    # attribute :my_int_array, :integer, array: true
    # add_column :your_table, :my_int_array, :integer, array: true, default: [
  end
end
