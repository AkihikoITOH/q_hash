# frozen_string_literal: true

class QHash
  VERSION = "0.2.0"

  class Error < StandardError; end

  class RecordNotFound < Error; end

  include Enumerable

  def initialize(data)
    @data = data
  end

  def find_by(**conditions)
    data.find { |record| apply_conditions(record, conditions) }
  end

  def find_by!(**conditions)
    find_by(**conditions) || raise(RecordNotFound)
  end

  def where(**conditions)
    result = data.select { |record| apply_conditions(record, conditions) }
    self.class.new(result)
  end

  def each(&block)
    data.each(&block)
  end

  def inspect
    data
  end

  private

  attr_reader :data

  def apply_conditions(record, conditions)
    conditions.all? { |query_key, query_value| query(record, query_key, query_value) }
  end

  def query(record, key, value)
    return false unless record.key?(key)

    case value
    when Proc
      value.call(record[key])
    when Hash
      value.all? { |nested_query_key, nested_query_value| query(record[key], nested_query_key, nested_query_value) }
    when Array
      value.include?(record[key])
    else
      value == record[key]
    end
  end
end
