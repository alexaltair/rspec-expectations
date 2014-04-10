module RSpec
  module Matchers
    module BuiltIn
      # @api private
      # Provides the implementation for `has_<predicate>`.
      # Not intended to be instantiated directly.
      class Has
        include Composable

        def initialize(method_name, *args, &block)
          @method_name, @args, @block = method_name, args, block
        end

        # @private
        def matches?(actual, &block)
          @actual = actual
          @block ||= block
          predicate_exists? && predicate_matches?
        end

        # @private
        def does_not_match?(actual, &block)
          @actual = actual
          @block ||= block
          predicate_exists? && !predicate_matches?
        end

        # @api private
        # @return [String]
        def failure_message
          validity_message || "expected ##{predicate}#{failure_message_args_description} to return true, got false"
        end

        # @api private
        # @return [String]
        def failure_message_when_negated
          validity_message || "expected ##{predicate}#{failure_message_args_description} to return false, got true"
        end

        # @api private
        # @return [String]
        def description
          [method_description, args_description].compact.join(' ')
        end

      private

        def predicate_exists?
          @actual.respond_to? predicate
        end

        def predicate_matches?
          @actual.__send__(predicate, *@args, &@block)
        end

        def predicate
          @predicate ||= :"has_#{@method_name.to_s.match(Matchers::HAS_REGEX).captures.first}?"
        end

        def method_description
          @method_name.to_s.gsub('_', ' ')
        end

        def args_description
          return nil if @args.empty?
          @args.map { |arg| arg.inspect }.join(', ')
        end

        def failure_message_args_description
          desc = args_description
          "(#{desc})" if desc
        end

        def validity_message
          "expected #{@actual} to respond to `#{predicate}`" unless predicate_exists?
        end
      end
    end
  end
end
