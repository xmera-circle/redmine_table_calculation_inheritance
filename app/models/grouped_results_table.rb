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

# Prepares SpreadsheetRowResult records of guest projects to be displayed
# in a single table grouped by each guest project.
# The host project shows the results of the underlying spreadsheet if it has
# SpreadsheetRow records. Otherwise, the host project rows are empty.
#
class GroupedResultsTable
  include RedmineTableCalculationInheritance::DefaultColumns
  include RedmineTableCalculation::CalculationUtils
  include Redmine::I18n

  attr_reader :calculation_configs

  # @param query [SpreadsheetQuery] SpreadsheetQuery instance.
  # @param spreadsheet [Spreadsheet] Spreadsheet instance of the current (host-) project.
  #
  def initialize(**attrs)
    @query = attrs[:query]
    @spreadsheet = attrs[:spreadsheet]
    @table_config = spreadsheet.table_config
    @calculation_configs = table_config.calculation_configs
  end

  # The number of header columns.
  def column_count
    header.count
  end

  # Header columns consisting of result and default columns sorted by
  # their position.
  def header
    FrozenResultTableHeader.new(default_columns: default_columns,
                                table_config: table_config).columns
  end

  # Makes sure that the host project is the first one in the list
  def projects
    rows.keys.reverse
  end

  # Retrieves all rows, one for each calcuation, of a given project.
  def rows_of(project)
    rows[project][:rows]
  end

  # Retrieves the spreadsheet of a given project.
  def spreadsheet_of(project)
    rows[project][:spreadsheet]
  end

  # Wrapps SpreadsheetRowResult instances with a FrozenResultTableRow for
  # all relevant projects (host and guests).
  def rows
    grouped_rows = prepare_guest_result_rows
    @rows ||= add_host_result_rows(grouped_rows)
  end

  private

  attr_reader :query, :spreadsheet, :table_config, :result_table

  delegate :host_project, :guest_spreadsheets_grouped_by_project, to: :query

  def frozen_result_table_header
    FrozenResultTableHeader.new(default_columns: default_columns,
                                table_config: table_config)
  end

  def prepare_guest_result_rows
    guest_spreadsheets_grouped_by_project.each_with_object({}) do |(project, datasheet), hash|
      datasheet = datasheet[0]
      hash[project] = {}
      hash[project][:rows] = FrozenResultTable.new(spreadsheet: datasheet,
                                                   result_rows: datasheet.result_rows).rows
      hash[project][:spreadsheet] = datasheet
      hash
    end
  end

  def add_host_result_rows(grouped_rows)
    grouped_rows[host_project] = {}
    grouped_rows[host_project][:rows] = host_rows
    grouped_rows[host_project][:spreadsheet] = spreadsheet
    grouped_rows
  end

  # Host data are always calculated from spreadsheet
  def host_rows
    CalculatedResultTable.new(spreadsheet: spreadsheet).rows
  end
end
