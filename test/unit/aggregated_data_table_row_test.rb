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
  class AggregatedDataTableRowTest < UnitTestCase
    def setup
      setup_inheritated_spreadsheets
      calculation_configs = @table_config.calculation_configs
      calculation_columns = calculation_configs
                            .map(&:columns)
                            .flatten.uniq.sort_by(&:position)
      host_project_params = { project: @host_project }
      row = add_spreadsheet_row_result(**host_project_params)
      @row = AggregatedDataTableRow.new(row: row,
                                        calculation_config: @sum_calculation_config,
                                        calculation_columns: calculation_columns)
    end

    test 'should respond to cells' do
      assert @row.respond_to?(:cells)
    end

    test 'should have column gaps' do
      # position 1: Name
      # position 2: Count
      # position 3: Condition
      assert_equal [3], @row.send(:column_gaps)
    end

    test 'should create data table cells' do
      assert_equal DataTableCell, @row.send(:data_table_cells).map(&:class).uniq[0]
      assert_equal 1, @row.send(:data_table_cells).size
    end

    test 'should fill cells if there are column gaps' do
      assert_equal 2, @row.send(:filled_cells).size
      assert_equal [DataTableCell, SpareTableCell], @row.send(:filled_cells).map(&:class).uniq
      assert_equal [2, 3], @row.send(:filled_cells).map(&:column_index)
    end

    test 'should return data table cells when there are no column gaps' do
      @row.stubs(:column_gaps).returns([])
      @row.stubs(:data_table_cells).returns(%w[Cell Cell])
      assert @row.send(:filled_cells).is_a?(Array)
      assert_equal 2, @row.send(:filled_cells).size
    end
  end
end
