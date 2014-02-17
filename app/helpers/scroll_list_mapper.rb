module ActionDispatch
  module Routing
    class Mapper
      module Resources
        def scroll_resources(resource, options = {}, &block)
          resources resource do
            get 'page/:page', action: :page, on: :collection
            get 'item/new', action: :new_item, on: :collection
            get 'item/:id', action: :item, on: :collection

            resource_class = resource.to_s.classify.constantize
            resource_class.reflect_on_all_associations(:has_many).each do |has_many|
              resources has_many.class_name.constantize.name.tableize.to_sym,
                        path: has_many.plural_name.to_sym,
                        as: has_many.plural_name.to_sym do
                get 'page/:page', action: :page, on: :collection
                get 'item/new', action: :new_item, on: :collection
                get 'item/:id', action: :item, on: :collection
              end
            end

            block && block.yield
          end
        end
      end
    end
  end
end