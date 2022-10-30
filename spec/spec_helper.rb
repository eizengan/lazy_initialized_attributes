require "lazy_initialized_attributes"

RSpec.configure do |config|
  # Show detailed output when only one file is run
  config.default_formatter = :documentation if config.files_to_run.one?

  # Disable RSpec exposing methods globally on `Module` and `main`
  # https://relishapp.com/rspec/rspec-core/docs/configuration/zero-monkey-patching-mode
  config.disable_monkey_patching!

  # Failure tracking file for the `--only-failures` and `--next-failure` CLI options
  config.example_status_persistence_file_path = ".rspec_status"

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect

    # Show all expectation messages when they are chained together
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Expecting/allowing method calls on nil is an error
    mocks.allow_message_expectations_on_nil = false

    # Disallow expecting/allowing unknown method calls
    mocks.verify_partial_doubles = true
  end

  # Run specs in random order
  config.order = :random

  # Profile the 5 slowest examples
  config.profile_examples = 5

  # Metadata on shared contexts is added to contexts where it is included instead of triggering inclusion
  config.shared_context_metadata_behavior = :apply_to_host_groups

  # Show warnings
  config.warnings = true

  # Allows use of `--seed` to deterministically reproduce test failures related to randomization
  Kernel.srand config.seed

  # # NOTE: class instance variables persist between tests and should be cleared to avoid cross-test pollution,
  # # particularly in cases when they have been stubbed. We remove the ones present in the following array before
  # # every test just to be safe
  # class_instance_variables = []
  # config.prepend_before do
  #   class_instance_variables.each do |klass, instance_variable|
  #     klass.remove_instance_variable(instance_variable) if klass.instance_variable_defined?(instance_variable)
  #   end
  # end
end
