ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular "slice", "slices"
  inflect.singular /(.*)([Aa]lias)/, "\\1\\2"
  inflect.plural /(.*)([Aa]lias)/, "\\1\\2es"
  inflect.singular /(.*)([Aa]lias)es/, "\\1\\2"
  inflect.plural /(.*)([Aa]liases)/, "\\1\\2"
  inflect.singular "slice", "slice"
  inflect.singular "slices", "slice"
end