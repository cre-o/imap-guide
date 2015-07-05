source 'https://rubygems.org'

ruby '2.2.1'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.2.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 5.0'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .coffee assets and views
gem 'coffee-rails', '~> 4.1.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer', platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Use angular as framework
gem 'angularjs-rails', '~> 1.3.15'
gem 'angularjs-file-upload-rails', '~> 1.1.6'
gem 'ng-rails-csrf'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
# gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0', group: :doc

# SASS frameworks
gem 'foundation-rails', '~> 5.5'
gem 'semantic-ui-sass', '~> 1.12'
# Sweet mixins
gem 'bourbon'
# CSS animations
gem 'animate-rails'
# Authentication
gem 'devise', '~> 3.5.1'

# Decorations
gem 'draper', '~> 2.1.0'

# File uploads
gem 'paperclip', '~> 4.2.0' # Main server-side upload gem

# States
gem 'state_machine', '~> 1.2.0'

# JS
gem 'lodash-rails' # javascript features
gem 'gon'
gem 'js-routes'

# API
gem 'active_model_serializers'

# Icons
gem 'font-awesome-rails'

#
# ==> Template engines
#
gem 'slim-rails', '~> 3.0.1'

# Css
gem 'magnific-popup-rails', '~> 0.9'

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use Unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

source 'https://rails-assets.org' do
  gem 'rails-assets-angular-devise'
end

group :development, :test do
  gem 'guard', '>= 2.2.2', require: false
  gem 'guard-livereload',  require: false
  gem 'rack-livereload'
  gem 'rb-fsevent', require: false

  gem 'better_errors'       # Better errors for debugging
  gem 'quiet_assets'
  gem 'rails-footnotes', '>= 4', '<5' # Footnotes with dev information
  #gem 'pry-rails'           # Interactive debuging shell

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'

  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

