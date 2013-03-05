require "scrolling_list_helper"

module ActionView
  module Helpers
    class FormBuilder
      def scroll_picker(form_object, related_object_class_name, method, options = { })
        @scroll_list_hash ||= Hash.new()

        # we should not assume that the method is <object function name>_id and guess the object from that
        # which we should assume that if there isn't an option with the object name or the object that it is that
        # but adding the code for the options is more than I want to do right now, or what I need to do.
        # Maybe later.
        method_object_name = method.to_s();
        if (method_object_name.length > 3)
          method_object_name = method_object_name[0..method_object_name.length - 4]
        end
        related_object = @object.send(method_object_name) unless method_object_name.blank?

        full_output = InstanceTag.new(@object_name, method, self,
                                      options.delete(:object)).to_scroll_picker(related_object, related_object_class_name, options)

        unless @scroll_list_hash[related_object_class_name]
          @scroll_list_hash[related_object_class_name] = scroll_list_dialog(form_object, related_object_class_name, related_object)
          full_output                                  += @scroll_list_hash[related_object_class_name]
        end

        full_output
      end

      def scroll_list_dialog(form_object, related_object_class_name, related_object)
        form_object.render(partial: "scrollable_list/scroll_pick_list", layout: false,
                           locals:  { related_object: related_object, related_object_class_name: related_object_class_name })
      end
    end

    class InstanceTag
      def to_scroll_picker(related_object, related_object_class_name, options = { })
        full_output = @template_object.hidden_field(@method_name, options)

        # Path helpers aren't available here, so we build it manually ourselves, but this is a simple path, so we'll just build it ourselves.
        #full_output += link_to(ScrollingListHelper.scroll_list_name(related_object), eval("#{related_object_class_name}_path related_object"), target: "_blank")

        output_link = "/#{related_object_class_name.to_s.pluralize}"
        if (related_object)
          output_link += "/#{related_object.id}"
          output_display_name = ScrollingListHelper.scroll_list_name(related_object)
        else
          output_link += "/new"
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