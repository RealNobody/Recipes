Dir[File.absolute_path(File.join(File.dirname(__FILE__), "**/*.rb"))].each do |f|
  unless File.basename(f) == File.basename(__FILE__)
    require(File.join(File.dirname(f), File.basename(f, ".rb")))
  end
end

# require "pages/recipe_app_page"
# require "pages/container_section"
# require "pages/ingredient_category_section"
# require "pages/ingredient_section"
# require "pages/keyword_section"
# require "pages/measurement_conversion_section"
# require "pages/measuring_unit_section"
# require "pages/prep_order_section"
# require "pages/recipe_section"
# require "pages/recipe_type_section"
# require "pages/search_alias_section"

class RecipeRspecApp < PageApplication
  # @@current_app = nil
  #
  # class << self
  #   def current_instance
  #     @@current_app ||= RecipeRspecApp.new
  #   end
  #
  #   def method_missing(method_sym, *arguments, &block)
  #     if RecipeRspecApp.current_instance.respond_to?(method_sym, true)
  #       RecipeRspecApp.current_instance.send(method_sym, *arguments)
  #     else
  #       super
  #     end
  #   end
  #
  #   def respond_to?(method_sym, include_private = false)
  #     if RecipeRspecApp.current_instance.respond_to?(method_sym, include_private)
  #       true
  #     else
  #       super
  #     end
  #   end
  # end

  def pages_module
    RecipePages
  end

  def full_page(user, model_class)
    instance_var_sym = "@full_#{model_class.name.underscore}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = nil

      if RecipePages.const_defined?("#{model_class.name}FullPage", false)
        class_object = "RecipePages::#{model_class.name}FullPage".constantize
      else
        class_object = Class.new(RecipeAppPage)

        class_object.class_eval do
          set_url "/#{model_class.name.tableize}{/item_id}{/edit}{?query*}"
          set_url_matcher /\/#{model_class.name.tableize}(?:(?:\/(?:\d+|new))(?:\/edit)?)?(?:\?.*)?/

          element :page_name, "h1.page_title"
          section :index_list,
                  ScrollingListSection,
                  ".scrolling-list-primary .scrolling-list-content"
          section model_class.name.tableize.to_sym,
                  "#{model_class.name}Section".constantize,
                  "\##{model_class.name.underscore}"
        end
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end

  def item_page(user, model_class)
    instance_var_sym = "@item_#{model_class.name.underscore}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = nil

      if RecipePages.const_defined?("#{model_class.name}ItemPage", false)
        class_object = "RecipePages::#{model_class.name}ItemPage".constantize
      else
        class_object = Class.new(RecipeAppPage)

        class_object.class_eval do
          set_url "/#{model_class.name.tableize}/item{/item_id}{/edit}{?query*}"
          set_url_matcher /\/#{model_class.name.tableize}\/item(?:(?:\/(?:\d+|new))(?:\/edit)?)?(?:\?.*)?/

          section model_class.name.tableize.to_sym,
                  "#{model_class.name}Section".constantize,
                  "\##{model_class.name.underscore}"
        end
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end

  def child_item_page(user, parent_model_class, model_class, relationship)
    instance_var_sym = "@child_item_#{parent_model_class.name.underscore}_#{model_class.name.underscore}_#{relationship}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = nil

      if RecipePages.const_defined?("#{parent_model_class.name}#{relationship.to_s.classify}ChildItemPage", false)
        class_object = "RecipePages::#{parent_model_class.name}#{relationship.to_s.classify}ChildItemPage".constantize
      else
        class_object = Class.new(RecipeAppPage)

        class_object.class_eval do
          set_url "/#{parent_model_class.name.tableize}/{parent_id}/#{relationship}/item{/item_id}{?query*}"
          set_url_matcher /\/#{parent_model_class.name.tableize}\/(?:new|\d*)\/#{relationship}\/item\/(?:new|\d*)(?:\/\d+)?/

          section model_class.name.tableize.to_sym,
                  "#{model_class.name}ShowSection".constantize,
                  "html"
        end
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end

  def scrolling_list_page(user, model_class)
    instance_var_sym = "@scrolling_list_#{model_class.name.underscore}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = nil

      if RecipePages.const_defined?("#{model_class.name}ScrollingListPage", false)
        class_object = "RecipePages::#{model_class.name}ScrollingListPage".constantize
      else
        class_object = Class.new(RecipeAppPage)

        class_object.class_eval do
          set_url "/#{model_class.name.tableize}/page/{page_number}{?query*}"
          set_url_matcher /\/#{model_class.name.tableize}\/page(?:\/\d+)?/

          element :selected_item, ".active a"
          element :wait_next, ".scrolling-next a"
          element :wait_previous, ".scrolling-previous a"
          elements :items, "li a"
        end
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end

  def child_scrolling_list_page(user, parent_model_class, model_class, relationship)
    instance_var_sym = "@child_scrolling_list_#{parent_model_class.name.underscore}_#{model_class.name.underscore}_#{relationship}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = nil

      if RecipePages.const_defined?("#{parent_model_class.name}#{relationship.to_s.classify}ChildScrollingListPage", false)
        class_object = "RecipePages::#{parent_model_class.name}#{relationship.to_s.classify}ChildScrollingListPage".constantize
      else
        class_object = Class.new(RecipeAppPage)

        class_object.class_eval do
          set_url "/#{parent_model_class.name.tableize}/{parent_id}/#{relationship}/page/{page_number}{?query*}"
          set_url_matcher /\/#{parent_model_class.name.tableize}\/(?:new|\d*)\/#{relationship}\/page(?:\/\d+)?/

          element :selected_item, ".active a"
          element :wait_next, ".scrolling-next a"
          element :wait_previous, ".scrolling-previous a"
          elements :items, "li a"
        end
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end
end