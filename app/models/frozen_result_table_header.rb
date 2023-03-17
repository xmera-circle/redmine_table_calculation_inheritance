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

class FrozenResultTableHeader
  include RedmineTableCalculation::CalculationUtils
  include Redmine::I18n
  include Enumerable

  attr_reader :default_columns, :table_config

  delegate :size, to: :columns

  # @param default_columns [Array(String)] Non-customizable attributes of SpreadsheetRowResult.
  # @param table_config [TableConfig] Table configuration of the underlying Spreadsheet.
  def initialize(**attrs)
    @default_columns = attrs[:default_columns]
    @table_config = attrs[:table_config]
  end

  # @return [Array(FrozenResultTableCell|SpareTableCell)] A list of cell objects each representing
  #                                                       a table column.
  def columns
    result_header_columns = result_header
    offset = result_header_columns.size
    [result_header_columns, default_header(offset)].flatten
  end

  # Customizable columns of the underlying table and calculation configuration.
  def result_header
    ResultTableHeader.new(data_table_header: data_table_header,
                          calculation_columns: calculation_columns).columns
  end

  # Non-customizable attributes of SpreadsheetRowResult each with its position
  # in the table header.
  def default_header(offset)
    default_columns.each_with_index.map do |column, index|
      SpareTableCell.new(position: offset + index, column_index: offset + index, name: column)
    end
  end

  # Allows to iterate through FrozenResultTableCell or SpareTableCell instances
  def each(&block)
    columns.each(&block)
  end

  private

  delegate :calculation_configs, to: :table_config, allow_nil: true

  # Data table columns sorted by its position
  def data_table_header
    table_config.columns.sort_by(&:position)
  end
end
