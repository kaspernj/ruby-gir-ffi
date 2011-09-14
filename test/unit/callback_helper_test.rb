require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))
require "gir_ffi/callback_helper"

describe GirFFI::CallbackHelper do
  describe ".map_single_callback_arg" do
    it "correctly maps a :struct type" do
      GirFFI.setup :GObject

      cl = GObject::Closure.new_simple GObject::Closure::Struct.size, nil

      cinfo = GObjectIntrospection::IRepository.default.find_by_name 'GObject', 'ClosureMarshal'
      ainfo = cinfo.args[0]

      r = GirFFI::CallbackHelper.map_single_callback_arg cl.to_ptr, ainfo

      assert_instance_of GObject::Closure, r
      assert_equal r.to_ptr, cl.to_ptr
    end
  end
end
