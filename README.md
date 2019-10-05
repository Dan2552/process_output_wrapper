# ProcessOutputWrapper

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'process_output_wrapper'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install process_output_wrapper

## Usage

Here's an example:

```
include ProcessOutputWrapper::DSL

run_this "echo hello; echo hi; echo hey" do
  whenever { line.start_with?("he") }
    .do { puts(line + " world") }
end
```

Which outputs the following:

``` ruby
hello world
hey world
```

Within the `do` block, you can toggle state on whether output should be filtered using `print_normally!` and `print_wrapped!`.

If the Ruby process is run with the environment variable `VERBOSE=true`, the output of the process would print as normal.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
