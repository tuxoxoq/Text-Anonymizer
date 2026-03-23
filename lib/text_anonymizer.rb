class TextAnonymizer
  NAMES_TO_HIDE = %w[Иван Алексей Дмитрий Максим Сергей Николай Михаил Артем Петр Александр].freeze

  RULES = {
    email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
    ip:    /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
    phone: /(?:\+?7|8)[\s\(\)-]*?(\d[\s\(\)-]*?){10}/,
    
    color: /\b(?:красн|син|зелен|желт|бел|черн|голуб|фиолетов)(?:ый|ий|ая|яя|ое|ее|ые|ие|ого|его|ому|ему|ую|юю|ым|им|ом|ем|ых|их|ыми|ими|а|о|е|и|у|я|ь)?\b/i,
    name:  /\b(?:#{NAMES_TO_HIDE.join('|')})\b/
  }.freeze

  def initialize(strategy)
    @strategy = strategy
    @combined_regex = Regexp.union(RULES.values)
  end

  def process(text)
    return "" if text.nil?
    text.gsub(@combined_regex) do |match|
      type = identify_type(match)
      @strategy.call(match, type)
    end
  end

  private

  def identify_type(match)
    return :email if match.match?(RULES[:email])
    return :ip    if match.match?(RULES[:ip])
    return :phone if match.match?(RULES[:phone])
    return :color if match.match?(RULES[:color])
    return :name  if match.match?(RULES[:name])
    :unknown
  end
end