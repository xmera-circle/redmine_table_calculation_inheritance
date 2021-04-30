# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation.
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

class SpreadsheetRowResult < ActiveRecord::Base
  include Redmine::SafeAttributes
  acts_as_customizable

  belongs_to :calculation
  belongs_to :spreadsheet
  belongs_to :author, class_name: 'User'

  after_destroy :destroy_adapted_row_values

  validates_presence_of :comment

  safe_attributes(
    :author_id,
    :spreadsheet_id,
    :calculation_id,
    :custom_fields,
    :custom_field_values,
    :comment
  )

  def available_custom_fields
    CustomField.where(id: column_ids).sorted.to_a
  end

  private

  ##
  # TODO: delegate to table
  #
  def column_ids
    spreadsheet&.table&.column_ids
  end

  def destroy_adapted_row_values
    CustomValue.where(customized_id: id).delete_all
  end
end
