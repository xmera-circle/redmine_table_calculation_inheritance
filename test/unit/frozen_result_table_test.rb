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
  class FrozenResultTableTest < UnitTestCase
    def setup
      setup_inheritated_spreadsheets
      @equipment_spreadsheet = @guest_project.spreadsheets.first
      @frozen_result_table = FrozenResultTable.new(spreadsheet: @equipment_spreadsheet)
    end

    test 'should have header' do
      expected_names = ['Calculation', '', 'Count', 'Condition', 'Rational', 'Status', 'Last Editing']
      assert_equal expected_names, @frozen_result_table.header.map(&:name)
      expected_positions = [0, 1, 2, 3, 4, 5, 6]
      assert_equal expected_positions, @frozen_result_table.header.map(&:position)
    end

    test 'should have empty rows when nothing is saved yet' do
      first_row = @frozen_result_table.rows.first
      first_expected_values = ['Number of devices', nil, nil, nil, nil, 'Not frozen', nil]
      assert_equal first_expected_values, first_row.map(&:value)
    end

    test 'should have frozen rows' do
      add_spreadsheet_row_result(project: @guest_project)
      first_row = @frozen_result_table.rows.first
      first_expected_values = ['Number of devices', nil, '17', nil, '-', 'Edited']
      # Value for Updated is removed since the time values differ by some seconds
      assert_equal first_expected_values, (first_row.map(&:value).reject { |value| value.instance_of?(ActiveSupport::TimeWithZone) })
    end

    test 'should return nil when no row exist for a given calculation config' do
      row = @frozen_result_table.send(:spreadsheet_result_row_by, calculation_config_id: @sum_calculation_config.id)
      assert_not row
    end
  end
end
