class AlertsSection < SitePrism::Section
  elements :alerts, ".alert"
  elements :notices, ".alert-notice"
  elements :errors, ".alert-error"
  element :close, ".close"
end

class TopMenuSection < SitePrism::Section
  element :login_state, "#login-state"
  element :home, "#menu_home"
  element :menu_planner, "#menu_menu_planner"
  element :administration, "#menu_administration"
end

class SideMenuSection < SitePrism::Section
  element :root, "#menu_root"
  element :recipes, "#menu_recipes"
  element :measuring_units, "#menu_measuring_units"
  element :measurment_aliases, "#menu_measurement_aliases"
  element :measurement_conversions, "#menu_measurement_conversions"
  element :ingredient_categories, "#menu_ingredient_categories"
  element :ingredient_aliases, "#menu_ingredient_aliases"
  element :ingredients, "#menu_ingredients"
  element :recipe_types, "#menu_recipe_types"
  element :containers, "#menu_containers"
  element :container_aliases, "#menu_container_aliases"
  element :keywords, "#menu_keywords"
  element :keyword_aliases, "#menu_keyword_aliases"
  element :prep_orders, "#menu_prep_orders"
end

class LayoutSection < SitePrism::Section
  section :alert_box, AlertsSection, "#alerts"
  section :side_menu, SideMenuSection, "#side-menu"
  section :top_menu, TopMenuSection, "#recipe-button-menu"
end