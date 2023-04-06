# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation.
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
  class FrozenResultTableHeaderTest < UnitTestCase
    def setup
      setup_frozen_result_table
      @default_columns = @frozen_result_table.send(:default_columns)
      @header = FrozenResultTableHeader.new(default_columns: @default_columns,
                                            table_config: @table_config)
    end

    test 'should respond to columns' do
      assert @header.respond_to?(:columns)
    end

    test 'should respond to result_header' do
      assert @header.respond_to?(:result_header)
    end

    test 'should respond to default_header' do
      assert @header.respond_to?(:default_header)
    end

    test 'should respond to each' do
      assert @header.respond_to?(:each)
    end

    test 'should have data_table_header' do
      expected_names = %w[Name Quality Amount Price]
      assert_equal expected_names, @header.send(:data_table_header).map(&:name)
    end
  end
end
