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

class FrozenResultTablesColumn
  include Enumerable

  def initialize(**attrs)
    @column = attrs[:column]
    @calculation_config = attrs[:calculation_config]
  end

  # Position of the column in the table
  def index
    map(&:column_index).uniq[0]
  end

  # Custom field id for this column
  def id
    map(&:column_id).uniq[0]
  end

  # Raw values of FrozenResultTableCells in this column
  def values
    map(&:value)
  end

  # Format of the underlying custom field
  def format
    map(&:format).uniq[0]
  end

  # Custom field object
  def custom_field
    map(&:custom_field).uniq[0]
  end

  # Is the column relevant for the given calculation?
  def calculable?(calculation_config)
    return false unless id

    calculation_config.column_ids.include? id
  end

  # Allows to iterate through FrozenResultTableCell instances
  def each(&block)
    column.each(&block)
  end

  private

  attr_reader :column, :calculation_config
end
