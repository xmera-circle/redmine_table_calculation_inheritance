# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021-2023  Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

module RedmineTableCalculationInheritance
  ##
  # Create table, calculation, and spreadsheets
  #
  # DataTable
  #
  # |Name      |Count|Condition|
  # |----------|-----|---------|
  # |Laptop    |12   |value1   |
  # |Smartphone|5    |value4   |
  #
  # FrozenResultTable
  #
  # |Calculation      |Count|Condition|Comment|Status    |Updated|
  # |-----------------|-----|---------|-------|----------|-------|
  # |Number of devices|17   |         |-      |New       |<date> |
  # |Best condition   |     |         |       |Not frozen|       |
  #
  # @note The second calculation result does not exist
  #
  module InheritatedSpreadsheets
    def setup_frozen_result_table
      setup_default_data_table
      @frozen_result_table = FrozenResultTable.new(spreadsheet: @spreadsheet)
    end

    def setup_inheritated_spreadsheets
      define_roles_and_permissions
      define_project_relations
      define_table_and_calculation_config
      generate_inheritated_spreadsheets
    end

    def define_roles_and_permissions
      @jsmith = User.find(2)
      @manager = Role.find_by(name: 'Manager')
      @manager.add_permission!(:view_spreadsheet)
      @developer = Role.find_by(name: 'Developer')
      @developer.add_permission!(:edit_spreadsheet_results)
      @developer.add_permission!(:view_spreadsheet)
    end

    def define_project_relations
      @superordinated_project_type = find_project_type(id: 4)
      @superordinated_project_type.subordinates << find_project_type(id: 5)
      @guest_project = project_with_type(id: 2, type: 4)
      @host_project = project_with_type(id: 1, type: 5)
      @guest_project.hosts << @host_project
      @host_project.enable_module!(:table_calculation)
      @guest_project.enable_module!(:table_calculation)
    end

    def project_with_type(id:, type:)
      project = Project.find(id)
      project.project_type_id = type
      project.save
      project
    end

    def define_table_and_calculation_config
      @name_column = TableCustomField.generate!(name: 'Name', field_format: 'string')
      @count_column = TableCustomField.generate!(name: 'Count', field_format: 'int')
      @condition_column = create_colored_custom_field(name: 'Condition')
      @condition_column_values = @condition_column.enumerations.pluck(:id)
      @table_config = TableConfig.create(name: 'Equipment', description: 'IT equipment list')
      @table_config.columns << [@name_column, @count_column, @condition_column]
      # Sum calculation
      @sum_calculation_config = CalculationConfig.create(name: 'Number of devices',
                                                         description: 'Sum up the devices of a list',
                                                         formula: 'sum',
                                                         inheritable: true,
                                                         table_config_id: @table_config.id)
      @sum_calculation_config.columns << @count_column
      @table_config.calculation_configs << @sum_calculation_config # sets explicitly the has_many side
      # Max calculation
      @max_calculation_config = CalculationConfig.create(name: 'Best condition',
                                                         description: 'Find the best condition available',
                                                         formula: 'max',
                                                         inheritable: true,
                                                         table_config_id: @table_config.id)
      @max_calculation_config.columns << @condition_column
      @table_config.calculation_configs << @max_calculation_config # sets explicitly the has_many side
    end

    def generate_inheritated_spreadsheets
      [@guest_project, @host_project].each do |project|
        equipment_spreadsheet = Spreadsheet.create(name: 'Equipment list',
                                          description: "Required Equipment for #{project.name}",
                                          project_id: project.id,
                                          author_id: @jsmith.id,
                                          table_config_id: @table_config.id)
        first_row = SpreadsheetRow.create(spreadsheet_id: equipment_spreadsheet.id, position: 1)
        first_row.custom_field_values = { @name_column.id => 'Laptop',
                                          @count_column.id => 12,
                                          @condition_column.id => @condition_column_values.first }
        first_row.save
        second_row = SpreadsheetRow.create(spreadsheet_id: equipment_spreadsheet.id, position: 2)
        second_row.custom_field_values = { @name_column.id => 'Smartphone',
                                           @count_column.id => 5,
                                           @condition_column.id => @condition_column_values.last }
        second_row.save
      end
    end

    def add_spreadsheet_row_result(project)
      result = SpreadsheetRowResult.new(author_id: @jsmith.id,
                                        spreadsheet_id: project.spreadsheets.take.id,
                                        calculation_config_id: @sum_calculation_config.id,
                                        comment: '-')
      result.custom_field_values = { @count_column.id => 17 }
      result.save!
    end

    def check_guest_project_permissions
      assert @jsmith.allowed_to?(:view_spreadsheet, @guest_project)
      assert @jsmith.allowed_to?(:edit_spreadsheet_results, @guest_project)
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
        calculation_config_id: @sum_calculation_config.id,
        project_id: project.id }
    end

    def spreadsheet_row_result_params
      { spreadsheet_row_result: {
        custom_field_values: {
          @count_column.id => 17
        },
        comment: '-'
      } }
    end
  end
end
