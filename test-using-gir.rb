#
# Exploratory program to see what kind of method_missing we would need in a
# module. In the end, this code would have to be generated by the Builder,
# or be provided by a mixin.
#

$LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
require 'girffi'
require 'girffi/builder'

module GObject
  module Lib
    extend FFI::Library
    ffi_lib "gobject-2.0"
    # TODO: Generate these
    CALLBACKS = []
    callback :Callback, [], :void
    callback :ClosureNotify, [:pointer, :pointer], :void
    enum :ConnectFlags, [:AFTER, (1<<0), :SWAPPED, (1<<1)]
  end

  def self.method_missing method, *arguments, &block
    @@builder ||= GirFFI::Builder.new
    go = @@builder.function_introspection_data "GObject", method.to_s

    # TODO: Unwind stack of raised NoMethodError to get correct error
    # message.
    return super if go.nil?
    return super if go.type != :function

    @@builder.attach_ffi_function Lib, go

    code = @@builder.function_definition go

    (class << self; self; end).class_eval code

    if block.nil?
      self.send method, *arguments
    else
      self.send method, *arguments, &block
    end
  end
end


module Gtk
  module Lib
    extend FFI::Library
    ffi_lib "gtk-x11-2.0"
    # TODO: Genereate these
    enum :GtkWindowType, [:GTK_WINDOW_TOPLEVEL, :GTK_WINDOW_POPUP]
    attach_function :gtk_window_new, [:GtkWindowType], :pointer
  end

  def self.method_missing method, *arguments
    @@builder ||= GirFFI::Builder.new
    go = @@builder.function_introspection_data "Gtk", method.to_s

    # TODO: Unwind stack of raised NoMethodError to get correct error
    # message.
    return super if go.nil?
    return super if go.type != :function

    @@builder.attach_ffi_function Lib, go

    code = @@builder.function_definition go

    (class << self; self; end).class_eval code

    self.send method, *arguments
  end

  class Widget
    def method_missing method, *arguments
      @@builder ||= GirFFI::Builder.new
      go = @@builder.method_introspection_data "Gtk", "Widget", method.to_s

      return super if go.nil?
      return super if go.type != :function

      @@builder.attach_ffi_function Lib, go

      code = @@builder.function_definition go

      (class << self; self; end).class_eval code

      self.send method, *arguments
    end
    def to_ptr
      @gobj
    end
  end

  class Window < Widget
    def initialize type
      @gobj = Lib.gtk_window_new(type)
    end
    def method_missing method, *arguments
      @@builder ||= GirFFI::Builder.new
      go = @@builder.method_introspection_data "Gtk", "Window", method.to_s

      return super if go.nil?
      return super if go.type != :function

      @@builder.attach_ffi_function Lib, go

      code = @@builder.function_definition go

      (class << self; self; end).class_eval code

      self.send method, *arguments
    end
  end
end

(my_len, my_args) = Gtk.init ARGV.length, ARGV
p my_len, my_args
win = Gtk::Window.new(:GTK_WINDOW_TOPLEVEL)
win.show
GObject.signal_connect_data(win, "destroy", nil, nil, 0) { Gtk.main_quit }
Gtk.main
