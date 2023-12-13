# Pay Lago Processor

Implements Lago support for the [Pay Gem](https://github.com/pay-rails/pay).

## Installation
Before you use this gem, make sure you are familiar with the Pay Gem, and have followed
its [installation instructions](https://github.com/pay-rails/pay/blob/main/docs/1_installation.md).

Install the gem and add to the application's Gemfile by executing:

    $ bundle add pay-lago

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install pay-lago

## Usage
### Using Pay with Lago

Lago works somewhat differently than the other payment processors so it comes with some limitations and differences.

* Lago itself doesn't handle payments, but can be set up to trigger them through other services (Stripe etc.)
  - Currently Pay doesn't provide an interface for setting up payment processors in Lago.
  - Payment providers will have to be configured directly with the Lago API or UI.
* Lago subscriptions do not have trials etc.
* Charges are mapped to Lago invoices.
* Some features require [Lago Premium](https://www.getlago.com/pricing) to function correctly.
* Wherever Lago requires an external_id, Pay will use the [GlobalID](https://github.com/rails/globalid) of the corresponding Pay object.
  - This is unless the object already has processor_id set, in which case it'll use that.

### Configuration

Lago requires an API key for it's client to work. This can be found at [/developers]() on your Lago instance.

If you are using Lago self-hosted, you will also need to provide the url to your API instance.

```yaml
# Configuration for Lago in Rails Credentials.
lago:
  api_key: <YOUR API KEY>
  api_url: <YOUR API URL>
```

```bash
# Configuration for Lago in Environment Variables
LAGO_API_URL="<YOUR API URL>" LAGO_API_KEY="<YOUR API KEY>" rails server
```

If your configuration is correct, `Pay::Lago.valid_auth?` will be true.

### Docs
See [Pay Gem](https://github.com/pay-rails/pay) for main pay docs.

- [Customer](docs/1_customers.md)
- [Charges](docs/2_charges.md)
- [Subscriptions](docs/3_subscriptions.md)
- [Webhooks](docs/4_webhooks.md)

### Using the Lago API Client

Pay automatically configures an instance of the Lago Client for use across the module. However, the same client can be accessed
for direct use of the [Lago API](https://docs.getlago.com/api-reference/intro).

The client instance can be accessed from `Pay::Lago.client`.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/demingfactor/pay-lago. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/demingfactor/pay-lago/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Pay::Lago project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/demingfactor/pay-lago/blob/master/CODE_OF_CONDUCT.md).
