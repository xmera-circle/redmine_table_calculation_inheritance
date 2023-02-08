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

require File.expand_path('lib/redmine_table_calculation_inheritance', __dir__)

Redmine::Plugin.register :redmine_table_calculation_inheritance do
  name 'Redmine Table Calculation Inheritance'
  author 'Liane Hampe, xmera'
  description 'Calculate spreadsheet results cross project'
  version '0.2.4'
  url 'https://circle.xmera.de/projects/redmine-table-calculation-inheritance'
  author_url 'http://xmera.de'

  requires_redmine version_or_higher: '4.1.0'
  requires_redmine_plugin :redmine_table_calculation, version_or_higher: '0.1.0'
  requires_redmine_plugin :redmine_project_types_relations, version_or_higher: '2.0.0'

  project_module :table_calculation do
    permission :view_spreadsheet_results, { spreadsheets: %i[results index] }
    permission :edit_spreadsheet_results, { spreadsheet_row_results: %i[new create edit update] }
  end
end

RedmineTableCalculationInheritance.setup
