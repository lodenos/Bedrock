# Cocaine

Cocaine is a light framework written in Crystal 1.0.0 that aims to be the most optimised, fastest and easy to use.
The Cocaine framework makes extensive use of metaprogramming to generate the code just needed to find the exact match.
Using the framework is so easy that you don't even need any code anymore.
You just have to describe how your API REST works with an array of Hashliteral and a single method to call.
You will only have to deal with the final behavior during a match.
Currently this is a Beta version, however the first speed tests are pretty good, the framework is able to respond to around 200000 req/sec on Intel i7-7820HQ (8) @ 2.90GHz.
There is still work to be done to provide a great APX experience, if you have the idea for improvement do not hesitate to do a pullrequest.

## Installation

1. Add the dependency to your `shard.yml`:

```yaml
  dependencies:
    cocaine:
      github: Minva/Cocaine
```

2. Run `shards install`

## Usage

```crystal
require "Cocaine"
```

TODO: Write usage instructions here

## Development

TODO: Write development instructions here

## Contributing

1. Fork it (<https://github.com/Minva/Cocaine/fork>)
2. Create your feature branch (`git checkout -b feature/my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin feature/my-new-feature`)
5. Create a new Pull Request

## Contributors

- [lodenos](https://github.com/lodenos) - creator and maintainer
