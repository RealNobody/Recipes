require "pages/layout_section"
require "pages/scrolling_list_section"

class RecipeAppPage < SitePrism::Page
  section :layout, LayoutSection, "body"

  def user=(user)
    @user = user
  end

  def load(*args)
    super(*args)

    validate_page @user
  end

  #def populate_values(values)
  #  unless values.is_a?(Hash)
  #    if values.respond_to?(:attributes)
  #      values = values.attributes
  #    else
  #      raise Exception.new("Cannot convert population values to a hash.")
  #    end
  #  end
  #
  #  populate_hash_values(values)
  #end

  class << self
    def full_page_for(model_class)
      class_eval do
        set_url "/#{model_class.name.tableize}{/item_id}{/edit}{?query*}"
        set_url_matcher /\/#{model_class.name.tableize}(?:(?:\/(?:\d+|new))(?:\/edit)?)?(?:\?.*)?/

        element :page_name, "h1.page_title"
        element "#{model_class.name.tableize}_tab".to_sym,
                "a[href=\"\##{model_class.name.underscore}\"]"
        section :index_list,
                ScrollingListSection,
                ".scrolling-list-primary .scrolling-list-content"
        section model_class.name.tableize.to_sym,
                "RecipePages::#{model_class.name}Section".constantize,
                "\##{model_class.name.underscore}"
      end
    end

    def item_page_for(model_class)
      class_eval do
        set_url "/#{model_class.name.tableize}/item{/item_id}{/edit}{?query*}"
        set_url_matcher /\/#{model_class.name.tableize}\/item(?:(?:\/(?:\d+|new))(?:\/edit)?)?(?:\?.*)?/

        section model_class.name.tableize.to_sym,
                "RecipePages::#{model_class.name}Section".constantize,
                "\##{model_class.name.underscore}"
      end
    end

    def child_item_page_for(parent_model_class, model_class, relationship)
      class_eval do
        set_url "/#{parent_model_class.name.tableize}/{parent_id}/#{relationship}/item{/item_id}{?query*}"
        set_url_matcher /\/#{parent_model_class.name.tableize}\/(?:new|\d*)\/#{relationship}\/item\/(?:new|\d*)(?:\/\d+)?/

        section model_class.name.tableize.to_sym,
                "RecipePages::#{model_class.name}ShowSection".constantize,
                "form"
      end
    end

    def scrolling_list_page_for(model_class)
      class_eval do
        set_url "/#{model_class.name.tableize}/page/{page_number}{?query*}"
        set_url_matcher /\/#{model_class.name.tableize}\/page(?:\/\d+)?/

        element :selected_item, ".active a"
        element :wait_next, ".scrolling-next a"
        element :wait_previous, ".scrolling-previous a"
        elements :items, "li a"
      end
    end

    def child_scrolling_list_page_for(parent_model_class, model_class, relationship)
      class_eval do
        set_url "/#{parent_model_class.name.tableize}/{parent_id}/#{relationship}/page/{page_number}{?query*}"
        set_url_matcher /\/#{parent_model_class.name.tableize}\/(?:new|\d*)\/#{relationship}\/page(?:\/\d+)?/

        element :selected_item, ".active a"
        element :wait_next, ".scrolling-next a"
        element :wait_previous, ".scrolling-previous a"
        elements :items, "li a"
      end
    end
  end
end