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
  class SpreadsheetsControllerTest < ControllerTestCase
    def setup
      setup_inheritated_spreadsheets
      @spreadsheet = @host_project.spreadsheets.take
    end

    test 'should show aggregated results' do
      @manager.add_permission!(:view_spreadsheet_results)
      @manager.add_permission!(:edit_spreadsheet_results)
      @developer.add_permission!(:view_spreadsheet_results)
      assert @jsmith.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: @spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'h2', text: "#{l(:label_calculation_summary)} » #{l(:label_spreadsheet_result_plural)} #{@spreadsheet.name}"
      assert_select '#content fieldset legend strong', 3
      # grouped results are asynchronosly rendered, therefore they do not count
      assert_select 'tbody tr td.name', { text: @sum_calculation_config.name, count: 2 }
      assert_select 'tbody tr td:nth-of-type(6)', { count: 2 }
      assert_select 'tbody tr td:nth-of-type(6)', { text: /Not frozen/, count: 2 }
      # assert_select 'fieldset.collapsible' do
      #   assert_select 'tbody tr td:nth-of-type(6)', { count: 4 }
      #   assert_select 'tbody tr td:nth-of-type(6)', { text: /Not frozen/, count: 2 }
      #   assert_select 'tbody tr td:nth-of-type(3)', { text: /17/, count: 1 } # calculated host result
      # end

      # confirm guest result to be used in aggregation
      check_guest_project_permissions
      confirm_guest_results

      get results_project_spreadsheet_path(id: @spreadsheet.id, project_id: @host_project.id)
      assert_response :success

      assert_select 'h2', text: "#{l(:label_calculation_summary)} » #{l(:label_spreadsheet_result_plural)} #{@spreadsheet.name}"
      assert_select '#content fieldset legend strong', 3
      # grouped results are asynchronosly rendered, therefore they do not count
      assert_select 'tbody tr td.name', { text: @sum_calculation_config.name, count: 2 }
      assert_select 'tbody tr td:nth-of-type(6)', { text: /Not frozen/, count: 2 }
      # assert_select 'fieldset.collapsible' do
      #   assert_select 'tbody tr td:nth-of-type(6)', { count: 4 }
      #   assert_select 'tbody tr td:nth-of-type(6)', { text: /Not frozen/, count: 1 }
      #   assert_select 'tbody tr td:nth-of-type(3)', { text: /17/, count: 2 } # guest result frozen, host as above
      # end
    end

    test 'should response 403 if not allowed to view aggregated results' do
      @manager.remove_permission!(:view_spreadsheet)
      assert_not @jsmith.allowed_to?(:view_spreadsheet, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: @spreadsheet.id, project_id: @host_project.id)
      assert_response 403
    end

    test 'should show link to edit aggregated results' do
      @manager.add_permission!(:edit_spreadsheet_results)
      @manager.add_permission!(:view_spreadsheet_results)
      assert @jsmith.allowed_to?(:view_spreadsheet, @host_project)
      assert @jsmith.allowed_to?(:edit_spreadsheet_results, @host_project)
      assert @jsmith.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: @spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'a[href*=?]', '/spreadsheet_row_results/', text: l(:button_edit)
    end

    test 'should show no link to edit aggregated results if not allowed to' do
      assert @jsmith.allowed_to?(:view_spreadsheet, @host_project)
      assert_not @jsmith.allowed_to?(:edit_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: @spreadsheet.id, project_id: @host_project.id)

      assert_response :forbidden
      assert_select 'a[href*=?]', '/spreadsheet_row_results/', { text: l(:button_edit), count: 0 }
    end

    test 'should show frozen results in the card on spreadsheets main page' do
      @manager.add_permission!(:edit_spreadsheet_results)
      @manager.add_permission!(:view_spreadsheet_results)
      @developer.add_permission!(:view_spreadsheet_results)
      assert @jsmith.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @jsmith.allowed_to?(:edit_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      # confirm guest result to be used in aggregation
      check_guest_project_permissions
      confirm_guest_results
      host_params = { project: @host_project }
      # confirm host results
      add_spreadsheet_row_result(**host_params)

      get project_spreadsheets_path(project_id: @host_project.id)
      assert_response :success
      assert_select '.spreadsheet.box h3'
      assert_select 'table.list' do
        assert_select 'tbody tr td.name', { text: @sum_calculation_config.name, count: 1 }
        assert_select 'tbody tr td:nth-of-type(6)', { text: /Not frozen/, count: 1 }
        assert_select 'tbody tr td:nth-of-type(3)', { text: /17/, count: 1 }
      end
      assert_select '.icon-zoom-in', 2
    end

    test 'should not show results in card on spreadsheets main page if not allowed to' do
      assert_not @jsmith.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @jsmith.allowed_to?(:view_spreadsheet, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get project_spreadsheets_path(project_id: @host_project.id)
      assert_response :success
      # since is allowed to view spreadsheets
      assert_select '.spreadsheet.box', 1
      assert_select '.spreadsheet.box h3', 1
      # since is not allowed to view spreadsheet results
      assert_select 'table.list', 0
      assert_select '.icon-zoom-in', 0
    end

    test 'should show no spreadsheets box on the main page when not allowed to view anything' do
      @manager.remove_permission!(:view_spreadsheet)

      log_user('jsmith', 'jsmith')
      get project_spreadsheets_path(project_id: @host_project.id)
      assert_response :forbidden
      # since is allowed to view spreadsheets
      assert_select '.spreadsheet.box', 0
    end
  end
end
