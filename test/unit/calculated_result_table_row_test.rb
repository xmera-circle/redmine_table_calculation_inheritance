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

require File.expand_path('../test_helper', __dir__)

module RedmineTableCalculationInheritance
  class CalculatedResultTableRowTest < UnitTestCase
    def setup
      @jsmith = users :users_002
      define_project_relations
      setup_frozen_result_table
      @default_columns = @frozen_result_table.send(:default_columns)
      @header = FrozenResultTableHeader.new(default_columns: @default_columns,
                                            table_config: @table_config)
      @result_header = @header.result_header
      @default_header = @header.default_header(@result_header.size)

      @calculated_result_table_row = CalculatedResultTableRow.new(result_header: @result_header,
                                                                  row: @spreadsheet.result_rows.first,
                                                                  calculation_config: @max_config,
                                                                  data_table: DataTable.new(spreadsheet: @spreadsheet))
    end

    test 'should respond to data table' do
      assert @calculated_result_table_row.send(:data_table).presence
    end

    test 'should respond to status' do
      assert_not @calculated_result_table_row.send(:status)
    end
  end
end
