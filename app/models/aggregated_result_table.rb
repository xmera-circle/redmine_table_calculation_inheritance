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

class AggregatedResultTable
  include RedmineTableCalculation::CalculationUtils

  attr_reader :projects, :spreadsheet, :spreadsheet_row_results, :table_config, :calculation_configs

  def initialize(**attrs)
    @projects = attrs[:projects]
    @spreadsheet = attrs[:spreadsheet]
    @spreadsheet_row_results = SpreadsheetRowResult.includes(:calculation_config, spreadsheet: [:project])
    @table_config = spreadsheet.table_config
    @calculation_configs = table_config.calculation_configs
  end

  def header
    AggregatedResultTableHeader.new(calculation_columns: calculation_columns,
                                    table_columns: table_columns).columns
  end

  def rows
    calculation_configs&.map do |calculation|
      result_row(calculation).calculate
    end
  end

  private

  def result_row(calculation_config)
    AggregatedResultTableRow.new(columns: columns(calculation_config),
                                 calculation_config: calculation_config,
                                 size: header.count + 1) # + updated_on
  end

  def columns(calculation_config)
    transpose_result_rows(calculation_config).map do |column|
      FrozenResultTablesColumn.new(column: column, calclation_config: calculation_config)
    end
  end

  # rubocop:disable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength
  def transpose_result_rows(calculation_config)
    results = frozen_row_results(calculation_config)
    return [] unless results.presence

    resolved_result_rows = results.map(&:custom_field_values).map do |custom_field_values|
      custom_field_values.map do |custom_field_value|
        FrozenResultTableCell.new(custom_field_value: custom_field_value)
      end
    end
    offset = resolved_result_rows.map(&:count).uniq[0]
    resolved_default_rows = results.map(&:attributes).map do |attributes|
      [DefaultColumnCell.new(name: :status,
                             value: attributes['status'],
                             column_index: offset + 1,
                             row_index: attributes['calculation_config_id']),
       DefaultColumnCell.new(name: :updated_on,
                             value: attributes['updated_on'],
                             column_index: offset + 1,
                             row_index: attributes['calculation_config_id'])]
    end
    resolved_result_rows.transpose | resolved_default_rows.transpose
  end
  # rubocop:enable Metrics/AbcSize, Metrics/CyclomaticComplexity, Metrics/MethodLength

  # Query all SpreadsheetRowResult records for a given calculation and with spreadsheets
  # of the given objects.
  #
  # @note As long as the spreadsheet name is unique for each object there will
  #       be no more than one spreadsheet for each object. This assumes also
  #       that there are no typos in a certain spreadsheet name.
  #
  # @return [ActiveRecord::Relation(SpreadsheetRowResult)]
  def frozen_row_results(calculation_config)
    spreadsheet_row_results
      .where(calculation_config_id: calculation_config.id)
      .where(spreadsheet: { project_id: projects.map(&:id), name: spreadsheet.name })
  end
end
