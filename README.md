# QHash - [ActiveRecord](https://github.com/rails/rails/tree/main/activerecord) style query interface for Hash

[![Ruby](https://github.com/AkihikoITOH/q_hash/actions/workflows/main.yml/badge.svg)](https://github.com/AkihikoITOH/q_hash/actions/workflows/main.yml)
[![Gem Version](https://badge.fury.io/rb/q_hash.svg)](https://badge.fury.io/rb/q_hash)
[![Maintainability](https://api.codeclimate.com/v1/badges/21e195471cca64af0366/maintainability)](https://codeclimate.com/github/AkihikoITOH/q_hash/maintainability)

QHash lets you query array of hashes with ActiveRecord-like interface.

## What's the point?

We often do something like

```ruby
users.select do |user|
  (dob = user.dig(:personal_data, :date_of_birth)) &&
    dob > Date.new(1990, 1, 1) &&
    user.dig(:address, :country) == "Germany" &&
    user.dig(:address, :city) == "Hamburg"
end
```

which can quickly become hard to read.

QHash provides syntax sugar that would allow you to do

```ruby
users.where(
  personal_data: {
    date_of_birth: ->(dob) { dob > Date.new(1990, 1, 1) }
  },
  address: {country: "Germany", city: "Hamburg"}
)
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'q_hash'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install q_hash

## Usage

Let's say you have the following array of hash:
```ruby
data = [
  {
    id: "da9d517e-eb1b-4f5b-8fec-c1258eda0db2",
    personal_info: {
      name: "John Doe",
      date_of_birth: "1900-01-01"
    },
    address: {
      country: "Japan",
      city: "Tokyo"
    },
    hobbies: [
      "jogging",
      "eating",
      "sleeping"
    ]
  },
  {
    id: "fab15d98-47d6-4552-a6e6-0b83de0b532b",
    personal_info: {
      name: "John Doe Jr.",
      date_of_birth: "2000-01-01"
    },
    address: {
      country: "Japan",
      city: "Tokyo"
    },
    biometrics: {
      height: 200,
      weight: 100
    }
  }
]
```

#### `QHash#find_by`

```ruby
QHash.new(data).find_by(id: "fab15d98-47d6-4552-a6e6-0b83de0b532b")
# =>
#   {:id=>"fab15d98-47d6-4552-a6e6-0b83de0b532b",
#     :personal_info=>{:name=>"John Doe Jr.", :date_of_birth=>"2000-01-01"},
#     :address=>{:country=>"Japan", :city=>"Tokyo"},
#     :biometrics=>{:height=>200, :weight=>100}}

```

Note that `#find_by` returns the first record that matches the condition, just like `Array#find_by`.

There's also `QHash#find_by!`, which raises `QHash::RecordNotFound` in case there's no record to be found.

#### `QHash#where`

```ruby
QHash.new(data).where(personal_info: { name: 'John Doe' })
# => [{:id=>"da9d517e-eb1b-4f5b-8fec-c1258eda0db2", :personal_info=>{:name=>"John Doe", :date_of_birth=>"1900-01-01"}, :address=>{:country=>"Japan", :city=>"Tokyo"}, :hobbies=>["jogging", "eating", "sleeping"]}]
```

Note that `#where` returns an instance of `QHash`, not an array of hashes.
But no worries, `QHash` is also an [`Enumerable`](https://ruby-doc.org/core-3.1.1/Enumerable.html).

#### Proc condition
If you'd like to query by more complex conditions, you can also use `Proc`s

```ruby
QHash.new(data).where(biometrics: {height: ->(height) { height > 100 }})
# => [{:id=>"fab15d98-47d6-4552-a6e6-0b83de0b532b", :personal_info=>{:name=>"John Doe Jr.", :date_of_birth=>"2000-01-01"}, :address=>{:country=>"Japan", :city=>"Tokyo"}, :biometrics=>{:height=>200, :weight=>100}}]
```

#### Chaining `#where` and `#find_by`
You can also chain `#where` and `#find_by`:

```ruby
QHash.new(data)
      .where(address: {country: "Japan", city: ["Tokyo", "Osaka"]})
      .where(biometrics: {height: ->(height) { height > 100 }})
      .find_by(id: data.last[:id])
# =>
#   {:id=>"fab15d98-47d6-4552-a6e6-0b83de0b532b",
#     :personal_info=>{:name=>"John Doe Jr.", :date_of_birth=>"2000-01-01"},
#     :address=>{:country=>"Japan", :city=>"Tokyo"},
#     :biometrics=>{:height=>200, :weight=>100}}
```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/AkihikoITOH/q_hash. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/q_hash/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the QHash project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/AkihikoITOH/q_hash/blob/master/CODE_OF_CONDUCT.md).
