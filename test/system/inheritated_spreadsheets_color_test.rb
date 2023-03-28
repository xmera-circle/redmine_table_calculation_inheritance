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

require File.expand_path('../test_helper', __dir__)

module TableCaclulationInheritance
  class InherentedSpreadsheetColorTest < ApplicationSystemTestCase
    include RedmineTableCalculation::Enumerations
    include RedmineTableCalculationInheritance::ProjectTypeCreator
    include RedmineTableCalculationInheritance::InheritatedSpreadsheets

    fixtures %i[projects users email_addresses roles members member_roles
                trackers projects_trackers enabled_modules issue_statuses issues
                enumerations custom_fields custom_values custom_fields_trackers
                watchers journals journal_details versions
                workflows]

    def setup
      super
      setup_inheritated_spreadsheets
      attrs = { project: @guest_project }
      add_spreadsheet_row_result(**attrs)
      Capybara.current_session.reset!
      log_user 'admin', 'admin'
    end

    test 'should render custom field enumeration color badge in result row' do
      visit results_project_spreadsheet_path(project_id: @host_project.id, id: @host_project.spreadsheets.first.id)
      expected_color = 'rgba(0, 102, 204, 1)' # blue
      Capybara.match = :first # since there are four badges (2 x blue, 2 x green)
      current_color = page.find('.enumeration-badge td').style('background-color')['background-color']
      assert_equal expected_color, current_color
    end

    test 'should render collapsed single calculation results' do
      visit results_project_spreadsheet_path(project_id: @host_project.id, id: @host_project.spreadsheets.first.id)
      Capybara.match = :prefer_exact # since there are three fieldset items
      toggle = page.find('fieldset.collapsible.collapsed')
      assert toggle
      visible_div = page.has_css?('fieldset.collapsible.collapsed div')
      assert_not visible_div
    end
  end
end
