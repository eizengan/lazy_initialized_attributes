# frozen_string_literal: true

RSpec.describe LazyLoadAttributes do
  let(:test_superclass) do
    Class.new do
      extend LazyLoadAttributes
    end
  end

  let(:test_class) do
    Class.new(test_superclass)
  end

  describe ".lazy_attributes" do
    subject(:lazy_attributes) { test_class.lazy_attributes }

    before do
      test_superclass.lazy_attr_reader(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_attr_reader(:class_attribute) { "class attribute" }
    end

    it "returns self-defined lazy-loaded attributes" do
      expect(lazy_attributes).to include(:class_attribute)
    end

    it "does not return inherited lazy-loaded attributes" do
      expect(lazy_attributes).not_to include(:superclass_attribute)
    end

    context "when the class redefines an inherited lazy-loaded attribute" do
      before do
        test_class.lazy_attr_reader(:superclass_attribute) { "redefine attribute" }
      end

      it "additionally returns the redefined attribute" do
        expect(lazy_attributes).to include(:class_attribute, :superclass_attribute)
      end
    end
  end

  describe ".all_lazy_attributes" do
    subject(:all_lazy_attributes) { test_class.all_lazy_attributes }

    before do
      test_superclass.lazy_attr_reader(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_attr_reader(:class_attribute) { "class attribute" }
    end

    it "returns both inherited and self-defined lazy-loaded attributes" do
      expect(all_lazy_attributes).to include(:class_attribute, :superclass_attribute)
    end
  end

  describe ".lazy_attr_reader" do
    before do
      test_superclass.lazy_attr_reader(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_attr_reader(:class_attribute) { "class attribute" }
    end

    it "defines a method to get the attribute" do
      expect do
        test_class.lazy_attr_reader(:another_attribute) { "class attribute" }
      end.to change { test_class.new.respond_to?(:another_attribute) }.from(false).to(true)
    end

    it "enables definition on both classes and superclasses", aggregate_failures: true do
      expect(test_class.new).to respond_to(:superclass_attribute)
      expect(test_class.new).to respond_to(:class_attribute)
    end

    it "overrides existing definitions on a superclass" do
      expect do
        test_class.lazy_attr_reader(:superclass_attribute) { "redefined attribute" }
      end.to change { test_class.new.superclass_attribute }.from("superclass attribute").to("redefined attribute")
    end

    context "when defining an attribute with a nonstandard name" do
      it "raises a NameError" do
        expect { test_class.lazy_attr_reader(:"Bad-ATTR") { nil } }.to raise_error(
          NameError,
          "bad attribute name 'Bad-ATTR' (use a-z, 0-9, _)"
        )
      end
    end

    context "when defining an attribute without an initializer" do
      it "raises an ArgumentError" do
        expect { test_class.lazy_attr_reader(:no_initializer) }.to raise_error(
          ArgumentError,
          "no initializer block given in lazy-loaded attribute definition"
        )
      end
    end
  end

  describe "#<attribute>" do
    let(:instance) { test_class.new }

    before do
      test_superclass.lazy_attr_reader(:superclass_attribute) { "superclass attribute" }

      test_class.class_eval do
        lazy_attr_reader(:class_attribute) { class_method }

        def class_method
          "class attribute"
        end
      end

      allow(instance).to receive(:class_method).and_call_original
    end

    it "evaluates the initializer and returns its value" do
      expect(instance.class_attribute).to eq "class attribute"
    end

    it "evaluates the initializer from the context of the calling instance", aggregate_failures: true do
      expect(instance).not_to have_received(:class_method)
      instance.class_attribute
      expect(instance).to have_received(:class_method).once
    end

    context "when the attribute method has been called before" do
      before { instance.class_attribute }

      it "returns the cached value without calling the initializer again", aggregate_failures: true do
        expect(instance).to have_received(:class_method).once
        instance.class_attribute
        expect(instance).to have_received(:class_method).once
      end
    end
  end

  describe "#eager_load_attributes!" do
    subject(:eager_load_attributes!) { instance.eager_load_attributes! }

    let(:instance) { test_class.new }

    before do
      test_superclass.lazy_attr_reader(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_attr_reader(:class_attribute) { "class attribute" }
      allow(instance).to receive(:superclass_attribute)
      allow(instance).to receive(:class_attribute)
    end

    it "calls each attribute to load it", aggregate_failures: true do
      expect(instance).not_to have_received(:superclass_attribute)
      expect(instance).not_to have_received(:class_attribute)
      eager_load_attributes!
      expect(instance).to have_received(:superclass_attribute).once
      expect(instance).to have_received(:class_attribute).once
    end

    it "returns a symbol for each attribute loaded" do
      expect(eager_load_attributes!).to contain_exactly :superclass_attribute, :class_attribute
    end
  end
end
