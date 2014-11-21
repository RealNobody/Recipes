class FactoryHelper
  def self.create_aliased_field(aliased_class, &block)
    aliased_value = nil

    (0..200).each do
      aliased_value = block.yield
      break if (aliased_value &&
          !aliased_class.find_by_alias(aliased_value) &&
              !aliased_class.find_by_alias(aliased_value.pluralize) &&
                  !aliased_class.find_by_alias(aliased_value.singularize)
      )
    end

    aliased_value
  end
end