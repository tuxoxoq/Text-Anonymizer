require 'telegram/bot'


token = ENV['BOT_TOKEN']

Telegram::Bot::Client.run(token) do |bot|
  bot.listen do |message|
    case message.text
    when '/start'
      bot.api.send_message(chat_id: message.chat.id, text: "Привет!")
    else
      
      result = "Анонимный текст: #{message.text.reverse}" # Пример
      bot.api.send_message(chat_id: message.chat.id, text: result)
    end
  end
end