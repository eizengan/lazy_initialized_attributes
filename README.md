# LazyLoadAttributes

Simple "Ruby core"-inspired syntactic sugar for defining cached, lazy-loaded attributes which intuitively handle inheritence and attribute redefinition.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'lazy_load_attributes'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install lazy_load_attributes

## Usage

The class-level `lazy_attr_reader` method defines a lazy-loaded attribute.
The class-level `lazy_attr_accessor` method additionally defines a setter for the lazy-loaded attribute.
The instance-level `eager_load_attributes!` method eager loads all lazy-loaded attributes which haven't been loaded.

A simple use-case:

```ruby
require "lazy_load_attributes"

class Example
  extend LazyLoadAttributes

  lazy_attr_reader(:lazy_attr) { puts "loaded"; lazy_attr_method }

  def lazy_attr_method
    "lazy value"
  end
end

example = Example.new
example.lazy_attr
# loaded
# => "lazy value"
example.lazy_attr
# => "lazy value"
```

This illustrates four major powers of LazyLoadAttributes:

- the attribute calls evaluate and return their definition's initializer
- the initializer is not evaluated until the first attribute call
- the initializer is evaluated in the context of the calling instance (i.e. `example` in the sample above), so its instance methods are available during evaluation as they would be within the body of a normal instance method
- the initializer is evaluated only once; subsequent attribute calls are served from a cache

Inheritence is handled transparently:

```ruby
class Superclass
  extend LazyLoadAttributes

  lazy_attr_reader(:super_attr) { super_attr_value }
  lazy_attr_reader(:redefine_attr) { "redefine_attr from Superclass" }

  def super_attr_value
    "Superclass#super_attr_value"
  end

  def sub_attr_value
    "Superclass#sub_attr_value"
  end
end

class Subclass < Superclass
  lazy_attr_reader(:redefine_attr) { "redefine_attr from Subclass" }
  lazy_attr_reader(:sub_attr) { sub_attr_value }

  def super_attr_value
    "Subclass#super_attr_value"
  end
end

super_instance = Superclass.new
super_instance.super_attr
# => "Superclass#super_attr_value"
super_instance.redefine_attr
# => "redefine_attr from Superclass"

sub_instance = Subclass.new
sub_instance.super_attr
# => "Subclass#super_attr_value"
sub_instance.sub_attr
# => "Superclass#sub_attr_value"
sub_instance.redefine_attr
# => "redefine_attr from Subclass"
```

The call to `sub_instance.super_attr` shows that the instance methods used by an initializer respect inheritence even when the attribute itself is defined in the superclass

The call to `sub_instance.sub_attr` shows that initializers used by definitions in a subclass have access to instance methods defined in a superclass

The call to `sub_instance.redefine_attr` shows that an attribute redefined in a subclass will override its definition in the superclass

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/eizengan/lazy_load_attributes. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/eizengan/lazy_load_attributes/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the LazyLoadAttributes project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/eizengan/lazy_load_attributes/blob/main/CODE_OF_CONDUCT.md).
