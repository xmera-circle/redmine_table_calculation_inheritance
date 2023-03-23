# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation.
#
# Copyright (C) 2023  Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
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

class SpreadsheetRowResultQuery
  attr_reader :relation, :host_spreadsheet, :host_project, :guest_projects

  def initialize(**attrs)
    @relation = SpreadsheetRowResult.includes(:calculation_config, spreadsheet: [:project, { rows: [:custom_values] }])
    @host_spreadsheet = attrs[:host_spreadsheet]
    @guest_projects = attrs[:guest_projects]
  end

  # @note As long as the spreadsheet name is unique for each object there will
  #       be no more than one spreadsheet for each object. This assumes also
  #       that there are no typos in a certain spreadsheet name.
  def spreadsheet_row_results
    relation
      .where(spreadsheet: { project_id: guest_project_ids, name: host_spreadsheet.name })
  end

  private

  def guest_project_ids
    guest_projects.map(&:id)
  end
end
