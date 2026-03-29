# frozen_string_literal: true

require_relative "scrapedo/version"
require_relative "scrapedo/google_builder"

module Scrapedo
  # Generates Google Search Endpoint. See {Scrapedo API}[https://scrape.do/documentation/google-search-api/search/]
  # @param token [String]
  # @param all_params [Boolean] If true, all available parameters will be included, otherwise only common parameters will be included.
  # @raise ArgumentError if token is nil or empty.
  # @example
  #   Scrapedo.google("your_token")
  #   Scrapedo.google("your_token", true)
  def self.google(token, all_params: false)
    raise ArgumentError, "Token is required" if token.nil? || token.empty?

    GoogleBuilder.new(token, all_params: all_params)
  end
end
