This is jho's modified version of the [Prelaunchr][prelaunchr] project.

[prelaunchr]: https://github.com/harrystech/prelaunchr
[jho]: https://jho.fr

Jho Launcher
============

The prelaunch site of [Jho][jho].

## Developer Setup

Get Ruby 2.3.3 (rbenv), bundle and install:

```no-highlight
brew update && brew upgrade ruby-build && rbenv install 2.3.3
```

Clone the repo and enter the folder (commands not shown).

Install Bundler, Foreman and Mailcatcher then Bundle:

```no-highlight
gem install bundler foreman mailcatcher
bundle
```

Copy the local `database.yml` file sample and `.env.sample`:

```no-highlight
cp config/database.yml.sample config/database.yml
cp .env.sample .env
```

Update your newly created .env file with the needed configuration
DEFAULT\_MAILER\_HOST: sets the action mailer default host as seen in
config/environment/<environment>.rb. You will minimally need this in production.
SECRET\_KEY\_BASE: sets a secret key to be used by config/initializers/devise.rb

Setup your local database:

```no-highlight
bundle exec rake db:create
bundle exec rake db:migrate
```

Start local server and mail worker:

```no-highlight
foreman start -f Procfile.dev
```

View your website at the port default `http://localhost:5000/`.
View sent mails at `http://localhost:1080/`.

### To create an admin account

In Rails console, run this command. Be careful to not use the example admin user
for security reasons. Password confirmation should match password.

`AdminUser.create!(:email => 'admin@example.com', :password => 'password', :password_confirmation => 'passwordconfirmaiton')`

You can run this locally in a Rails console for development testing.

The project is built to run on [Clevercloud][clevercloud]. Just add a
database and the correct environment variables.

## Teardown

When your prelaunch campaign comes to an end we've included a helpful `rake`
task to help you compile the list of winners into CSV's containing the email
addresses and the amount of referrals the user had.

* Run `bundle exec rake prelaunchr:create_winner_csvs` and the app will export
CSV's in `/lib/assets` corresponding to each prize group.

## Configuration

Most important settings can be set using the following environment variables:

### Clever Cloud config

* `CACHE_DEPENDENCIES` [`true`|`false`] Re-use dependencies between deploys
* `CC_RACKUP_SERVER` eg `puma`
* `CC_WORKER_COMMAND` set to `bundle exec rake jobs:work`
* `ENABLE_METRICS` [`true`|`false`] The app logs some metrics to statsd. When `true`, this will make Clever Cloud collect these metrics, and others (beta).
* `PORT` HTTP port to use (eg 8080)
* `STATIC_FILES_PATH` Path for static files, eg `/public`
* `STATIC_URL_PREFIX` URL prefix for static files, eg `/public`

### General config
* `CAMPAIGN_ENDED`  [`true`|`false`] Hide the campaign (not fully implemented)
* `CAMPAIGN_STARTED`  [`true`|`false`] Show placeholder page when `false`
* `CANONICAL_HOST` eg `staging.jho.fr`
* `DEFAULT_HOST` eg `https://staging.jho.fr`
* `DEFAULT_MAILER_HOST` eg `https://staging.jho.fr` (used in emails)
* `IP_LIMIT` How many signups to allow per IP
* `SECRET_KEY_BASE` Rails secret key
* `SMTP_HOST` SMTP server for outgoing emails, eg `smtp.mailgun.org`
* `SMTP_PASSWORD` SMTP password
* `SMTP_PORT` SMTP port
* `SMTP_USER_NAME` SMTP username
* `USERDATA_EMAIL` Email address(es) where daily report (CSV) is sent, eg `me@example,com,you@example.com`

## License

The code, documentation, non-branded copy and configuration are released under
the MIT license. Any branded assets are included only to illustrate and inspire.

Please change the artwork to use your own brand! Jho does not give you
permission to use our brand or trademarks in your own marketing.
