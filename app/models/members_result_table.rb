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

class MembersResultTable < SpreadsheetResultTable
  attr_reader :name, :members

  def initialize(members, spreadsheet)
    @name = spreadsheet.name
    @members = members
    super(spreadsheet)
  end

  ##
  # Rows are collected over member spreadsheets. Hence,
  # all calculations will be based on these rows.
  #
  def rows(_calculation_id = nil)
    collection = []
    members.each do |member|
      collection << member_rows(member)
    end
    collection.flatten.compact
  end

  def member_rows(member)
    # Observer the usage of this line. Maybe comment it out.
    return member_result_rows(member) if member_result_rows(member)

    member_spreadsheet_rows(member)
  end

  def member_result_rows(member)
    results = spreadsheet_of(member)&.result_rows&.split&.flatten
    results.present? ? results : nil
  end

  def member_spreadsheet_rows(member)
    spreadsheet_of(member)&.rows&.split&.flatten
  end

  private

  def spreadsheet_of(member)
    member.spreadsheets.find_by(name: name)
  end
end
