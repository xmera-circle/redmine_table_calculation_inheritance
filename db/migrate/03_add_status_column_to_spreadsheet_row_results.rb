# frozen_string_literal: true

# This file is part of the Plugin Redmine Table spreadsheet.
#
# Copyright (C) 2023 Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class AddStatusColumnToSpreadsheetRowResults < ActiveRecord::Migration[5.2]
  def self.up
    add_column :spreadsheet_row_results, :status, :integer, default: 1
    add_index :spreadsheet_row_results, %i[spreadsheet_id calculation_config_id status],
              name: 'row_results_by_spreadsheet_calculation_and_status'
  end

  def self.down
    remove_column :spreadsheet_row_results, :status if table_exists?(:spreadsheet_row_results)
  end
end
