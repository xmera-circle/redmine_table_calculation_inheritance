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
  class SpreadsheetsRowResultsControllerTest < ControllerTestCase
    def setup
      setup_inheritated_spreadsheets
      @spreadsheet = @host_project.spreadsheets.take
      @sum_id = @sum_calculation_config.id
      SpreadsheetRowResult.create!(custom_field_values: { @count_column.id => '34' },
                                  author_id: User.current.id,
                                  spreadsheet_id: @spreadsheet.id,
                                  calculation_config_id: @sum_id,
                                  comment: '-')
      @row_result = @spreadsheet.result_rows.take
    end

    test 'should render new for admin' do
      log_user('admin', 'admin')
      get new_project_spreadsheet_spreadsheet_row_result_path(spreadsheet_id: @spreadsheet.id,
                                                              calculation_config_id: @sum_id,
                                                              project_id: @host_project.id)
      assert :success

      assert_select '.box.tabular', 1

      assert_select 'input[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select '#spreadsheet_row_result_comment'
      assert_select 'label', text: 'Reviewed', count: 0
    end

    test 'should render new for an authorized user' do
      @manager.add_permission!(:edit_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      get new_project_spreadsheet_spreadsheet_row_result_path(spreadsheet_id: @spreadsheet.id,
                                                              calculation_config_id: @sum_id,
                                                              project_id: @host_project.id)
      assert :success

      assert_select '.box.tabular', 1
      assert_select 'input[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select '#spreadsheet_row_result_comment'
    end

    test 'should not render new when the user is not allowed to' do
      log_user('jsmith', 'jsmith')
      get new_project_spreadsheet_spreadsheet_row_result_path(spreadsheet_id: @spreadsheet.id,
                                                              calculation_config_id: @sum_id,
                                                              project_id: @host_project.id)
      assert 403

      assert_select '.box.tabular', 0
    end

    test 'should create and view results if allowed to' do
      @manager.add_permission!(:edit_spreadsheet_results)
      @manager.add_permission!(:view_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      assert_difference 'SpreadsheetRowResult.count' do
        post project_spreadsheet_spreadsheet_row_results_path(spreadsheet_id: @spreadsheet.id,
                                                              calculation_config_id: @sum_id,
                                                              project_id: @host_project.id),
             params: {
               spreadsheet_row_result: {
                 custom_field_values: {
                   @count_column.id => '34'
                 },
                 comment: '-'
               }
             }
      end
      assert_redirected_to results_project_spreadsheet_path @host_project, @spreadsheet
    end

    test 'should not create if not allowed to' do
      log_user('jsmith', 'jsmith')
      assert_no_difference 'SpreadsheetRowResult.count' do
        post project_spreadsheet_spreadsheet_row_results_path(spreadsheet_id: @spreadsheet.id,
                                                              calculation_config_id: @sum_id,
                                                              project_id: @host_project.id),
             params: {
               spreadsheet_row_result: {
                 custom_field_values: {
                   @count_column.id => '34'
                 },
                 comment: '-'
               }
             }
      end
      assert 403
    end

    test 'should render edit form with reviewed field' do
      @manager.add_permission!(:edit_spreadsheet_results)
      @manager.add_permission!(:view_spreadsheet_results)
      spreadsheet_row_result =  {
        custom_field_values: { @count_column.id => '17' },
        calculation_config_id: @sum_id,
        spreadsheet_id: @spreadsheet.id
      }

      log_user('jsmith', 'jsmith')

      get edit_spreadsheet_row_result_path(id: @row_result.id),
          params: {
            spreadsheet_row_result: spreadsheet_row_result
          }
      assert :success
      assert_select '.box.tabular', 1
      assert_select 'input[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select '#spreadsheet_row_result_comment'
      assert_select 'label', text: 'Reviewed'
    end

    test 'should update and view results if allowed to' do
      SpreadsheetRowResult.create!(custom_field_values: { @count_column.id => '34' },
                                  author_id: User.current.id,
                                  spreadsheet_id: @spreadsheet.id,
                                  calculation_config_id: @sum_id,
                                  comment: '-')
      @manager.add_permission!(:edit_spreadsheet_results)
      @manager.add_permission!(:view_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      patch spreadsheet_row_result_path(@row_result.id),
            params: {
              spreadsheet_row_result: {
                custom_field_values: {
                  @count_column.id => '34'
                },
                comment: 'reviewed'
              }
            }
      assert_redirected_to results_project_spreadsheet_path @host_project, @spreadsheet
      get results_project_spreadsheet_path @host_project, @spreadsheet
      assert :success

      assert_select '.name', text: 'reviewed'
    end

    test 'should not update if not allowed to' do
      log_user('jsmith', 'jsmith')
      patch spreadsheet_row_result_path(@row_result.id),
            params: {
              spreadsheet_row_result: {
                custom_field_values: {
                  @count_column.id => '34'
                },
                comment: 'reviewed'
              }
            }
      assert 403
    end

    test 'should update custom field values' do
      @manager.add_permission!(:edit_spreadsheet_results)
      @manager.add_permission!(:view_spreadsheet_results)
      # changes the value from 34 to 17
      spreadsheet_row_result =  {
        custom_field_values: { @count_column.id => '17' },
        calculation_config_id: @sum_id,
        spreadsheet_id: @spreadsheet.id
      }

      log_user('jsmith', 'jsmith')

      patch spreadsheet_row_result_path(id: @row_result.id),
          params: {
            spreadsheet_row_result: spreadsheet_row_result
          }
      assert_redirected_to results_project_spreadsheet_path @host_project, @spreadsheet
      get results_project_spreadsheet_path @host_project, @spreadsheet
      assert :success
      assert_select '.name', text: '17'
    end
  end
end
