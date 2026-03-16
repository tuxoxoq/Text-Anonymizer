require 'rspec'
require_relative '../lib/text_anonymizer'
require_relative '../lib/strategies/fake_data_strategy'

RSpec.describe TextAnonymizer do
  let(:strategy) { FakeDataStrategy.new }
  let(:anonymizer) { TextAnonymizer.new(strategy) }

  describe '#process' do
    it 'анонимизирует email' do
      input = "Моя почта test@example.com"
      result = anonymizer.process(input)
      expect(result).not_to include("test@example.com")
      expect(result).to include("@") # Проверяем, что Faker вставил какой-то другой email
    end

    it 'анонимизирует IP-адрес' do
      input = "Мой IP 192.168.1.1"
      result = anonymizer.process(input)
      expect(result).not_to include("192.168.1.1")
      # Проверяем формат IP (4 группы цифр)
      expect(result).to match(/\d{1,3}(\.\d{1,3}){3}/)
    end

    it 'анонимизирует телефон без точек' do
      input = "Звони 89991234567"
      result = anonymizer.process(input)
      expect(result).not_to include("89991234567")
      expect(result).to include("+7") # Наша стратегия всегда ставит +7
    end

    it 'обрабатывает всё вместе в одной строке' do
      input = "Email: a@b.ru, IP: 1.1.1.1, Тел: 89001112233"
      result = anonymizer.process(input)
      
      expect(result).not_to include("a@b.ru")
      expect(result).not_to include("1.1.1.1")
      expect(result).not_to include("89001112233")
    end
  end
end