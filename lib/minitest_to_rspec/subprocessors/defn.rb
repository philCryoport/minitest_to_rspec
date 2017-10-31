require_relative "../model/defn"
require_relative "base"

module MinitestToRspec
  module Subprocessors
    # Minitest tests can be defined as methods using names beginning with 'test_'.
    # Process those tests into RSpec `it` example blocks.
    class Defn < Base
      def initialize(sexp, rails, mocha)
        super(rails, mocha)
        @rails = rails
        @mocha = mocha
        @exp = Model::Defn.new(sexp)
        sexp.clear
      end

      # Given a `Model::Defn`, returns a `Sexp`
      def process
        s(:iter,
          s(:call, nil, :it, s(:str, example_title)),
          0,
          generate_block)
      end

      private

      # Remove 'test_' prefix and replace underscores with spaces
      def example_title
        @exp.method_name.sub(/^test_/, '').tr('_', ' ')
      end

      def generate_block
        block = s(:block)
        @exp.innards.each_with_object(block) do |innard, blk|
          blk << process_innard(innard)
        end
      end

      def process_innard(innard)
        ::MinitestToRspec::Processor.new(@rails, @mocha).process(innard)
      end
    end
  end
end
