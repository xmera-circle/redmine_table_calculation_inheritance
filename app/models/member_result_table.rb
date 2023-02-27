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

class MemberResultTable < SpreadsheetResultTable
  attr_reader :name, :member

  def initialize(member, spreadsheet)
    @name = spreadsheet.name
    @member = member
    super(spreadsheet)
  end

  ##
  # Rows are collected over member spreadsheets. Hence,
  # all calculations will be based on these rows.
  #
  def rows(_calculation_config_id = nil)
    collection = []
    collection << member_rows
    collection.flatten.compact
  end

  def member_rows
    member_result_rows
  end

  def member_result_rows
    results = spreadsheet&.result_rows&.split&.flatten
    results.presence
  end
end
