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

class AggregatedResultTableRow < ResultTableRow
  def initialize(**attrs)
    super(**attrs)
    @size = attrs[:size]
  end

  def calculate
    results = super
    return results if results.count == size

    results.append(empty_cells).flatten
  end

  private

  attr_reader :size

  # Empty cells as placeholders for table field values not yet stored
  def empty_cells
    (1..(size - 1)).map do |index|
      SpareTableCell.new(value: nil, column_index: index, row_index: calculation_config_id)
    end
  end
end
