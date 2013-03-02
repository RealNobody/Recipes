module ActionDispatch
    module Routing
    class Mapper
      module Resources
        def scroll_resources(resource)
          resources resource

          resource_scope(:resources, Resource.new(resource)) do
            get 'page/:page', action: :page, on: :collection
            get 'item/new', action: :new_item, on: :collection
            get 'item/:id', action: :item, on: :collection
          end
        end
      end
    end
  end
end