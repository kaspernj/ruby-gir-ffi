require File.expand_path('../gir_ffi_test_helper.rb', File.dirname(__FILE__))

describe GirFFI::Builder::Type::Interface do
  describe "#pretty_print" do
    it "returns a module block, extending InterfaceBase" do
      mock(info = Object.new).safe_name { "Bar" }
      stub(info).namespace { "Foo" }

      builder = GirFFI::Builder::Type::Interface.new(info)

      assert_equal "module Bar\n  extend InterfaceBase\nend", builder.pretty_print
    end
  end

  describe "#build_class" do
    before do
      info = get_introspection_data 'GObject', 'TypePlugin'
      @bldr = GirFFI::Builder::Type::Interface.new info
      @iface = @bldr.build_class
    end

    it "builds an interface as a module" do
      assert_instance_of Module, @iface
    end

    it "creates methods on the interface" do
      assert_defines_instance_method @iface, :complete_interface_info
    end
  end
end



