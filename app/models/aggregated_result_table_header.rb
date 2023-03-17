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

class AggregatedResultTableHeader
  include Redmine::I18n

  def initialize(**attrs)
    @calculation_columns = attrs[:calculation_columns]
    @table_columns = attrs[:table_columns]
  end

  def columns
    sorted = cells.sort_by(&:position)
    sorted.prepend(first_column).append(last_column)
  end

  private

  attr_reader :calculation_columns, :table_columns

  # Separate TableCustomFields used for calculation by those
  # not to be used for calculation.
  def cells
    table_columns.map do |column|
      if calculable?(column.id)
        column
      else
        SpareTableCell.new(position: column.position, name: '')
      end
    end
  end

  # Prepare first calculation column
  def first_column
    SpareTableCell.new(column_index: 0, position: 0, name: l(:label_calculation))
  end

  def last_column
    SpareTableCell.new(column_index: size + 1, position: 0, name: l(:label_row_result_status))
  end

  def size
    calculation_columns.count
  end

  def calculable?(id)
    calculation_column_ids.include? id
  end

  def calculation_column_ids
    calculation_columns.map(&:id).flatten
  end
end
