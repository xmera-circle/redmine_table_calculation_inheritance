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
                     project: project,
                     spreadsheet: spreadsheet }
  end

  def render_grouped_results_table(query, spreadsheet, data_table)
    render partial: 'spreadsheets/grouped_results',
           locals: { table: GroupedResultsTable.new(query: query,
                                                    spreadsheet: spreadsheet,
                                                    data_table: data_table) }
  end

  # @see InheritanceSpreadsheetsHelper#new_or_edit_spreadsheet_row_result_path
  def inherit_calculated_results(**params)
    link_to l(:label_inherit),
            new_or_edit_spreadheet_row_result_path(**params),
            class: 'icon icon-checked',
            title: l(:label_inherit)
  end

  # @param result_row [InheritanceSpreadsheetsHelper#result_row_of]
  # @param spreadsheet_row_result [InheritanceSpreadsheetsHelper#spreadsheet_row_result_params]
  #
  def new_or_edit_spreadheet_row_result_path(**params)
    result_row = params[:result_row]
    spreadsheet_row_result = params[:spreadsheet_row_result]

    if result_row
      edit_spreadsheet_row_result_path(id: result_row.id,
                                       spreadsheet_row_result: spreadsheet_row_result)
    else
      new_project_spreadsheet_spreadsheet_row_result_path(
        spreadsheet_row_result: spreadsheet_row_result
      )
    end
  end

  # @param row [AggregatedDataTableRow#cells] A row of an AggregatedDataTable
  #                                           instance.
  # @param spreadsheet_row_result [InheritanceSpreadsheetsHelper#spreadsheet_row_result_params]
  #
  def result_row_of(row, spreadsheet_result_rows)
    spreadsheet_result_rows.find_by(calculation_config_id: calculation_config_id(row))
  end

  # @param row [AggregatedDataTableRow#cells] A row of an AggregatedDataTable
  #                                           instance.
  # @param spreadsheet_id [Integer] The id of the underlying spreadsheet.
  #
  def spreadsheet_row_result_params(row, spreadsheet_id)
    { custom_field_values: custom_field_values_of(row),
      calculation_config_id: calculation_config_id(row),
      spreadsheet_id: spreadsheet_id }
  end

  # Prepares custom field values as key/value-pair to be submittable as
  # params:
  # @example { "custom_field.id" => "value" }
  #
  # @param row [AggregatedDataTableRow#cells] A row of an AggregatedDataTable
  #                                           instance.
  #
  def custom_field_values_of(row)
    row.each_with_object({}) do |cell, hash|
      if cell.custom_field
        hash[cell.custom_field.id.to_s] = cell.value
        hash
      end
    end
  end

  # Derives the calculation config id from a given row.
  #
  # @param row [AggregatedDataTableRow#cells] A row of an AggregatedDataTable
  #                                           instance.
  def calculation_config_id(row)
    row.last.send(:row_index)
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
