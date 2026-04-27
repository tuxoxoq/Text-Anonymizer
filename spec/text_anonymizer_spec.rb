require 'rspec'
require 'colorize'
require_relative '../lib/text_anonymizer'
require_relative '../lib/strategies/fake_data_strategy'
require_relative '../lib/strategies/colorize_strategy'

RSpec.describe TextAnonymizer do
  let(:fake_strategy) { FakeDataStrategy.new }
  let(:color_strategy) { ColorizeStrategy.new }

  describe '1. Базовая надежность' do
    let(:anonymizer) { TextAnonymizer.new(fake_strategy) }

    it 'тест 1: пустая строка' do
      expect(anonymizer.process("")).to eq("")
    end

    it 'тест 2: nil' do
      expect(anonymizer.process(nil)).to eq("")
    end

    it 'тест 3: оригинал без секретов' do
      expect(anonymizer.process("текст")).to eq("текст")
    end
  end

  describe '2. Анонимизация (FakeDataStrategy)' do
    let(:anonymizer) { TextAnonymizer.new(fake_strategy) }

    it 'тест 4: заменяет email на латиницу' do
      result = anonymizer.process("почта: user@mail.ru")
      email_part = result.split.last
      expect(email_part).not_to include("user@mail.ru")
      
      expect(email_part).not_to match(/[а-яё]/i)
    end

    it 'тест 5: несколько email' do
      expect(anonymizer.process("a@a.ru b@b.com").scan(/@/).size).to eq(2)
    end

    it 'тест 6: IP формат' do
      expect(anonymizer.process("1.1.1.1")).to match(/\b(?:\d{1,3}\.){3}\d{1,3}\b/)
    end

    it 'тест 7: телефон с +7' do
      expect(anonymizer.process("+7 (999) 000-00-00")).not_to include("000-00-00")
    end

    it 'тест 8: телефон с 8' do
      expect(anonymizer.process("89001112233")).not_to include("89001112233")
    end



    it 'тест 9: защита городов' do
      expect(anonymizer.process("Москва")).to eq("Москва")
    end
  end

  describe '3. Раскрашивание (ColorizeStrategy)' do
    let(:colorizer) { TextAnonymizer.new(color_strategy) }

    it 'тест 10: красит падежи' do
      expect(colorizer.process("синими")).to eq("синими".blue)
    end

    it 'тест 11: НЕ красит похожие слова (красота, синица)' do
      input = "красота и синица"
      # Теперь синица останется просто текстом!
      expect(colorizer.process(input)).to eq(input)
    end
  end

  describe '4. Интеграция' do
    let(:anonymizer) { TextAnonymizer.new(fake_strategy) }
    let(:colorizer) { TextAnonymizer.new(color_strategy) }

    it 'тест 12: цепочка работает' do
      input = "Красный Петр 1.1.1.1"
      res = colorizer.process(anonymizer.process(input))
      expect(res).to include("Красный".red)
      expect(res).not_to include("Петр")
    end
  end
end