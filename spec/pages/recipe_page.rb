require "pages/layout_section"

class RecipePage < SitePrism::Page
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
end