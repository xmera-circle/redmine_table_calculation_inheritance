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
    def setup
      @admin = users :users_001
      @jsmith = users :users_002
      prepare_project_relations
      prepare_table_config
      prepare_calculation_config
      prepare_spreadsheets
      prepare_host_spreadsheet_column_contents
      prepare_guest_spreadsheet_column_contents
      prepare_host_frozen_result_values
      prepare_guest_frozen_result_values
      @spreadsheet = spreadsheet_by(@guest_project, 'Fruit Store')
      @table_config = @spreadsheet.table_config
    end

    test 'should have many custom values' do
      association = SpreadsheetRowResult.reflect_on_association(:custom_values)
      assert_equal :custom_values, association.name
      assert_equal :has_many, association.macro
    end

    test 'should respond to safe attributes' do
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      assert SpreadsheetRowResult.respond_to? :safe_attributes
      assert row.respond_to?(:author_id), 'Does not respond to :author_id'
      assert row.respond_to?(:spreadsheet_id), 'Does not respond to :spreadsheet_id'
      assert row.respond_to?(:calculation_config_id), 'Does not respond to :calculation_config_id'
      # assert row.respond_to?(:custom_fields), 'Does not respond to :custom_fields'
      assert row.respond_to?(:custom_field_values), 'Does not respond to :custom_field_values'
      assert row.respond_to?(:comment), 'Does not respond to :comment'
      assert row.respond_to?(:reviewed), 'Does not respond to :reviewed'
    end

    test 'should validate comment' do
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id)
      assert row.invalid?
      assert_equal [:comment], row.errors.attribute_names
    end

    test 'should destroy custom field values when row is destroyed' do
      rows = @spreadsheet.result_rows
      row_ids = rows.map(&:id)
      assert rows.first.custom_field_values.map(&:value).any?
      custom_values = CustomValue.where(customized_id: row_ids.first)
      assert custom_values.presence
      rows.destroy_all
      custom_values = CustomValue.where(customized_id: row_ids.first)
      assert_not custom_values.presence
    end

    test 'should find TableCustomField instances' do
      rows = @spreadsheet.result_rows
      row = rows.first
      assert_equal %w[Quality Amount Price], row.available_custom_fields.map(&:name)
    end

    test 'should have default status' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      assert_equal 'Edited', row.status
    end

    test 'should update status to edited when custom field value has changed' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      row.custom_field_values = { cf.id => 'A' }
      row.save!
      assert_equal 'Edited', row.status
    end

    test 'should leave status unchanged when custom field value stayed the same' do
      cf = custom_field
      @table_config.columns << cf
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      row.comment = 'Update comment'
      row.save!
      assert_equal 'Edited', row.status
    end

    test 'should have visible custom fields only' do
      row = SpreadsheetRowResult.create(spreadsheet_id: @spreadsheet.id,
                                        comment: 'First result')
      assert row.visible?
    end

    test 'should detect unchanged custom field values' do
      guest_rows = @spreadsheet.result_rows
      row = guest_rows.second
      # submit unchanged custom_field_values
      assert_not row.changed_custom_field_values?({ @amount_field.id.to_s => '21' })
    end

    test 'should change hosts status when custom field values changed' do
      guest_rows = @spreadsheet.result_rows
      guest_status = guest_rows.map(&:status)
      assert_equal %w[Edited Edited], guest_status
      # reset hosts to status Edited
      host_rows = spreadsheet_by(@host_project, 'Fruit Store').result_rows
      host_rows.each do |row|
        row.status = 1
        row.save!
      end
      host_status = host_rows.map(&:status)
      assert_equal %w[Edited Edited], host_status
      # change custom_field_values
      guest_rows.second.custom_field_values = { @amount_field.id => 25 }
      guest_rows.second.save!
      host_rows_reloaded = spreadsheet_by(@host_project, 'Fruit Store').result_rows
      host_status_reloaded = host_rows_reloaded.map(&:status)
      assert_equal %w[Edited Review], host_status_reloaded
    end

    test 'should touch updated_on field when reviewed' do
      row = SpreadsheetRowResult.create!(spreadsheet_id: @spreadsheet.id,
                                         comment: '-')
      current_update = Time.zone.strptime(row.updated_on.to_s, '%Y-%m-%d %H:%M:%S')
      sleep(1)
      row.safe_attributes = { author_id: @jsmith.id, reviewed: 1 }
      row.save!
      assert_not_equal current_update, Time.zone.strptime(row.updated_on.to_s, '%Y-%m-%d %H:%M:%S')
    end

    test 'should not touch updated_on field when not reviewed' do
      row = SpreadsheetRowResult.create!(spreadsheet_id: @spreadsheet.id,
                                         comment: '-')
      current_update = Time.zone.strptime(row.updated_on.to_s, '%Y-%m-%d %H:%M:%S')
      row.safe_attributes = { author_id: @jsmith.id, reviewed: 0 }
      row.save!
      assert_equal current_update, Time.zone.strptime(row.updated_on.to_s, '%Y-%m-%d %H:%M:%S')
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
