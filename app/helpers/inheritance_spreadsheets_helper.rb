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

module InheritanceSpreadsheetsHelper
  def render_final_result_table(guests, project, spreadsheet)
    render partial: 'final_calculation_results',
           locals: { table: FinalResultTable.new(guests, project, spreadsheet) }
  end

  def render_members_result_table(guests, project, spreadsheet)
    render partial: 'members_calculation_results',
           locals: { table: MembersResultTable.new(guests, project, spreadsheet) }
  end

  def render_member_result_table(member, spreadsheet)
    render partial: 'member_calculation_results',
           locals: { table: MemberResultTable.new(member, spreadsheet) }
  end

  def render_card_table(guests, project, spreadsheet)
    render partial: 'spreadsheets/card_table',
           locals: { table: FinalResultTable.new(guests, project, spreadsheet) }
  end

  def spreadsheet_of(member)
    member.spreadsheets.find_by(name: @spreadsheet.name)
  end

  def calculations_of(spreadsheet)
    table = spreadsheet.table || NullTable.new
    table.calculations
  end

  def custom_field_values_of(current_row)
    group = current_row.group_by(&:col_id)
    cfv = group.each_with_object({}) do |(k, v), hash|
      hash[k] = v.first ? v.first.value : ''
      hash
    end
    cfv.compact
  end
end
