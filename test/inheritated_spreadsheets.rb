# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021 Liane Hampe <liaham@xmera.de>, xmera.
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
    def setup_inheritated_spreadsheets
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
      @first_column = TableCustomField.generate!(name: 'Name', field_format: 'string')
      @second_column = TableCustomField.generate!(name: 'Count', field_format: 'int')
      table = Table.create(name: 'Equipment', description: 'IT equipment list')
      table.columns << [@first_column, @second_column]
      @calculation = Calculation.create(name: 'Number of devices',
                                        description: 'Sum up the devices of a list',
                                        formula: 'sum',
                                        columns: true,
                                        rows: false,
                                        table_id: table.id)
      @calculation.fields << @second_column
      table.calculations << @calculation # sets explicitly the has_many side

      # Define spreadsheet
      [@guest_project, @host_project].each do |project|
        spreadsheet = Spreadsheet.create(name: 'Equipment list',
                                          description: "Required Equipment for #{project.name}",
                                          project_id: project.id,
                                          author_id: @manager.id,
                                          table_id: table.id)
        first_row = SpreadsheetRow.create(spreadsheet_id: spreadsheet.id, position: 1)
        first_row.custom_field_values = { @first_column.id => 'Laptop', @second_column.id => 12 }
        first_row.save
        second_row = SpreadsheetRow.create(spreadsheet_id: spreadsheet.id, position: 2)
        second_row.custom_field_values = { @first_column.id => 'Smartphone', @second_column.id => 5 } 
        second_row.save
      end
    end

    def project_with_type(id:, type:)
      project = Project.find(id)
      project.project_type_id = type
      project.save
      project
    end
  end
end
