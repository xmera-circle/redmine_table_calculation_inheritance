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
    module SpreadsheetPatch
      def self.prepended(base)
        base.class_eval do
          has_many :result_rows, class_name: 'SpreadsheetRowResult', dependent: :destroy
        end
      end
    end
  end
end

# Apply patch
Rails.configuration.to_prepare do
  unless Spreadsheet.included_modules.include?(TableCalculationInheritance::Patches::SpreadsheetPatch)
    Spreadsheet.prepend TableCalculationInheritance::Patches::SpreadsheetPatch
  end
end
