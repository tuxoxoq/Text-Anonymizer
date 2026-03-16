require 'bundler/setup'
require 'colorize'
require_relative 'lib/text_anonymizer'
require_relative 'lib/strategies/fake_data_strategy'

def print_section(title, color)
  puts "\n" + "=" * 50
  puts title.center(50).bold.send(color)
  puts "=" * 50
end

input_text = ARGV.empty? ? nil : ARGV.join(' ')

if input_text.nil?
  input_text = "Привет! Мой email: ivan@mail.ru, тел: 89991234567. IP: 127.0.0.1"
  puts "Подсказка: ты можешь передать свой текст так: ruby main.rb 'твой текст'".gray
end

anonymizer = TextAnonymizer.new(FakeDataStrategy.new)
result = anonymizer.process(input_text)

print_section("ВХОДНЫЕ ДАННЫЕ", :blue)
puts input_text

print_section("РЕЗУЛЬТАТ", :green)
puts result.bold.white