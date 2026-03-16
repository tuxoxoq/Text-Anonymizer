require 'colorize'
require_relative 'lib/text_anonymizer'
require_relative 'lib/strategies/fake_data_strategy'

#Готовим данные
raw_text = "Контакт: ivan_ivanov@mail.ru, телефон: +7 999 123 45 67, IP: 192.168.1.1"

#Выбираем стратегию (Случайные данные)
strategy = FakeDataStrategy.new
anonymizer = TextAnonymizer.new(strategy)

#Запускаем
puts "--- ОРИГИНАЛ ---".blue
puts raw_text

clean_text = anonymizer.process(raw_text)

puts "\n--- РЕЗУЛЬТАТ (Strategy: FakeData) ---".green
puts clean_text