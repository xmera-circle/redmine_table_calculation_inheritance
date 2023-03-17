# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021-2023  Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class FrozenResultTable
  include RedmineTableCalculation::CalculationUtils
  include Redmine::I18n

  attr_reader :spreadsheet, :table_config, :spreadsheet_result_rows, :calculation_configs

  def initialize(**attrs)
    @spreadsheet = attrs[:spreadsheet]
    @table_config = spreadsheet.table_config
    @spreadsheet_result_rows = spreadsheet.result_rows
    @calculation_configs = table_config.calculation_configs
  end

  # The header of a frozen result table having empty columns where no result is
  # required and a first column header for the calculation name.
  def header
    frozen_result_table_header.columns
  end

  # Result rows, one for each calculation.
  def rows
    calculation_configs.map do |config|
      row = spreadsheet_result_row_by(calculation_config_id: config.id)
      FrozenResultTableRow.new(result_header: frozen_result_table_header.result_header,
                               calculation_config: config,
                               row: row)
    end
  end

  def frozen_result_table_header
    FrozenResultTableHeader.new(default_columns: default_columns,
                                table_config: table_config)
  end

  private

  # @returns [SpreadsheetRowResult|nil]
  def spreadsheet_result_row_by(**attrs)
    row = spreadsheet_result_rows.find_by(calculation_config_id: attrs[:calculation_config_id])
    row.presence
  end

  def default_columns
    [l(:label_row_result_comment), l(:label_row_result_status), l(:label_row_result_last_editing)]
  end
end
