# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
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

module TableCalculationInheritance
  module Patches
    module SpreadsheetResultTablePatch
      def self.prepended(base)
        base.prepend(InstanceMethods)
      end

      module InstanceMethods
        private

        ##
        # Provide rows for further calculation.
        # A row can be a result row or a pure spreadsheet row (accessed by super).
        #
        # @override SpreadsheetResultTable#row
        #
        def rows(calculation_id)
          single_result_row = spreadsheet.result_rows.where(calculation_id: calculation_id)
          return single_result_row if single_result_row.present?

          super
        end

        def spreadsheet_result_row(calculation_id)
          SpreadsheetRowResult.find_by(calculation_id: calculation_id,
                                       spreadsheet_id: spreadsheet.id)
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless SpreadsheetResultTable.included_modules.include?(TableCalculationInheritance::Patches::SpreadsheetResultTablePatch)
    SpreadsheetResultTable.prepend TableCalculationInheritance::Patches::SpreadsheetResultTablePatch
  end
end
