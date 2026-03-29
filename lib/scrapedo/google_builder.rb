# frozen_string_literal: true

require "net/http"
require "json"
require "yaml"

class GoogleBuilder
  CONFIG_PATH = Pathname.new(__dir__ || ".").join("config/google_builder").expand_path
  FILE_MAP = {
    time_period: "time_period.yml",
    hl: "host_language.yml",
    lr: "language_restrict.yml",
    gl: "geo_location.yml",
    cr: "country_restrict.yml",
    google_domain: "domain.yml"
  }.freeze

  # Initializes a new instance of GoogleBuilder
  #
  # @param token [String]
  # @param all_params [Boolean] If true, all available parameters will be included, otherwise only common parameters will be included.
  def initialize(token, all_params: false)
    @has_next = false
    @data = { token: token }
    @params_cache = {}
    @all_params = all_params
  end

  # Returns +true+ if result have more pages; otherwise +false+.
  def next?
    @has_next
  end

  # Search query. See {Required Parameters}[https://scrape.do/documentation/google-search-api/search/#required].
  #
  # @note This is required!
  # @param query [String]
  # @raise ArgumentError if query is nil or empty.
  def search(query)
    raise ArgumentError, "Query is required" if blank? query

    @data.select! { |key| key == :token }
    @has_next = false
    @data[:q] = query
    self
  end

  # Device type for SERP layout. See {General Parameters}[https://scrape.do/documentation/google-search-api/search/#general].
  # Accepted values: desktop, mobile, default is desktop.
  #
  # This can also use GoogleBuilder#{device}. For example:
  # - GoogleBuilder#device("desktop") is same as GoogleBuilder#desktop.
  # - GoogleBuilder#device("mobile") is same as GoogleBuilder#mobile.
  #
  # @param device [String]
  def device(device)
    @data[:device] = device if %w[desktop mobile].include?(device)
    self
  end

  # Time Period limits results to a specific recency window. See {Time-Based Filtering}[https://scrape.do/documentation/google-search-api/localization/#time-based-filtering].
  # Accepted values: last_hour, last_day, last_week, last_month, last_year
  #
  # This can also use GoogleBuilder#{time_period}. For example:
  # - GoogleBuilder#time("last_hour") is same as GoogleBuilder#hour and GoogleBuilder#last_hour.
  # - GoogleBuilder#time("last_day") is same as GoogleBuilder#day and GoogleBuilder#last_day and GoogleBuilder#today.
  # - GoogleBuilder#time("last_week") is same as GoogleBuilder#week and GoogleBuilder#last_week.
  # - GoogleBuilder#time("last_month") is same as GoogleBuilder#month and GoogleBuilder#last_month.
  # - GoogleBuilder#time("last_year") is same as GoogleBuilder#year and GoogleBuilder#last_year.
  #
  # @param time_period [String]
  def time(time_period)
    @data[:time_period] = time_period
    self
  end

  # Result includes the raw Google HTML. Useful for debugging and custom parsing.
  # See {General Parameters}[https://scrape.do/documentation/google-search-api/search/#general].
  def include_html
    @data[:include_html] = true
    self
  end

  # Host language of the Google UI. Default is en.
  # Supports 150+ languages. ISO 639-1 codes. See {Language Parameter}[https://scrape.do/documentation/google-search-api/localization/#language-parameter-hl].
  #
  # This can also use GoogleBuilder#hl_{language}. For example:
  # - GoogleBuilder#hl("en") is same as GoogleBuilder#hl_en and GoogleBuilder#hl_english.
  # - GoogleBuilder#hl("ach") is same as GoogleBuilder#hl_ach and GoogleBuilder#hl_luo. (For this one, all_params must be true)
  #
  # GoogleBuilder#host_language is an alias for GoogleBuilder#hl.
  #
  # @param language [String]
  def hl(language)
    @data[:hl] = language
    self
  end
  alias host_language hl

  # Geo Location (datacenter country). Determines from which country's perspective results are ranked and returned. Default is us.
  # Supports 240+ countries. ISO 3166-1 alpha-2 codes. See {Country Parameter}[https://scrape.do/documentation/google-search-api/localization/#country-parameter-gl].
  #
  # This can also use GoogleBuilder#gl_{location}. For example:
  # - GoogleBuilder#gl("us") is same as GoogleBuilder#gl_us and GoogleBuilder#gl_united_states.
  # - GoogleBuilder#gl("cl") is same as GoogleBuilder#gl_cl and GoogleBuilder#gl_chile. (For this one, all_params must be true)
  #
  # GoogleBuilder#geo_location is an alias for GoogleBuilder#gl.
  #
  # @param location [String]
  def gl(location)
    @data[:gl] = location
    self
  end
  alias geo_location gl

  # Google domain to query. Prefixes [https://], [http://], and [www.] are automatically stripped. Default is google.com.
  # Supports 84 regional domains. See {Supported Google Domains}[https://scrape.do/documentation/google-search-api/localization/#supported-google-domains].
  #
  # This can also use GoogleBuilder#domain_{location}. For example:
  # - GoogleBuilder#domain("google.com") is same as GoogleBuilder#domain_united_states.
  #
  # GoogleBuilder#google_domain is an alias for GoogleBuilder#domain.
  #
  # @param domain [String]
  def domain(domain)
    @data[:google_domain] = domain
    self
  end
  alias google_domain domain

  # Location name in Google's canonical format. Automatically encoded to UULE internally.
  # See {Location}[https://scrape.do/documentation/google-search-api/localization/#location].
  #
  # Format: City,State/Region,Country
  #
  # Examples:
  #   [Istanbul,Istanbul,Turkey]
  #   [New York,New York,United States]
  #
  # @param location [String]
  def location(location)
    @data[:location] = location
    self
  end

  # Google UULE-encoded location string.
  # Auto-generated from location when not provided.
  # If both location and uule are sent, uule takes priority. location is sufficient for most use cases.
  # See {uule}[https://scrape.do/documentation/google-search-api/localization/#uule].
  #
  # @param uule [String]
  def uule(uule)
    @data[:uule] = uule
    self
  end

  # Language Restrict applies strict language filtering. Only results written in the specified language are returned.
  # Supports 35 languages. See {Language Restrict Parameter}[https://scrape.do/documentation/google-search-api/localization/#language-restrict-parameter-lr].
  #
  # This can also use GoogleBuilder#lr_{language}. For example:
  # - GoogleBuilder#lr("en") is same as GoogleBuilder#lr_en and GoogleBuilder#lr_english.
  #
  # GoogleBuilder#language_restrict is an alias for GoogleBuilder#lr.
  #
  # @param language [String]
  def lr(language)
    @data[:lr] = language
    self
  end
  alias language_restrict lr

  # Country Restrict applies strict country filtering. Only results originating from the specified country are returned.
  # Supports 240+ countries. See {Country Restrict Parameter}[https://scrape.do/documentation/google-search-api/localization/#country-restrict-parameter-cr].
  #
  # This can also use GoogleBuilder#cr_{country}. For example:
  # - GoogleBuilder#cr("countryUS") is same as GoogleBuilder#cr_us and GoogleBuilder#cr_united_states.
  # - GoogleBuilder#cr("countryAL") is same as GoogleBuilder#cr_al and GoogleBuilder#cr_albania. (For this one, all_params must be true)
  #
  # GoogleBuilder#country_restrict is an alias for GoogleBuilder#cr.
  #
  # @param country [String]
  def cr(country)
    @data[:cr] = country
    self
  end
  alias country_restrict cr

  # Send active to filter adult content from results.
  def safe_search
    @data[:safe] = "active"
    self
  end

  # Enables Google's automatic spelling correction.
  def enable_nfpr
    @data[:nfpr] = true
    self
  end

  # Disables "Similar Results" and "Omitted Results" filters.
  def disable_filter
    @data[:filter] = false
    self
  end

  # Start scraping from a specific offset.
  # See {General Parameters}[https://scrape.do/documentation/google-search-api/search/#general].
  #
  # @param start [Integer] The offset to start from. Default is 0.
  # @raise ArgumentError If the search query is not set.
  # @return [JSON] The search results starting from the specified offset.
  def start(start = 0)
    raise ArgumentError, "Query is required" if blank? @data[:q]

    @data[:start] = start.positive? ? start / 10 * 10 : 0
    response = Net::HTTP.get(scrapedo_url)
    result = JSON.parse(response)
    @has_next = !result["pagination"]["next"].nil?
    result
  end

  # Gets next page if result has next page.
  #
  # @return [JSON] The next page of results.
  def next
    start(@data[:start] + 10) if next?
  end

  %i[desktop mobile].each do |name|
    define_method(name) do
      @data[:device] = name
      self
    end
  end

  # Set any parameter from {Google Search API}[https://scrape.do/documentation/google-search-api/search/].
  #
  # @param params [Hash] A hash of parameters to set.
  def params(*params)
    params.first.each do |key, value|
      key_sym = key.to_sym
      @data[key_sym] = value if key_sym != :token && key_sym != :start && !value.nil?
    end
    self
  end

  # Returns the URL to be used for the request.
  def scrapedo_url
    url = URI("https://api.scrape.do/plugin/google/search")
    url.query = URI.encode_www_form(@data)
    url
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
                                  YAML.safe_load_file(path, symbolize_names: true, aliases: true)[:all]
                                else
                                  YAML.safe_load_file(path, symbolize_names: true, aliases: true)[:common]
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
