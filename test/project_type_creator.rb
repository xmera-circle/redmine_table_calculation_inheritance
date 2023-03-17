# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation Inheritance.
#
# Copyright (C) 2021-2023  Liane Hampe <liaham@xmera.de>, xmera Solutions GmbH.
#
# This program is free software; you can redistribute it and/or
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
  ##
  # Create project types since fixtures does not work due to missing
  # project_type table
  #
  module ProjectTypeCreator
    def project_with_type(id:, type:)
      project = Project.find(id)
      project.project_type_id = type
      project.save
      project
    end

    def find_project_type(id:)
      project_type = ProjectType.find(id)
      project_type.is_project_type = true
      project_type.save
      project_type
    end

    def project_type_params(name:)
      { project: project_type_attributes(name: name) }
    end

    def create_project_type(name:)
      ProjectType.create(project_type_attributes(name: name))
    end

    def project_type_attributes(name:)
      { name: name,
        identifier: name.parameterize,
        is_project_type: true }
    end
  end
end
