require "pages/recipe_app_page"
require "pages/container_section"
require "pages/ingredient_category_section"
require "pages/ingredient_section"
require "pages/keyword_section"
require "pages/measurement_conversion_section"
require "pages/measuring_unit_section"
require "pages/prep_order_section"
require "pages/recipe_section"
require "pages/recipe_type_section"
require "pages/search_alias_section"

class RecipeRspecApp
  @@current_app = nil

  class << self
    def current_instance
      @@current_app ||= RecipeRspecApp.new
    end

    def method_missing(method_sym, *arguments, &block)
      if RecipeRspecApp.current_instance.respond_to?(method_sym, true)
        RecipeRspecApp.current_instance.send(method_sym, *arguments)
      else
        super
      end
    end

    def respond_to?(method_sym, include_private = false)
      if RecipeRspecApp.current_instance.respond_to?(method_sym, include_private)
        true
      else
        super
      end
    end
  end

  def full_page(user, model_class)
    instance_var_sym = "@full_#{model_class.name.underscore}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = Class.new(RecipeAppPage)

      class_object.class_eval do
        set_url "/#{model_class.name.underscore.pluralize}{/item_id}{/edit}{?query*}"
        set_url_matcher /\/#{model_class.name.underscore.pluralize}(:?(:?\/(:?\d+|new))(:?\/edit)?)?(:?\?.*)?/

        section :index_list,
                ScrollingListSection,
                "#scroll-#{model_class.name.underscore.pluralize} .scrolling-list-content"
        section model_class.name.underscore.pluralize.to_sym,
                "#{model_class.name}Section".constantize,
                "\##{model_class.name.underscore}"
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end

  def item_page(user, model_class)
    instance_var_sym = "@full_#{model_class.name.underscore}_page".to_sym
    instance_var     = instance_variable_get(instance_var_sym)

    unless instance_var
      class_object = Class.new(RecipeAppPage)

      class_object.class_eval do
        set_url "/#{model_class.name.underscore.pluralize}/item{/item_id}{/edit}{?query*}"
        set_url_matcher /\/#{model_class.name.underscore.pluralize}\/item(:?(:?\/(:?\d+|new))(:?\/edit)?)?(:?\?.*)?/

        section model_class.name.underscore.pluralize.to_sym,
                "#{model_class.name}Section".constantize,
                "\##{model_class.name.underscore}"
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
      class_object = Class.new(RecipeAppPage)

      class_object.class_eval do
        set_url "/#{model_class.name.underscore.pluralize}/page/{page_number}{?query*}"
        set_url_matcher /\/#{model_class.name.underscore.pluralize}\/page\/(:?\/\d+)?/

        element :selected_item, ".active"
        element :wait_next, ".scrolling-next"
        element :wait_previous, ".scrolling-previous"
        elements :items, "li a"
      end

      instance_var = class_object.new
      instance_variable_set(instance_var_sym, instance_var)
    end

    instance_var.user = user
    instance_var
  end
end