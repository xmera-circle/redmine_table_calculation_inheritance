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

module RedmineTableCalculationInheritance
  module Patches
    module SpreadsheetsControllerPatch
      def self.prepended(base)
        base.prepend InstanceMethods
        base.class_eval do
          helper :inheritance_spreadsheets
        end
      end

      module InstanceMethods
        ##
        # Adds the required project type relations needed for inheritated
        # calculations.
        #
        def index
          super
          # it may happen, that a project is included in guests, for unkown reasons yet
          @guests = @project.guests - [@project]
          @members = @project.guests.prepend(@project)
        end

        ##
        # Refers to the instance variables in SpreadsheetsController#index
        #
        def results
          index
        end
      end
    end
  end
end
