require 'faker'
require_relative 'base_strategy'

class FakeDataStrategy < BaseStrategy
  def call(_match, type)
    case type
    when :email 
      Faker::Internet.unique.email
    when :ip
      Faker::Internet.ip_v4_address
    when :phone 
     
      "+7 (9#{rand(10..99)}) #{rand(100..999)}-#{rand(10..99)}-#{rand(10..99)}"
    else 
      "[REDACTED]"
    end
  end
end