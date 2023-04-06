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
    def setup
      @jsmith = users :users_002
      define_project_relations
      setup_frozen_result_table
      @default_columns = @frozen_result_table.send(:default_columns)
      @header = FrozenResultTableHeader.new(default_columns: @default_columns,
                                            table_config: @table_config)
      @result_header = @header.result_header
      @default_header = @header.default_header(@result_header.size)
    end

    test 'should respond to :id, :author, :visible?' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      assert frozen_result_table_row.respond_to?(:id), 'Does not respond to :id'
      assert frozen_result_table_row.respond_to?(:author), 'Does not respond to :author'
      assert frozen_result_table_row.respond_to?(:visible?), 'Does not respond to :visible?'
    end

    test 'should respond to :result_header, :row, :calculation_config, :spreadsheet' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      assert frozen_result_table_row.respond_to?(:result_header), 'Does not respond to :result_header'
      assert frozen_result_table_row.respond_to?(:row), 'Does not respond to :row'
      assert frozen_result_table_row.respond_to?(:calculation_config), 'Does not respond to :calculation_config'
      assert frozen_result_table_row.respond_to?(:spreadsheet), 'Does not respond to :spreadsheet'
    end

    test 'should respond to cells, new_result_row_params, each' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      assert frozen_result_table_row.respond_to?(:cells), 'Does not respond to :cells'
      assert frozen_result_table_row.respond_to?(:new_result_row_params), 'Does not respond to :new_result_row_params'
      assert frozen_result_table_row.respond_to?(:each), 'Does not respond to :each'
    end

    test 'should have empty cells when no frozen result exists' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      expected_result_row = ['Calculate maximum quality', nil, nil, nil, nil, nil, 'Not frozen', nil]
      assert_equal expected_result_row, frozen_result_table_row.map(&:value)
    end

    test 'should return empty Array when no row given' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: nil,
                                                         calculation_config: @max_config)
      assert_equal [], frozen_result_table_row.send(:result_cells)
    end

    test 'should return stored_result_cells when no result column gap exists' do
      @spreadsheet.update(project: @host_project)
      max_results = SpreadsheetRowResult.new(author_id: @jsmith.id,
                                             spreadsheet: @spreadsheet,
                                             calculation_config: @max_config,
                                             comment: '-')
      max_results.custom_field_values = { @quality_field.id => @enumeration_values.last }
      max_results.save!
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      frozen_result_table_row.stubs(:result_column_gaps).returns([])
      stored_result_cells = %w[Cell Cell]
      frozen_result_table_row.stubs(:stored_result_cells).returns(stored_result_cells)
      assert_equal stored_result_cells, frozen_result_table_row.send(:result_cells)
    end


    test 'should have result_cells when results are frozen' do
      @spreadsheet.update(project: @host_project)
      max_results = SpreadsheetRowResult.new(author_id: @jsmith.id,
                                             spreadsheet: @spreadsheet,
                                             calculation_config: @max_config,
                                             comment: '-')
      max_results.custom_field_values = { @quality_field.id => @enumeration_values.last }
      max_results.save!
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      current_result_cells = frozen_result_table_row.send(:result_cells)
      expected_max_results = [nil, @enumeration_values.last.to_s, nil, nil]
      assert_equal expected_max_results, current_result_cells.map(&:value)
    end

    test 'should build cells with zero offset' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      results = []
      offset = 0
      current_cells = frozen_result_table_row.send(:build_cells, results, offset)
      expected_empty_cells = [nil, nil, nil, nil]
      expected_default_cells = [nil, 'Not frozen', nil]
      assert_equal [1, 2, 3, 4], current_cells.first.map(&:column_index)
      assert_equal expected_empty_cells, current_cells.first.map(&:value)
      assert_equal [5, 6, 7], current_cells.last.map(&:column_index)
      assert_equal expected_default_cells, current_cells.last.map(&:value)
    end

    test 'should build cells with offset greater zero' do
      frozen_result_table_row = FrozenResultTableRow.new(result_header: @result_header,
                                                         row: @spreadsheet.result_rows.first,
                                                         calculation_config: @max_config)
      results = []
      offset = 4
      current_cells = frozen_result_table_row.send(:build_cells, results, offset)
      expected_default_cells = [nil, 'Not frozen', nil]
      assert_equal [5, 6, 7], current_cells.first.map(&:column_index)
      assert_equal expected_default_cells, current_cells.first.map(&:value)
    end
  end
end
