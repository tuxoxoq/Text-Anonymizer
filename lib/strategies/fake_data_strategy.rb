require_relative 'base_strategy'
require 'faker'

class FakeDataStrategy < BaseStrategy
  def initialize 
    Faker::Config.locale = 'ru'
  end

  def call(match, type)
    case type
    when :name  then Faker::Name.first_name
    when :email then Faker::Internet.email
    when :ip    then Faker::Internet.ip_v4_address
    when :phone then Faker::PhoneNumber.cell_phone_in_e164
    when :color then match 
    else "[REDACTED]"
    end
  end
end