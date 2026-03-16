require 'faker'
require_relative 'base_strategy'

class FakeDataStrategy < BaseStrategy
  def call(match, type)
    case type
    when :email then Faker::Internet.unique.email
    when :phone then Faker::PhoneNumber.cell_phone
    when :ip    then Faker::Internet.ip_v4_address
    else "[REDACTED]"
    end
  end
end