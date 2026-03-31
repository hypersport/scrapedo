# Scrapedo

[![Ruby](https://github.com/hypersport/scrapedo/workflows/Ruby/badge.svg)](https://github.com/hypersport/scrapedo/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/scrapedo.svg)](https://badge.fury.io/rb/scrapedo)

An unofficial Ruby gem designed to provide a convenient interface for Ruby developers.
It eliminates the need to handle complex HTTP requests and parsing logic, allowing you to easily access data from the Scrapedo API (currently supports only Google Search API) within your applications.

It supports **ALL** parameters of the [Scrapedo's Google Search API](https://scrape.do/documentation/google-search-api/search/).

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add scrapedo

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install scrapedo

## Usage

`scrapedo` supports **ALL** parameters of the [Scrapedo's Google Search API](https://scrape.do/documentation/google-search-api/search/).
Every parameter **MUST** meet scrapedo's requirements.

See [Scrapedo Document](https://rubydoc.info/github/hypersport/scrapedo) for more details.

Example: Search for "scracedo" on google.com.hk, with the search period set to within one week, the device type as mobile phone, the interface language as Japanese, and the country as South Korea.
```ruby
client = Scrapedo.google('your_token')
puts client.search('scracedo').domain_hong_kong.week.mobile.hl_ja.gl_kr.start
while client.next?
  puts client.next
end
```

Below is the detailed explanation of all methods:

Create a Google search client with your token, this will return a `GoogleBuilder` instance and use common parameters by default:
```ruby
client = Scrapedo.google('your_token')
```

If you want to use [all available parameters](https://scrape.do/documentation/google-search-api/localization/), you can pass `true` as the second argument:
```ruby
client = Scrapedo.google('your_token', true)
```

`search` method is required.
See [Required Parameters](https://scrape.do/documentation/google-search-api/search/#required):
```ruby
client.search('your_query')
```

`start` method is used to start scraping from a specific position, default is `0`, (0..9) will set 0, (10..19) will set 10, etc.
See [General Parameters](https://scrape.do/documentation/google-search-api/search/#general):
```ruby
client.start
```

`scrapedo_url` method displays the url which is used to make the request:
```ruby
# https://api.scrape.do/plugin/google/search?token=#{token}&q=your_query&device=mobile&time_period=last_day
client.search('your_query').day.mobile.scrapedo_url
```

`next?` method is used to check if there are more pages:
```ruby
client.next?
```

`next` method is used to get the next page if `next?` returns `true`:
```ruby
client.next
```

`device` method specifies the device type for SERP layout, accepted values: desktop, mobile, default is desktop.
See [General Parameters](https://scrape.do/documentation/google-search-api/search/#general):
```ruby
client.device("desktop")
# or
client.desktop
```

`time` method limits results to a specific recency window, accepted values: last_hour, last_day, last_week, last_month, last_year.
See [Time-Based Filtering](https://scrape.do/documentation/google-search-api/localization/#time-based-filtering):
```ruby
client.time("last_day")
# or
client.last_day
# or
client.day
```

`include_html` method lets the result include the raw Google HTML, useful for debugging and custom parsing.
See [General Parameters](https://scrape.do/documentation/google-search-api/search/#general):
```ruby
client.include_html
```

`safe_search` method is used to filter adult content from results.
See [Result Filtering](https://scrape.do/documentation/google-search-api/search/#result-filtering):
```ruby
client.safe_search
```

`enable_nfpr` method enables Google's automatic spelling correction.
See [Result Filtering](https://scrape.do/documentation/google-search-api/search/#result-filtering):
```ruby
client.enable_nfpr
```

`disable_filter` method disables "Similar Results" and "Omitted Results" filters.
See [Result Filtering](https://scrape.do/documentation/google-search-api/search/#result-filtering):
```ruby
client.disable_filter
```

`hl` and `host_language` is the host language of the Google UI, default is en.
Supports 150+ languages. ISO 639-1 codes. This can also use GoogleBuilder#hl_{language}.
See [Language Parameter](https://scrape.do/documentation/google-search-api/localization/#language-parameter-hl).
```ruby
client.hl("en")
client.host_language("en")
client.hl_en
client.hl_english

# Follows must set all_params to true
client.hl("ach")
client.host_language("ach")
client.hl_ach
client.hl_luo
```

`gl` and `geo_location` is the geo location (datacenter country), determines from which country's perspective results are ranked and returned,
default is us. Supports 240+ countries. ISO 3166-1 alpha-2 codes. This can also use GoogleBuilder#gl_{location}.
See [Country Parameter](https://scrape.do/documentation/google-search-api/localization/#country-parameter-gl]).
```ruby
client.gl("us")
client.geo_location("us")
client.gl_us
client.gl_united_states

# Follows must set all_params to true
client.gl("cl")
client.geo_location("cl")
client.gl_cl
client.gl_chile
```

`lr` and `language_restrict` is Language Restrict which applies strict language filtering, only results written in the specified language are returned.
Supports 35 languages. This can also use GoogleBuilder#lr_{language}.
See [Language Restrict Parameter](https://scrape.do/documentation/google-search-api/localization/#language-restrict-parameter-lr).
```ruby
client.lr("en")
client.language_restrict("en")
client.lr_english
```

`cr` and `country_restrict` is Country Restrict which applies strict country filtering, only results originating from the specified country are returned.
Supports 240+ countries. This can also use GoogleBuilder#cr_{country}.
See [Country Restrict Parameter](https://scrape.do/documentation/google-search-api/localization/#country-restrict-parameter-cr).
```ruby
client.cr("countryUS")
client.country_restrict("countryUS")
client.cr_us
client.cr_united_states

# Follows must set all_params to true
client.cr("countryAL")
client.country_restrict("countryAL")
client.cr_al
client.cr_albania
```

`domain` and `google_domain` is Google domain to query, prefixes `https://`, `http://` and `www.` are automatically stripped, default is `google.com`.
Supports 84 regional domains. This can also use GoogleBuilder#domain_{location}.
See [Supported Google Domains](https://scrape.do/documentation/google-search-api/localization/#supported-google-domains).
```ruby
client.domain("google.com.hk")
client.google_domain("google.com.hk")
client.domain_hong_kong
```

`location` is used to set location name in Google's canonical format, automatically encoded to UULE internally.
See [Location](https://scrape.do/documentation/google-search-api/localization/#location).
```
Format:
    City,State/Region,Country
Examples:
    [Istanbul,Istanbul,Turkey]
    [New York,New York,United States]
```

`uule` is used to set Google UULE-encoded location string, auto-generated from location when not provided.
If both location and uule are sent, uule takes priority. `location` method is sufficient for most use cases.
See [uule](https://scrape.do/documentation/google-search-api/localization/#uule).

`params` method sets any parameter from the [Scrapedo's Google Search API](https://scrape.do/documentation/google-search-api/search/).
```ruby
client.params(device: "desktop", hl: "en", gl: "us")
# or
client.params({ device: "desktop", hl: "en", gl: "us" })
```

## Notes

First of all, thanks to [Scrape.do](https://scrape.do) for their wonderful service.
Just as it is written on their website, Scrape.do is the ultimate toolkit for collecting public data at scale. Unmatched speed, unbeatable prices, unblocked access.

Their free plan includes 1,000 successful API calls per month with every Scrape.do feature and no credit card required.
These free credits are just enough for me. Therefore, I did not test all the functions of this Gem.

If you find any issues or have any suggestions, please feel free to submit an issue and a pull request.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, just run `bundle exec rake install`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/hypersport/scrapedo. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/hypersport/scrapedo/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Scrapedo project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/hypersport/scrapedo/blob/master/CODE_OF_CONDUCT.md).
