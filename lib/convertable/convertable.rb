require 'units/metric_units'
require 'units/imperial_units'

require 'numeric/numeric_units'

module Convertable
  def convert_default(value, unit_id, type)
    type ||= "Imperial"
    actual_unit = unit_sym(unit_id, type)
    value.to_f.send(:from, actual_unit).send(unit_id.to_sym)
  rescue => e
    Rails.logger.error e.inspect
    nil
  end

  def convert(value, unit_id, type)
    type ||= "Imperial"
    target_unit = unit_sym(unit_id, type)
    value.to_f.send(:from, unit_id.to_sym).send(target_unit)
  rescue => e
    Rails.logger.error e.inspect
    nil
  end

  def unit_sym(unit_id, type)
    type ||= "Imperial"
    ("#{type}Units").constantize::send(unit_id.to_sym)
  rescue => e
    Rails.logger.error e.inspect
    nil
  end

  def unit(unit_id, type)
    type ||= "Imperial"
    raw ("#{type}Units").constantize::send(unit_id.to_sym).to_s.sub('__', '/').sub('_', '&middot;').sub('2', '&sup2;').sub('3', '&sup3;')
  rescue => e
    Rails.logger.error e.inspect
    nil
  end
end
