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
  include Enumerable
  attr_reader :result_header, :row, :calculation_config

  # @param result_header [FrozenResultTableHeader#result_header] ResultTableHeader columns.
  # @param row [SpreadsheetRowResult] The SpreadsheetRowResult object.
  # @param calculation_config [CalculationConfig] The rows calculation config object (optional).
  def initialize(**attrs)
    @result_header = attrs[:result_header]
    @row = attrs[:row]
    @calculation_config = attrs[:calculation_config] || row&.calculation_config
  end

  # All cells (empty or not) for the underlying calculation
  def cells
    results = result_cells
    offset = results.size
    results = build_cells(results, offset)
    results.flatten!
    results.prepend(SpareTableCell.new(value: calculation_config&.name,
                                       column_index: 0,
                                       row_index: calculation_config_id))
  end

  # Allows to iterate through FrozenResultTableCell instances
  def each(&block)
    cells.each(&block)
  end

  private

  delegate :id, to: :calculation_config, prefix: true, allow_nil: true
  delegate :size, to: :result_header, prefix: true

  # Stored results of table fields
  def result_cells
    return [] unless row

    row.custom_field_values.map do |custom_field_value|
      custom_field = custom_field_value.custom_field
      if result_column_names.include? custom_field.name
        FrozenResultTableCell.new(custom_field_value: custom_field_value)
      else
        SpareTableCell.new(value: nil, column_index: custom_field.position, row_index: calculation_config_id)
      end
    end
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
      SpareTableCell.new(value: row&.send(attr) || nil, column_index: offset + index, row_index: calculation_config_id)
    end
  end

  def result_column_names
    return [] unless result_header

    result_header.map(&:name)
  end
end
