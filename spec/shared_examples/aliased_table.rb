RSpec.shared_examples "an aliased table" do
  let(:initialize_fields_hash) do
    initialize_fields_hash = {}
    described_class.aliased_fields.each do |field_name|
      initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.pluralize
    end

    described_class.pleural_aliased_fields.each do |field_name|
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

  let(:init_field_name) { described_class.initialize_field }

  let(:described_class_symbol) { described_class.name.to_s.underscore.to_sym }
  let(:find_object) { FactoryGirl.create(described_class_symbol, initialize_fields_hash) }
  let(:find_object_2) { FactoryGirl.create(described_class_symbol, initialize_fields_hash_2) }
  let(:search_results) { described_class.search_alias(all_names[0], limit: described_class.count + 1)[1].to_a.map { |row| row[init_field_name] } }
  let(:search_results_count) { described_class.search_alias(all_names[0], limit: described_class.count + 1)[0] }

  it "should respond to #aliased?" do
    expect(described_class.respond_to?(:aliased?)).to be_truthy
  end

  describe "SearchAlias" do
    it "should index by klass_index_sort" do
      expect(SearchAlias).to respond_to "#{described_class_symbol}_index_sort"
    end

    it "should not allow a nil alias" do
      nil_alias = FactoryGirl.build(:search_alias, alias: nil, aliased_type: described_class_symbol.to_s.classify)
      expect(nil_alias).to_not be_valid
    end

    it "should be aliased" do
      expect(SearchAlias.is_class_aliased?(described_class)).to be_truthy
    end

    it "should be aliased as a symbol" do
      expect(SearchAlias.is_class_aliased?(described_class_symbol)).to be_truthy
    end

    it "should be aliased as a plural symbol" do
      expect(SearchAlias.is_class_aliased?(described_class_symbol.to_s.pluralize)).to be_truthy
    end

    describe "does default alias deletions" do
      let(:not_default_alias) { FactoryGirl.create(:search_alias, aliased_type: described_class_symbol.to_s.classify) }

      it "should be deleted when the parent is deleted" do
        delete_id = not_default_alias.id

        not_default_alias.aliased.destroy()

        found_alias = SearchAlias.where(id: delete_id)

        expect(found_alias.length).to be <= 0
      end

      it "should not allow default aliases to be deleted as appropriate" do
        delete_alias = SearchAlias.where(alias: not_default_alias.aliased.
                                             send(not_default_alias.aliased.class.initialize_field).downcase()).
            first()
        delete_id    = delete_alias.id

        delete_alias.destroy()
        found_alias = SearchAlias.where(id: delete_id)

        if (described_class.allow_delete_defaults)
          expect(found_alias.length).to be <= 0
        else
          expect(found_alias.length).to be > 0
        end
      end

      it "should allow non-default aliases to be deleted" do
        delete_id = not_default_alias.id

        not_default_alias.destroy()
        found_alias = SearchAlias.where(id: delete_id)

        expect(found_alias.length).to be <= 0
      end
    end
  end

  describe "#klass.initialize_field" do
    it "should respond to #initialize_field" do
      expect(described_class.respond_to?(:initialize_field)).to be_truthy
    end

    it "should respond to #initialize_field" do
      expect(described_class.initialize_field).to eq init_field_name
    end
  end

  describe "#klass.aliased_fields" do
    it "should respond to #aliased_fields" do
      expect(described_class.respond_to?(:aliased_fields)).to be_truthy
    end

    it "should have aliased_fields" do
      expect(described_class.aliased_fields).to_not be_blank
    end
  end

  describe "#klass.pleural_aliased_fields " do
    it "should respond to #pleural_aliased_fields " do
      expect(described_class.respond_to?(:pleural_aliased_fields)).to be_truthy
    end

    it "should have pleural_aliased_fields" do
      unless (described_class.pleural_aliased_fields == [])
        expect(described_class.pleural_aliased_fields).to_not be_blank
      end
    end
  end

  describe "#create" do
    it "should create automatic aliases on save" do
      initialize_fields_hash = {}

      described_class.aliased_fields.each do |field_name|
        initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.pluralize
      end

      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class_symbol, initialize_fields_hash)
      initialize_fields_hash.each do |field_name, value|
        expect(new_object[field_name]).to eq(value)
      end

      described_class.aliased_fields.each do |field_name|
        expect(new_object.is_default_alias?(new_object[field_name].singularize)).to be_truthy
        expect(described_class.find_by_alias(new_object[field_name].singularize).id).to eq(new_object.id)
        unless described_class.pleural_aliased_fields.include?(field_name)
          expect(new_object.is_default_alias?(new_object[field_name].pluralize)).to_not be_truthy
          expect(described_class.find_by_alias(new_object[field_name].pluralize)).to_not be
        end
      end
    end

    it "should create automatic pleural aliases on save" do
      initialize_fields_hash = {}

      described_class.pleural_aliased_fields.each do |field_name|
        unless initialize_fields_hash[field_name.to_sym]
          initialize_fields_hash[field_name.to_sym] = Faker::Lorem.sentence.singularize
        end
      end

      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class_symbol, initialize_fields_hash)
      initialize_fields_hash.each do |field_name, value|
        expect(new_object[field_name]).to eq(value)
      end

      described_class.pleural_aliased_fields.each do |field_name|
        expect(new_object.is_default_alias?(new_object[field_name].pluralize)).to be_truthy
        expect(described_class.find_by_alias(new_object[field_name].pluralize).id).to eq(new_object.id)
        unless described_class.aliased_fields.include?(field_name)
          expect(new_object.is_default_alias?(new_object[field_name].singularize)).to_not be_truthy
          expect(described_class.find_by_alias(new_object[field_name].singularize)).to_not be
        end
      end
    end

    it "should not allow a new record with an existing alias" do
      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class_symbol, initialize_fields_hash)
      field_name = (Array.wrap(described_class.aliased_fields) | Array.wrap(described_class.pleural_aliased_fields)).sample

      new_fields = initialize_fields_hash.clone
      initialize_fields_hash.each do |key, _|
        new_object[key] = Faker::Lorem.sentence unless key == field_name
      end

      bad_object = FactoryGirl.build(described_class_symbol, new_fields)
      expect(bad_object).to_not be_valid
    end

    it "should not allow a new record with an existing alias case insensitive" do
      expect(initialize_fields_hash).to_not be_empty

      new_object = FactoryGirl.create(described_class_symbol, initialize_fields_hash)
      field_name = (Array.wrap(described_class.aliased_fields) | Array.wrap(described_class.pleural_aliased_fields)).sample

      new_fields = initialize_fields_hash.clone
      initialize_fields_hash.each do |key, _|
        if key == field_name
          new_object[key] = new_object[key].swapcase
        else
          new_object[key] = Faker::Lorem.sentence
        end
      end

      bad_object = FactoryGirl.build(described_class_symbol, new_fields)
      expect(bad_object).to_not be_valid
    end
  end

  it "should respond to #search_aliases" do
    expect(find_object.respond_to?(:search_aliases)).to be_truthy
  end

  describe "#find_by_alias" do
    it "should find an alias record exact match" do
      expect(find_object.id).to be
      described_class.aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].singularize).id).to eq(find_object.id)
      end

      described_class.pleural_aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].pluralize).id).to eq(find_object.id)
      end
    end

    it "should find an alias record exact match case insensitive" do
      expect(find_object.id).to be
      described_class.aliased_fields.each do |field_name|
        expect(described_class.find_by_alias(initialize_fields_hash[field_name.to_sym].singularize.swapcase).id).to eq(find_object.id)
      end

      described_class.pleural_aliased_fields.each do |field_name|
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
      described_class.aliased_fields.each do |field_name|
        expect(find_object_2.add_alias(initialize_fields_hash[field_name.to_sym].singularize.swapcase)).to_not be
      end

      described_class.pleural_aliased_fields.each do |field_name|
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
      described_class.aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].singularize)
        expect(init_item.id).to_not be
        expect(init_item[init_field_name]).to eq(initialize_fields_hash[field_name.to_sym].singularize)
      end

      described_class.pleural_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].pluralize)
        expect(init_item.id).to_not be
        expect(init_item[init_field_name]).to eq(initialize_fields_hash[field_name.to_sym].pluralize)
      end
    end

    it "should find an object with an exact match" do
      expect(find_object).to be

      described_class.aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].singularize)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end

      described_class.pleural_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].pluralize)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end
    end

    it "should find an object with an exact match case insensitive" do
      expect(find_object).to be

      described_class.aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].singularize.swapcase)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end

      described_class.pleural_aliased_fields.each do |field_name|
        init_item = described_class.find_or_initialize(initialize_fields_hash[field_name.to_sym].pluralize.swapcase)
        expect(init_item.id).to eq(find_object.id)
        expect(init_item[field_name]).to eq(initialize_fields_hash[field_name.to_sym])
      end
    end
  end

  describe "#search_alias" do
    let(:long_set_1) { AliasWordList.get_word_list(described_class).long_words[0] }
    let(:long_set_2) { AliasWordList.get_word_list(described_class).long_words[1] }
    let(:long_set_3) { AliasWordList.get_word_list(described_class).long_words[2] }
    let(:short_set_1) { AliasWordList.get_word_list(described_class).short_words[0] }
    let(:short_set_2) { AliasWordList.get_word_list(described_class).short_words[1] }
    let(:short_set_3) { AliasWordList.get_word_list(described_class).short_words[2] }
    let(:word_set_1) { AliasWordList.get_word_list(described_class).mixed_word_set[0] }
    let(:word_set_2) { AliasWordList.get_word_list(described_class).mixed_word_set[1] }
    let(:word_set_3) { AliasWordList.get_word_list(described_class).mixed_word_set[2] }
    let(:compound_word_set_1) { AliasWordList.get_word_list(described_class).compound_words[0] }
    let(:compound_word_set_2) { AliasWordList.get_word_list(described_class).compound_words[1] }
    let(:join_clauses) { [" ", "\. ", ", ", "; ", ": ", "\t"] }
    let(:all_names) { [] }
    let(:alt_names) { AliasWordList.get_word_list(described_class).used_words.clone }

    before(:each) do
      # 0 - All words
      all_names << (word_set_1 + short_set_2).sample(40).join(join_clauses.sample)

      # 1 - All words in same order + short words
      build_word = all_names[all_names.count - 1].split()
      7.times { build_word.insert(rand(0..build_word.count), short_set_2.sample) }
      build_word = build_word.join(join_clauses.sample)
      all_names << build_word

      # 2 - All words scrambled
      build_word = word_set_1.sample(20).join(join_clauses.sample)
      while build_word == all_names[all_names.count - 1]
        build_word = word_set_1.sample(20).join(join_clauses.sample)
      end
      all_names << build_word

      # 3 - All words scrambled + other words
      all_names << (word_set_1 + word_set_2).sample(40).join(join_clauses.sample)

      # 4 - 5 words
      all_names << (long_set_1.sample(5) + word_set_2.sample(rand(1..7))).sample(40).join(join_clauses.sample)

      # 5 - 4 words
      all_names << (compound_word_set_1.sample(4) + word_set_2.sample(rand(1..7))).sample(40).join(join_clauses.sample)

      # 6 - 3 words + all short words
      all_names << (long_set_1.sample(3) + short_set_1.map { |word| word + word }).sample(40).join(join_clauses.sample)

      # 7 - 2 words
      all_names << (long_set_1.sample(2) + word_set_2.sample(rand(1..7))).sample(40).join(join_clauses.sample)

      # 8 - 1 words
      all_names << compound_word_set_1.sample(1)[0]

      # 9 - No words - short words only
      all_names << short_set_1.sample(20).join(join_clauses.sample)

      # 10 - 2 short words
      all_names << short_set_1.sample(2).join(join_clauses.sample)

      # 11 - 2 short words + stuff
      all_names << (Array.wrap(all_names[all_names.count - 1]) + word_set_2.sample(5)).sample(40).join(join_clauses.sample)

      # No words - all other words
      all_names << word_set_2.join(join_clauses.sample)

      # No words - all other words
      4.times do
        build_word = compound_word_set_2.sample(rand(1..7)).join(join_clauses.sample)
        unless all_names.include?(build_word)
          all_names << build_word
        end
      end

      all_names.each do |alias_word|
        FactoryGirl.create(described_class_symbol, build_factory_params(alias_word))
      end
    end

    it "should return everything if empty string passed" do
      described_class_search_alias = described_class.search_alias("", limit: described_class.count + 1)
      expect(described_class_search_alias[1].count).to eq(described_class.count)
    end

    it "should return everything if nil is passed" do
      described_class_search_alias = described_class.search_alias(nil, limit: described_class.count + 1)
      expect(described_class_search_alias[1].count).to eq(described_class.count)
    end

    it "should return anything with a partial match" do
      expect(search_results_count).to be >= 9
      expect(search_results.count).to be >= 9
      all_names[0..8].each do |match_word|
        expect(search_results.include?(match_word)).to be_truthy
      end
    end

    it "should prefer an exact match" do
      described_class_search_alias = described_class.search_alias(all_names[0])
      expect(described_class_search_alias[1].first[init_field_name]).to eq(all_names[0])
    end

    it "should find a mixed-up match" do
      described_class.search_alias(all_names[0], limit: 8)[1].to_a[0..3].each do |match_row|
        expect(all_names[0..3].include?(match_row[init_field_name])).to be_truthy
      end
    end

    it "should ignore small words < 2" do
      expect(search_results.include?(all_names[1])).to be_truthy
      expect(search_results.include?(all_names[9])).to be_falsey
    end

    it "should search for small words exact match only if multiples" do
      described_class_search_alias = described_class.search_alias(all_names[10], limit: SearchAlias.count)
      short_find_results           = described_class_search_alias[1].to_a.map { |row| row[init_field_name] }

      expect(short_find_results.count).to eq(described_class_search_alias[0])
      expect(short_find_results.count).to be >= 2
      expect(short_find_results[0]).to eq(all_names[10])
      expect(short_find_results.include?(all_names[11])).to be_truthy
    end

    it "should search for small words if they are the only thing entered" do
      described_class_search_alias = described_class.search_alias(short_set_1.sample, limit: described_class.count + 1)
      short_find_results           = described_class_search_alias[1].to_a.map { |row| row[init_field_name] }

      expect(short_find_results.count).to be >= 6
      expect(short_find_results.count).to eq(described_class_search_alias[0])

      expect(short_find_results.include?(all_names[0])).to be_truthy
      expect(short_find_results.include?(all_names[1])).to be_truthy
      expect(short_find_results.include?(all_names[2])).to be_truthy
      expect(short_find_results.include?(all_names[3])).to be_truthy
      expect(short_find_results.include?(all_names[6])).to be_truthy
      expect(short_find_results.include?(all_names[9])).to be_truthy
    end

    it "should not find words that do not include the search words" do
      expect(search_results.count).to be >= 9
      all_names[9..-1].each do |match_word|
        expect(search_results.include?(match_word)).to be_falsey
      end
    end

    describe "paging" do
      it "should return anything with a partial match" do
        found_element = (1..9).map { false }
        (0..search_results_count).step(2) do |page|
          sub_search_results_count, sub_search_results = described_class.search_alias(all_names[0],
                                                                                      offset: page,
                                                                                      limit:  2)
          expect(sub_search_results_count).to be >= 9
          expect(sub_search_results.count).to be <= 2
          all_names[0..8].each_with_index do |match_word, index|
            if (sub_search_results.map(&init_field_name).include?(match_word))
              found_element[index] = true
            end
          end
        end

        found_element.each do |found|
          expect(found).to be_truthy
        end
      end

      it "should ignore small words < 2" do
        (0..search_results_count).step(2) do |page|
          sub_search_results_count, sub_search_results = described_class.search_alias(all_names[0],
                                                                                      offset: page,
                                                                                      limit:  2)
          expect(sub_search_results_count).to be >= 9
          expect(sub_search_results.count).to be <= 2
          expect(sub_search_results.map(&init_field_name).include?(all_names[9])).to be_falsey
        end
      end

      it "should not find words that do not include the search words" do
        (0..search_results_count).step(2) do |page|
          sub_search_results_count, sub_search_results = described_class.search_alias(all_names[0],
                                                                                      offset: page,
                                                                                      limit:  2)
          expect(sub_search_results_count).to be >= 9
          expect(sub_search_results.count).to be <= 2
          all_names[9..-1].each do |match_word|
            expect(sub_search_results.map(&init_field_name).include?(match_word)).to be_falsey
          end
        end
      end
    end

    described_class.reflect_on_all_associations(:has_many).each do |has_many|
      next unless has_many.class_name.constantize.respond_to?(:aliased?) && has_many.class_name.constantize.aliased? &&
          # TODO: Fix the code to support non aliased items after we fix the search for non-aliased items
          # TODO: Fix the code to support ThroughReflection - Can only be one after custom controller fix done.
          !has_many.is_a?(ActiveRecord::Reflection::ThroughReflection)

      describe "#{has_many.plural_name}" do
        let(:parent_obj) { FactoryGirl.create(described_class_symbol,
                                              init_field_name.to_sym => "x " + compound_word_set_2.sample(rand(1..7)).join(join_clauses.sample)) }
        let(:not_parent_obj) { FactoryGirl.create(described_class_symbol,
                                                  init_field_name.to_sym => "y " + compound_word_set_2.sample(rand(1..7)).join(join_clauses.sample)) }
        let(:child_init_field_name) { has_many.class_name.constantize.initialize_field }
        let(:child_basic_results) do
          has_many.class_name.constantize.search_alias(all_names[0],
                                                       parent_object: parent_obj,
                                                       relationship:  has_many.plural_name,
                                                       limit:         has_many.class_name.constantize.count + 1)
        end
        let(:child_result_values) { child_basic_results[1].to_a.map { |row| row[child_init_field_name] } }

        before(:each) do
          has_many_table_name = has_many.class_name.constantize.name.underscore.to_sym

          all_names.each do |field_name|
            FactoryGirl.create(has_many_table_name,
                               child_init_field_name => field_name,
                               has_many.foreign_key  => parent_obj.id)
            FactoryGirl.create(has_many_table_name,
                               child_init_field_name => "z " + field_name,
                               has_many.foreign_key  => not_parent_obj.id)
          end
        end

        it "should return anything with a partial match" do
          expect(child_basic_results[0]).to be >= 9
          expect(child_basic_results[1].count).to be >= 9
          all_names[0..8].each do |match_word|
            expect(child_result_values.include?(match_word)).to be_truthy
          end
        end

        it "should return everything if empty string passed" do
          results = has_many.class_name.constantize.search_alias("",
                                                                 parent_object: parent_obj,
                                                                 relationship:  has_many.plural_name,
                                                                 limit:         has_many.class_name.constantize.count + 1)

          expect(results[1].count).to eq(parent_obj.send(has_many.plural_name).count)
        end

        it "should return everything if nil is passed" do
          results = has_many.class_name.constantize.search_alias(nil,
                                                                 parent_object: parent_obj,
                                                                 relationship:  has_many.plural_name,
                                                                 limit:         has_many.class_name.constantize.count + 1)

          expect(results[1].count).to eq(parent_obj.send(has_many.plural_name).count)
        end

        it "should prefer an exact match" do
          expect(child_basic_results[1].first[has_many.class_name.constantize.initialize_field]).to eq(all_names[0])
        end

        it "should find a mixed-up match" do
          child_basic_results[1].to_a[0..3].each do |match_row|
            expect(all_names[0..3].include?(match_row[child_init_field_name])).to be_truthy
          end
        end

        it "should ignore small words < 2" do
          expect(child_result_values.include?(all_names[1])).to be_truthy
          expect(child_result_values.include?(all_names[9])).to be_falsey
        end

        it "should search for small words exact match only if multiples" do
          results = has_many.class_name.constantize.search_alias(all_names[10],
                                                                 parent_object: parent_obj,
                                                                 relationship:  has_many.plural_name,
                                                                 limit:         has_many.class_name.constantize.count + 1)

          short_find_results = results[1].to_a.map { |row| row[child_init_field_name] }

          expect(short_find_results.count).to eq(results[0])
          expect(short_find_results.count).to be >= 2
          expect(short_find_results[0]).to eq(all_names[10])
          expect(short_find_results.include?(all_names[11])).to be_truthy
        end

        it "should search for small words if they are the only thing entered" do
          results            = has_many.class_name.constantize.search_alias(short_set_1.sample,
                                                                            parent_object: parent_obj,
                                                                            relationship:  has_many.plural_name,
                                                                            limit:         has_many.class_name.constantize.count + 1)
          short_find_results = results[1].to_a.map { |row| row[child_init_field_name] }

          expect(short_find_results.count).to be >= 6
          expect(short_find_results.count).to eq(results[0])

          expect(short_find_results.include?(all_names[0])).to be_truthy
          expect(short_find_results.include?(all_names[1])).to be_truthy
          expect(short_find_results.include?(all_names[2])).to be_truthy
          expect(short_find_results.include?(all_names[3])).to be_truthy
          expect(short_find_results.include?(all_names[6])).to be_truthy
          expect(short_find_results.include?(all_names[9])).to be_truthy
        end

        it "should not find words that do not include the search words" do
          expect(child_basic_results[0]).to be >= 9
          expect(child_result_values.length).to be >= 9
          all_names[9..-1].each do |match_word|
            expect(child_result_values.include?(match_word)).to be_falsey
          end
        end

        describe "paging" do
          it "should return anything with a partial match" do
            found_element = (1..9).map { false }
            (0..child_basic_results[0]).step(2) do |page|
              sub_results = has_many.class_name.constantize.search_alias(all_names[0],
                                                                         parent_object: parent_obj,
                                                                         relationship:  has_many.plural_name,
                                                                         limit:         2,
                                                                         offset:        page)

              expect(sub_results[0]).to be >= 9
              expect(sub_results[1].count).to be <= 2
              all_names[0..8].each_with_index do |match_word, index|
                if (sub_results[1].map(&child_init_field_name).include?(match_word))
                  found_element[index] = true
                end
              end
            end

            found_element.each do |found|
              expect(found).to be_truthy
            end
          end

          it "should ignore small words < 2" do
            (0..child_basic_results[0]).step(2) do |page|
              sub_results = has_many.class_name.constantize.search_alias(all_names[0],
                                                                         parent_object: parent_obj,
                                                                         relationship:  has_many.plural_name,
                                                                         limit:         2,
                                                                         offset:        page)

              expect(sub_results[0]).to be >= 9
              expect(sub_results[1].count).to be <= 2
              expect(sub_results[1].map(&child_init_field_name).include?(all_names[9])).to be_falsey
            end
          end

          it "should not find words that do not include the search words" do
            (0..child_basic_results[0]).step(2) do |page|
              sub_results = has_many.class_name.constantize.search_alias(all_names[0],
                                                                         parent_object: parent_obj,
                                                                         relationship:  has_many.plural_name,
                                                                         limit:         2,
                                                                         offset:        page)

              expect(sub_results[0]).to be >= 9
              expect(sub_results[1].count).to be <= 2
              all_names[9..-1].each do |match_word|
                expect(sub_results[1].map(&child_init_field_name).include?(match_word)).to be_falsey
              end
            end
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
      described_class.aliased_fields.each do |field_name|
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].singularize)).to be_truthy
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].singularize.swapcase)).to be_truthy
      end
    end

    it "should return true if the alias is a default pleural alias" do
      described_class.pleural_aliased_fields.each do |field_name|
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].pluralize)).to be_truthy
        expect(find_object.is_default_alias?(initialize_fields_hash[field_name].pluralize.swapcase)).to be_truthy
      end
    end

    it "should return false if the alias is not a default alias" do
      additional_aliases.each do |alias_value|
        expect(find_object.is_default_alias?(alias_value)).to be_falsey
        expect(find_object.is_default_alias?(alias_value.swapcase)).to be_falsey
      end
    end
  end

  def build_factory_params(primary_value)
    build_params = { init_field_name => primary_value }
    [described_class.aliased_fields, described_class.pleural_aliased_fields].each do |alias_list|
      (alias_list - [init_field_name]).each do |alt_field|
        new_word = nil
        while !new_word || alt_names.include?(new_word)
          new_word = ((short_set_1 + short_set_2 + compound_word_set_2 + long_set_2 + word_set_3) - all_names).sample
        end
        alt_names << new_word

        build_params[alt_field] = new_word
      end
    end

    build_params
  end
end