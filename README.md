# Geb

Geb is a static website manager/builder named after the Egyptian god Geb, the foundation of the web.
It uses the [dry-cli](https://rubygems.org/gems/dry-cli) gem to create a command line tool.

![Geb Logo](lib/geb/samples/basic/assets/images/hero.png)

Geb, draws a symbolic connection to the ancient Egyptian god Geb, the deity of the Earth. 
Just as Geb the god provides a stable foundation for the world, software Geb offers a 
robust and essential foundation for building and managing static websites, which are the 
very bedrock of the web.


## Installation

Installing geb is as simple as installing a Ruby Gem
```bash
$ gem install geb
```

If you would like to install geb from source, follow the following steps
```bash
# clone the repository
$ git clone https://github.com/mainfram-work/geb.git
$ cd geb

# install dependencies
$ bundle install

# make sure everything works
$ rake test

# build and install the geb gem
$ rake build
$ rake install
```

## Usage

Geb has several commands to help you manage your site. running "geb help" will list the available commands.
```bash
$ geb help
Commands:
  geb build                    # Build the full site, includes pages and assets
  geb init SITE_PATH           # Initialise geb site, creates folder locations, git repository and initial file structures
  geb release                  # Builds the release version of the site (pages and assets)
  geb remote                   # Launch remote ssh session using the config file settings
  geb server                   # Start a local server to view the site output (runs build first), uses webrick
  geb upload                   # Upload the site to the remote server
  geb version                  # Print version
```

To get help for a particular command simply run.
```bash
$ geb [command] --help
```

The basic geb workflow is as follows.

```bash
# initialize a new site in the directory nexthing
$ geb init nexthing
$ cd nexthing

# build the site
$ geb build

# start a local web server to access your built site
$ geb server

# build a release version of the site
$ geb release

# upload the released site to your remote server
$ geb upload
```
## Geb Site Configuration

Every geb site has a configuration file in the root of the site.  The file is called **geb.config.yml**
The geb command will use values in the configuration file over the default values in almost all cases.

Check out a [sample geb configuration file](lib/geb/samples/geb.config.yml) for detailed description of all configuration items.

## Site Templates

Geb has a concept of site templates.  Think of it as a way to share site designs, libraries and content.
Geb comes with a set of site templates, distributed with the geb gem. These are:

- **basic** - this is a default template, provides a simple site structure and placeholders for various concepts such as headers, footers, javascript and css and so on.
- **bootstrap_jquery** - a site template with bootstrap 5 and jquery 3.7, along with example pages.

To use one of the built-in templates, simply pass the name to the geb init command
```bash
$ geb init new_site --template bootstrap_jquery
```
If you do not specify a site template, geb will use basic template that comes bundled with the geb gem.

Site templates can also be other sites you have developed. To 


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/geb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/geb/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Geb project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/geb/blob/main/CODE_OF_CONDUCT.md).

cat extensions.list | xargs -L 1 code --install-extension