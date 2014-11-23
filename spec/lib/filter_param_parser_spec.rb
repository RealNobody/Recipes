require 'rails_helper'
require "filter_param_parser"

RSpec.describe FilterParamParser do
  let(:basic_parse) { FilterParamParser.new(nil) }

  describe "reducing booleans" do
    it "does not regurn a group as the first element" do
      basic_parse.send(:parse, "(a=c&(a=b))")
      expect(basic_parse.parsed_fields).to be == { type:               :&,
                                                   filter_expressions: [{ type: :"=", token: "a", values: [["c"]] },
                                                                        { type: :"=", token: "a", values: [["b"]] }]
      }
    end

    it "reduces !(!()) to nothing" do
      basic_parse.send(:parse, "!(!(a))")
      expect(basic_parse.parsed_fields).to be == { type: :token, token: "a" }
    end

    it "reduces groups with (!()) to !" do
      basic_parse.send(:parse, "(!(a))")
      expect(basic_parse.parsed_fields).to be == { type:              :not_filter,
                                                   filter_expression: { type: :token, token: "a" } }
    end

    it "reduces groups with !(()) to !" do
      basic_parse.send(:parse, "!((a))")
      expect(basic_parse.parsed_fields).to be == { type:              :not_filter,
                                                   filter_expression: { type: :token, token: "a" } }
    end

    [",", "&", "|"].each do |compare|
      it "reduces #{compare} in groups to the left" do
        basic_parse.send(:parse, "(a#{compare}b)#{compare}c")
        expect(basic_parse.parsed_fields).to be == { type:               compare == "," ? :& : compare.to_sym,
                                                     filter_expressions: [{ type: :token, token: "a" },
                                                                          { type: :token, token: "b" },
                                                                          { type: :token, token: "c" }] }
      end

      it "does not reduce ! groups" do
        basic_parse.send(:parse, "a#{compare}!(b#{compare}c)")
        comapre_symbol = (compare == "&" ? "," : compare)
        expect(basic_parse.to_s).to be == "a#{comapre_symbol}!(b#{comapre_symbol}c)"
      end

      it "reduces #{compare} in groups to the left" do
        basic_parse.send(:parse, "a#{compare}(b#{compare}c)")
        expect(basic_parse.parsed_fields).to be == { type:               compare == "," ? :& : compare.to_sym,
                                                     filter_expressions: [{ type: :token, token: "a" },
                                                                          { type: :token, token: "b" },
                                                                          { type: :token, token: "c" }] }
      end

      it "doesn't allow #{compare} in arrays or tuples" do
        if compare == ","
          to_function = :not_to
          to_params   = raise_exception
        else
          to_function = :to
          to_params   = raise_exception(FilterParamParser::InvalidFormat)
        end

        expect { basic_parse.send(:parse, "a<[b,#{compare}c,d]") }.
            send(to_function, to_params)
        expect { basic_parse.send(:parse, "a<[b,c#{compare},d]") }.
            send(to_function, to_params)
        expect { basic_parse.send(:parse, "a[b,#{compare}c,d]") }.
            send(to_function, to_params)
        expect { basic_parse.send(:parse, "a[b,c#{compare},d]") }.
            send(to_function, to_params)
        expect { basic_parse.send(:parse, "a[b,[c#{compare}],d]") }.
            send(to_function, to_params)
        expect { basic_parse.send(:parse, "a[b,[#{compare}c],d]") }.
            send(to_function, to_params)
      end
    end
  end

  describe "simple comparisons" do
    ["=".to_sym, "~=".to_sym, :<, :>, :<=, :>=].each do |comparison|
      it "compares two things using #{comparison}" do
        token = Faker::Lorem.word
        value = Faker::Lorem.word
        basic_parse.send(:parse, "#{token}#{comparison}#{value}")
        expect(basic_parse.parsed_fields).to eq({ type: comparison, token: token, values: [[value]] })
      end

      it "#{comparison} unescapes tokens and values" do
        token = Faker::Lorem.word + "!()[]&|~=<>"
        value = Faker::Lorem.word + "!()[]&|~=<>"
        basic_parse.send(:parse, "#{CGI.escape(token)}#{comparison}#{CGI.escape(value)}")
        expect(basic_parse.parsed_fields).to eq({ type: comparison, token: token, values: [[value]] })
      end

      it "doesn't allow a #{comparison} comparitor after a group" do
        expect { basic_parse.send(:parse, "(a)#{comparison}b") }.to raise_exception FilterParamParser::InvalidFormat
      end

      [",", "&", "|"].each do |compare|
        it "allows <token>#{comparison}<empty>#{compare}" do
          token = Faker::Lorem.word
          value = Faker::Lorem.word
          basic_parse.send(:parse, "#{token}#{comparison}#{compare}#{value}")
          expect(basic_parse.parsed_fields).to eq({ type:               (compare == "," ? "&" : compare).to_sym,
                                                    filter_expressions: [{ type: comparison, token: token, values: [[""]] },
                                                                         { type: :token, token: value }
                                                                        ] })
        end

        it "allows (<token>#{comparison}<empty>)#{compare}" do
          token = Faker::Lorem.word
          value = Faker::Lorem.word
          basic_parse.send(:parse, "(#{token}#{comparison})#{compare}#{value}")
          expect(basic_parse.parsed_fields).to eq({ type:               (compare == "," ? "&" : compare).to_sym,
                                                    filter_expressions: [{ type: comparison, token: token, values: [[""]] },
                                                                         { type: :token, token: value }
                                                                        ] })
        end
      end
    end

    it "allows an empty tuple" do
      basic_parse.send(:parse, "q>[]")
      expect(basic_parse.parsed_fields).to be == { type: :>, token: "q", values: [[""]] }
    end
  end

  describe "token only" do
    it "parses a token only" do
      token = Faker::Lorem.word
      basic_parse.send(:parse, "#{token}")
      expect(basic_parse.parsed_fields).to eq({ type: :token, token: token })
    end

    it "parses a set of tokens" do
      token_array      = (1..(5 + rand(10))).to_a.map { Faker::Lorem.word }
      expected_results = { type: :&, filter_expressions: token_array.map { |token| ({ type: :token, token: token }) } }
      basic_parse.send(:parse, token_array.join(","))
      expect(basic_parse.parsed_fields).to eq(expected_results)
    end
  end

  describe "arrays" do
    ["[", "~["].each do |pre_type|
      it "#{pre_type}] accepts an array of 1 item" do
        token = Faker::Lorem.word
        value = Faker::Lorem.word
        basic_parse.send(:parse, "#{token}#{pre_type}#{value}]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [[value]] })
      end

      it "#{pre_type}] unescapes values" do
        token = Faker::Lorem.word + "!()[]&|~=<>"
        value = Faker::Lorem.word + "!()[]&|~=<>"
        basic_parse.send(:parse, "#{CGI.escape(token)}#{pre_type}#{CGI.escape(value)}]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [[value]] })
      end

      it "#{pre_type}] accepts an array of multiple items" do
        token  = Faker::Lorem.word
        value  = Faker::Lorem.word
        value2 = Faker::Lorem.word
        basic_parse.send(:parse, "#{token}#{pre_type}#{value},,#{value2}]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [[value], [""], [value2]] })
      end

      it "#{pre_type}] accepts an array of no items" do
        token = Faker::Lorem.word
        value = ""
        basic_parse.send(:parse, "#{token}#{pre_type}#{value}]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [] })
      end

      it "#{pre_type}] accepts an array of an empty token" do
        token = Faker::Lorem.word
        value = ""
        basic_parse.send(:parse, "#{token}#{pre_type}[#{value}]]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [[""]] })
      end

      it "#{pre_type}] accepts an array with 1 tuple" do
        token = Faker::Lorem.word
        value = Faker::Lorem.word
        basic_parse.send(:parse, "#{token}#{pre_type}[#{value}]]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [[value]] })
      end

      it "#{pre_type}] unescapes tuple values" do
        token = Faker::Lorem.word + "!()[]&|~=<>"
        value = Faker::Lorem.word + "!()[]&|~=<>"
        basic_parse.send(:parse, "#{CGI.escape(token)}#{pre_type}[#{CGI.escape(value)}]]")
        expect(basic_parse.parsed_fields).to eq({ type: "#{pre_type}]".to_sym, token: token, values: [[value]] })
      end

      it "#{pre_type}] accepts an array with multiple items" do
        token            = Faker::Lorem.word
        value_array      = (1..(5 + rand(10))).to_a.map { Faker::Lorem.word }
        expected_results = { type: "#{pre_type}]".to_sym, token: token, values: value_array.map { |token| [token] } }
        basic_parse.send(:parse, "#{token}#{pre_type}#{value_array.join(",")}]")
        expect(basic_parse.parsed_fields).to eq(expected_results)
      end

      it "#{pre_type}] accepts an array with multiple tuples" do
        token            = Faker::Lorem.word
        value_array      = (1..(5 + rand(10))).to_a.map { (1..(5 + rand(10))).to_a.map { Faker::Lorem.word } }
        expected_results = { type: "#{pre_type}]".to_sym, token: token, values: value_array.map { |token| token } }
        basic_parse.send(:parse, "#{token}#{pre_type}#{value_array.map { |token| "[#{token.join(",")}]" }.join(",")}]")
        expect(basic_parse.parsed_fields).to eq(expected_results)
      end

      it "#{pre_type}] accepts an array with multiple empty tuples" do
        token            = Faker::Lorem.word
        value_array      = (1..(5 + rand(10))).to_a.map { (1..(5 + rand(10))).to_a.map { "" } }
        expected_results = { type: "#{pre_type}]".to_sym, token: token, values: value_array.map { |token| token } }
        basic_parse.send(:parse, "#{token}#{pre_type}#{value_array.map { |token| "[#{token.join(",")}]" }.join(",")}]")
        expect(basic_parse.parsed_fields).to eq(expected_results)
      end

      it "#{pre_type}] accepts an array with multiple tuples and items" do
        token            = Faker::Lorem.word
        value_array      = (1..(5 + rand(10))).to_a.map do
          if (rand(2) % 2) == 0
            Faker::Lorem.word
          else
            (1..(5 + rand(10))).to_a.map { Faker::Lorem.word }
          end
        end
        expected_results = { type: "#{pre_type}]".to_sym, token: token, values: value_array.map do |token|
          if token.is_a?(Array)
            token
          else
            [token]
          end
        end }
        basic_parse.send(:parse, "#{token}#{pre_type}#{value_array.map do |token|
          if token.is_a?(Array)
            "[#{token.join(",")}]"
          else
            token
          end
        end.join(",")}]")
        expect(basic_parse.parsed_fields).to eq(expected_results)
      end

      it "doesn't allow a #{pre_type} after a group" do
        expect { basic_parse.send(:parse, "(a)#{pre_type}b]") }.to raise_exception FilterParamParser::InvalidFormat
      end
    end
  end

  describe "simple expressions" do
    [:<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym,
     :[], "~[]".to_sym, :"![]".to_sym, "!~[]".to_sym, :tuple].each do |operator|
      [:test_value_single, :test_value_tuple].each do |test_value|
        [:arrays_singles, :arrays_tuples, :arrays_mixed].each do |array_values|
          [:array_size_single, :array_size_multi].each do |array_sizes|
            [:tuples_multi, :tuples_single].each do |tuples|
              [:plain_string, :encode_string].each do |strings|
                it "buids a sample = #{operator}, #{test_value}, #{array_values}, #{array_sizes}, #{tuples}, #{strings}" do
                  options               = {}
                  options[operator]     = true
                  options[test_value]   = true
                  options[array_values] = true
                  options[array_sizes]  = true
                  options[tuples]       = true
                  options[strings]      = true

                  build_hash, build_string = build_comparison(options)
                  expect(basic_parse.send(:parse, build_string)).to be == build_hash
                end
              end
            end
          end
        end
      end
    end
  end

  describe "filter expressions" do
    [:not_filter, :group, :&, :|, ",".to_sym, :comparison].each do |filter|
      it "builds a #{filter} filter" do
        options         = {}
        options[filter] = true

        build_hash, build_string = build_filter_expression(options)
        expect(basic_parse.send(:parse, build_string)).to be == build_hash
      end
    end
  end

  describe "error checking" do
    it "checks for unclosed parentheses" do
      expect { basic_parse.send(:parse, "(a<b") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "checks for unclosed parentheses nested deeply" do
      expect { basic_parse.send(:parse, "((a<b&(b))&(c<d&q>r)&f!=u") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "checks for mismatched parentheses" do
      expect { basic_parse.send(:parse, "((a<b&(b))&(c))<d&q>r)&f!=u") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "doesn't allow arrays where tuples are expected" do
      expect { basic_parse.send(:parse, "abc!~=[a,b,c,[de,fg]]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "checks for unclosed tuples" do
      expect { basic_parse.send(:parse, "abc!~=[a,b,c,de,fg") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "checks for unclosed arrays" do
      expect { basic_parse.send(:parse, "abc[a,b,c,de,fg") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "checks for unclosed tuples in arrays" do
      expect { basic_parse.send(:parse, "abc!~=[a,b,c,[de,fg") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "checks for unclosed arrays with tuples" do
      expect { basic_parse.send(:parse, "abc!~=[a,b,c,[de,fg]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow sub-tuples" do
      expect { basic_parse.send(:parse, "abc!~=[a,b,c,[de,[fg]]]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow mixed boolean operations" do
      expect { basic_parse.send(:parse, "q>=r&x<=y|r![a,b,c]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow groupings before a compare" do
      expect { basic_parse.send(:parse, "q>=r&x(<=y)") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow groupings before a boolean" do
      expect { basic_parse.send(:parse, "q>=r(&x<=y)") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow groupings in an array" do
      expect { basic_parse.send(:parse, "(f[a,(f=b)])") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow ] if not closing a tuple or an array" do
      expect { basic_parse.send(:parse, "a]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow ! before a token" do
      expect { basic_parse.send(:parse, "!a") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow ! before a simple value" do
      expect { basic_parse.send(:parse, "a!a") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow ~ before a simple value" do
      expect { basic_parse.send(:parse, "a~a") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow !~ before a simple value" do
      expect { basic_parse.send(:parse, "a!~a") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "does not allow groupings in the middle of a compare expression" do
      expect { basic_parse.send(:parse, "q>(=r&x<=y)") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "requires an opening ( for a )" do
      expect { basic_parse.send(:parse, "a)") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "doesn't allow a ) without an opening (" do
      expect { basic_parse.send(:parse, "a&b&c)") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "requires a token" do
      expect { basic_parse.send(:parse, ">bgs") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "requires a token for an array" do
      expect { basic_parse.send(:parse, "[bgs]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "doesn't allow a bad comparer" do
      expect { basic_parse.send(:parse, "a<<[bgs]") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "doesn't allow a comparer in the wrong place" do
      expect { basic_parse.send(:parse, "a<b<gs") }.to raise_exception FilterParamParser::InvalidFormat
    end

    it "doesn't allow a !!" do
      expect { basic_parse.send(:parse, "a<b&!!gs") }.to raise_exception FilterParamParser::InvalidFormat
    end
  end

  describe "#to_s" do
    it "outputs the parsed input as a string" do
      basic_parse.send(:parse, "!((a=)|b>|c)&((x~=[y,z])&((((((a<b)&(c>d))|((e<=f)|(g>=h)))&(i=j))&(k[[l,m,n],[o,p],q,,r]))&(s!=[t,u]&v!~=w)))")
      expect(basic_parse.to_s).to be == "!(a=|b>|c),x~=[y,z],((a<b,c>d)|e<=f|g>=h),i=j,k[[l,m,n],[o,p],q,,r],s!=[t,u],v!~=w"
    end

    it "outputs the parsed input as a safe_url" do
      basic_parse.send(:parse, "!((a=)|b>|c)&((x~=[y,z])&((((((a<b)&(c>d))|((e<=f)|(g>=h)))&(i=j))&(k[[l,m,n],[o,p],q,,r]))&(s!=[t,u]&v!~=w)))")
      expect(basic_parse.to_url_param).to be == "!(a%3D|b>|c),x~%3D[y,z],((a<b,c>d)|e<%3Df|g>%3Dh),i%3Dj,k[[l,m,n],[o,p],q,,r],s!%3D[t,u],v!~%3Dw"
    end

    it "outputs the parsed input as a safe_url" do
      basic_parse.send(:parse, "!((a=)|b>|c)&((x~=[y,z])&((((((a<b)&(c>d))|((e<=f)|(g>=h)))&(i=j))&(k[[l,m,n],[o,p],q,,r]))&(s!=[t,u]&v!~=w)))")
      expect(basic_parse.to_strict_url_param).to be == "%21%28a%3D%7Cb%3E%7Cc%29%2Cx%7E%3D%5By%2Cz%5D%2C%28%28a%3Cb%2Cc%3Ed%29%7Ce%3C%3Df%7Cg%3E%3Dh%29%2Ci%3Dj%2Ck%5B%5Bl%2Cm%2Cn%5D%2C%5Bo%2Cp%5D%2Cq%2C%2Cr%5D%2Cs%21%3D%5Bt%2Cu%5D%2Cv%21%7E%3Dw"
    end
  end

  describe "complex built filter" do
    (1..100).to_a.map do |index|
      it "parses complex filters #{index}" do
        # This is an uncontrolled and uncontrollable test.
        # I just generate a ton of random, but valid, string and the
        # expected results and test them out.
        #
        # This generates strings with patterns I would never have thought
        # would be problems, and more often than not finds problems I wouldn't
        # have otherwise.
        #
        # The main problem is that any bugs found could be in the parser or in the
        # expectation, so debugging can be interesting.  Especially since the
        # strings purposefully end up being pretty large usually.

        build_hash, build_string = build_complex_expression
        basic_parse.send(:parse, build_string)

        expect(basic_parse.parsed_fields).to be == build_hash

        # This is a convenient time to test the to_s.  So, we parse the results of the
        # to_s and see if they come out the same.  This isn't really much of a test
        # really as we know that the to_s is built from the underlying structure, so
        # it should always be true, but it is something at least.
        expect(basic_parse.send(:parse, basic_parse.to_s)).to be == build_hash
      end
    end
  end

  describe "invalid filter strings" do
    (1..100).to_a.map do |index|
      it "catches random errors #{index}" do
        build_hash, build_string = build_complex_expression no_tokens: true
        basic_parse.send(:parse, build_string)

        expect(basic_parse.parsed_fields).to be == build_hash
        expect(basic_parse.send(:parse, basic_parse.to_s)).to be == build_hash

        # I don't have & and | because if they are inserted into a token (random here)
        # they will create a valid state.
        bad_string         = build_string
        reserved_chars     = %w(! \( \) [ ] ~ = < >)
        reserved_character = reserved_chars.sample
        bad_pos            = 1 + rand(build_string.length - 1)
        while (bad_pos < build_string.length)
          case reserved_character
            when "!"
              break if !["[", "=", "(", "~"].include?(bad_string[bad_pos])
            when "~"
              break if !["[", "="].include?(bad_string[bad_pos])
            when "="
              break if !["!", "~", "<", ">"].include?(bad_string[bad_pos-1]) && !["["].include?(bad_string[bad_pos])
            when ">", "<"
              break if [">", "<"].include?(bad_string[bad_pos-1])
              break if !["=", "["].include?(bad_string[bad_pos])
          end
          bad_pos+= 1
        end

        bad_string = bad_string[0..(bad_pos - 1)] + reserved_character + bad_string[bad_pos..-1]
        expect { basic_parse.send(:parse, bad_string) }.to raise_exception FilterParamParser::InvalidFormat
      end
    end
  end

  def build_complex_expression(options={})
    num_levels      = options[:num_levels] || (1 + rand(5))
    num_sub_filters = 2

    if (num_levels >= 1)
      complex_type = [:not_filter, :group, :&, :|, ",".to_sym, :comparison].sample
      sub_filters  = []
    else
      complex_type = :comparison
    end

    case complex_type
      when :not_filter, :group
        num_sub_filters = 1

      when :comparison
        sub_filters     = nil
        num_sub_filters = 0

      else
        num_sub_filters = options[:num_sub_filters] || (2 + rand(5))
    end

    sub_options = { num_levels: num_levels - 1, partial_filter: true, no_tokens: options[:no_tokens] }

    while (num_sub_filters > 0)
      sub_filters << build_complex_expression(sub_options)
      num_sub_filters -= 1
    end

    build_options = { sub_filters:    sub_filters,
                      complex_type    => true,
                      partial_filter: options[:partial_filter],
                      no_tokens:      options[:no_tokens]
    }

    build_filter_expression(build_options)
  end

  def build_filter_expression(options = {})
    filter_complete        = !options[:partial_filter]
    build_filter_expression= [:not_filter, :group, :&, :|, ",".to_sym, :comparison].find do |operator|
      options[operator] ? operator : nil
    end
    unless build_filter_expression
      build_filter_expression = [:not_filter, :group, :&, :|, ",".to_sym, :comparison].sample
    end

    sub_filter_options = options[:sub_filter_options] || options

    case build_filter_expression
      when :not_filter
        if options[:sub_filters]
          sub_filter_hash, sub_filter_string = options[:sub_filters][0]
        else
          sub_filter_hash, sub_filter_string = build_comparison(sub_filter_options)
        end

        case sub_filter_hash[:type]
          when :group
            filter_hash        = sub_filter_hash
            filter_hash[:type] = :not_filter
          when :not_filter
            if filter_complete
              filter_hash = sub_filter_hash[:filter_expression]
            else
              filter_hash        = sub_filter_hash
              filter_hash[:type] = :group
            end
          else
            filter_hash = { type: :not_filter, filter_expression: sub_filter_hash }
        end
        filter_string = "!(#{sub_filter_string})"

      when :group
        if options[:sub_filters]
          sub_filter_hash, sub_filter_string = options[:sub_filters][0]
        else
          sub_filter_hash, sub_filter_string = build_comparison(sub_filter_options)
        end


        if filter_complete
          if :group == sub_filter_hash[:type]
            filter_hash = sub_filter_hash[:filter_expression]
          else
            filter_hash = sub_filter_hash
          end
        else
          if [:group, :not_filter].include?(sub_filter_hash[:type])
            filter_hash = sub_filter_hash
          else
            filter_hash = { type: :group, filter_expression: sub_filter_hash }
          end
        end

        filter_string = "(#{sub_filter_string})"

      when :&, :|, ",".to_sym
        num_booleans = (options[:sub_filters] && options[:sub_filters].length) || 2

        compare_symbol = build_filter_expression
        compare_symbol = :& if compare_symbol == ",".to_sym

        sub_filter_strings     = []
        sub_filter_expressions = []

        while num_booleans > 0
          if options[:sub_filters] && options[:sub_filters].length >= num_booleans
            sub_filter_hash, sub_filter_string = options[:sub_filters][num_booleans - 1]
          else
            sub_filter_hash, sub_filter_string = build_comparison(sub_filter_options)
          end

          if :group == sub_filter_hash[:type]
            if ![:&, :|].include?(sub_filter_hash[:filter_expression][:type]) ||
                sub_filter_hash[:filter_expression][:type] == compare_symbol
              sub_filter_hash = sub_filter_hash[:filter_expression]
            end
          end

          if [:&, :|].include?(sub_filter_hash[:type])
            if sub_filter_hash[:type] == compare_symbol
              sub_filter_expressions.concat sub_filter_hash[:filter_expressions]
            else
              sub_filter_hash = { type: :group, filter_expression: sub_filter_hash }
              sub_filter_expressions << sub_filter_hash
            end
            sub_filter_string = "(#{sub_filter_string})"
          else
            sub_filter_expressions << sub_filter_hash
          end

          sub_filter_strings << sub_filter_string

          num_booleans -= 1
        end

        filter_hash   = { type: compare_symbol, filter_expressions: sub_filter_expressions }
        filter_string = sub_filter_strings.map { |filter| filter }.join(compare_symbol.to_s)

      when :comparison
        if options[:sub_filters]
          filter_hash, filter_string = options[:sub_filters][0]
        else
          filter_hash, filter_string = build_comparison(sub_filter_options)
        end
    end

    [filter_hash, filter_string]
  end

  def build_comparison(options = {})
    operator_list = [:<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, :[], "~[]".to_sym, "!=".to_sym, "!~=".to_sym,
                     :"![]".to_sym, "!~[]".to_sym, :token]

    operator_list -= [:token] if options[:no_tokens]

    build_operator = operator_list.find do |operator|
      options[operator] ? operator : nil
    end
    unless build_operator
      build_operator = operator_list.sample
    end

    token_value = build_string(options)
    case build_operator
      when :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym
        values_hash, values_string = build_test_value(options)
        values_string              = "#{CGI.escape(token_value)}#{build_operator.to_s}#{values_string}"
      when :[], "~[]".to_sym, :"![]".to_sym, "!~[]".to_sym
        values_hash, values_string = build_array(options)
        values_string              = "#{CGI.escape(token_value)}#{build_operator.to_s[0..-2]}#{values_string}]"
      when :token
        values_hash   = {}
        values_string = "#{CGI.escape(token_value)}"
    end

    values_hash[:type]  = build_operator
    values_hash[:token] = token_value
    [values_hash, values_string]
  end

  def build_test_value(options={})
    build_test_values = [:test_value_single, :test_value_tuple].find do |operator|
      options[operator] ? operator : nil
    end
    unless build_test_values
      build_test_values = [:test_value_single, :test_value_tuple].sample
    end

    case build_test_values
      when :test_value_single
        string = build_string(options)
        [{ values: [[string]] }, CGI.escape(string)]
      when :test_value_tuple
        hash, string = build_tuple(options)
        [{ values: [hash] }, string]
    end
  end

  def build_array(options={})
    build_arrays = [:arrays_singles, :arrays_tuples, :arrays_mixed].find do |operator|
      options[operator] ? operator : nil
    end
    unless build_arrays
      build_arrays = [:arrays_singles, :arrays_tuples, :arrays_mixed].sample
    end

    build_size = [:array_size_single, :array_size_multi].find do |operator|
      options[operator] ? operator : nil
    end
    unless build_size
      build_size = [:array_size_single, :array_size_multi].sample
    end

    array_size = 1
    case build_size
      when :array_size_multi
        array_size = 2 + rand(10)
    end

    array_values = (1..array_size).to_a.map do
      case build_arrays
        when :arrays_singles
          string = build_string(options)
          [string, CGI.escape(string)]
        when :arrays_mixed
          ((rand(2) % 2) == 0) ? (string = build_string(options); [string, CGI.escape(string)]) : build_tuple(options)
        when :arrays_tuples
          build_tuple(options)
      end
    end

    array_hash   = array_values.map { |value| value[0] }
    array_string = array_values.map { |value| value[1] }

    array_string = array_string.join(",")
    array_hash   = array_hash.map do |value|
      value.is_a?(Array) ? value : [value]
    end

    [{ values: array_hash }, array_string]
  end

  def build_tuple(options = {})
    build_tuples = [:tuples_multi, :tuples_single].find do |operator|
      options[operator] ? operator : nil
    end
    unless build_tuples
      build_tuples = [:tuples_multi, :tuples_single].sample
    end

    tuple_hash = nil
    case build_tuples
      when :tuples_multi
        tuple_hash = (1..(2 + rand(10))).to_a.map { build_string(options) }

      when :tuples_single
        tuple_hash = [build_string(options)]
    end

    tuple_string = tuple_hash.map { |value| CGI.escape(value) }.join(",")
    tuple_string = "[#{tuple_string}]"

    [tuple_hash, tuple_string]
  end

  def build_string(options = {})
    build_string = [:plain_string, :encode_string].find do |operator|
      options[operator] ? operator : nil
    end
    unless build_string
      build_string = [:plain_string, :encode_string].sample
    end

    case build_string
      when :plain_string
        Faker::Lorem.word

      when :encode_string
        Faker::Lorem.word + (1..(1 + rand(5))).to_a.map { [%w(% & = [ ] < > \( \) ! ~ |).sample] }.join("")
    end
  end
end