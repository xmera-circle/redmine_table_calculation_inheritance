# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021 - 2022  Liane Hampe <liaham@xmera.de>, xmera.
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
  attr_reader :name, :guests, :project

  def initialize(guests, project, spreadsheet)
    @guests = guests
    @project = project
    @name = spreadsheet.name
    super(spreadsheet)
  end

  ##
  # Rows are collected over guest spreadsheets. Hence,
  # all calculations will be based on these rows.
  #
  def rows(_calculation_id = nil)
    collection = project_spreadsheet_rows
    guests.each do |guest|
      collection << guest_rows(guest)
    end
    collection.flatten.compact
  end

  def guest_rows(guest)
    guest_result_rows(guest)
  end

  def guest_result_rows(guest)
    results = spreadsheet_of(guest)&.result_rows&.split&.flatten
    results.present? ? results : nil
  end

  def project_spreadsheet_rows
    spreadsheet&.rows&.split&.flatten
  end

  private

  def spreadsheet_of(guest)
    guest.spreadsheets.find_by(name: name)
  end
end
