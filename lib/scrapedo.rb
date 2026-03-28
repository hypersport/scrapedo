# frozen_string_literal: true

require_relative "scrapedo/version"
require_relative "scrapedo/google_builder"

module Scrapedo
  def self.google(token)
    raise ArgumentError, "Token is required" if token.nil? || token.empty?

    GoogleBuilder.new(token)
  end
end
