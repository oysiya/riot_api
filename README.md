# Riot API

A Ruby wrapper around connecting to the Riot API

Early days yet, but trying to make it as modular as possible :cat:

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'riot_api'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install riot_api
```

## Usage:

Example
``
require 'riot_api'

# Create Instace of the API
ra = RiotApi::API.new :api_key => 'API_KEY_HERE', :region => 'euw', :debug => true

# Search by Summoner name
summoner_details = ra.summoner.name('Best Lux EUW')
#<Hashie::Rash id=44600324 name="Best Lux EUW" profile_icon_id=7 revision_date=1375116256000 revision_date_str="07/29/2013 04:44 PM UTC" summoner_level=6>

summoner.name # => "Best Lux EUW"
```

## ChangeLog / History / Releases

see the [CHANGELOG.md](./CHANGELOG.md) file.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

### Contributors

* None Yet :)

For more information and a complete list see [the contributor page on GitHub](https://github.com/petems/riot_api/contributors).

## License

[MIT](./LICENSE)

