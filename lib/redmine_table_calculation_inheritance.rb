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

require_relative 'redmine_table_calculation_inheritance/patches/spreadsheet_patch'
require_relative 'redmine_table_calculation_inheritance/patches/spreadsheets_controller_patch'

module RedmineTableCalculationInheritance
  class << self
    def setup
      %w[spreadsheet_patch spreadsheets_controller_patch].each do |patch|
        AdvancedPluginHelper::Patch.register(send(patch))
      end
      AdvancedPluginHelper::Patch.apply do
        { klass: RedmineTableCalculationInheritance,
          method: :add_helper }
      end
    end

    private

    def spreadsheet_patch
      { klass: Spreadsheet,
        patch: RedmineTableCalculationInheritance::Patches::SpreadsheetPatch,
        strategy: :prepend }
    end

    def spreadsheets_controller_patch
      { klass: SpreadsheetsController,
        patch: RedmineTableCalculationInheritance::Patches::SpreadsheetsControllerPatch,
        strategy: :prepend }
    end

    def add_helper
      ProjectsController.send :helper, InheritanceSpreadsheetsHelper
    end
  end
end
