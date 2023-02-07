# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021 - 2022  Liane Hampe <liaham@xmera.de>, xmera.
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

module TableCaclulationInheritance
  class SpreadsheetsRowResultsControllerTest < ActionDispatch::IntegrationTest
    extend RedmineTableCalculationInheritance::LoadFixtures
    include RedmineTableCalculationInheritance::AuthenticateUser
    include RedmineTableCalculationInheritance::ProjectTypeCreator
    include RedmineTableCalculationInheritance::InheritatedSpreadsheets
    include Redmine::I18n

    fixtures :projects,
             :members, :member_roles, :roles, :users

    def setup
      setup_inheritated_spreadsheets
    end

    test 'should render new for admin' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take

      log_user('admin', 'admin')
      get new_project_spreadsheet_spreadsheet_row_result_path(spreadsheet_id: spreadsheet.id,
                                                              calculation_id: calc.id,
                                                              project_id: @host_project.id)
      assert :success

      assert_select '.box.tabular.settings', 1
      assert_select 'input[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select 'select[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select '#spreadsheet_row_result_comment'
    end

    test 'should render new when allowed to' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take
      @manager_role.add_permission!(:edit_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      get new_project_spreadsheet_spreadsheet_row_result_path(spreadsheet_id: spreadsheet.id,
                                                              calculation_id: calc.id,
                                                              project_id: @host_project.id)
      assert :success

      assert_select '.box.tabular.settings', 1
      assert_select 'input[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select 'select[id^="spreadsheet_row_result_custom_field_values_"]', 1
      assert_select '#spreadsheet_row_result_comment'
    end

    test 'should not render new when allowed to' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take

      log_user('jsmith', 'jsmith')
      get new_project_spreadsheet_spreadsheet_row_result_path(spreadsheet_id: spreadsheet.id,
                                                              calculation_id: calc.id,
                                                              project_id: @host_project.id)
      assert 403

      assert_select '.box.tabular.settings', 0
    end

    test 'should create if allowed to' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take
      @manager_role.add_permission!(:edit_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      assert_difference 'SpreadsheetRowResult.count' do
        post project_spreadsheet_spreadsheet_row_results_path(spreadsheet_id: spreadsheet.id,
                                                              calculation_id: calc.id,
                                                              project_id: @host_project.id),
             params: {
               spreadsheet_row_result: {
                 custom_field_values: {
                   @second_column.id => '34'
                 },
                 comment: '-'
               }
             }
      end
      assert_redirected_to results_project_spreadsheet_path @host_project, spreadsheet
    end

    test 'should not create if not allowed to' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take
      @manager_role.add_permission!(:edit_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      assert_difference 'SpreadsheetRowResult.count' do
        post project_spreadsheet_spreadsheet_row_results_path(spreadsheet_id: spreadsheet.id,
                                                              calculation_id: calc.id,
                                                              project_id: @host_project.id),
             params: {
               spreadsheet_row_result: {
                 custom_field_values: {
                   @second_column.id => '34'
                 },
                 comment: '-'
               }
             }
      end
      assert 403
    end

    test 'should update if allowed to' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take
      SpreadsheetRowResult.create(custom_field_values: { @second_column.id => '34' },
                                  author_id: User.current.id,
                                  spreadsheet_id: spreadsheet.id,
                                  calculation_id: calc.id,
                                  comment: '-')
      row_result = spreadsheet.result_rows.take
      @manager_role.add_permission!(:edit_spreadsheet_results)

      log_user('jsmith', 'jsmith')
      patch spreadsheet_row_result_path(row_result.id),
            params: {
              spreadsheet_row_result: {
                custom_field_values: {
                  @second_column.id => '34'
                },
                comment: 'reviewed'
              }
            }
      assert_redirected_to results_project_spreadsheet_path @host_project, spreadsheet
      get results_project_spreadsheet_path @host_project, spreadsheet
      assert :success
      assert_select '.name', text: 'reviewed'
    end

    test 'should not update if not allowed to' do
      spreadsheet = @host_project.spreadsheets.take
      calc = spreadsheet.table.calculations.take
      SpreadsheetRowResult.create(custom_field_values: { @second_column.id => '34' },
                                  author_id: User.current.id,
                                  spreadsheet_id: spreadsheet.id,
                                  calculation_id: calc.id,
                                  comment: '-')
      row_result = spreadsheet.result_rows.take

      log_user('jsmith', 'jsmith')
      patch spreadsheet_row_result_path(row_result.id),
            params: {
              spreadsheet_row_result: {
                custom_field_values: {
                  @second_column.id => '34'
                },
                comment: 'reviewed'
              }
            }
      assert 403
    end
  end
end
