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

module TableCaclulationInheritance
  class SpreadsheetsControllerTest < ActionDispatch::IntegrationTest
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

    test 'should show aggregated results' do
      assert @user.allowed_to?(:view_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'h2', text: "#{l(:label_calculation_summary)} » #{l(:label_spreadsheet_result_plural)} #{spreadsheet.name}"
      assert_select '#content fieldset legend strong', 3
      assert_select 'tbody tr td.name', { text: @calculation.name, count: 4 }
      assert_select 'tbody tr td:nth-of-type(2)', { text: /34/, count: 0 }
      assert_select 'tbody tr td:nth-of-type(2)', { text: /17/, count: 3 }
      assert_select 'fieldset.collapsible' do
        assert_select 'tbody tr td:nth-of-type(2)', { text: /17/, count: 1 }
      end

      # confirm guest result to be used in aggregation
      check_guest_project_permissions
      confirm_guest_results

      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'h2', text: "#{l(:label_calculation_summary)} » #{l(:label_spreadsheet_result_plural)} #{spreadsheet.name}"
      assert_select '#content fieldset legend strong', 3
      assert_select 'tbody tr td.name', { text: @calculation.name, count: 4 }
      assert_select 'tbody tr td:nth-of-type(2)', { text: /34/, count: 2 }
      assert_select 'fieldset.collapsible' do
        assert_select 'tbody tr td:nth-of-type(2)', { text: /17/, count: 2 }
      end
    end

    test 'should response 403 if not allowed to view aggregated results' do
      @manager_role.remove_permission!(:view_spreadsheet_results)
      assert_not @user.allowed_to?(:view_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response 403
    end

    test 'should show link to edit aggregated results' do
      @manager_role.add_permission!(:edit_spreadsheet_results)
      assert @user.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @user.allowed_to?(:edit_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'a[href*=?]', '/spreadsheet_row_results/', text: l(:button_edit)
    end

    test 'should show no link to edit aggregated results if not allowed to' do
      assert @user.allowed_to?(:view_spreadsheet_results, @host_project)
      assert_not @user.allowed_to?(:edit_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)

      assert_response :success
      assert_select 'a[href*=?]', '/spreadsheet_row_results/', { text: l(:button_edit), count: 0 }
    end

    test 'should show aggregated result in the card on spreadsheets main page' do
      @manager_role.add_permission!(:edit_spreadsheet_results)
      assert @user.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @user.allowed_to?(:edit_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      # confirm guest result to be used in aggregation
      check_guest_project_permissions
      confirm_guest_results

      get project_spreadsheets_path(project_id: @host_project.id)
      assert_response :success
      assert_select '.spreadsheet.box h3'
      assert_select 'table.list' do
        assert_select 'tbody tr td.name', { text: @calculation.name, count: 1 }
        assert_select 'tbody tr td:nth-of-type(2)', { text: /34/, count: 1 }
      end
      assert_select '.icon-zoom-in', 2
    end

    test 'should not show results in card on spreadsheets main page if not allowed to' do
      @manager_role.remove_permission!(:view_spreadsheet_results)
      assert_not @user.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get project_spreadsheets_path(project_id: @host_project.id)
      assert_response 403
      assert_select 'table.list', 0
      assert_select '.icon-zoom-in', 0
    end
  end
end
