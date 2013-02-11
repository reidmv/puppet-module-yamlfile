require 'puppetx/filemapper'
require 'yaml'

require 'ruby-debug'

Puppet::Type.type(:yaml_setting).provide(:mapped) do
  include PuppetX::FileMapper

  desc "Generic filemapper provider for yaml_setting"

  def select_file
    #target
    '/tmp/test.yaml'
  end

  def self.target_files
    #target
    ['/tmp/test.yaml']
  end

  def self.properties_to_hash(array)
    hashes = Array.new
    array.each do |r|
      hashes << r[:name].split('/').reverse.inject(r[:value]) do |a,n|
        { n => a }
      end
    end
    result = Hash.new
    hashes.each do |hash|
      deep_merge!(result, hash)
    end
    result
  end

  def self.hash_to_properties(value)
    r_hash_to_properties('', value)
  end

  def self.r_hash_to_properties(key, value)
    return [{:value => value}] unless value.is_a?(Hash)
    result = Array.new
    value.each do |k,v|
      result << r_hash_to_properties(k,v).map do |elem|
        elem[:name] = elem[:name] ? "#{k}/#{elem[:name]}" : k
        elem
      end
    end
    result.flatten
  end

  def self.deep_merge!(hash1,hash2)
    hash2.each_key do |key|
      case
        when (hash1[key].is_a?(Hash) and hash2[key].is_a?(Hash))
          deep_merge!(hash1[key], hash2[key])
        when hash1[key].nil?
          hash1[key] = hash2[key]
        else
          raise "Unable to cleanly merge yaml_setting resources"
      end
    end
  end

  def self.transform_keys_to_strings(value)
    return value if not value.is_a?(Hash)
    hash = value.inject({}) do |memo,(k,v)|
      memo[k.to_s] = transform_keys_to_strings(v)
      memo
    end
    return hash
  end

  def self.parse_file(filename, contents)
    yaml = File.exists?(filename) ? YAML::load(File.read(filename)) : {}
    properties_hashes = hash_to_properties(yaml)
    properties_hashes.map! do |resource|
      resource[:target] = filename
      resource
    end
    properties_hashes
  end

  def self.format_file(filename, providers)
    properties_hashes = providers.inject([]) do |arr, provider|
      hash = Hash.new
      hash[:name]   = provider.name
      hash[:target] = provider.target
      hash[:value]  = provider.value
      arr << hash
    end
    content_hash = properties_to_hash(properties_hashes)
    transform_keys_to_strings(content_hash).to_yaml
  end

end
