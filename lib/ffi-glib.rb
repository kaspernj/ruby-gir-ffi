require 'gir_ffi-base/glib/strv'

GirFFI.setup :GLib

require 'ffi-glib/s_list'
require 'ffi-glib/list'
require 'ffi-glib/hash_table'
require 'ffi-glib/byte_array'
require 'ffi-glib/array'
require 'ffi-glib/ptr_array'

module GLib
  # FIXME: Compatibility function. Remove in version 0.5.0.
  def self.main_loop_new context, is_running
    GLib::MainLoop.new context, is_running
  end

  load_class :HFunc
  load_class :HashFunc
  load_class :EqualFunc
  load_class :Func

  module Lib
    attach_function :g_slist_prepend, [:pointer, :pointer], :pointer

    attach_function :g_list_append, [:pointer, :pointer], :pointer

    attach_function :g_hash_table_foreach,
      [:pointer, HFunc, :pointer], :void
    attach_function :g_hash_table_new,
      [HashFunc, EqualFunc], :pointer
    attach_function :g_hash_table_insert,
      [:pointer, :pointer, :pointer], :void

    attach_function :g_byte_array_new, [], :pointer
    attach_function :g_byte_array_append,
      [:pointer, :pointer, :uint], :pointer

    attach_function :g_array_new, [:int, :int, :uint], :pointer
    attach_function :g_array_append_vals,
      [:pointer, :pointer, :uint], :pointer

    attach_function :g_ptr_array_new, [], :pointer
    attach_function :g_ptr_array_add, [:pointer, :pointer], :void
    attach_function :g_ptr_array_foreach, [:pointer, Func, :pointer],
      :pointer
  end
end
