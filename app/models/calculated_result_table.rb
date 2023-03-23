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

class CalculatedResultTable < FrozenResultTable
  def initialize(**attrs)
    super(**attrs)
    @data_table = attrs[:data_table] || DataTable.new(spreadsheet: spreadsheet)
  end

  # Result rows, one for each calculation.
  def rows
    calculation_configs.map do |calculation_config|
      calculated_row(calculation_config)
    end
  end

  def calculated_row(calculation_config)
    CalculatedResultTableRow.new(result_header: frozen_result_table_header.result_header,
                                 calculation_config: calculation_config,
                                 spreadsheet: spreadsheet,
                                 data_table: data_table)
  end

  private

  attr_reader :data_table
end
