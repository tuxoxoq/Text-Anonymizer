require 'telegram/bot'
require 'open-uri'
require 'faraday/multipart'
require 'docx'
require_relative 'lib/text_anonymizer'
require_relative 'lib/strategies/fake_data_strategy'   # Обычный режим
require_relative 'lib/strategies/redact_strategy'      # Режим ЦРУ
require_relative 'lib/strategies/colorize_strategy'

token = ENV['BOT_TOKEN']

# Создаем все три станка для нашего конвейера
fake_anonymizer = TextAnonymizer.new(FakeDataStrategy.new)
redact_anonymizer = TextAnonymizer.new(RedactStrategy.new)
color_anonymizer = TextAnonymizer.new(ColorizeStrategy.new)

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    
    
    if message.text
      if message.text == '/start'
        bot.api.send_message(chat_id: message.chat.id, text: "Агент на связи.\n\nПросто отправь текст/файл — заменю на фейк.\nДобавь команду /censor перед текстом (или в подписи к файлу) — включу режим ЦРУ █.")

      
      elsif message.text =~ /^\/add_name\s+(.+)$/i
        new_name = $1.strip.capitalize
        File.open('names.txt', 'a') { |f| f.puts(new_name) }
        
        
        fake_anonymizer.refresh!
        redact_anonymizer.refresh!
        color_anonymizer.refresh!
        
        bot.api.send_message(chat_id: message.chat.id, text: "✅ Имя '#{new_name}' добавлено в базу.")

      
      elsif message.text.start_with?('/censor ')
        raw_text = message.text.sub('/censor ', '') 
        step1 = redact_anonymizer.process(raw_text) 
        final = color_anonymizer.process(step1)
        bot.api.send_message(chat_id: message.chat.id, text: final)

      
      else
        step1 = fake_anonymizer.process(message.text) 
        final = color_anonymizer.process(step1)
        bot.api.send_message(chat_id: message.chat.id, text: final)
      end

    
    elsif message.document
      file_name = message.document.file_name
      
      if file_name.end_with?('.txt') || file_name.end_with?('.docx')
        
        
        is_cia_mode = (message.caption != nil && message.caption.include?('/censor'))
        
        
        active_anonymizer = is_cia_mode ? redact_anonymizer : fake_anonymizer
        
        mode_text = is_cia_mode ? "стиле ЦРУ █" : "обычном режиме (замена на фейк)"
        bot.api.send_message(chat_id: message.chat.id, text: "📂 Файл принят. Обрабатываю в #{mode_text}...")
        
        begin
          file_info = bot.api.get_file(file_id: message.document.file_id)
          file_url = "https://api.telegram.org/file/bot#{token}/#{file_info.file_path}"
          
          
          output_filename = is_cia_mode ? "CLASSIFIED_#{file_name}" : "safe_#{file_name}"

          
          if file_name.end_with?('.txt')
            downloaded_text = URI.open(file_url).read.force_encoding('UTF-8')
            step1 = active_anonymizer.process(downloaded_text)
            final_text = color_anonymizer.process(step1)
            File.write(output_filename, "\xEF\xBB\xBF" + final_text)

          
          elsif file_name.end_with?('.docx')
            temp_input = "temp_#{file_name}"
            File.open(temp_input, 'wb') { |f| f.write(URI.open(file_url).read) }
            
            doc = Docx::Document.open(temp_input)
            
            doc.paragraphs.each do |p|
              next if p.text.nil? || p.text.empty?
              step1 = active_anonymizer.process(p.text)
              p.text = color_anonymizer.process(step1) # Применяем изменения
            end
            
            doc.save(output_filename)
            File.delete(temp_input)
          end
          
          
          bot.api.send_document(
            chat_id: message.chat.id, 
            document: Faraday::UploadIO.new(output_filename, 'application/octet-stream')
          )
          
          File.delete(output_filename) if File.exist?(output_filename)
          
        rescue => e
          bot.api.send_message(chat_id: message.chat.id, text: "❌ Ошибка при обработке файла: #{e.message}")
        end
      else
        bot.api.send_message(chat_id: message.chat.id, text: "⚠️ Отправляй только документы в формате .txt или .docx")
      end
    end

  end
end