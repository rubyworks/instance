module MetaInstance::FreezeMethod
  extend ActiveSupport::Concern

  # Store Object methods so they cannot be overriden by the delegate class.
  METHODS = {}

  module ClassMethods
    def freeze_method(name)
      METHODS[name.to_sym] = Module.instance_method(name)
    end
  end

end
