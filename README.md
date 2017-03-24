# Aem

This gem is used to help out with interacting with the AEM server

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'aem', github: 'indellient/aem'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install aem

## Usage

This can be used as a CLI, or within another project.

### CLI

Helpful information.
```
aem help
```

Display all packages.
```
aem packages
```

Filter out package based on property key, value, key defaults to package name.
```
aem package <value> <key>
```

Build a specific package by name.
```
aem build <package-name>
```

Download a specific package by name
```
aem download <package-name>
```

Upload a package by path and name
```
aem upload <path-to-package> <package-name>
```

Install a specific package by name
```
aem install <package-name>
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/indellient/aem.

