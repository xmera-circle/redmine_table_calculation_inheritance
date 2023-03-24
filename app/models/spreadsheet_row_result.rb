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
  include RedmineTableCalculation::CalculationUtils
  include Redmine::SafeAttributes
  include Redmine::I18n
  acts_as_customizable

  belongs_to :calculation_config
  belongs_to :spreadsheet
  belongs_to :author, class_name: 'User'

  validates :comment, presence: true

  after_validation :update_status
  after_validation :change_hosts_status
  after_destroy :destroy_adapted_row_values

  delegate :table_config, :project, to: :spreadsheet
  delegate :calculation_configs, to: :table_config
  delegate :host_ids, to: :project

  safe_attributes(
    :author_id,
    :spreadsheet_id,
    :calculation_config_id,
    :custom_fields,
    :custom_field_values,
    :comment
  )

  STATUS = { label_row_result_status_edited: 1,
             label_row_result_status_review: 2 }.freeze

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

  # @overridden Redmine::Acts::Customizable#available_custom_fields
  def available_custom_fields
    CustomField.where(id: calculation_column_ids).sorted.to_a
  end

  # Compare given custom field values with their current values.
  # Format: {"custom_field1.id" => "value1", "custom_field2.id" => "value2"}
  #
  # @example values.to_unsafe_hash
  #          {"28"=>"56", "44"=>"58", "45"=>"62"}
  #
  def changed_custom_field_values?(values)
    current_custom_field_values != given_custom_field_values(values)
  end

  private

  # Updates status to: 1 <=> edited when the user has edited the record.
  #
  # This method assumes that the user is not able to set the status by himself.
  # If the status would change than it is controlled through the codebase and
  # this change would pass.
  def update_status
    return if new_record?

    self.status = 1 unless status_changed?
  end

  def current_custom_field_values
    values = custom_field_values.each_with_object({}) do |custom_field_value, hash|
      value = custom_field_value.value
      custom_field = custom_field_value.custom_field
      hash[custom_field.id.to_s] = value if value
      hash
    end
    values.sort.to_h
  end

  def given_custom_field_values(values)
    safe = values.respond_to?(:to_unsafe_hash) ? values.to_unsafe_hash : values
    safe.sort.to_h
  end

  def destroy_adapted_row_values
    CustomValue.where(customized_id: id).delete_all
  end

  # Host instances of SpreadsheetRowResult will be marked to be reviewed.
  #
  # rubocop:disable Rails/SkipsModelValidations
  def change_hosts_status
    return unless custom_field_values_changed?

    SpreadsheetRowResult.no_touching do
      SpreadsheetRowResult
        .includes(:calculation_config, spreadsheet: [project: [:hosts]])
        .where(calculation_config: calculation_config_id,
               spreadsheet: { project_id: host_ids, name: spreadsheet.name })
        .update_all(status: 2)
    end
  end
  # rubocop:enable Rails/SkipsModelValidations
end
