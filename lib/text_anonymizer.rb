class TextAnonymizer
  def initialize(strategy)
    @strategy = strategy
    @names = load_names_from_file
    @rules = build_rules
    @combined_regex = Regexp.union(@rules.values)
  end

  def process(text)
    return "" if text.nil?
    text.gsub(@combined_regex) do |match|
      type = identify_type(match)
      @strategy.call(match, type)
    end
  end

  def refresh!
    @names = load_names_from_file
    @rules = build_rules
    @combined_regex = Regexp.union(@rules.values)
  end

  private

  def load_names_from_file
    file_path = File.join(File.dirname(__FILE__), '../names.txt')
    if File.exist?(file_path)
      File.read(file_path).split(/[\s,]+/).map(&:strip).reject(&:empty?).uniq
    else
      %w[Иван Алексей Дмитрий Максим Сергей Николай Михаил Артем Петр Александр Рустам Тимур Владимир Дарья]
    end
  end

  def build_rules
    {
      email: /[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}/,
      ip:    /\b(?:\d{1,3}\.){3}\d{1,3}\b/,
      phone: /(?:\+?7|8)[\s\(\)-]*?(\d[\s\(\)-]*?){10}/,
      color: /\b(?:красн|син|зелен|желт|бел|черн|голуб|фиолетов)(?:ый|ий|ая|яя|ое|ее|ые|ие|ого|его|ому|ему|ую|юю|ым|им|ом|ем|ых|их|ыми|ими|а|о|е|и|у|я|ь|ой|ей|ою|ею)?\b/i,
      name:  /\b(?:#{@names.join('|')})\b/i
    }
  end

  def identify_type(match)
    return :email if match.match?(@rules[:email])
    return :ip    if match.match?(@rules[:ip])
    return :phone if match.match?(@rules[:phone])
    return :color if match.match?(@rules[:color])
    return :name  if match.match?(@rules[:name])
    :unknown
  end
end