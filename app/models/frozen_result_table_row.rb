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

class FrozenResultTableRow
  include Redmine::I18n
  include Enumerable
  attr_reader :result_header, :row, :calculation_config, :spreadsheet

  delegate :id, :author, :visible?, to: :row, allow_nil: true

  # @param result_header [FrozenResultTableHeader#result_header] ResultTableHeader columns.
  # @param row [SpreadsheetRowResult] The SpreadsheetRowResult object.
  # @param calculation_config [CalculationConfig] The rows calculation config object (optional).
  def initialize(**attrs)
    @result_header = attrs[:result_header]
    @row = attrs[:row]
    @calculation_config = attrs[:calculation_config]
    @spreadsheet = attrs[:spreadsheet]
  end

  # All cells (empty or not) for the underlying calculation:
  #
  # result_cells may contain SpareTableCell instances as placeholder for
  # non required cells in dependence of the calculation config.
  #
  # default_cells refer to cells which are independent of the calculation
  # config.
  #
  def cells
    results = result_cells
    offset = results.size
    results = build_cells(results, offset)
    results.flatten!
    results.prepend(SpareTableCell.new(value: calculation_config&.name,
                                       column_index: 0,
                                       row_index: calculation_config_id))
  end

  # Controller params for preparing a new SpreadsheetRowResult record
  def result_params
    { spreadsheet_id: spreadsheet.id,
      calculation_config_id: calculation_config_id,
      cfv: {} }
  end

  # Allows to iterate through FrozenResultTableCell instances
  def each(&block)
    cells.each(&block)
  end

  private

  delegate :id, to: :calculation_config, prefix: true, allow_nil: true
  delegate :size, to: :result_header, prefix: true

  # Fills the gaps between result columns and columns of the stored result.
  def result_cells
    return [] unless row
    return stored_result_cells if result_column_gaps.none?

    result_column_gaps.each do |position|
      next if position.zero?

      cell = SpareTableCell.new(value: nil, column_index: position, row_index: calculation_config_id)
      @stored_result_cells << cell
    end
    @stored_result_cells.sort_by(&:column_index)
  end

  # Stored result of table fields or calculated row of ResultTable if any
  def stored_result_cells
    return [] unless row

    @stored_result_cells ||= row.custom_field_values.map do |custom_field_value|
      custom_field = custom_field_value.custom_field
      if result_column_names.include? custom_field.name
        FrozenResultTableCell.new(custom_field_value: custom_field_value)
      else
        SpareTableCell.new(value: nil, column_index: custom_field.position, row_index: calculation_config_id)
      end
    end
  end

  def result_column_gaps
    result_column_positions - stored_result_cell_positions
  end

  def stored_result_cell_positions
    stored_result_cells.map(&:column_index)
  end

  # Builds cells consisting of result cells or empty cells and default cells.
  def build_cells(results, offset)
    if offset.zero?
      results.append(empty_cells(result_header_size))
      results.append(default_cells(result_header_size))
    else
      results.append(default_cells(offset))
    end
    results
  end

  # Empty cells as placeholders for table field values not yet stored
  def empty_cells(count)
    (1..(count - 1)).map do |index|
      SpareTableCell.new(value: nil, column_index: index, row_index: calculation_config_id)
    end
  end

  # SpreadsheetRowResult default attributes which should be always rendered
  def default_cells(offset)
    %w[comment status updated_on].each_with_index.map do |attr, index|
      SpareTableCell.new(name: attr,
                         value: row&.send(attr) || send(attr),
                         column_index: offset + index + 1,
                         row_index: calculation_config_id)
    end
  end

  def result_column_names
    return [] unless result_header

    result_header.map(&:name)
  end

  def result_column_positions
    return [] unless result_header

    result_header.map(&:position)
  end

  def comment
    nil
  end

  def status
    l(:label_row_result_status_unfrozen)
  end

  def updated_on
    nil
  end
end
