require "singleton"

class AliasWordList
  include Singleton

  class << self
    def get_word_list(aliased_class)
      AliasWordList.instance.get_word_list aliased_class
    end
  end

  def get_word_list(aliased_class)
    @cached_word_lists                     ||= {}
    @cached_word_lists[aliased_class.name] ||= AliasWordListGenerator.new(aliased_class)

    @cached_word_lists[aliased_class.name]
  end
end

class AliasWordListGenerator
  SPECIAL_CHARACTERS = ["\u00E9", "", "\u00E5", "", "\u00EE", "", "\u00FC", "", "\u00F1", "", "\u00F8", ""] +
      ["\u00A5", "", "\u2122", "", "\u00A3", "", "\u00A2", "", "\u221E", "", "\u00A7", "", "\u00B6", "", "\u2022", ""] +
      ["\u00AA", "", "\u00BA", "", "\u0153", "", "\u2020", "", "\u03C0", "", "\u2202", "", "\u00A9", "", "\u02DA", ""] +
      ["\u00AC", "", "\u2026", "", "\u03A9", "", "\u2248", "", "\u221A", "", "\u222B", "", "\u2264", "", "\u2265", ""] +
      ["\u00B5", "", "\u00E6", "", "\u00AB", "", "\u201C", "", "\u2260", "", "\u2013", "", "\u00E8", ""]

  attr_reader :short_words, :long_words, :compound_words, :mixed_word_set, :used_words

  def initialize(aliased_class)
    @used_words = SearchAlias.where(aliased_type: aliased_class.name.to_s).map(&:alias)

    @short_words    = []
    @long_words     = []
    @compound_words = []
    @mixed_word_set = []

    @long_words << build_long_word_set(*@long_words)
    @long_words << build_long_word_set(*@long_words)
    @long_words << build_long_word_set(*@long_words)

    @short_words << build_short_word_set(*@short_words)
    @short_words << build_short_word_set(*@short_words)
    @short_words << build_short_word_set(*@short_words)

    @mixed_word_set << @short_words[0] + @long_words[0]
    @mixed_word_set << @short_words[1] + @long_words[1]
    @mixed_word_set << @short_words[2] + @long_words[2]

    @compound_words << build_compound_word_set(@long_words[0], @mixed_word_set[1])
    @compound_words << build_compound_word_set(@long_words[1], @mixed_word_set[2], exlusive_sets: [@long_words[0]])

    finished_building_sets
  end

  def build_long_word_set(*args)
    options = args.extract_options!

    set_size = (options[:size] || 10) - 1
    word_set = []

    loop_count = 0
    while word_set.count < set_size && loop_count < 500 do
      loop_count += 1
      add_word   = Faker::Lorem.word
      unless add_word.length <= 2 ||
          contains_word(add_word, @used_words, word_set, *args)
        word_set << add_word
      end
    end

    loop_count = 0
    while word_set.count < set_size + 2 && loop_count < 500 do
      loop_count += 1
      add_word   = ('a'..'z').map { |a| a }.sample(rand(1..2)).join("")
      unless contains_word(add_word, @used_words, word_set, *args)
        word_set << add_word
      end
    end

    word_set
  end

  def build_short_word_set(*args)
    options = args.extract_options!

    set_size = options[:size] || 5
    word_set = []

    loop_count = 0
    while word_set.count < set_size && loop_count < 500 do
      loop_count += 1
      add_word   = (('a'..'z').to_a - ['a', 'e', 'i', 'o', 'u']).map { |a| a }.sample(rand(1..2)).join("")
      unless contains_word(add_word, @used_words, word_set, *args) || add_word == "s"
        word_set << add_word
      end
    end

    word_set
  end

  def build_compound_word_set(*args)
    options = args.extract_options!

    exclude_items = options[:exlusive_sets] || []
    base_word_set = args.shift

    word_set = []
    base_word_set[0..-3].each do |word|
      new_word = word
      until new_word != word
        new_word = (rand(0..1) == 0) ? "" : args.try(:sample).try(:sample)
        new_word += word
        new_word += (rand(0..1) == 0) ? "" : args.try(:sample).try(:sample)
        if contains_word(new_word, @used_words, word_set, *exclude_items) || new_word == "s"
          new_word = word
        end
      end

      word_set << new_word
    end

    word_set
  end

  def contains_word(add_word, *args)
    [add_word.singularize, add_word.pluralize].reduce(false) do |found_test_word, test_word|
      found_test_word || args.reduce(false) do |found, other_set|
        found || other_set.reduce(false) do |found_word, word|
          found_word || (!word.empty? && (/#{word}/ =~ test_word || /#{test_word}/ =~ word))
        end
      end
    end
  end

  # add upper cases
  # add foreign characters
  def finished_building_sets
    @long_words.each do |long_set|
      prefix  = long_set.pop
      postfix = long_set.pop

      new_word = prefix + postfix
      while new_word == prefix + postfix
        new_word = "#{SPECIAL_CHARACTERS.sample}#{prefix}#{SPECIAL_CHARACTERS.sample}#{postfix}#{SPECIAL_CHARACTERS.sample}"
      end
      long_set << new_word
    end

    [@long_words, @short_words, @compound_words].each do |set_set|
      set_set.each do |word_set|
        (0..(word_set.count - 1)).map { |a| a }.sample(rand(1..(word_set.count / 2))).each do |index|
          word_set[index] = word_set[index].capitalize
        end
      end
    end
  end
end