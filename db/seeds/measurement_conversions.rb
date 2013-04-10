# Code while debugging conversions to clear seeds in between times.

#puts("Removing default seeds")
#
#MeasurementConversion.all.each do | conversion_obj |
#  if (!conversion_obj.larger_measuring_unit.can_delete?() && !conversion_obj.smaller_measuring_unit.can_delete?())
#    conversion_obj.destroy()
#  end
#end

puts("Seed standard conversions")

from_unit = MeasuringUnit.find_or_initialize("Milliliter")
to_unit   = MeasuringUnit.find_or_initialize("Liter")
from_unit.add_conversion(to_unit, 1000)

from_unit = MeasuringUnit.find_or_initialize("Milliliter")
to_unit   = MeasuringUnit.find_or_initialize("Teaspoon")
from_unit.add_conversion(to_unit, 4.92892)

from_unit = MeasuringUnit.find_or_initialize("Teaspoon")
to_unit   = MeasuringUnit.find_or_initialize("Tablespoon")
from_unit.add_conversion(to_unit, 3)

# An approximate conversion to simplify life/conversions...
from_unit = MeasuringUnit.find_or_initialize("Teaspoon")
to_unit   = MeasuringUnit.find_or_initialize("Heaping-Teaspoon")
from_unit.add_conversion(to_unit, 1.5)

from_unit = MeasuringUnit.find_or_initialize("Tablespoon")
to_unit   = MeasuringUnit.find_or_initialize("Fluid-Ounce")
from_unit.add_conversion(to_unit, 2)

from_unit = MeasuringUnit.find_or_initialize("Tablespoon")
to_unit   = MeasuringUnit.find_or_initialize("Cup")
from_unit.add_conversion(to_unit, 16)

from_unit = MeasuringUnit.find_or_initialize("Cup")
to_unit   = MeasuringUnit.find_or_initialize("Pint")
from_unit.add_conversion(to_unit, 2)

from_unit = MeasuringUnit.find_or_initialize("Pint")
to_unit   = MeasuringUnit.find_or_initialize("Quart")
from_unit.add_conversion(to_unit, 2)

from_unit = MeasuringUnit.find_or_initialize("Quart")
to_unit   = MeasuringUnit.find_or_initialize("Gallon")
from_unit.add_conversion(to_unit, 4)

from_unit = MeasuringUnit.find_or_initialize("Gram")
to_unit   = MeasuringUnit.find_or_initialize("Kilogram")
from_unit.add_conversion(to_unit, 1000)

from_unit = MeasuringUnit.find_or_initialize("Gram")
to_unit   = MeasuringUnit.find_or_initialize("Ounce")
from_unit.add_conversion(to_unit, 28.3495)

from_unit = MeasuringUnit.find_or_initialize("Ounce")
to_unit   = MeasuringUnit.find_or_initialize("Pound")
from_unit.add_conversion(to_unit, 16)