shared_examples "an aliased table" do
  let(:initialize_fields_hash) do
    initialize_fields_hash = {}
    described_class.default_aliased_fields.each do |field_name|
      initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.pluralize
    end

    described_class.default_pleural_aliased_fields.each do |field_name|
      unless initialize_fields_hash[field_name.to_sym]
        initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.singularize
      end
    end

    initialize_fields_hash
  end

  let(:initialize_fields_hash_2) do
    initialize_fields_hash_2 = initialize_fields_hash.clone
    initialize_fields_hash.each do |field, _|
      initialize_fields_hash_2[field] = Faker::Lorem.sentence
    end
    initialize_fields_hash_2
  end

  let(:init_field_name) do
    init_field_name = described_class.default_aliased_fields[0] unless described_class.default_aliased_fields.empty?
    init_field_name ||= described_class.default_pleural_aliased_fields[0] unless described_class.default_pleural_aliased_fields.empty?
    init_field_name.to_sym
  end

  let(:find_object) { FactoryGirl.create(described_class.name.to_s.underscore.to_sym, initialize_fields_hash) }
  let(:find_object_2) { FactoryGirl.create(described_class.name.to_s.underscore.to_sym, initialize_fields_hash_2) }
  let(:search_results) { described_class.search_alias(all_names[0])[1].to_a.map { |row| row[init_field_name] } }
  let(:search_results_count) { described_class.search_alias(all_names[0])[0] }
  let(:special_characters) { ["\u00E9", "", "\u00E5", "", "\u00EE", "", "\u00FC", "", "\u00F1", "", "\u00F8", ""] +
      ["\u00A5", "", "\u2122", "", "\u00A3", "", "\u00A2", "", "\u221E", "", "\u00A7", "", "\u00B6", "", "\u2022", ""] +
      ["\u00AA", "", "\u00BA", "", "\u0153", "", "\u2020", "", "\u03C0", "", "\u2202", "", "\u00A9", "", "\u02DA", ""] +
      ["\u00AC", "", "\u2026", "", "\u03A9", "", "\u2248", "", "\u221A", "", "\u222B", "", "\u2264", "", "\u2265", ""] +
      ["\u00B5", "", "\u00E6", "", "\u00AB", "", "\u201C", "", "\u2260", "", "\u2013", "", "\u00E8", ""] }

  describe "#klass.initialize_field" do
    it "should respond to #initialize_field" do
      expect(described_class.respond_to?(:initialize_field)).to be_true
    end

    it "should respond to #initialize_field" do
      expect(described_class.initialize_field).to eq init_field_name
    end
  end

  describe "#klass.default_aliased_fields" do
    it "should respond to #default_aliased_fields" do
      expect(described_class.respond_to?(:default_aliased_fields)).to be_true
    end
  end

  describe "#klass.default_pleural_aliased_fields " do
    it "should respond to #default_pleural_aliased_fields " do
      expect(described_class.respond_to?(:default_pleural_aliased_fields)).to be_true
    end
  end

  describe "#create" do
    it "should create automatic aliases on save" do
      initialize_fields_hash = {}

      described_class.default_aliased_fields.each do |field_name|
        initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.pluralize
      end

      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class.name.to_s.underscore.to_sym, initialize_fields_hash)
      initialize_fields_hash.each do |field_name, value|
        expect(new_object[field_name]).to eq(value)
      end

      described_class.default_aliased_fields.each do |field_name|
        expect(new_object.is_default_alias?(new_object[field_name].singularize)).to be_true
        expect(described_class.find_by_alias(new_object[field_name].singularize).id).to eq(new_object.id)
        unless described_class.default_pleural_aliased_fields.include?(field_name)
          expect(new_object.is_default_alias?(new_object[field_name].pluralize)).to_not be_true
          expect(described_class.find_by_alias(new_object[field_name].pluralize)).to_not be
        end
      end
    end

    it "should create automatic pleural aliases on save" do
      initialize_fields_hash = {}

      described_class.default_pleural_aliased_fields.each do |field_name|
        unless initialize_fields_hash[field_name.to_sym]
          initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.singularize
        end
      end

      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class.name.to_s.underscore.to_sym, initialize_fields_hash)
      initialize_fields_hash.each do |field_name, value|
        expect(new_object[field_name]).to eq(value)
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        expect(new_object.is_default_alias?(new_object[field_name].pluralize)).to be_true
        expect(described_class.find_by_alias(new_object[field_name].pluralize).id).to eq(new_object.id)
        unless described_class.default_aliased_fields.include?(field_name)
          expect(new_object.is_default_alias?(new_object[field_name].singularize)).to_not be_true
          expect(described_class.find_by_alias(new_object[field_name].singularize)).to_not be
        end
      end
    end

    it "should not allow a new record with an existing alias" do
      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class.name.to_s.underscore.to_sym, initialize_fields_hash)
      field_name = [described_class.default_aliased_fields.presence,
                    described_class.default_pleural_aliased_fields.presence].compact.sample.sample

      new_fields = initialize_fields_hash.clone
      initialize_fields_hash.each do |key, _|
        new_object[key] = Faker::Lorem.sentence unless key == field_name
      end

      bad_object = FactoryGirl.build(described_class.name.to_s.underscore.to_sym, new_fields)
      expect(bad_object).to_not be_valid
    end

    it "should not allow a new record with an existing alias case insensitive" do
      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class.name.to_s.underscore.to_sym, initialize_fields_hash)
      field_name = [described_class.default_aliased_fields.presence,
                    described_class.default_pleural_aliased_fields.presence].compact.sample.sample

      new_fields = initialize_fields_hash.clone
      initialize_fields_hash.each do |key, _|
        if key == field_name
          new_object[key] = new_object[key].swapcase
        else
          new_object[key] = Faker::Lorem.sentence
        end
      end

      bad_object = FactoryGirl.build(described_class.name.to_s.underscore.to_sym, new_fields)
      expect(bad_object).to_not be_valid
    end
  end

  describe "#find_by_alias" do
    it "should find an alias record exact match" do
      expect(find_object.id).to be
      described_class.default_aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].singularize).id).to eq(find_object.id)
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].pluralize).id).to eq(find_object.id)
      end
    end

    it "should find an alias record exact match case insensitive" do
      expect(find_object.id).to be
      described_class.default_aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].singularize.swapcase).id).to eq(find_object.id)
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].pluralize.swapcase).id).to eq(find_object.id)
      end
    end

    it "should not search for nil" do
      expect(find_object.id).to be
      expect(described_class.find_by_alias(nil)).to_not be
    end
  end

  describe "#add_alias" do
    it "should not add an alias that is an alias for another item" do
      expect(find_object).to be
      described_class.default_aliased_fields.each do |field_name|
        expect(find_object_2.add_alias(initialize_fields_hash[field_name.to_sym].singularize.swapcase)).to_not be
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        expect(find_object_2.add_alias(initialize_fields_hash[field_name.to_sym].pluralize.swapcase)).to_not be
      end
    end

    it "should add an alias that is not already in the list of aliases for the item (not saved)" do
      expect(find_object).to be
      alias_value = Faker::Lorem.sentence
      added_alias = find_object_2.add_alias(alias_value)
      expect(added_alias).to be
      expect(added_alias.id).to_not be

      added_alias.save

      expect(described_class.find_by_alias(alias_value).id).to eq(find_object_2.id)
      expect(described_class.find_by_alias(alias_value.swapcase).id).to eq(find_object_2.id)
    end

    it "should return an already existing alias" do
      expect(find_object).to be
      alias_value = Faker::Lorem.sentence
      added_alias = find_object_2.add_alias(alias_value)
      added_alias.save

      expect(find_object_2.add_alias(alias_value).id).to eq(added_alias.id)
      expect(find_object_2.add_alias(alias_value.swapcase).id).to eq(added_alias.id)
    end
  end

  describe "#find_or_initialize" do
    it "should initialize an object if it cannot be found" do
      described_class.default_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].singularize)
        expect(init_item.id).to_not be
        expect(init_item[init_field_name]).to eq(initialize_fields_hash[field_name.to_sym].singularize)
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].pluralize)
        expect(init_item.id).to_not be
        expect(init_item[init_field_name]).to eq(initialize_fields_hash[field_name.to_sym].pluralize)
      end
    end

    it "should find an object with an exact match" do
      expect(find_object).to be

      described_class.default_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].singularize)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].pluralize)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end
    end

    it "should find an object with an exact match case insensitive" do
      expect(find_object).to be

      described_class.default_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].singularize.swapcase)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end

      described_class.default_pleural_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].pluralize.swapcase)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end
    end
  end

  describe "#search_alias" do
    let(:long_set_1) { build_long_word_set }
    let(:short_set_1) { build_short_word_set }
    let(:long_set_2) { build_long_word_set long_set_1 }
    let(:short_set_2) { build_short_word_set short_set_1 }
    let(:long_set_3) { build_long_word_set long_set_1, long_set_2 }
    let(:short_set_3) { build_short_word_set short_set_1, short_set_2 }
    let(:word_set_1) { short_set_1 + long_set_1 }
    let(:word_set_2) { short_set_2 + long_set_2 }
    let(:word_set_3) { short_set_3 + long_set_3 }
    let(:compound_word_set_1) { build_compound_word_set long_set_1, word_set_2 }
    let(:compound_word_set_2) { build_compound_word_set long_set_2, word_set_3 }
    let(:join_clauses) { [" ", "\. ", ", ", "; ", ": ", "\t"] }
    let(:all_names) { [] }

    before(:each) do
      finished_building_sets([long_set_1, long_set_2, long_set_3], [short_set_1, short_set_2, short_set_3],
                             [compound_word_set_1, compound_word_set_2])
      # 0 - All words
      all_names << (word_set_1 + short_set_2).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 1 - All words in same order + short words
      build_word = all_names[all_names.count - 1].split()
      7.times { build_word.insert(rand(0..build_word.count), short_set_2.sample) }
      build_word = build_word.join(join_clauses.sample)
      all_names << build_word
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 2 - All words scrambled
      build_word = word_set_1.sample(20).join(join_clauses.sample)
      while build_word == all_names[all_names.count - 1]
        build_word = word_set_1.sample(20).join(join_clauses.sample)
      end
      all_names << build_word
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 3 - All words scrambled + other words
      all_names << (word_set_1 + word_set_2).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 4 - 5 words
      all_names << (long_set_1.sample(5) + word_set_2.sample(rand(1..7))).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 5 - 4 words
      all_names << (compound_word_set_1.sample(4) + word_set_2.sample(rand(1..7))).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 6 - 3 words + all short words
      all_names << (long_set_1.sample(3) + short_set_1.map { |word| word + word }).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 7 - 2 words
      all_names << (long_set_1.sample(2) + word_set_2.sample(rand(1..7))).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 8 - 1 words
      all_names << compound_word_set_1.sample(1)[0]
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 9 - No words - short words only
      all_names << short_set_1.sample(20).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 10 - 2 short words
      all_names << short_set_1.sample(2).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # 11 - 2 short words + stuff
      all_names << (Array.wrap(all_names[all_names.count - 1]) + word_set_2.sample(5)).sample(40).join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # No words - all other words
      all_names << word_set_2.join(join_clauses.sample)
      FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])

      # No words - all other words
      4.times do
        build_word = compound_word_set_2.sample(rand(1..7)).join(join_clauses.sample)
        unless all_names.include?(build_word)
          all_names << build_word
          FactoryGirl.create(described_class.name.to_s.underscore.to_sym, init_field_name.to_sym => all_names[all_names.count - 1])
        end
      end
    end

    it "should return everything if empty string passed" do
      described_class_search_alias = described_class.search_alias("")
      expect(described_class_search_alias[1].count).to eq(described_class.all.count)
    end

    it "should return everything if nil is passed" do
      described_class_search_alias = described_class.search_alias(nil)
      expect(described_class_search_alias[1].count).to eq(described_class.all.count)
    end

    it "should return anything with a partial match" do
      expect(search_results_count).to be >= 9
      expect(search_results.count).to be >= 9
      all_names[0..8].each do |match_word|
        expect(search_results.include?(match_word)).to be_true
      end
    end

    it "should prefer an exact match" do
      described_class_search_alias = described_class.search_alias(all_names[0])
      expect(described_class_search_alias[1].first[init_field_name]).to eq(all_names[0])
    end

    it "should find a mixed-up match" do
      described_class.search_alias(all_names[0])[1].to_a[0..3].each do |match_row|
        expect(all_names[0..3].include?(match_row[init_field_name])).to be_true
      end
    end

    it "should ignore small words < 2" do
      expect(search_results.include?(all_names[1])).to be_true
      expect(search_results.include?(all_names[9])).to be_false
    end

    it "should search for small words exact match only if multiples" do
      described_class_search_alias = described_class.search_alias(all_names[10])
      short_find_results           = described_class_search_alias[1].to_a.
          map { |row| row[init_field_name] }
      expect(short_find_results.count).to eq(described_class_search_alias[0])
      expect(short_find_results.count).to be >= 2
      expect(short_find_results[0]).to eq(all_names[10])
      expect(short_find_results.include?(all_names[11])).to be_true
    end

    it "should search for small words if they are the only thing entered" do
      described_class_search_alias = described_class.search_alias(short_set_1.sample)
      short_find_results           = described_class_search_alias[1].to_a.map { |row| row[init_field_name] }

      expect(short_find_results.count).to be >= 6
      expect(short_find_results.count).to eq(described_class_search_alias[0])

      expect(short_find_results.include?(all_names[0])).to be_true
      expect(short_find_results.include?(all_names[1])).to be_true
      expect(short_find_results.include?(all_names[2])).to be_true
      expect(short_find_results.include?(all_names[3])).to be_true
      expect(short_find_results.include?(all_names[6])).to be_true
      expect(short_find_results.include?(all_names[9])).to be_true
    end

    it "should not find words that do not include the search words" do
      expect(search_results.count).to be >= 9
      all_names[9..-1].each do |match_word|
        expect(search_results.include?(match_word)).to be_false
      end
    end

    describe "paging" do
      it "should return anything with a partial match" do
        found_element = (1..9).map { false }
        (0..search_results_count).step(2) do |page|
          sub_search_results_count, sub_search_results = described_class.search_alias(all_names[0], page, 2)
          expect(sub_search_results_count).to be >= 9
          expect(sub_search_results.count).to be <= 2
          all_names[0..8].each_with_index do |match_word, index|
            if (sub_search_results.map(&init_field_name).include?(match_word))
              found_element[index] = true
            end
          end
        end

        found_element.each do |found|
          expect(found).to be_true
        end
      end

      it "should ignore small words < 2" do
        (0..search_results_count).step(2) do |page|
          sub_search_results_count, sub_search_results = described_class.search_alias(all_names[0], page, 2)
          expect(sub_search_results_count).to be >= 9
          expect(sub_search_results.count).to be <= 2
          expect(sub_search_results.map(&init_field_name).include?(all_names[9])).to be_false
        end
      end

      it "should not find words that do not include the search words" do
        (0..search_results_count).step(2) do |page|
          sub_search_results_count, sub_search_results = described_class.search_alias(all_names[0], page, 2)
          expect(sub_search_results_count).to be >= 9
          expect(sub_search_results.count).to be <= 2
          all_names[9..-1].each do |match_word|
            expect(sub_search_results.map(&init_field_name).include?(match_word)).to be_false
          end
        end
      end
    end
  end

  describe "#is_default_alias?" do
    let(:additional_aliases) { [-1].reduce([]) { |map, _| 5.times { map << Faker::Lorem.sentence }; map } }

    before(:each) do
      additional_aliases.each do |alias_value|
        find_object.add_alias(alias_value)
      end
    end

    it "should return true if the alias is a default alias" do
      described_class.default_aliased_fields.each do |field_name|
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].singularize)).to be_true
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].singularize.swapcase)).to be_true
      end
    end

    it "should return true if the alias is a default pleural alias" do
      described_class.default_pleural_aliased_fields.each do |field_name|
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].pluralize)).to be_true
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].pluralize.swapcase)).to be_true
      end
    end

    it "should return false if the alias is not a default alias" do
      additional_aliases.each do |alias_value|
        expect(find_object.is_default_alias?(alias_value)).to be_false
        expect(find_object.is_default_alias?(alias_value.swapcase)).to be_false
      end
    end
  end

  # add upper cases
  # add foreign characters
  def contains_word(add_word, *args)
    args.reduce(false) do |found, other_set|
      found || other_set.reduce(false) { |found_word, word| found_word || /#{word}/ =~ add_word || /#{add_word}/ =~ word }
    end
  end

  def finished_building_sets(long_sets, short_sets, compound_sets)
    long_sets.each do |long_set|
      prefix  = long_set.pop
      postfix = long_set.pop

      new_word = prefix + postfix
      while new_word == prefix + postfix
        new_word = "#{special_characters.sample}#{prefix}#{special_characters.sample}#{postfix}#{special_characters.sample}"
      end
      long_set << new_word
    end

    [long_sets, short_sets, compound_sets].each do |set_set|
      set_set.each do |word_set|
        (0..(word_set.count - 1)).map { |a| a }.sample(rand(1..(word_set.count / 2))).each do |index|
          word_set[index] = word_set[index].capitalize
        end
      end
    end
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
          contains_word(add_word, word_set, *args)
        word_set << add_word
      end
    end

    loop_count = 0
    while word_set.count < set_size + 2 && loop_count < 500 do
      loop_count += 1
      add_word   = ('a'..'z').map { |a| a }.sample(rand(1..2)).join("")
      unless contains_word(add_word, word_set, *args)
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
      add_word   = ('a'..'z').map { |a| a }.sample(rand(1..2)).join("")
      unless contains_word(add_word, word_set, *args) || add_word == "s"
        word_set << add_word
      end
    end

    word_set
  end

  def build_compound_word_set(*args)
    options = args.extract_options!

    base_word_set = args.shift

    word_set = []
    base_word_set[0..-3].each do |word|
      new_word = word
      until new_word != word
        new_word = (rand(0..1) == 0) ? "" : args.try(:sample).try(:sample)
        new_word += word
        new_word += (rand(0..1) == 0) ? "" : args.try(:sample).try(:sample)
      end

      word_set << new_word
    end

    word_set
  end
end