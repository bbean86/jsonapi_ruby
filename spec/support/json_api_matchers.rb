require 'rspec/expectations'

RSpec::Matchers.define :have_relationship do |expected|
  match do |actual|
    relationships = Hash(actual).stringify_keys['relationships']
    Hash(relationships).keys.include?(expected)
  end
end

RSpec::Matchers.define :have_data do
  match do |actual|
    data = Hash(actual).stringify_keys['data']
    data.present?
  end
end

RSpec::Matchers.define :have_meta do
  match do |actual|
    data = Hash(actual).stringify_keys['meta']
    data.present?
  end
end

RSpec::Matchers.define :have_attribute do |key_name|
  match do |actual|
    attributes = Hash(actual).stringify_keys['attributes']
    return false unless attributes.keys.include?(key_name.to_s)
    return true if @chained.blank?
    attributes[key_name.to_s] == @expected_value
  end

  chain :with_value do |key_value|
    @chained = true
    @expected_value = key_value
  end
end

RSpec::Matchers.define :be_valid_json_api do
  match do |actual|
    is_a_hash = actual.is_a?(Hash)
    actual = Hash(actual).stringify_keys
    has_id_and_type = actual['id'].present? && actual['type'].present?

    is_a_hash && has_id_and_type && actual['id'].is_a?(String)
  end
end

RSpec::Matchers.define :have_links_for do |expected|
  match do |actual|
    relationships = Hash(actual).stringify_keys['relationships']
    relation = Hash(relationships)[expected]
    Hash(relation).keys.include?('links')
  end
end
