# frozen_string_literal: true

RSpec.describe LazyInitializedAttributes do
  let(:test_superclass) do
    Class.new do
      extend LazyInitializedAttributes
    end
  end

  let(:test_class) do
    Class.new(test_superclass)
  end

  describe ".lazy_initialized_attributes" do
    subject(:lazy_initialized_attributes) { test_class.lazy_initialized_attributes }

    before do
      test_superclass.lazy_initialize_attribute(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_initialize_attribute(:class_attribute) { "class attribute" }
    end

    it "returns self-defined lazy-initialized attributes" do
      expect(lazy_initialized_attributes).to include(:class_attribute)
    end

    it "does not return inherited lazy-initialized attributes" do
      expect(lazy_initialized_attributes).not_to include(:superclass_attribute)
    end

    context "when the class overrides an inherited lazy-initialized attribute" do
      before do
        test_class.lazy_initialize_attribute(:superclass_attribute) { "override attribute" }
      end

      it "additionally returns the overridden attribute" do
        expect(lazy_initialized_attributes).to include(:class_attribute, :superclass_attribute)
      end
    end
  end

  describe ".all_lazy_initialized_attributes" do
    subject(:all_lazy_initialized_attributes) { test_class.all_lazy_initialized_attributes }

    before do
      test_superclass.lazy_initialize_attribute(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_initialize_attribute(:class_attribute) { "class attribute" }
    end

    it "returns both inherited and self-defined lazy-initialized attributes" do
      expect(all_lazy_initialized_attributes).to include(:class_attribute, :superclass_attribute)
    end
  end

  describe ".lazy_initialize_attribute" do
    before do
      test_superclass.lazy_initialize_attribute(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_initialize_attribute(:class_attribute) { "class attribute" }
    end

    it "creates a method to get the attribute" do
      expect do
        test_class.lazy_initialize_attribute(:another_attribute) { "class attribute" }
      end.to change { test_class.new.respond_to?(:another_attribute) }.from(false).to(true)
    end

    it "allows definition on classes or superclasses", aggregate_failures: true do
      expect(test_class.new).to respond_to(:superclass_attribute)
      expect(test_class.new).to respond_to(:class_attribute)
    end

    it "overrides any existing definitions on a superclass" do
      expect do
        test_class.lazy_initialize_attribute(:superclass_attribute) { "override attribute" }
      end.to change { test_class.new.superclass_attribute }.from("superclass attribute").to("override attribute")
    end
  end

  describe "#<attribute>" do
    let(:instance) { test_class.new }

    before do
      test_superclass.lazy_initialize_attribute(:superclass_attribute) { "superclass attribute" }

      test_class.class_eval do
        lazy_initialize_attribute(:class_attribute) { class_method }

        def class_method
          "class attribute"
        end
      end

      allow(instance).to receive(:class_method).and_call_original
    end

    it "returns the return value of the given block" do
      expect(instance.class_attribute).to eq "class attribute"
    end

    it "executes the given block from the context of the calling instance", aggregate_failures: true do
      expect(instance).not_to have_received(:class_method)
      instance.class_attribute
      expect(instance).to have_received(:class_method).once
    end

    context "when the attribute method has been called before" do
      before { instance.class_attribute }

      it "returns the cached value without calling the given block again", aggregate_failures: true do
        expect(instance).to have_received(:class_method).once
        instance.class_attribute
        expect(instance).to have_received(:class_method).once
      end
    end
  end

  describe "#eager_initialize!" do
    subject(:eager_initialize!) { instance.eager_initialize! }

    let(:instance) { test_class.new }

    before do
      test_superclass.lazy_initialize_attribute(:superclass_attribute) { "superclass attribute" }
      test_class.lazy_initialize_attribute(:class_attribute) { "class attribute" }
      allow(instance).to receive(:superclass_attribute)
      allow(instance).to receive(:class_attribute)
    end

    it "calls each attribute to initialize it", aggregate_failures: true do
      expect(instance).not_to have_received(:superclass_attribute)
      expect(instance).not_to have_received(:class_attribute)
      eager_initialize!
      expect(instance).to have_received(:superclass_attribute).once
      expect(instance).to have_received(:class_attribute).once
    end

    it "returns the attributes initialized" do
      expect(eager_initialize!).to contain_exactly :superclass_attribute, :class_attribute
    end
  end
end
