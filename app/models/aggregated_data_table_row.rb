# frozen_string_literal: true

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

class AggregatedDataTableRow < DataTableRow
  def initialize(**attrs)
    super(**attrs)
    @calculation_config = attrs[:calculation_config]
    @calculation_columns = attrs[:calculation_columns]
  end

  def cells
    filled_cells
  end

  private

  attr_reader :calculation_config, :calculation_columns

  def filled_cells
    return data_table_cells if column_gaps.none?

    column_gaps.each do |position|
      next if position.zero?

      cell = SpareTableCell.new(value: nil, column_index: position, row_index: calculation_config.id)
      @data_table_cells << cell
    end
    @data_table_cells.sort_by(&:column_index)
  end

  def data_table_cells
    @data_table_cells ||= row.custom_field_values.filter_map do |custom_field_value|
      next unless calculable?(custom_field_value.custom_field)

      DataTableCell.new(custom_field_value: custom_field_value)
    end
    @data_table_cells
  end

  def calculable?(custom_field)
    calculation_config.columns.include?(custom_field)
  end

  def column_gaps
    calculation_column_positions - data_table_cell_positions
  end

  def data_table_cell_positions
    data_table_cells.map(&:column_index)
  end

  def calculation_column_positions
    calculation_columns.map(&:position)
  end
end
