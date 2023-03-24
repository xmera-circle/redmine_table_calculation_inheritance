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

class CalculatedResultTableRow < FrozenResultTableRow
  # @return [Array(ResultTableCell)] The calculated row for the underlying spreadsheet.
  def initialize(**attrs)
    super(**attrs)
    @data_table = attrs[:data_table]
  end

  def result_cells
    result_row = ResultTable.new(data_table: data_table)
                            .send(:result_row, calculation_config)
                            .calculate
    result_row.delete_at(0) # calculation name column
    result_row
  end

  private

  attr_reader :data_table

  def status
    nil
  end
end
