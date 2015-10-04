HAM
===

## Getting Started

**Install Ruby 2.1.1:**

```
$ brew install rbenv
$ brew install ruby-build
$ eval "$(rbenv init -)"
$ rbenv install 2.1.1
```

**Clone the project:**

```
$ git clone git@github.com:caseyohara/ham
$ cd ham
```

**Fetch dependencies:**

```
$ bundle install
```

**Run the tests:**

```
$ bin/ham test
```

If everything is green, you're in good shape.


**Start the server:**

```
$ bin/ham server
```

If the server starts and you're able to open [http://localhost:9292](http://localhost:9292) without issue, then you're in good shape.


## Testing

Unit testing uses [RSpec](http://rspec.info/) as the testing framework.

```
$ rspec spec
```

# API

Base endpoint: `/api`

Specs are avaiable for the API surface area and response payloads in the [specs](spec/ham/web/api_spec.rb)


## Routes:

```
GET     /api/gifs                       # List all gifs
POST    /api/gifs                       # Create gif
GET     /api/gifs/:gif_id               # Get gif
GET     /api/gifs/:gif_id/tags          # List gif tags
POST    /api/gifs/:gif_id/tags          # Create gif tag
DELETE  /api/gifs/:gif_id/tags/:tag_id  # Delete gif tag
GET     /api/tags                       # List all tags
GET     /api/tags/complete              # Autocomplete tags by searching
```

