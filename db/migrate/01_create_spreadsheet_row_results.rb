# frozen_string_literal: true

# This file is part of the Plugin Redmine Table spreadsheet.
#
# Copyright (C) 2020-2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
#
# This plugin program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301, USA.

class CreateSpreadsheetRowResults < ActiveRecord::Migration[4.2]
  def self.up
    return if table_exists?(:spreadsheet_row_results)

    create_table :spreadsheet_row_results do |t|
      t.integer :author_id, default: 0, null: false
      t.integer :spreadsheet_id, default: 0, null: false
      t.integer :calculation_id, default: 0, null: false
      t.text :comment
      t.timestamp :created_on
      t.timestamp :updated_on
    end

    add_index :spreadsheet_row_results, %i[spreadsheet_id], name: 'row_results_by_spreadsheet'
    add_index :spreadsheet_row_results, %i[spreadsheet_id calculation_id],
              name: 'row_results_by_spreadsheet_and_calculation'
  end

  def self.down
    drop_table :spreadsheet_row_results if table_exists?(:spreadsheet_row_results)
  end
end
