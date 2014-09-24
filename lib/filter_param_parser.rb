class FilterParamParser
  # Filter format:
  #
  # <filter_expression>       = <basic_filter_expression>
  #                             <and_expression>
  #                             <or_expression>
  #
  # <basic_filter_expression> = !(<filter_expression>)
  #                             (<filter_expression>)
  #                             <token><comparison>
  #                             <token>
  #
  # <and_expression>          = <basic_filter_expression>
  #                             <basic_filter_expression>&<and_expression>
  #                             <basic_filter_expression>,<and_expression>
  #                             (<or_expression>)
  #
  # <or_expression>           = <basic_filter_expression>
  #                             <basic_filter_expression>|<or_expression>
  #                             (<and_expression>)
  #
  # <token>                   = a string with 1 or more characters - may not be blank
  #                             any string containing a reserved character: !()[],&|~=<>
  #                             must be uri encoded using CGI.escape
  #                             tokens will be decoded using CGI.unescape
  #
  # <comparison>              = =<test_value>
  #                             ~=<test_value>
  #                             !=<test_value>
  #                             !~=<test_value>
  #                             <<test_value>
  #                             ><test_value>
  #                             >=<test_value>
  #                             <=<test_value>
  #                             [<test_value>(,<test_value>...)]
  #                             ~[<test_value>(,<test_value>...)]
  #                             ![<test_value>(,<test_value>...)]
  #                             !~[<test_value>(,<test_value>...)]
  #
  # <test_value>              = <simple_field>
  #                             <tuple>
  #
  # <tuple>                   = [<simple_field>(,<simple_field>...)]
  #
  # <simple_field>            = a string - may be blank
  #                             any string containing a reserved character: !()[],&|~=<>
  #                             must be uri encoded using CGI.escape
  #                             tokens will be decoded using CGI.unescape
  #
  # Some notes:
  #   The parser will not trim whitespace.
  #   If a filter comes in with:  field = value, then the filter will parse this similar to:
  #     { token: "field ", operator: "=", value: " value" }
  #   In fact, whitespace may be an error:
  #     a<b | (b<c)
  #          ^ This space is an error because the parser thinks it is a token and the ( is not
  #            allowed inside or immediately after a token.
  #
  #   The parser only validates the format structure defined here.
  #   The parser assumes no knowledge or structure to the fields and the comparisons.
  #   That is, the parser does not know that "field_1=fred" is invalid because field_1
  #   requires an integer, not a string.
  #
  #   The parser is designed to allow the value that is being tested to be a set of values.
  #   If the value is a set of values instead of a single value, the parser assumes that the
  #   filterer will interpret the value set appropriately to reduce it to a single clause.
  #   This allows the filter to consider the following constructs to be valid:
  #     * field[[value_1_1,value_1_2,value_1_3]]
  #     * field[[value_1_1,value_1_2,value_1_3],[value_2_1,value_2_2,value_2_3]]
  #     * field<[value_1_1,value_1_2,value_1_3]
  #
  #   A filter expression without at least one <comparison> is consider an empty filter.
  #
  #   A filter with no <comparison> is considered a "flag" filter.  It is up to the consumer
  #   to determine what to do with this filter as the operation and value will be nil.
  #
  #   To simplify life, all instances of <test_value> are considered tuples after parsing.
  #   If a simple value is entered, it will be converted to a tuple.
  #
  #   The parser will remove unnecessary groupings.
  #     ((a<b&c<d)) => a<b&c<d.
  #     (!((a<b)&c<d)) => !(a<b&c<d)
  #     !(!((a<b)&c<d)) => a<b&c<d
  #
  #   The parser will not allow an unclear expression.  This means that it will not allow mixing & and | expressions
  #   without groupings.
  #     a&b|c => invalid
  #     (a&b)|c => valid
  #     a&(b|c) => valid
  #
  #   Because mixed expressions are not allowed, the parser can and will reduce unnecessary groups between
  #   boolean expressions that are the same
  #     a&(b&(c&(d|e))) => a&b&c&(d|e)

  # A note on the code...
  #   I am not a compiler expert.
  #   I wanted something to parse fairly simple boolean expressions, so this is what
  #   I came up with.  It seems to do a decent job.
  #   I'd be willing to bet good money that most of the if checks I have to validate states
  #   just plain aren't necessary.  I'm conservative, so I'm going to leave them in.
  #
  #   To get test coverage, I have commented out some of the conservative parts of the code.
  #   I know it is a bad practice to leave in commented out code.
  #   I am leaving the code in just in case I need it later, and to remind me of the tests that
  #   aren't needed.
  #
  #   I'd be willing to bet that there is a more efficient way to do this.  A less spaghetti looking
  #   way that is probably also faster.
  #
  #   I'm not too concerned about that right now.  This passes through the string once, processing as it
  #   goes.  It doesn't go over any character multiple times except to extract the tokens and simple strings.
  #   Which I could probably do differently, but I suspect that it is more efficient to do it the way I
  #   am doing it.
  #
  #   Are there bugs?  Probably - see above, I am not a compiler expert.
  #   Are they critical - probably not.  I think that the tests that I have are fairly decent, and that
  #   though randomish, they do a decent job of stressing the code to make sure it does what it is supposed
  #   to be doing.  The random nature of the tests is actually pretty good for me in that they test things
  #   I wouldn't have thought of doing, and test far more complex and comprehensive than I probably
  #   would have thought of doing.
  #
  #   If you find/have any problems, please let me know, and I will fix them.

  class InvalidFormat < Exception
  end

  attr_accessor :parsed_fields

  # create an instance and parse the passed in string.
  # The passed in string may be blank.
  def initialize(param_string)
    @parsed_fields = {}

    parse(param_string) unless param_string.blank?
  end

  # The string representation of the filter expression.
  def to_s
    filter_expression_to_s @parsed_fields
  end

  # output the filter as a string that should be OK for most browsers.
  # This string will be mostly readable, though things like the = will be encoded to be safe
  # , is used instead of & so that it will not need encoding.
  def to_url_param
    filter_expression_to_s @parsed_fields, uri_safe: true
  end

  # output the filter as a string that is fully encoded.
  def to_strict_url_param
    filter_expression_to_s @parsed_fields, fully_safe: true
  end

  # I want to do these, just not right now...
  #def build_filter_piece(*arguments)
  #end
  #
  #def add_filter(*arguments)
  #end

  private
  def parse(param_string, options = {})
    # filter_expression[:type] list:
    #   :not_filter_proto
    #   "!~".to_s
    #   :not_filter
    #   :group
    #   :token
    #   :simple_field
    #   :tuple
    #   :<
    #   :>
    #   :<=
    #   :>=
    #   "=".to_sym
    #   "~=".to_sym
    #   "!=".to_sym
    #   "!~=".to_sym
    #   :[]
    #   "~[]".to_sym
    #   :"![]".to_sym
    #   "!~[]".to_sym
    #   :&
    #   :|

    unless param_string.blank?
      state_stack   = []
      current_state = start_new_state(state_stack, 0)

      char_index       = 0
      param_string_len = param_string.length
      while (char_index < param_string_len)
        char = param_string[char_index]

        #param_string.each_char.each_with_index do |char, char_index|
        case char
          when "!", "("
            # ( can only occur at the start of a <filter_expression>
            # If we have not closed the expression, this is a parsing error
            unless current_state[:filter_expression].nil? || current_state[:filter_expression][:type] == :token
              invalid_format(param_string, char_index, "starting a group in the middle of an incomplete statement")
            end

            if current_state[:filter_expression] && current_state[:filter_expression][:type] == :token
              complete_token(param_string, current_state, char_index - 1)
              current_state[:filter_expression][:type] = :not_filter_proto
            else
              # we can only start a group at the beginning of a group, not filter or
              # the second half of a binary filter group.
              if state_stack.length > 0
                unless [:&, :|, :group, :not_filter, :not_filter_proto].
                    include?(state_stack[-1][:filter_expression][:type])
                  invalid_format(param_string, char_index, "starting a group in the middle of an incomplete expression")
                end
              end

              # Check to see if this is immediately after a !
              if char == "!"
                if !current_state[:filter_expression] &&
                    !state_stack.empty? &&
                    state_stack[-1][:filter_expression][:type] == :not_filter_proto
                  invalid_format(param_string, char_index, "cannot have an ! after another !")
                end
                current_state[:filter_expression] = { type: :not_filter_proto }
                state_stack.push(current_state)
              else
                if state_stack.empty? || state_stack[-1][:filter_expression][:type] != :not_filter_proto
                  current_state[:filter_expression] = { type: :group }
                  state_stack.push(current_state)
                end
                if !state_stack.empty? && state_stack[-1][:filter_expression][:type] == :not_filter_proto
                  state_stack[-1][:filter_expression][:type] = :not_filter
                end
              end
              current_state = start_new_state(state_stack, char_index + 1)
            end

          when ")"
            # This closes an expression
            current_state = complete_current_state(param_string, state_stack, current_state, char_index,
                                                   "trying to close a grouping in the middle of an expression")

            current_state                              = close_group(param_string, state_stack, current_state, char_index)

            # now that we've closed a group, we are complete.  Tag it so we don't think that this is an exception
            # in other places...
            current_state[:filter_expression_complete] = true

          # This could be opening an array or a new tuple.
          when "["
            new_state = start_new_state(state_stack, char_index + 1)

            if current_state[:filter_expression].nil?
              # only valid if starting a tuple in an array.
              unless !state_stack.empty? && current_state[:in_array]
                invalid_format(param_string, char_index, "tuples may only occur in an array")
              end

              current_state[:in_tuple]          = true
              current_state[:filter_expression] = { type: :tuple, values: [] }

              new_state[:in_tuple]          = true
              new_state[:filter_expression] = { type: :simple_field }
            else
              # only valid if starting a tuple or a comparitor array.
              unless [:not_filter_proto, :token, :~, "!~".to_sym, :<, :<=, :>, :>=,
                      "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym].
                  include?(current_state[:filter_expression][:type]) && !current_state[:filter_expression_complete]
                invalid_format(param_string, char_index,
                               "you may not have an array or a tuple except after a token or an expression")
              end

              if [:not_filter_proto, :token, :~, "!~".to_sym].include?(current_state[:filter_expression][:type])
                case current_state[:filter_expression][:type]
                  when :not_filter_proto
                    current_state[:filter_expression][:type] = "![]".to_sym
                  when :~
                    current_state[:filter_expression][:type] = "~[]".to_sym
                  when "!~".to_sym
                    current_state[:filter_expression][:type] = "!~[]".to_sym
                  else
                    complete_token(param_string, current_state, char_index - 1)
                    current_state[:filter_expression][:type] = :[]
                end

                current_state[:in_array]                   = true
                current_state[:filter_expression][:values] = []

                new_state[:in_array] = true
              else
                state_stack.push(current_state)

                # Start a tuple
                current_state                     = start_new_state(state_stack, char_index)
                current_state[:in_tuple]          = true
                current_state[:filter_expression] = { type: :tuple, values: [] }

                # the next thing has to be a simple field
                new_state[:in_tuple]              = true
                new_state[:filter_expression]     = { type: :simple_field }
              end
            end

            state_stack.push(current_state)
            current_state = new_state

          # close a tuple or an array, or it's an error
          when "]"
            if current_state[:in_tuple]
              current_state = close_tuple(param_string, state_stack, current_state, char_index)
            elsif current_state[:in_array]
              current_state = close_array(param_string, state_stack, current_state, char_index)
            else
              invalid_format(param_string, char_index, "not closing a tuple or array")
            end

          # Joining two expressions, or if , splitting tuple or array values
          when ",", "&", "|"
            if char == ","
              if current_state[:in_tuple]
                # splitting a tuple.  Put the current value into the pending tuple.
                #if :simple_field != current_state[:filter_expression][:type] ||
                #    state_stack.length <= 0 ||
                #    state_stack[-1][:filter_expression][:type] != :tuple
                #  invalid_format(param_string, char_index, "parsing error, not processing a tuple in a tuple")
                #end

                complete_simple_field(param_string, current_state, char_index - 1)

                state_stack[-1][:filter_expression][:values] << current_state[:simple_field]

                current_state                     = start_new_state(state_stack, char_index + 1)
                current_state[:in_tuple]          = true
                current_state[:filter_expression] = { type: :simple_field }
              elsif current_state[:in_array]
                # splitting an array.  Put the current value (or tuple) into the pending array.
                unless current_state[:filter_expression]
                  current_state[:filter_expression] = { type: :simple_field }
                end
                if current_state[:filter_expression][:type] == :simple_field
                  complete_simple_field(param_string, current_state, char_index - 1)
                end

                #if !([:[], "~[]".to_sym, "![]".to_sym, "!~[]".to_sym].include?(state_stack[-1][:filter_expression][:type]))
                #  invalid_format(param_string, char_index, "parsing error, in an array but not in an array")
                #end

                case current_state[:filter_expression][:type]
                  when :simple_field
                    state_stack[-1][:filter_expression][:values] << [current_state[:simple_field]]
                  when :tuple
                    state_stack[-1][:filter_expression][:values] << current_state[:filter_expression][:values]
                  #else
                  #  invalid_format(param_string, char_index, "parsing error, arrays can only contain values or tuples")
                end

                current_state = start_new_state(state_stack, char_index + 1)
              else
                # , == &.  This is just a shorthand notation.
                char = "&"
              end
            end

            if ["|", "&"].include?(char)
              # first finish up the current thing we're processing (if we can and it isn't already finished.)
              current_state = complete_current_state(param_string, state_stack, current_state, char_index,
                                                     "the previous statement is not completed")
              if current_state[:filter_expression] && current_state[:filter_expression][:type] == :token
                current_state[:filter_expression_complete] = true
              end

              if current_state[:filter_expression_complete]
                left_filter = current_state
              else
                left_filter = complete_filter_expression(param_string, state_stack, current_state, char_index, false)
              end

              if state_stack.blank? || !([:&, :|].include?(state_stack[-1][:filter_expression][:type]))
                current_state = start_new_state(state_stack, char_index)

                current_state[:filter_expression] = { type:               char.to_sym,
                                                      filter_expressions: [left_filter[:filter_expression]] }

                if left_filter[:filter_expression][:type] == :group &&
                    left_filter[:filter_expression][:filter_expression][:type] == current_state[:filter_expression][:type]
                  current_state[:filter_expression][:filter_expressions] =
                      left_filter[:filter_expression][:filter_expression][:filter_expressions]
                end

                state_stack.push(current_state)
              else
                if [:&, :|].include?(state_stack[-1][:filter_expression][:type]) &&
                    state_stack[-1][:filter_expression][:type] != char.to_sym
                  invalid_format(param_string, char_index, "cannot mix boolean expressions & and | use () to make the expression clear")
                end

                if left_filter[:filter_expression][:type] == :group &&
                    left_filter[:filter_expression][:filter_expression][:type] == state_stack[-1][:filter_expression][:type]
                  state_stack[-1][:filter_expression][:filter_expressions].
                      concat left_filter[:filter_expression][:filter_expression][:filter_expressions]
                else
                  state_stack[-1][:filter_expression][:filter_expressions] << left_filter[:filter_expression]
                end
              end

              current_state = start_new_state(state_stack, char_index + 1)
            end

          # can only appear after a token.
          when "~"
            unless current_state[:filter_expression] && !current_state[:filter_expression_complete]
              invalid_format(param_string, char_index, "~ may only appear in an expression following a token")
            end
            case current_state[:filter_expression][:type]
              when :not_filter_proto
                current_state[:filter_expression][:type] = "!~".to_sym
              else
                complete_token(param_string, current_state, char_index - 1)
                current_state[:filter_expression][:type] = :~
            end

          # can only appear after a token or ~<> (which also end a token).
          when "="
            if current_state[:filter_expression].nil? || current_state[:filter_expression_complete]
              invalid_format(param_string, char_index, "there must be a token before an =")
            end

            case current_state[:filter_expression][:type]
              when "!~".to_sym
                current_state[:filter_expression][:type] = "!~=".to_sym
              when :~
                current_state[:filter_expression][:type] = "~=".to_sym
              when :<
                current_state[:filter_expression][:type] = :<=
              when :>
                current_state[:filter_expression][:type] = :>=
              when :not_filter_proto
                current_state[:filter_expression][:type] = "!=".to_sym
              else
                complete_token(param_string, current_state, char_index - 1)
                current_state[:filter_expression][:type] = "=".to_sym
            end
            current_state[:filter_expression][:values] = []

          # can only appear after a token.
          when "<"
            complete_token(param_string, current_state, char_index - 1)
            unless current_state[:filter_expression] &&
                current_state[:filter_expression][:type] == :token &&
                !current_state[:filter_expression_complete]
              invalid_format(param_string, char_index, "< may only appear after a token")
            end
            current_state[:filter_expression][:type]   = :<
            current_state[:filter_expression][:values] = []

          # can only appear after a token.
          when ">"
            complete_token(param_string, current_state, char_index - 1)
            unless current_state[:filter_expression] &&
                current_state[:filter_expression][:type] == :token &&
                !current_state[:filter_expression_complete]
              invalid_format(param_string, char_index, "> may only appear after a token")
            end
            current_state[:filter_expression][:type]   = :>
            current_state[:filter_expression][:values] = []

          else
            # A non-reserved character.  Can only be a token or a simple_field...

            if current_state[:filter_expression].nil?
              # we aren't processing anything, if we're in a tuple or an array, it is
              # simple_field, otherwise it is a token.
              if current_state[:in_array] || current_state[:in_tuple]
                current_state[:filter_expression] = { type: :simple_field }
              else
                if !state_stack.empty? && state_stack[-1][:filter_expression][:type] == :not_filter_proto
                  invalid_format(param_string, char_index - 1, "invalid character following !")
                end

                current_state[:filter_expression] = { type: :token }
              end
            else
              case current_state[:filter_expression][:type]
                when :~, :[], "~[]".to_sym, "![]".to_sym, "!~[]".to_sym
                  # ~ must be followed by = or [
                  # [ will close itself and start an unknown expression, so this shouldn't happen.
                  invalid_format(param_string, char_index - 1, "~ not followed by an = or [")

                when :not_filter_proto
                  # ~ must be followed by = or [
                  # [ will close itself and start an unknown expression, so this shouldn't happen.
                  invalid_format(param_string, char_index - 1, "! not followed by an (, =, [ or ~")

                when "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym, :<, :>, :<=, :>=
                  # We've just finished an expression, start a simple field.
                  state_stack.push(current_state)

                  current_state                     = start_new_state(state_stack, char_index)
                  current_state[:filter_expression] = { type: :simple_field }

                when :token, :simple_field
                  # do nothing

                else
                  invalid_format(param_string, char_index, "free-text not allowed here")
              end
            end
        end

        char_index += 1
      end

      if current_state[:filter_expression] || !state_stack.empty?
        current_state = complete_current_state(param_string, state_stack, current_state, char_index,
                                               "incomplete expression")

        until state_stack.empty?
          current_state = complete_filter_expression(param_string, state_stack, current_state, char_index, false)
        end
      end

      if current_state[:filter_expression][:type] == :group
        @parsed_fields = current_state[:filter_expression][:filter_expression]
      else
        @parsed_fields = current_state[:filter_expression]
      end
    end
  end

  def start_new_state(state_stack, char_index)
    new_state = { start_pos: char_index }

    unless state_stack.empty?
      if state_stack[-1][:in_tuple]
        new_state[:in_tuple] = true
      end
      if state_stack[-1][:in_array]
        new_state[:in_array] = true
      end
    end

    new_state
  end

  def complete_token(param_string, current_state, char_index)
    unless current_state[:filter_expression_complete]
      # if we are not building a token, or the token string is blank, it is an error.
      if !current_state[:filter_expression] ||
          :token != current_state[:filter_expression][:type] ||
          current_state[:start_pos] > char_index
        invalid_format(param_string, char_index, "tokens may not be blank")
      end

      current_state[:filter_expression][:token] = CGI.unescape(param_string[current_state[:start_pos]..char_index])
    end
  end

  def complete_simple_field(param_string, current_state, char_index)
    # simple field can be an empty string.
    if current_state[:start_pos] > char_index
      current_state[:simple_field] = ""
    else
      current_state[:simple_field] = CGI.unescape(param_string[current_state[:start_pos]..char_index])
    end
  end

  # Add anything that is still being worked on to the tuple
  def close_tuple(param_string, state_stack, current_state, char_index)
    tuple_field = state_stack.pop

    #if !tuple_field || !(:tuple == tuple_field[:filter_expression][:type])
    #  invalid_format(param_string, char_index, "parsing error, could not find tuple")
    #end

    if current_state[:filter_expression]
      if :simple_field == current_state[:filter_expression][:type]
        complete_simple_field(param_string, current_state, char_index - 1)
        tuple_field[:filter_expression][:values] << current_state[:simple_field]
      end
    end

    tuple_field[:in_tuple] = false

    tuple_field
  end

  # Add anything that is still being worked on to the array, and leave it on the stack for now...
  def close_array(param_string, state_stack, current_state, char_index)
    array_field = state_stack.pop

    if current_state[:filter_expression]
      case current_state[:filter_expression][:type]
        when :simple_field
          complete_simple_field(param_string, current_state, char_index - 1)
          array_field[:filter_expression][:values] << [current_state[:simple_field]]
        when :tuple
          array_field[:filter_expression][:values] << current_state[:filter_expression][:values]
      end
    end

    array_field[:in_array]                   = false
    array_field[:filter_expression_complete] = true

    array_field
  end

  def close_group(param_string, state_stack, current_state, char_index)
    if state_stack.empty?
      invalid_format(param_string, char_index, "closing ) without an opening (")
    end

    while current_state &&
        state_stack.length > 0 &&
        !([:group, :not_filter].include?(current_state[:filter_expression][:type]) &&
            !current_state[:filter_expression_complete])
      current_state = complete_filter_expression(param_string, state_stack, current_state, char_index, true)
    end

    case current_state[:filter_expression][:type]
      when :group
        if [:group, :not_filter, :token, :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym,
            "!=".to_sym, "!~=".to_sym, :[], "~[]".to_sym, "![]".to_sym, "!~[]".to_sym].
            include?(current_state[:filter_expression][:filter_expression][:type])
          current_state[:filter_expression] = current_state[:filter_expression][:filter_expression]
        end

      when :not_filter
        # do nothing.

      else
        invalid_format(param_string, char_index, "closing parenthesis without an opening parenthesis")
    end

    current_state
  end

  # The current state you are working on should be the last piece of a filter_experssion
  # on the stack.  If it isn't, that is an error.
  # If it is, pop the filter_expression off of the stack, and complete it.
  #
  # return the completed filter_expression
  def complete_filter_expression(param_string, state_stack, current_state, char_index, complete_group)
    if !current_state[:filter_expression]
      invalid_format(param_string, char_index, "parsing error, no expression to close")
    end

    prev_state = state_stack.pop
    invalid_format(param_string, char_index, "an expression is incomplete") unless prev_state

    case current_state[:filter_expression][:type]
      when :simple_field, :tuple
        case prev_state[:filter_expression][:type]
          when :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym
            if current_state[:filter_expression][:type] == :simple_field
              prev_state[:filter_expression][:values] << [current_state[:simple_field]]
            else
              prev_state[:filter_expression][:values] << current_state[:filter_expression][:values]
            end

          else
            invalid_format(param_string, char_index, "values and tuples may only occur after an expression")
        end

      when :&, :|, :not_filter, :group, :token, :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym,
          "!=".to_sym, "!~=".to_sym, :[], "~[]".to_sym, "![]".to_sym, "!~[]".to_sym
        #if [:&, :|, :not_filter, :group].include?(current_state[:filter_expression][:type]) &&
        #    !current_state[:filter_expression_complete] &&
        #    !current_state[:filter_expression][:filter_expressions]
        #  invalid_format(param_string, char_index, "incomplete expression")
        #end

        case prev_state[:filter_expression][:type]
          when :&, :|
            #unless prev_state[:filter_expression][:filter_expressions]
            #  invalid_format(param_string, char_index, "parsing error, binary expression without a left half")
            #end
            if :group == current_state[:filter_expression][:type] &&
                (current_state[:filter_expression][:filter_expression][:type] == prev_state[:filter_expression][:type] ||
                    ![:&, :|].include?(current_state[:filter_expression][:filter_expression][:type])
                )
              prev_state[:filter_expression][:filter_expressions].
                  concat current_state[:filter_expression][:filter_expression][:filter_expressions]
            else
              prev_state[:filter_expression][:filter_expressions] << current_state[:filter_expression]
            end

          when :not_filter, :group
            if !complete_group && !current_state[:filter_expression_complete]
              invalid_format(param_string, char_index, "incomplete group")
            end
            #if prev_state[:filter_expression][:filter_expression]
            #  invalid_format(param_string, char_index, "parsing error, group already has an expression")
            #end

            if [:group, :not_filter].include?(current_state[:filter_expression][:type])
              # They are both groups or not groups, reduce the expression
              if current_state[:filter_expression][:type] == :not_filter &&
                  prev_state[:filter_expression][:type] == :not_filter
                prev_state[:filter_expression][:type] = :group
              elsif current_state[:filter_expression][:type] == :not_filter ||
                  prev_state[:filter_expression][:type] == :not_filter
                prev_state[:filter_expression][:type] = :not_filter
              end

              prev_state[:filter_expression][:filter_expression] = current_state[:filter_expression][:filter_expression]
            else
              prev_state[:filter_expression][:filter_expression] = current_state[:filter_expression]
            end

          #when :not_filter_proto
          #  invalid_format(param_string, char_index, "invalid character(s) following !")

          #else
          #  invalid_format(param_string, char_index, "cannot add an expression to an expression or an incomplete expression")
        end

      #else
      #  invalid_format(param_string, char_index, "the expression is incomplete")
    end

    prev_state
  end

  def complete_current_state(param_string, state_stack, current_state, char_index, exception_description)
    if current_state[:filter_expression]
      case current_state[:filter_expression][:type]
        when :token
          complete_token(param_string, current_state, char_index - 1)

        when :simple_field
          complete_simple_field(param_string, current_state, char_index - 1)

        when :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym
          if (current_state[:filter_expression][:values].blank?)
            current_state[:filter_expression][:values] = []
            state_stack.push current_state
            current_state                     = start_new_state(state_stack, char_index)
            current_state[:filter_expression] = { type: :simple_field }
            complete_simple_field(param_string, current_state, char_index - 1)
          end

        #else
        #  unless current_state[:filter_expression_complete] || current_state[:filter_expression][:type] == :tuple
        #    invalid_format(param_string, char_index, exception_description)
        #  end
      end
    end

    current_state
  end

  def invalid_format(param_string, char_index, error_description)
    raise FilterParamParser::InvalidFormat.
              new("Invalid format near character %{char_index}(%{character_val}) in \"%{sample_segment}\" - %{error_description}" % {
        char_index:        char_index + 1,
        character_val:     param_string[char_index],
        sample_segment:    string_segment(param_string, char_index),
        error_description: error_description })
  end

  def string_segment(param_string, char_index)
    "...#{param_string[([0, char_index - 10].max)..(char_index + 10)]}..."
  end

  def escape_to_s(string, options = {})
    return_string = CGI.escape(string)
    if options[:uri_safe] && !options[:fully_safe]
      return_string = CGI.escape(return_string)
    end
    return_string
  end

  def escape_type_to_s(string, options = {})
    return_string = string
    if options[:uri_safe] && !options[:fully_safe]
      #return_string = CGI.escape(return_string)
      return_string = return_string.gsub("=", "%3D")
    end
    return_string
  end

  # This function takes 2 params:
  #   :uri_safe     - minimal escape of compare strings for output in a uri
  #   :fully_safe   - escape everything for output to a very strict uri
  def filter_expression_to_s(filter_expression, options={})
    full_escape        = options[:fully_safe] && !options[:sub_call]
    options[:uri_safe] = true if (full_escape)
    options[:sub_call] = true

    expression = case filter_expression[:type]
                   when :not_filter
                     "!(#{filter_expression_to_s filter_expression[:filter_expression], options})"

                   when :group
                     "(#{filter_expression_to_s filter_expression[:filter_expression], options})"

                   when :token
                     escape_to_s(filter_expression[:token], options)

                   when :<, :>, :<=, :>=, "=".to_sym, "~=".to_sym, "!=".to_sym, "!~=".to_sym
                     "#{escape_to_s(filter_expression[:token], options)}#{escape_type_to_s(filter_expression[:type].to_s, options)}#{filter_expression[:values].map do |tuple|
                       if tuple.length > 1
                         "[#{tuple.map { |value| escape_to_s(value, options) }.join(",")}]"
                       else
                         escape_to_s(tuple[0], options)
                       end
                     end.join(",")}"

                   when :[], "~[]".to_sym, :"![]".to_sym, "!~[]".to_sym
                     "#{escape_to_s(filter_expression[:token], options)}#{escape_type_to_s(filter_expression[:type].to_s[0..-2], options)}#{filter_expression[:values].map do |tuple|
                       if tuple.length > 1
                         "[#{tuple.map { |value| escape_to_s(value, options) }.join(",")}]"
                       else
                         escape_to_s(tuple[0], options)
                       end
                     end.join(",")}]"

                   when :&
                     filter_expression[:filter_expressions].map do |sub_expression|
                       filter_expression_to_s sub_expression, options
                     end.join(",")

                   when :|
                     filter_expression[:filter_expressions].map do |sub_expression|
                       filter_expression_to_s sub_expression, options
                     end.join("|")

                   #when :not_filter_proto
                   #  "!"
                   #when "!~".to_s
                   #  "!~"
                   #when :simple_field
                   #  ":simple_field"
                   #when :tuple
                   #  "[#{filter_expression[:values].map { |value| "#{escape_to_s(value, options)}" }.join(",")}]"
                   #else
                   #  if full_escape || options[:uri_safe]
                   #    FilterParamParser::InvalidFormat.new("filter ")
                   #  end
                   #  escape_type_to_s("unrecognized type: #{filter_expression.to_s}", options)
                 end

    if full_escape
      expression = CGI.escape(expression)
    end

    expression
  end
end