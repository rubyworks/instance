# This is based on a few things from
# http://reference.jumpingmonkey.org/programming_languages/ruby/ruby-metaprogramming.html
#
# allows the adding of methods to instances,
# but not the entire set of instances for a
# particular class
module MetaInstance::InstanceMethodDefine
  extend ActiveSupport::Concern

  # when a method is stubbed with snapshot data, we stare the
  # original method prixefixed with this:
  METHOD_BACKUP_KEY = "_mata_instance_backup_current_"

  # backs up and overrides a method.
  # but don't override if we already have overridden this method
  def instance_override(name, &block)
    unless respond_to?("#{METHOD_BACKUP_KEY}#{name}")
      backup_method(name)
    end
    define_method(name, &block)
  end

  # Adds methods to a singletonclass
  # define_singleton_method(name, &block) is the same as doing
  #
  # meta_eval {
  #   define_method(name, &block)
  # }
  def define_method(name, &block)
    define_singleton_method(name, &block)
  end

  # backs up a method in case we want to restore it later
  def backup_method(name)
    meta_eval {
      alias_method "#{METHOD_BACKUP_KEY}#{name}", name
    }
  end

  # the original method becomes reaccessible
  def restore_method(name)
    if respond_to?("#{METHOD_BACKUP_KEY}#{name}")
      meta_eval {
        alias_method name, "#{METHOD_BACKUP_KEY}#{name}"
        remove_method "#{METHOD_BACKUP_KEY}#{name}"
      }
    end
  end

  private

  # evals a block inside of a singleton class, aka
  #
  # class << self
  #   self
  # end
  def meta_eval(&block)
    singleton_class.instance_eval(&block)
  end

end
