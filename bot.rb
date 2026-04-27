require 'telegram/bot'
require 'open-uri'
require 'faraday/multipart'
require_relative 'lib/text_anonymizer'
require_relative 'lib/strategies/fake_data_strategy'
require_relative 'lib/strategies/colorize_strategy'

token = ENV['BOT_TOKEN']

fake_anonymizer = TextAnonymizer.new(FakeDataStrategy.new)
color_anonymizer = TextAnonymizer.new(ColorizeStrategy.new)

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    
    # 1. ОБРАБОТКА ТЕКСТА И КОМАНД
    if message.text
      if message.text == '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Готово! Напиши текст, скинь .txt файл или добавь новое имя командой:\n/add_name Имя")

      elsif message.text =~ /^\/add_name\s+(.+)$/i
        new_name = $1.strip.capitalize
        
        File.open('names.txt', 'a') { |f| f.puts(new_name) }
        
        fake_anonymizer.refresh!
        color_anonymizer.refresh!

        bot.api.send_message(chat_id: message.chat.id, text: "✅ Имя '#{new_name}' добавлено в список исключений.")

      else
        step1 = fake_anonymizer.process(message.text)
        final = color_anonymizer.process(step1)
        bot.api.send_message(chat_id: message.chat.id, text: final)
      end

    # 2. ОБРАБОТКА ФАЙЛОВ
    elsif message.document
      if message.document.file_name.end_with?('.txt') || message.document.mime_type == 'text/plain'
        bot.api.send_message(chat_id: message.chat.id, text: "📂 Файл получен, обрабатываю...")
        
        begin
          file_info = bot.api.get_file(file_id: message.document.file_id)
          file_url = "https://api.telegram.org/file/bot#{token}/#{file_info.file_path}"
          
          downloaded_text = URI.open(file_url).read.force_encoding('UTF-8')
          
          step1 = fake_anonymizer.process(downloaded_text)
          final_text = color_anonymizer.process(step1)
          
          output_filename = "safe_#{message.document.file_name}"
          
          File.write(output_filename, "\xEF\xBB\xBF" + final_text)
          
          bot.api.send_document(
            chat_id: message.chat.id, 
            document: Faraday::UploadIO.new(output_filename, 'text/plain')
          )
          
          File.delete(output_filename) if File.exist?(output_filename)
        rescue => e
          bot.api.send_message(chat_id: message.chat.id, text: "❌ Ошибка при обработке файла: #{e.message}")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, text: "⚠️ Отправляй только текстовые файлы формата .txt")
      end
    end

  end
end