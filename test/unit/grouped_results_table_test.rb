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
  class GroupedResultsTableTest < UnitTestCase
    def setup
      prepare_spreadsheet_users
      prepare_spreadsheet_roles
      prepare_spreadsheet_permissions
      prepare_project_relations
      prepare_table_config
      prepare_calculation_config
      prepare_spreadsheets
      prepare_host_spreadsheet_column_contents
      prepare_guest_spreadsheet_column_contents
      prepare_host_frozen_result_values
      prepare_guest_frozen_result_values
      @host_spreadsheet = spreadsheet_by(@host_project, 'Fruit Store')
      @guest_spreadsheet = spreadsheet_by(@guest_project, 'Fruit Store')
      @data_table = DataTable.new(spreadsheet: @host_spreadsheet)
      @result_table = ResultTable.new(data_table: @data_table)
      @members = @host_project.guests.prepend(@host_project)
      @query = SpreadsheetQuery.new(host_project: @host_project,
                                    host_spreadsheet: @host_spreadsheet,
                                    guest_projects: @host_project.guests)
      @grouped_results_table =
        GroupedResultsTable.new(query: @query,
                                spreadsheet: @host_spreadsheet,
                                result_table: @result_table)
    end

    test 'should respond to column_count' do
      @grouped_results_table.respond_to?(:column_count)
    end

    test 'should respond to header' do
      @grouped_results_table.respond_to?(:header)
    end

    test 'should respond to projects' do
      @grouped_results_table.respond_to?(:projects)
    end

    test 'should respond to rows_of' do
      @grouped_results_table.respond_to?(:rows_of)
    end

    test 'should respond to spreadsheet_of' do
      @grouped_results_table.respond_to?(:spreadsheet_of)
    end

    test 'should respond to rows' do
      @grouped_results_table.respond_to?(:rows)
    end

    test 'should return host rows' do
      # calculation_configs order: max, min, sum
      host_rows = @grouped_results_table.send(:host_rows)
      assert_equal 3, host_rows.count

      expected_max_results = ['Calculate maximum quality', '', @enumeration_values.last, '', '', nil, nil, nil]
      assert_equal expected_max_results, host_rows.first.map(&:value)

      expected_min_results = ['Calculate minimum price', '', '', '', 1.8, nil, nil, nil]
      assert_equal expected_min_results, host_rows.second.map(&:value)

      expected_sum_results = ['Calculate sum of amount', '', '', 18, '', nil, nil, nil]
      assert_equal expected_sum_results, host_rows.last.map(&:value)
    end

    test 'should add host result rows to grouped rows of guests' do
      host_rows = [[1], [2], [3]]
      @grouped_results_table.stubs(:host_project).returns(@host_project)
      @grouped_results_table.stubs(:host_rows).returns(host_rows)
      grouped_rows = {}
      host_result_rows = @grouped_results_table.send(:add_host_result_rows, grouped_rows)
      assert host_result_rows.keys.map(&:id).include?(@host_project.id)
      assert_equal @host_project.spreadsheets.first, host_result_rows[@host_project][:spreadsheet]
      assert_equal host_rows, host_result_rows[@host_project][:rows]
    end

    test 'should prepare guest result rows with empty query' do
      grouped_rows = {}
      @grouped_results_table.stubs(:guest_spreadsheets_grouped_by_project).returns(grouped_rows)
      guest_result_rows = @grouped_results_table.send(:prepare_guest_result_rows)
      assert_equal grouped_rows, guest_result_rows
    end

    test 'should prepare guest result rows with query data' do
      guest_result_rows = @grouped_results_table.send(:prepare_guest_result_rows)
      assert guest_result_rows.keys.map(&:id).include?(@guest_project.id)
      assert_equal @guest_project.spreadsheets.first, guest_result_rows[@guest_project][:spreadsheet]
      assert_equal [FrozenResultTableRow, FrozenResultTableRow, FrozenResultTableRow], guest_result_rows[@guest_project][:rows].map(&:class)
    end
  end
end
