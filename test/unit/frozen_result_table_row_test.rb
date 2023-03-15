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
  class FrozenResultTableRowTest < UnitTestCase
    fixtures :users

    def setup
      @jsmith = users :users_002
      setup_default_data_table
      @frozen_result_table = FrozenResultTable.new(spreadsheet: @spreadsheet)
      @frozen_result_table_header = FrozenResultTableHeader.new(default_columns: @frozen_result_table.send(:default_columns),
                                                                table_config: @spreadsheet.table_config)
      @result_header = @frozen_result_table_header.result_header
      @default_header = @frozen_result_table_header.default_header(@result_header.size)
    end

    test 'should have empty cells when no frozen result exists' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      expected_result_row = ['Calculate maximum quality', nil, nil, nil, nil, nil, nil, nil]
      assert_equal expected_result_row, frozen_result_table_row.map(&:value)
    end

    test 'should have cells when results are frozen' do
      max_results = SpreadsheetRowResult.new(author_id: @jsmith.id,
                                             spreadsheet: @spreadsheet,
                                             calculation_config: @max_config,
                                             comment: '-')
      max_results.custom_field_values = { @quality_field.id => @enumeration_values.last }
      max_results.save!
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first)
      # Calculation name, Name, Quality, Amount, Price, Comment, Status, Updated
      expected_max_results = [@max_config.name, nil, @enumeration_values.last.to_s, nil, nil, '-', 'New']
      # Value for Updated is removed since the time values differ by some seconds
      assert_equal expected_max_results, (frozen_result_table_row.cells.map(&:value).reject { |value| value.instance_of?(ActiveSupport::TimeWithZone) })
    end
  end
end
