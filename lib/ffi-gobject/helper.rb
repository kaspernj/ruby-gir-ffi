module GObject
  module Helper
    # Create a signal hander callback. Wraps the given block in such a way that
    # arguments and return value are cast correctly to the ruby world and back.
    #
    # @param  klass   The class of the object that will receive the signal.
    # @param  signal  The name of the signal
    # @param  block   The body of the signal handler
    #
    # @return [FFI::Function] The signal handler, ready to be passed as a
    #   callback to C.
    def self.signal_callback klass, signal, &block
      sig_info = klass.find_signal signal

      callback_block = signal_callback_args(sig_info, klass, &block)

      builder.build_callback sig_info, &callback_block
    end

    def self.builder= bldr
      @builder = bldr
    end

    def self.builder
      @builder ||= GirFFI::Builder
    end

    # FIXME: Move either to ISignalInfo or the base GObject class.
    def self.signal_callback_args sig, klass, &block
      raise ArgumentError, "Block needed" if block.nil?
      return Proc.new do |*args|
        mapped = cast_back_signal_arguments sig, klass, *args
        block.call(*mapped)
      end
    end

    def self.signal_arguments_to_gvalue_array signal, instance, *rest
      sig = instance.class.find_signal signal

      arr = ::GObject::ValueArray.new sig.n_args + 1

      arr.append signal_reciever_to_gvalue instance

      sig.args.zip(rest).each do |info, arg|
        arr.append signal_argument_to_gvalue info, arg
      end

      arr
    end

    def self.signal_reciever_to_gvalue instance
      val = ::GObject::Value.new
      val.init ::GObject.type_from_instance instance
      val.set_instance instance
      return val
    end

    def self.signal_argument_to_gvalue info, arg
      val = gvalue_for_type_info info.argument_type
      val.set_value arg
    end

    def self.gvalue_for_type_info info
      tag = info.tag
      gtype = case tag
              when :interface
                info.interface.g_type
              when :void
                return nil
              else
                TYPE_TAG_TO_GTYPE[tag]
              end
      raise "GType not found for type info with tag #{tag}" unless gtype
      Value.new.tap {|val| val.init gtype}
    end

    def self.gvalue_for_signal_return_value signal, object
      sig = object.class.find_signal signal
      rettypeinfo = sig.return_type

      gvalue_for_type_info rettypeinfo
    end

    # TODO: Generate cast back methods using existing Argument builders.
    def self.cast_back_signal_arguments signalinfo, klass, *args
      instance = klass.wrap args.shift
      user_data = GirFFI::ArgHelper::OBJECT_STORE[args.pop.address]

      extra_arguments = signalinfo.args.zip(args).map do |info, arg|
        cast_signal_argument(info, arg)
      end

      return [instance, *extra_arguments].push user_data
    end

    def self.cast_signal_argument info, arg
      arg_t = info.argument_type
      if arg_t.tag == :interface
        iface = arg_t.interface
        kls = GirFFI::Builder.build_class iface
        case iface.info_type
        when :enum, :flags
          kls[arg]
        when :interface
          arg.to_object
        else
          kls.wrap(arg)
        end
      else
        arg
      end
    end
  end
end
