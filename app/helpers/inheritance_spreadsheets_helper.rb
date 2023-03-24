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

module InheritanceSpreadsheetsHelper
  def render_frozen_result_table(project, spreadsheet)
    render partial: 'spreadsheets/frozen_results',
           locals: { table: FrozenResultTable.new(spreadsheet: spreadsheet),
                     project: project }
  end

  def render_aggregated_result_table(query, spreadsheet_result_rows, project, spreadsheet)
    aggregated_data_table = AggregatedDataTable.new(spreadsheet: spreadsheet, query: query)
    render partial: 'spreadsheets/aggregated_results',
           locals: { table: ResultTable.new(data_table: aggregated_data_table),
                     spreadsheet_result_rows: spreadsheet_result_rows,
                     project: project }
  end

  def render_grouped_results_table(query, spreadsheet, data_table)
    render partial: 'spreadsheets/grouped_results',
           locals: { table: GroupedResultsTable.new(query: query,
                                                    spreadsheet: spreadsheet,
                                                    data_table: data_table) }
  end

  # The edit button should only be shown when the table is integrated into
  # a view where the user should be able to edit the spreadsheet row results.
  def editable?
    %w[spreadsheets].include?(controller_name) && %w[results].include?(action_name)
  end

  def calculations_of(spreadsheet)
    spreadsheet.table_config.calculation_configs
  end
end
