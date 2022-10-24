# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021 - 2022  Liane Hampe <liaham@xmera.de>, xmera.
#
# This program is free software; you can redistribute it and/or
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

module TableCalculationInheritance
  ##
  # Create table, calculation, and spreadsheets
  #
  module InheritatedSpreadsheets
    include TableCalculationInheritance::Enumerations

    def setup_inheritated_spreadsheets
      @user = User.find(2)
      @manager_role = Role.find_by_name('Manager')
      @manager_role.add_permission!(:view_spreadsheet_results)
      @developer_role = Role.find_by_name('Developer')
      @developer_role.add_permission!(:edit_spreadsheet_results)
      @developer_role.add_permission!(:view_spreadsheet_results)

      # Define relations
      superordinated_project_type = find_project_type(id: 4)
      superordinated_project_type.subordinates << find_project_type(id: 5)
      @guest_project = project_with_type(id: 2, type: 4)
      @host_project = project_with_type(id: 1, type: 5)
      @guest_project.hosts << @host_project
      @host_project.enable_module!(:table_calculation)
      @guest_project.enable_module!(:table_calculation)

      # Define table and calculation
      @first_column = TableCustomField.generate!(name: 'Name', field_format: 'string')
      @second_column = TableCustomField.generate!(name: 'Count', field_format: 'int')
      @third_column = create_colored_custom_field
      @third_column_values = @third_column.enumerations.pluck(:id)
      table = Table.create(name: 'Equipment', description: 'IT equipment list')
      table.columns << [@first_column, @second_column, @third_column]
      @calculation = Calculation.create(name: 'Number of devices',
                                        description: 'Sum up the devices of a list',
                                        formula: 'sum',
                                        columns: true,
                                        rows: false,
                                        table_id: table.id)
      @calculation.fields << @second_column
      @calculation.fields << @third_column
      table.calculations << @calculation # sets explicitly the has_many side

      # Define spreadsheet
      [@guest_project, @host_project].each do |project|
        @spreadsheet = Spreadsheet.create(name: 'Equipment list',
                                          description: "Required Equipment for #{project.name}",
                                          project_id: project.id,
                                          author_id: @user.id,
                                          table_id: table.id)
        first_row = SpreadsheetRow.create(spreadsheet_id: @spreadsheet.id, position: 1)
        first_row.custom_field_values = { @first_column.id => 'Laptop',
                                          @second_column.id => 12,
                                          @third_column.id => @third_column_values.first }
        first_row.save
        second_row = SpreadsheetRow.create(spreadsheet_id: @spreadsheet.id, position: 2)
        second_row.custom_field_values = { @first_column.id => 'Smartphone',
                                           @second_column.id => 5,
                                           @third_column.id => @third_column_values.first }
        second_row.save
      end
    end

    def project_with_type(id:, type:)
      project = Project.find(id)
      project.project_type_id = type
      project.save
      project
    end

    def add_spreadsheet_row_result(project)
      result = SpreadsheetRowResult.create(author_id: @user.id,
                                           spreadsheet_id: project.spreadsheets.take.id,
                                           calculation_id: @calculation.id,
                                           comment: '-')
      result.custom_field_values = { @second_column.id => 17,
                                     @third_column.id => @third_column_values.second }
      result.save
    end

    def check_guest_project_permissions
      assert @user.allowed_to?(:view_spreadsheet_results, @guest_project)
      assert @user.allowed_to?(:edit_spreadsheet_results, @guest_project)
    end

    ##
    # Confirm guest results in order to make it usable in aggregation
    #
    def confirm_guest_results
      assert_difference 'SpreadsheetRowResult.count' do
        post project_spreadsheet_spreadsheet_row_results_path(spreadsheet_row_result_ids(@guest_project)),
             params: spreadsheet_row_result_params
      end
    end

    def spreadsheet_row_result_ids(project)
      { spreadsheet_id: project.spreadsheets.take.id,
        calculation_id: @calculation.id,
        project_id: project.id }
    end

    def spreadsheet_row_result_params
      { spreadsheet_row_result: {
        custom_field_values: {
          @second_column.id => 17
        },
        comment: '-'
      } }
    end
  end
end
