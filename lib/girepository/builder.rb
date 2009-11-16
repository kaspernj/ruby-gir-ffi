module GIRepository
  class Builder
    def build_object namespace, classname, box
      ::Object.const_set box.to_s, boxm = Module.new
      boxm.const_set namespace.to_s, namespacem = Module.new
      namespacem.const_set classname.to_s, klass = Class.new

      gir = GIRepository::IRepository.default
      gir.require namespace, nil
      info = gir.find_by_name namespace, classname
      info.methods.each do |m|
	klass.class_eval {
	  define_method(m.name) {}
	}
      end
    end
  end
end