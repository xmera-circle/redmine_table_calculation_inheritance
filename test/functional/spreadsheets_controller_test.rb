# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation.
#
# Copyright (C) 2021 Liane Hampe <liaham@xmera.de>, xmera.
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
    extend TableCalculationInheritance::LoadFixtures
    include TableCalculationInheritance::AuthenticateUser
    include TableCalculationInheritance::ProjectTypeCreator
    include Redmine::I18n

    fixtures :projects,
             :members, :member_roles, :roles, :users

    def setup
      @manager = User.find(2)
      @manager_role = Role.find_by_name('Manager')
      @manager_role.add_permission!(:view_spreadsheet_results)

      # Define relations
      superordinated_project_type = find_project_type(id: 4)
      superordinated_project_type.subordinates << find_project_type(id: 5)
      @guest_project = project_with_type(id: 2, type: 4)
      @host_project = project_with_type(id: 1, type: 5)
      @guest_project.hosts << @host_project
      @host_project.enable_module!(:table_calculation)

      # Define table and calculation
      first_column = TableCustomField.create(name: 'Name', field_format: 'string')
      second_column = TableCustomField.create(name: 'Count', field_format: 'int')
      table = Table.create(name: 'Equipment', description: 'IT equipment list')
      table.columns << [first_column, second_column]
      @calculation = Calculation.create(name: 'Number of devices',
                                        description: 'Sum up the devices of a list',
                                        formula: 'sum',
                                        columns: true,
                                        rows: false,
                                        table_id: table.id)
      @calculation.fields << second_column
      table.calculations << @calculation # sets explicitly the has_many side

      # Define spreadsheet
      [@guest_project, @host_project].each do |project|
        spreadsheet = Spreadsheet.create(name: 'Equipment list',
                                          description: "Required Equipment for #{project.name}",
                                          project_id: project.id,
                                          author_id: @manager.id,
                                          table_id: table.id)
        first_row = SpreadsheetRow.create(spreadsheet_id: spreadsheet.id, position: 1)
        first_row.custom_field_values = { first_column.id => 'Laptop', second_column.id => 12 }
        first_row.save
        second_row = SpreadsheetRow.create(spreadsheet_id: spreadsheet.id, position: 2)
        second_row.custom_field_values = { first_column.id => 'Smartphone', second_column.id => 5 } 
        second_row.save
      end
    end

    test 'should show aggregated results' do
      assert @manager.allowed_to?(:view_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
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
      assert_not @manager.allowed_to?(:view_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response 403
    end

    test 'should show link to edit aggregated results' do
      @manager_role.add_permission!(:edit_spreadsheet_results)
      assert @manager.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @manager.allowed_to?(:edit_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'a[href*=?]', '/spreadsheet_row_results/', text: l(:button_edit)
    end

    test 'should show no link to edit aggregated results if not allowed to' do
      assert @manager.allowed_to?(:view_spreadsheet_results, @host_project)
      assert_not @manager.allowed_to?(:edit_spreadsheet_results, @host_project)
      spreadsheet = @host_project.spreadsheets.take
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get results_project_spreadsheet_path(id: spreadsheet.id, project_id: @host_project.id)
      assert_response :success
      assert_select 'a[href*=?]', '/spreadsheet_row_results/', { text: l(:button_edit), count: 0 }
    end

    test 'should show aggregated result in the card on spreadsheets main page' do
      @manager_role.add_permission!(:edit_spreadsheet_results)
      assert @manager.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @manager.allowed_to?(:edit_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
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
      assert_not @manager.allowed_to?(:view_spreadsheet_results, @host_project)
      assert @host_project.guests.present?

      log_user('jsmith', 'jsmith')
      get project_spreadsheets_path(project_id: @host_project.id)
      assert_response 403
      assert_select 'table.list', 0
      assert_select '.icon-zoom-in', 0
    end

    private

    def project_with_type(id:, type:)
      project = Project.find(id)
      project.project_type_id = type
      project.save
      project
    end
  end
end
