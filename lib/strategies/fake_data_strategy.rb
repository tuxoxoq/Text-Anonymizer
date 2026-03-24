require_relative 'base_strategy'
require 'faker'
class FakeDataStrategy < BaseStrategy
  def initialize 
    Faker::Config.locale = 'ru'
  end

  def call(match, type)
    case type
    when :name
      Faker::Name.name
    
    when :email
      Faker::Internet.email
      
    when :ip 
      Faker::Internet.ip_v4_address
    
    when :phone 
      Faker::PhoneNumber.cell_phone_in_e164
    
    when :color 
      match
    
    else 
      "[REDACTED]"
    end
  end
end