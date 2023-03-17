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
  class AggregatedResultTableTest < UnitTestCase
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
      @aggregated_result_table =
        AggregatedResultTable.new(projects: @projects,
                                  spreadsheet: spreadsheet_by(@host_project, 'Fruit Store'))
    end

    test 'should return header' do
      expected_names =  ['Calculation', '', 'Quality', 'Amount', 'Price', 'Status']
      assert_equal expected_names, @aggregated_result_table.header.map(&:name)
    end

    test 'should return calculated row values' do
      expected_values = [
        ['Calculate maximum quality', '', @enumeration_values.last, '', '', '', ''],
        ['Calculate minimum price', nil, nil, nil, nil, nil, nil],
        ['Calculate sum of amount', '', '', 39, '', '', '']
      ]
      assert_equal expected_values, (@aggregated_result_table.rows.map { |row| row.map(&:value) })
    end
  end
end
