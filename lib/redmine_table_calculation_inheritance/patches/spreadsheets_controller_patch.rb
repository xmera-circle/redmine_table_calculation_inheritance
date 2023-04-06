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

module RedmineTableCalculationInheritance
  module Patches
    module SpreadsheetsControllerPatch
      def self.prepended(base)
        base.prepend InstanceMethods
        base.class_eval do
          helper :inheritance_spreadsheets
        end
      end

      module InstanceMethods
        ##
        # Refers to the instance variables in SpreadsheetsController#index
        # but renders results.html.erb
        #
        def results
          index

          project_guests = @project.guests
          # it may happen, that a project is included in guests, for unkown reasons yet
          @guests = project_guests - [@project]
          @members = project_guests.prepend(@project)
          @spreadsheet_result_rows = @spreadsheet.result_rows
          @spreadsheet_query = SpreadsheetQuery.new(host_project: @project,
                                                    host_spreadsheet: @spreadsheet,
                                                    guest_projects: @guests)
          @spreadsheet_row_result_query = SpreadsheetRowResultQuery.new(host_spreadsheet: @spreadsheet,
                                                                        guest_projects: @guests)
        end

        def grouped_results
          results
          table = GroupedResultsTable.new(query: @spreadsheet_query,
                                          spreadsheet: @spreadsheet,
                                          data_table: @data_table)
          render partial: 'grouped_results', locals: { table: table }
        end
      end
    end
  end
end
