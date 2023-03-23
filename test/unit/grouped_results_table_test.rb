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
    fixtures :projects,
             :members, :member_roles, :roles, :users

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
      @query = SpreadsheetRowResultQuery.new(projects: @members,
                                             spreadsheet: @host_spreadsheet)
      @grouped_result_table =
        GroupedResultsTable.new(query: @query,
                                spreadsheet: @host_spreadsheet,
                                result_table: @result_table)
    end

    test 'should get grouped rows' do
      grouped_rows = @grouped_result_table.send(:grouped_rows)
      expected_spreadsheet_ids = [@host_spreadsheet.id, @guest_spreadsheet.id]
      assert_equal expected_spreadsheet_ids, grouped_rows.keys.map(&:id)
      expected_result_row_ids = [@host_spreadsheet.result_row_ids, @guest_spreadsheet.result_row_ids].flatten
      assert_equal expected_result_row_ids, grouped_rows.values.flatten.map(&:id)
    end

    test 'should get rows' do
      rows = @grouped_result_table.rows
      assert_equal Spreadsheet, rows.keys.map(&:class).uniq[0]
      assert_equal 6, rows.values.flatten.count
      assert_equal FrozenResultTableRow, rows.values.flatten.map(&:class).uniq[0]
    end
  end
end
