require "seedling"

# This module defines new cleaning algorithms for the project
# The cleaning algorithm is defined to be fast, not complete or infalible.
# This is a departure from traditional database cleaners.
# For most common tests, this system will likely work well.
#
# The following are true:
#   1)  The database is reset before any tests are run.
#       To ensure that the data is valid, the Seedlings class is used to seed the database after the reset
#       NOTE: This is done because it is possible for the rspec after calls to not be called depending
#             on the reason for the crash.  To ensure that the database is at a known state at the
#             start of the tests, a full reset and re-seed is done.
#             This is assumed to be an expensive operation, but is acceptable in general.
#   2)  Unless specified otherwise below, all tests are executed in transactions.
#   3)  All javascript (:js, js: true) tests are executed outside of transactions.
#       JavaScript tests have the following options:
#         :no_truncate  - Do not reset the database after the test.  Leave the database dirty.
#                         If used, the database will only be reset at the end of running all tests.
#         :full_reset   - At the end of the test, truncate all tables and re-seed database.
#   4)  Because we do a full reset when tests are run, we don't bother to do a full reset
#       at the end of tests.

class RspecCleaner
  @@seedlings = nil
  @@reset_seedlings = false

  def self.seedlings
    @@seedlings
  end

  def self.seedlings=(value)
    @@seedlings = value
  end

  def self.reset_seedlings
    @@reset_seedlings
  end

  def self.reset_seedlings=(value)
    @@reset_seedlings = value
  end
end

RSpec.configure do |config|
  config.before(:suite) do
    reset_database

    DatabaseCleaner.strategy = :transaction
  end

  config.before(:suite) do
    initialize_seedlings
  end

  config.after(:suite) do
    if RspecCleaner.reset_seedlings
      RspecCleaner.seedlings.suite_end
    end
  end

  config.before(:each) do |example|
    example = example.example if example.respond_to?(:example)

    if example.metadata[:js]
      unless example.metadata[:no_truncate]
        if example.metadata[:full_reset]
          DatabaseCleaner.strategy = :truncation
          DatabaseCleaner.start
        else
          DatabaseCleaner.strategy = :truncation

          example.instance_variable_set(:@test_seedlings, Seedling.test_start)
        end
      end
    else
      DatabaseCleaner.strategy = :transaction
      DatabaseCleaner.start
    end
  end

  config.after(:each) do |example|
    example = example.example if example.respond_to?(:example)

    if example.metadata[:js]
      RspecCleaner.reset_seedlings = true

      unless example.metadata[:no_truncate]
        if example.metadata[:full_reset]
          reset_database
          initialize_seedlings
        else
          example.instance_variable_get(:@test_seedlings).test_end
        end
      end
    else
      DatabaseCleaner.clean
    end
  end
end

def initialize_seedlings
  RspecCleaner.seedlings = Seedling.suite_start
  RspecCleaner.reset_seedlings = false
end

def reset_database
  DatabaseCleaner.clean_with(:truncation)

  seed_data
end

def seed_data
  Seedling.seed_all
end