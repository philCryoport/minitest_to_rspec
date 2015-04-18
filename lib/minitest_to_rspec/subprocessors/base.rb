module MinitestToRspec
  module Subprocessors
    class Base
      class << self

        # Returns a s-expression representing an rspec-mocks stub.
        def allow_to(msg_recipient, matcher)
          target = s(:call, nil, :allow, msg_recipient)
          s(:call, target, :to, matcher)
        end

        def assert_sexp_type(type, exp)
          unless sexp_type?(type, exp)
            raise TypeError, "Expected #{type} s-expression, got #{exp}"
          end
        end

        # Returns a s-expression representing an RSpec expectation, i.e. the
        # combination of an "expectation target" and a matcher.
        def expect(target, eager, phase, matcher)
          s(:call, expectation_target(target, eager), phase, matcher)
        end

        def expect_to(matcher, target, eager)
          expect(target, eager, :to, matcher)
        end

        def expect_to_not(matcher, target, eager)
          expect(target, eager, :to_not, matcher)
        end

        # In RSpec, `expect` returns an "expectation target".  This
        # can be based on an expression, as in `expect(1 + 1)` or it
        # can be based on a block, as in `expect { raise }`.  Either
        # way, it's called an "expectation target".
        def expectation_target(exp, eager = true)
          m = "expectation_target_%s" % [eager ? "eager" : "lazy"]
          send(m, exp)
        end

        def expectation_target_eager(exp)
          s(:call, nil, :expect, exp)
        end

        def expectation_target_lazy(block)
          s(:iter,
            s(:call, nil, :expect),
            s(:args),
            full_process(block)
          )
        end

        # Run `exp` through a new `Processor`.  This is useful for expressions
        # that cannot be fully understood by a single subprocessor.  For
        # example, we process :iter expressions, because we're interested in
        # :iter that contain e.g. an `assert_difference`.  However, if the :iter
        # turns out to be uninteresting, we still want to fully process its
        # sub-expressions. TODO: `full_process` may not be the best name.
        def full_process(exp)
          Processor.new(false).process(exp)
        end

        def matcher(name, *args)
          exp = s(:call, nil, name)
          exp.concat(args)
        end

        def sexp_type?(type, exp)
          exp.is_a?(Sexp) && exp.sexp_type == type.to_sym
        end
      end
    end
  end
end
