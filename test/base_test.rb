require File.expand_path('test_helper.rb', File.dirname(__FILE__))
require 'gir_ffi/base'

class BaseTest < Test::Unit::TestCase
  context "A class derived from GirFFI::Base" do
    setup do
      @klass = Class.new(GirFFI::Base) do
	# Boilerplate to make regular #new work again.
	def initialize; end
	def self.new; self._real_new; end
      end
    end

    should "be able to use method_name to get the names of its methods" do
      @klass.class_eval do
	def this_is_my_name
	  method_name
	end
      end
      assert_equal "this_is_my_name", @klass.new.this_is_my_name
    end
  end
end
