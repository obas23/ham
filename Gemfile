source 'https://rubygems.org'
ruby '2.1.1'

gem 'rails', '4.2.0'

# Data & modeling
gem 'redis', '~> 3.2.1'

# Assets
gem 'jquery-rails', '~> 4.0.3'
gem 'turbolinks', '~> 2.5.3'

# Environment & deployment
gem 'dotenv-rails', '~> 1.0.2'
gem 'quiet_assets', '~> 1.1.0'
gem 'lograge', '~> 0.3.1'

group :production do
  gem 'rails_12factor', '~> 0.0.3'
end

group :development, :test do
  gem 'spring', '~> 1.3.2'
  gem 'spring-commands-rspec', '~> 1.0.4'
  gem 'rspec-rails', '~> 3.2.0'
end

group :test do
  gem 'mock_redis', '~> 0.14.0'
end

