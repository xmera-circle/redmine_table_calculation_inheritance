# frozen_string_literal: true

# This file is part of the Plugin Redmine Table Calculation.
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

class SpreadsheetRowResult < ActiveRecord::Base
  include Redmine::I18n
  include Redmine::SafeAttributes
  acts_as_customizable

  belongs_to :calculation_config
  belongs_to :spreadsheet
  belongs_to :author, class_name: 'User'

  after_validation :update_status
  after_destroy :destroy_adapted_row_values

  validates :comment, presence: true

  safe_attributes(
    :author_id,
    :spreadsheet_id,
    :calculation_config_id,
    :custom_fields,
    :custom_field_values,
    :comment
  )

  STATUS = { label_row_result_status_new: 1,
             label_row_result_status_unchanged: 2,
             label_row_result_status_changed: 3 }.freeze

  # Translates the database value for status via the mapped
  # label in an understandable value for the user.
  def status
    l(STATUS.key(read_attribute(:status)))
  end

  ##
  # Is required by ApplicationHelpers#format_object.
  #
  def visible?
    true
  end

  def available_custom_fields
    CustomField.where(id: column_ids).sorted.to_a
  end

  private

  def update_status
    return if new_record?

    self.status = custom_field_values_changed? ? 3 : 2
  end

  ##
  # TODO: delegate to table
  #
  def column_ids
    spreadsheet&.table_config&.column_ids
  end

  def destroy_adapted_row_values
    CustomValue.where(customized_id: id).delete_all
  end
end
