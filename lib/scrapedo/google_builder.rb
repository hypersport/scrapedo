# frozen_string_literal: true

require "net/http"
require "json"
require "yaml"

class GoogleBuilder
  CONFIG_PATH = Pathname.new(__dir__).join("config/google_builder").expand_path
  FILE_MAP = {
    time_period: "time_period.yml",
    hl: "host_language.yml",
    lr: "language_restrict.yml",
    gl: "geo_location.yml",
    cr: "country_restrict.yml",
    google_domain: "domain.yml"
  }.freeze

  def initialize(token, all_params: false)
    @has_next = false
    @token = token
    @data = {}
    @params_cache = {}
    @all_params = all_params
  end

  def next?
    @has_next
  end

  def search(query)
    raise ArgumentError, "Query is required" if blank? query

    @data[:query] = query
    self
  end

  def device(device)
    @data[:device] = device if %w[desktop mobile].include?(device)
    self
  end

  def include_html
    @data[:include_html] = true
    self
  end

  def hl(language)
    @data[:hl] = language
    self
  end
  alias host_language hl

  def gl(location)
    @data[:gl] = location
    self
  end
  alias geo_location gl

  def google_domain(domain)
    @data[:google_domain] = domain
    self
  end
  alias domain google_domain

  def location(location)
    @data[:location] = location
    self
  end

  def uule(uule)
    @data[:uule] = uule
    self
  end

  def lr(language)
    @data[:lr] = language
    self
  end
  alias language_restrict lr

  def cr(country)
    @data[:cr] = country
    self
  end
  alias country_restrict cr

  def safe_search
    @data[:safe] = "active"
    self
  end

  def enable_nfpr
    @data[:nfpr] = true
    self
  end

  def disable_filter
    @data[:filter] = false
    self
  end

  def start(start = 0)
    raise ArgumentError, "Query is required" if blank? @data[:query]

    @data[:token] = @token
    @data[:start] = start.positive? ? start / 10 * 10 : 0
    url = URI("https://api.scrape.do/plugin/google/search")
    url.query = URI.encode_www_form(@data)
    url
    # response = Net::HTTP.get(url)
    # @data.clear
    # result = JSON.parse(response)
    # @has_next = !results["pagination"]["next"].nil?
    # result
  end

  %i[desktop mobile].each do |name|
    define_method(name) do
      @data[:device] = name
      self
    end
  end

  def method_missing(name, *args, &block)
    source_type, config_data = find_config_source(name)
    if source_type
      define_singleton_method(name) do
        @data[source_type] = config_data[name]
        self
      end
      return send(name)
    end
    super
  end

  def respond_to_missing?(name, include_private = false)
    find_config_source(name)&.present? || super
  end

  def inspect
    vars = instance_variables.map do |var|
      value = instance_variable_get(var)
      "#{var}=#{value.inspect}" unless var == :@params_cache
    end.join(", ")
    "#<#{self.class}:0x#{object_id.to_s(16)} #{vars}>"
  end

  private

  def load_yaml(filename)
    if @params_cache[filename].nil?
      path = CONFIG_PATH.join(filename)
      @params_cache[filename] = if @all_params
                                  YAML.load_file(path, symbolize_names: true, aliases: true)[:all]
                                else
                                  YAML.load_file(path, symbolize_names: true, aliases: true)[:common]
                                end
    end
    @params_cache[filename]
  end

  def find_config_source(key)
    FILE_MAP.each do |type, filename|
      data = load_yaml(filename)
      return [type, data] if data.key?(key)
    end
    nil
  end

  def blank?(value)
    value.nil? || (value.respond_to?(:strip) && value.strip.empty?)
  end
end