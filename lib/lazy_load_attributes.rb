# frozen_string_literal: true

require "set"
require_relative "lazy_load_attributes/version"

module LazyLoadAttributes
  ATTR_NAME_REGEX = /\A[a-z0-9_]+\z/.freeze

  def self.extended(base)
    base.extend(ClassMethods)
    base.include(InstanceMethods)
  end

  module ClassMethods
    def lazy_attributes
      @lazy_attributes ||= Set.new
    end

    def all_lazy_attributes
      ancestors.select { |ancestor| ancestor.singleton_class.include?(::LazyLoadAttributes) }
               .map(&:lazy_attributes)
               .reduce(&:|)
    end

    def lazy_attr_accessor(attribute, &initializer)
      lazy_attr_reader(attribute, &initializer)
      attr_writer attribute
    end

    def lazy_attr_reader(attribute, &initializer) # rubocop:disable Metrics/MethodLength
      raise NameError, "bad attribute name '#{attribute}' (use a-z, 0-9, _)" unless attribute.match? ATTR_NAME_REGEX
      raise ArgumentError, "no initializer block given in lazy-loaded attribute definition" if initializer.nil?

      lazy_attributes.add(attribute)

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
    def eager_load_attributes!
      self.class.all_lazy_attributes.each { |attribute| send(attribute) }
    end
  end
end
