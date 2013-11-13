require "scrolling_list_helper"

module ActionView
  module Helpers
    class FormBuilder
      # scroll_picker puts a picker on the screen for the user to pick an item from a scrolling list class.
      # The picker consists of a link to the related object with its scroll_list_name and a button to open
      # a picker dialog allowing the user to pick a new related item.  Finally, the picker will output a
      # picker dialog onto the form for the related table if another scroll_picker hasn't already output
      # a picker for the related table.
      #
      # From a form builder object, you call it like:
      #   form_builder.scroll_picker(<name of the table we are picking from>, <field that links to the related table>)
      #
      # Parameters:
      #   related_object_class_name
      #     The name of the class that we are picking an item from
      #   method
      #     The field we are reading/writing into. (This needs to be the foreign ID to the record in
      #       related_object_class_name)
      #   options
      #     relationship_method
      #       The method to use to access the related object
      #     All other options are passed on to the form builder.

      def scroll_picker(related_object_class_name, method, options = {})
        @scroll_list_hash  ||= Hash.new()

        # We should not assume that the method is <object function name>_id and guess the object from that.
        # We should assume that if there isn't an option with the object name or the object that it is that way.
        # However, adding the code for the options is more than I want to do right now, or what I need to do.
        # Maybe later.
        method_object_name = options.delete(:relationship_method).to_s
        if (method_object_name.empty?)
          # guess the name from the method by removing _id from the method.
          method_object_name = method.to_s();
          if (method_object_name.length > 3)
            method_object_name = method_object_name[0..method_object_name.length - 4]
          end
        end
        related_object = @object.send(method_object_name) unless method_object_name.blank?

        # output the link and the button as a single "control"
        full_output = InstanceTag.new(@object_name, method, self,
                                      options.delete(:object) || {}).to_scroll_picker(related_object,
                                                                                 related_object_class_name, options)

        # if the dialog doesn't already exist on the form, output it.
        unless @scroll_list_hash[related_object_class_name]
          @scroll_list_hash[related_object_class_name] = scroll_list_dialog(related_object_class_name, related_object)
          full_output                                  += @scroll_list_hash[related_object_class_name]
        end

        full_output
      end

      # A helper function used to output the picker dialog.
      # Because the picker dialog is complicated, it is implemented as a form, so we just output it
      # and pass in parameters to drive how it works.
      def scroll_list_dialog(related_object_class_name, related_object)
        @template.render(partial: "scrollable_list/scroll_pick_list", layout: false,
                         locals:  { related_object: related_object, related_object_class_name: related_object_class_name })
      end
    end

    class InstanceTag < ActionView::Helpers::Tags::Base
      # This is a helper to output the link and selector button for scrollable list item pickers.
      #
      # Parameters:
      #   related_object
      #     The related object.  This is used to get the text for the link and the link URL.
      #     If this is nil, then a "new" link will be output.
      #   related_object_class_name
      #     The class name of the related object.  It is part of the URL path.
      def to_scroll_picker(related_object, related_object_class_name, options = {})
        full_output = @template_object.hidden_field(@method_name, options)

        # Path helpers aren't available here, so we build it manually ourselves, but this is a simple path, so we'll just build it ourselves.
        #full_output += link_to(ScrollingListHelper.scroll_list_name(related_object), eval("#{related_object_class_name}_path related_object"), target: "_blank")

        output_link = "/#{related_object_class_name.to_s.pluralize}"
        if (related_object)
          output_link         += "/#{related_object.id}"
          output_display_name = ScrollingListHelper.scroll_list_name(related_object)
        else
          output_link         += "/new"
          output_display_name = ""
        end
        full_output += link_to(output_display_name,
                               output_link,
                               target: "_blank",
                               id:     "link_#{sanitized_object_name}_#{sanitized_method_name}")
        full_output += " "
        full_output += link_to(I18n.t("scrolling_list.picker.change_button"), "#",
                               class:            "btn scroll_picker_change_btn",
                               id:               "pick_#{sanitized_object_name}_#{sanitized_method_name}",
                               "data-class-name" => "#{related_object_class_name}")
      end
    end
  end
end