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

module RedmineTableCalculationInheritance
  class RenderGroupedResultsTableTest < SystemTestCase
    def setup
      super
      setup_inheritated_spreadsheets
      attrs = { project: @guest_project }
      add_spreadsheet_row_result(**attrs)
      Capybara.current_session.reset!
      log_user 'admin', 'admin'
    end

    test 'should render collapsed grouped calculation results' do
      visit results_project_spreadsheet_path(project_id: @host_project.id, id: @host_project.spreadsheets.first.id)
      Capybara.match = :prefer_exact # since there are three fieldset items
      assert page.find('fieldset.collapsible.collapsed')
      visible_div = page.has_css?('fieldset.collapsible div')
      assert_not visible_div
    end

    test 'should render expanded grouped calculation results' do
      visit results_project_spreadsheet_path(project_id: @host_project.id, id: @host_project.spreadsheets.first.id)
      Capybara.match = :prefer_exact # since there are three fieldset items
      toggle = page.find('fieldset.collapsible legend')
      toggle.click
      assert page.has_css?('fieldset.collapsible div')
      assert page.has_css?('fieldset.collapsible div table')
      assert page.has_css?('.group')
    end
  end
end
