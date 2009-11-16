require 'ffi'

module GIRepository
  module Helper
    module GType
      def self.init; Lib::g_type_init; end
      private
      module Lib
	extend FFI::Library
	ffi_lib "gobject-2.0"
	attach_function :g_type_init, [], :void
      end
    end
  end
end

