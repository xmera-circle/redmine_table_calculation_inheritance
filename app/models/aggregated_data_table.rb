# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation.
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

class AggregatedDataTable < DataTable
  include RedmineTableCalculation::CalculationUtils

  attr_reader :query, :calculation_configs, :spreadsheet_result_rows

  def initialize(**attrs)
    super(**attrs)
    @query = attrs[:query]
    @calculation_configs = attrs[:calculation_configs] || table_config.calculation_configs
    @spreadsheet_result_rows = attrs[:spreadsheet_result_rows] || @query.spreadsheet_row_results
  end

  def header
    calculation_columns
  end

  def columns
    transpose_rows.map do |column|
      DataTableColumn.new(column: column, table_config: table_config)
    end
  end

  def rows
    data_table_rows = host_result_rows
    data_table_rows << guests_result_rows
    data_table_rows.flatten.compact
  end

  private

  def guests_result_rows
    return unless spreadsheet_result_rows.presence

    spreadsheet_result_rows.map do |row|
      AggregatedDataTableRow.new(row: row, calculation_configs: calculation_configs)
    end
  end

  def host_result_rows
    host_rows.map do |row|
      AggregatedDataTableRow.new(row: row, calculation_configs: calculation_configs)
    end
  end

  def host_rows
    spreadsheet.result_rows.presence || spreadsheet_rows
  end
end
