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


module InheritanceSpreadsheetsHelper
  def render_final_result_table(members, spreadsheet)
    render partial: 'calculation_results',
           locals: { table: FinalResultTable.new(members, spreadsheet) }
  end

  def render_members_result_table(members, spreadsheet)
    render partial: 'calculation_results',
           locals: { table: MembersResultTable.new(members, spreadsheet) }
  end

  def render_spreadsheet_result_table(spreadsheet)
    render partial: 'calculation_results',
           locals: { table: SpreadsheetResultTable.new(spreadsheet) }
  end

  def render_card_table(members, spreadsheet)
    render partial: 'spreadsheets/card_table',
           locals: { table: FinalResultTable.new(members, spreadsheet) }
  end
end