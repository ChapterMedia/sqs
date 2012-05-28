$:.unshift File.expand_path('..', __FILE__)
$:.unshift File.expand_path('../../lib', __FILE__)

require 'bundler/setup'
require 'sqs'
require 'rspec'
require 'webmock/rspec'
require 'date'
require 'timecop'

def sample_response(name)
  path = File.expand_path("../fixtures/#{name}.xml", __FILE__)
  File.read(path)
end
