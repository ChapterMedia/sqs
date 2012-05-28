# Sqs

Simple Amazon SQS client

## Installation

Add this line to your application's Gemfile:

    gem 'sqs', :github => "Mixbook/sqs"

And then execute:

    $ bundle

## Usage

In order to instantiate client you need to pass aws credentials:

```ruby
client = Sqs::Client.new config: { access_key_id: access_key_id, secret_access_key: secret_access_key }
```

Then you can run basic operations on client:

```ruby
queue = client.create_queue("foo")

message = client.send_message(queue, "This is body of a message")

message = client.receive_message(queue)

client.delete_message(message)
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## TODO

1. Implement failure responses properly
2. Implement other SQS actions
