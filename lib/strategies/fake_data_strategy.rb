require_relative 'base_strategy'

class FakeDataStrategy < BaseStrategy
  FIRST_NAMES = %w[Александр Дмитрий Максим Артем Иван Михаил Сергей Николай Алексей Андрей].freeze
  LAST_NAMES  = %w[Иванов Петров Сидоров Смирнов Кузнецов Попов Васильев Соколов Новиков Волков].freeze
  
  LATIN_LOGINS = %w[alex dmitry max artem ivan mikhail sergey nick alexey andrew vova].freeze
  FAKE_DOMAINS = %w[example.com mail.test anon.org hidden.ru].freeze

  def call(match, type)
    case type
    when :name
      "#{FIRST_NAMES.sample} #{LAST_NAMES.sample}"
    
    when :email
      
      "#{LATIN_LOGINS.sample}#{rand(10..99)}@#{FAKE_DOMAINS.sample}"
      
    when :ip 
      Array.new(4) { rand(0..255) }.join('.')
    
    when :phone 
      "+7 (9#{rand(10..99)}) #{rand(100..999)}-#{rand(10..99)}-#{rand(10..99)}"
    
    when :color 
      match
    
    else 
      "[REDACTED]"
    end
  end
end