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

require File.expand_path('../test_helper', __dir__)

module TableCaclulationInheritance
  class ProjectsControllerTest < ActionDispatch::IntegrationTest
    extend TableCalculationInheritance::LoadFixtures
    include TableCalculationInheritance::AuthenticateUser
    include TableCalculationInheritance::ProjectTypeCreator
    include TableCalculationInheritance::InheritatedSpreadsheets
    include Redmine::I18n

    fixtures :projects,
             :members, :member_roles, :roles, :users

    def setup
      setup_inheritated_spreadsheets
    end

    test 'should display spreadsheet card on projects overview page' do
      log_user('jsmith', 'jsmith')
      get project_path(@host_project.id)
      assert :success
      assert_select '.spreadsheet.box h3'
      assert_select 'table.list' do
        assert_select 'tbody tr td.name', { text: @calculation.name, count: 1 }
        assert_select 'tbody tr td:nth-of-type(2)', { text: /34/, count: 1 }
      end
      assert_select '.icon-zoom-in', 2
    end

    test 'should not display spreadsheet card on projects overview page if not allowed to' do
      @manager_role.remove_permission!(:view_spreadsheet_results)
      assert_not @manager.allowed_to?(:view_spreadsheet_results, @host_project)

      log_user('jsmith', 'jsmith')
      get project_path(@host_project.id)
      assert :success
      assert_select '.spreadsheet.box h3', 0
    end
  end
end
