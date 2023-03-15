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
  class SpreadsheetRowResultTest < UnitTestCase
    fixtures :projects, :users

    def setup
      @table_config = TableConfig.generate!
      @spreadsheet = Spreadsheet.generate!(project_id: Project.find(1).id,
                                           author_id: User.find(2).id,
                                           table_config_id: @table_config.id)
    end

    test 'should have many custom values' do
      association = SpreadsheetRowResult.reflect_on_association(:custom_values)
      assert_equal :custom_values, association.name
      assert_equal :has_many, association.macro
    end

    test 'should respond to safe attributes' do
      assert SpreadsheetRowResult.respond_to? :safe_attributes
    end

    test 'should find TableCustomField instances' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.new(spreadsheet_id: @spreadsheet.id)
      assert row.available_custom_fields.count == 1
    end

    test 'should have default status' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      assert_equal 'New', row.status
    end

    test 'should update status to changed when custom field value has changed' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      row.custom_field_values = { cf.id => 'A' }
      row.save!
      assert_equal 'Changed', row.status
    end

    test 'should update status to unchanged when custom field value stayed the same' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      row.comment = 'Update comment'
      row.save!
      assert_equal 'Unchanged', row.status
    end

    private

    def custom_field
      CustomField.generate! table_attributes(name: 'CF')
    end

    def table_attributes(name:)
      { name: name,
        regexp: '',
        is_for_all: true,
        is_filter: true,
        type: 'TableCustomField',
        possible_values: %w[A B C],
        is_required: false,
        field_format: 'list',
        default_value: '',
        editable: true }
    end
  end
end
