# frozen_string_literal: true

class CreateProfiles < ActiveRecord::Migration[7.1]
  def change
    create_table :profiles do |t|
      t.string :firstName
      t.string :lastName
      t.string :email
      t.string :password
      t.string :confirmPassword

      t.timestamps
    end
  end
end
