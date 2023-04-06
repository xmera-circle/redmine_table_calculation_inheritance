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

module RedmineTableCalculationInheritance
  module PrepareSpreadsheetRowResults
    def prepare_spreadsheet_users
      @admin = User.find(1)
      @jsmith = User.find(2)
    end

    def prepare_spreadsheet_roles
      @manager = Role.find_by(name: 'Manager')
      @developer = Role.find_by(name: 'Developer')
    end

    def prepare_spreadsheet_permissions
      @manager.add_permission!(:view_spreadsheet)
      @manager.add_permission!(:edit_spreadsheet_results)
      @developer.add_permission!(:view_spreadsheet)
    end

    def prepare_project_relations
      @superordinated_project_type = find_project_type(id: 4)
      @guest_project = project_with_type(id: 2, type: 4)
      @superordinated_project_type.subordinates << find_project_type(id: 5)
      @host_project = project_with_type(id: 1, type: 5)
      @guest_project.hosts << @host_project
      @host_project.enable_module!(:table_calculation)
      @guest_project.enable_module!(:table_calculation)
      assert_equal 1, @host_project.guests.count
      assert_equal 1, @guest_project.hosts.count
    end

    # RedmineTableCalculation::PrepareDataTable#define_table_config
    # @return @table_config
    def prepare_table_config
      define_table_config
    end

    # RedmineTableCalculation::PrepareDataTable#define_calculation_config
    # @max_config: @quality_field
    # @min_config: @price_field
    # @sum_config: @amount_field
    #
    # @return [@max_config, @min_config, @sum_config]
    def prepare_calculation_config
      define_calculation_config
    end

    # Name:String
    # Quality:Enumeration
    # Amount:Integer
    # Price:Float
    #
    def prepare_spreadsheets
      @projects = @host_project.guests.prepend(@host_project)
      @projects.each do |project|
        Spreadsheet.generate!(name: 'Fruit Store',
                              description: 'Fruit inventory list',
                              project_id: project.id,
                              table_config_id: @table_config.id,
                              author_id: @admin.id)
      end
    end

    # RedmineTableCalculation::PrepareDataTable#default_column_content
    #
    # Host Spreadsheet
    #
    # |Name  |Quality|Amount|Price|
    # |------|-------|------|-----|
    # |Apple |value1 |4     |3.95 |
    # |Orange|value2 |6     |1.80 |
    # |Banana|value3 |8     |4.25 |
    #
    def prepare_host_spreadsheet_column_contents
      default_column_content
      prepare_spreadsheet_contents(@host_project, @columns)
    end

    # Guest Spreadsheet
    #
    # |Name  |Quality|Amount|Price|
    # |------|-------|------|-----|
    # |Apple |value3 |9     |3.95 |
    # |Orange|value2 |7     |1.80 |
    # |Banana|value1 |5     |4.25 |
    #
    def prepare_guest_spreadsheet_column_contents
      @guest_columns = {}
      @guest_columns[@name_field] = { values: %w[Apple Orange Banana] }
      @guest_columns[@quality_field] = { values: @enumeration_values.reverse }
      @guest_columns[@amount_field] = { values: [4, 6, 8].map { |i| i + 1 }.reverse }
      @guest_columns[@price_field] = { values: [3.95, 1.80, 4.25] }
      prepare_spreadsheet_contents(@guest_project, @guest_columns)
    end

    def prepare_spreadsheet_contents(project, column_contents)
      column_contents.each do |column, content|
        row_indices = [1, 2, 3]
        row_indices.each do |row_index|
          values = content[:values]
          spreadsheet = spreadsheet_by(project, 'Fruit Store')
          rows = spreadsheet.rows
          row = rows.find { |item| item.position == row_index }
          row ||= SpreadsheetRow.new(spreadsheet_id: spreadsheet.id,
                                     position: rows.count + 1)
          row.custom_field_values = { column.id => values[row_index - 1] }
          row.save!
        end
      end
    end

    # |Calculation              |Name   |Quality|Amount |Price  |
    # |-------------------------|-------|-------|-------|-------|
    # |Calculate maximum quality|nil    |value3 |nil    |nil    |
    # |Calculate sum of amount  |nil    |nil    |18     |nil    |
    # |Calculate minimum price  |nil    |nil    |nil    |nil    |
    #
    def prepare_host_frozen_result_values
      @host_results = {}
      @host_results[@max_config] = { @quality_field.id => @enumeration_values.last }
      @host_results[@sum_config] = { @amount_field.id => 18 }
      prepare_spreadsheet_row_results(@host_project, @host_results)
    end

    # |Calculation              |Name   |Quality|Amount |Price  |
    # |-------------------------|-------|-------|-------|-------|
    # |Calculate maximum quality|nil    |value3 |nil    |nil    |
    # |Calculate sum of amount  |nil    |nil    |21     |nil    |
    # |Calculate minimum price  |nil    |nil    |nil    |nil    |
    #
    def prepare_guest_frozen_result_values
      @guest_results = {}
      @guest_results[@max_config] = { @quality_field.id => @enumeration_values.last }
      @guest_results[@sum_config] = { @amount_field.id => 21 }
      prepare_spreadsheet_row_results(@guest_project, @guest_results)
    end

    def prepare_spreadsheet_row_results(project, results)
      results.each do |calculation_config, result|
        spreadsheet = spreadsheet_by(project, 'Fruit Store')
        row = SpreadsheetRowResult.new(spreadsheet_id: spreadsheet.id,
                                       calculation_config_id: calculation_config.id,
                                       comment: 'Accepted ')
        row.custom_field_values = result
        row.save!
        row
      end
    end

    def spreadsheet_by(project, name)
      project.spreadsheets.find_by(name: name)
    end
  end
end
