# frozen_string_literal: true

require "set"
require_relative "lazy_initialized_attributes/version"

module LazyInitializedAttributes
  def self.extended(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module ClassMethods
    def lazy_initialized_attributes
      @lazy_initialized_attributes ||= Set.new
    end

    def all_lazy_initialized_attributes
      ancestors.select { |ancestor| ancestor.respond_to?(:lazy_initialized_attributes) }
               .map(&:lazy_initialized_attributes)
               .reduce(&:|)
    end

    def lazy_initialize_attribute(attribute, &initializer)
      lazy_initialized_attributes.add(attribute)

      define_method(attribute) do
        instance_variable = :"@#{attribute}"
        if instance_variable_defined?(instance_variable)
          instance_variable_get(instance_variable)
        else
          instance_variable_set(instance_variable, instance_eval(&initializer))
        end
      end
    end
  end

  module InstanceMethods
    def eager_initialize!
      self.class.all_lazy_initialized_attributes.each { |attribute| send(attribute) }
    end
  end
end
