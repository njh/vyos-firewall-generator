$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'bundler'
require 'json'
require 'simplecov'
require "minitest/autorun"

SimpleCov.start do
  add_filter '/test/'
end

def fixture_path(name)
  File.join(__dir__, 'fixtures', name.to_s)
end

def fixture(name)
  File.read(fixture_path(name))
end

def json_fixture(name)
  JSON.parse(fixture(name))
end
