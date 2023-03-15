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

# Suppresses ruby gems warnings when running tests
$VERBOSE = nil

# Load the Redmine helper
require File.expand_path('../../../test/test_helper', __dir__)
require File.expand_path('../../../test/application_system_test_case', __dir__)
# Load Redmine Table Calculation plugin test helper
require File.expand_path('../../../plugins/redmine_table_calculation/test/load_fixtures', __dir__)
require File.expand_path('../../../plugins/redmine_table_calculation/test/authenticate_user', __dir__)
require File.expand_path('../../../plugins/redmine_table_calculation/test/enumerations', __dir__)
require File.expand_path('../../../plugins/redmine_table_calculation/test/project_creator', __dir__)
require File.expand_path('../../../plugins/redmine_table_calculation/test/test_object_creators', __dir__)
require File.expand_path('../../../plugins/redmine_table_calculation/test/prepare_spreadsheet', __dir__)
require File.expand_path('../../../plugins/redmine_table_calculation/test/prepare_data_table', __dir__)
# Load Redmine Table Calculation Inheritance plugin test helper
require_relative 'inheritated_spreadsheets'
require_relative 'project_type_creator'

# The gem minitest-reporters gives color to the command-line
require 'minitest/reporters'
Minitest::Reporters.use!
# require "minitest/rails/capybara"
require 'mocha/minitest'

module RedmineTableCalculationInheritance
  class UnitTestCase < ActiveSupport::TestCase
    include Redmine::I18n
    extend RedmineTableCalculation::LoadFixtures
    include RedmineTableCalculation::ProjectCreator
    include RedmineTableCalculationInheritance::ProjectTypeCreator
    include RedmineTableCalculation::TestObjectCreators
    include RedmineTableCalculation::Enumerations
    include RedmineTableCalculation::PrepareDataTable
    include RedmineTableCalculation::PrepareSpreadsheet
    include RedmineTableCalculationInheritance::InheritatedSpreadsheets
  end
end
