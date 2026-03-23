require 'bundler/setup'
require 'colorize'
require_relative 'lib/text_anonymizer'
require_relative 'lib/strategies/fake_data_strategy'
require_relative 'lib/strategies/colorize_strategy'

input = ""


if ARGV.empty?
  
  puts "💡 Подсказка: можно передать текст: ruby main.rb 'текст' или файл: ruby main.rb -f text.txt\n".gray
  input = "Красный закат над синим морем. Артем (ivan@mail.ru) зашел с IP 1.1.1.1 и звонил на 89991234567."

elsif ARGV[0] == '-f' || ARGV[0] == '--file'
  
  filename = ARGV[1]
  if filename && File.exist?(filename)
    input = File.read(filename)
    puts "📂 Читаем данные из файла: #{filename}\n".gray
  else
    puts "❌ Ошибка: Файл '#{filename}' не найден!".red
    exit 
  end

else
  
  input = ARGV.join(' ')
end



anonymizer = TextAnonymizer.new(FakeDataStrategy.new)
safe_text = anonymizer.process(input)


colorizer = TextAnonymizer.new(ColorizeStrategy.new)
final_result = colorizer.process(safe_text)




puts "\n--- ОРИГИНАЛ ---".blue
puts input

puts "\n--- РЕЗУЛЬТАТ ---".green
puts final_result