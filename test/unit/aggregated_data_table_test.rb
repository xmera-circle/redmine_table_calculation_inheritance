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
  class AggregatedDataTableTest < UnitTestCase
    def setup
      setup_inheritated_spreadsheets
      @query = SpreadsheetRowResultQuery.new(host_spreadsheet: @host_project.spreadsheets.first,
                                             guest_projects: [@guest_project])
      # min calculation results are not yet frozen
      @aggregated_data_table =
        AggregatedDataTable.new(
          spreadsheet: spreadsheet_by(@host_project, 'Equipment list'),
          query: @query
        )
    end

    test 'should respond to header' do
      assert @aggregated_data_table.respond_to?(:header)
    end

    test 'should respond to columns' do
      assert @aggregated_data_table.respond_to?(:columns)
    end

    test 'should transpose host rows of given calculation where guest rows are missing' do
      # sum calculation config
      expected_values = %w[12 5]
      current_columns = @aggregated_data_table.send(:transpose_rows, @sum_calculation_config)
      assert_equal 2, current_columns.count
      assert_equal DataTableCell, current_columns.first.map(&:class).uniq[0]
      assert_equal expected_values, current_columns.first.map(&:value)
      assert_equal SpareTableCell, current_columns.last.map(&:class).uniq[0]
      # max calculation config
      expected_values = [@condition_column_values.first.to_s, @condition_column_values.last.to_s]
      current_columns = @aggregated_data_table.send(:transpose_rows, @max_calculation_config)
      assert_equal 2, current_columns.count
      assert_equal SpareTableCell, current_columns.first.map(&:class).uniq[0]
      assert_equal DataTableCell, current_columns.last.map(&:class).uniq[0]
      assert_equal expected_values, current_columns.last.map(&:value)
    end

    test 'should transpose guest rows of given calculation where host rows are given too' do
      # sum calculation config
      guest_params = { project: @guest_project }
      add_spreadsheet_row_result(**guest_params)
      expected_values = %w[12 5 17]
      current_columns = @aggregated_data_table.send(:transpose_rows, @sum_calculation_config)
      assert_equal 2, current_columns.count
      assert_equal DataTableCell, current_columns.first.map(&:class).uniq[0]
      assert_equal expected_values, current_columns.first.map(&:value)
      assert_equal SpareTableCell, current_columns.last.map(&:class).uniq[0]
      # max calculation config is without guest rows
      expected_values = [@condition_column_values.first.to_s, @condition_column_values.last.to_s]
      current_columns = @aggregated_data_table.send(:transpose_rows, @max_calculation_config)
      assert_equal 2, current_columns.count
      assert_equal SpareTableCell, current_columns.first.map(&:class).uniq[0]
      assert_equal DataTableCell, current_columns.last.map(&:class).uniq[0]
      assert_equal expected_values, current_columns.last.map(&:value)
    end
  end
end
