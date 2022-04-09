# frozen_string_literal: true

class QHash
  VERSION = "0.1.0"

  class Error < StandardError; end

  class RecordNotFound < Error; end

  include Enumerable

  def initialize(data)
    @data = data
  end

  def find_by(conditions)
    data.find do |hash|
      conditions.all? { |key, value| query(hash, key, value) }
    end
  end

  def find_by!(conditions)
    find_by(conditions) || raise(RecordNotFound)
  end

  def where(conditions)
    self.class.new(filter_by_conditions(conditions))
  end

  def each(&block)
    data.each(&block)
  end

  def inspect
    data
  end

  private

  def filter_by_conditions(conditions)
    data.select do |hash|
      conditions.all? { |key, value| query(hash, key, value) }
    end
  end

  def query(record, key, value)
    return false if record[key].nil?

    case value
    when Proc
      value.call(record[key])
    when Hash
      value.all? { |nested_key, nested_value| query(record[key], nested_key, nested_value) }
    when Array
      value.include?(record[key])
    else
      record[key] == value
    end
  end

  def top_level_keys
    @top_level_keys ||= array_of_hashes.flat_map(&:keys).uniq
  end

  attr_reader :data, :filtered_data
end
