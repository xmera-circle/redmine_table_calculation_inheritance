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

module RedmineTableCalculationInheritance
  module TestObjectCreators
    def Table.generate!(attributes = {})
      @generated_table_name ||= +'Table 0'
      @generated_table_name.succ!
      table = new(attributes)
      table.name = @generated_table_name.dup if table.name.blank?
      table.description = 'A test table' if table.description.blank?
      yield table if block_given?
      table.save!
      table
    end

    def Spreadsheet.generate!(attributes = {})
      @generated_spreadsheet_name ||= +'Spreadsheet 0'
      @generated_spreadsheet_name.succ!
      sheet = new(attributes)
      sheet.name = @generated_spreadsheet_name.dup if sheet.name.blank?
      sheet.description = 'A test spreadsheet' if sheet.description.blank?
      yield sheet if block_given?
      sheet.save!
      sheet
    end
  end
end
