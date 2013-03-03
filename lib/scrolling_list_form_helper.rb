require "scrolling_list_helper"

module ActionView
  module Helpers
    class FormBuilder
      def scroll_picker(form_object, related_object_name, method, options = {})
        @scroll_list_hash ||= Hash.new()

        related_object = @object.send(related_object_name)
        full_output    = InstanceTag.new(@object_name, method, self,
                                         options.delete(:object)).to_scroll_picker(related_object, options)

        unless @scroll_list_hash[related_object.class.name.pluralize.underscore.to_sym]
          @scroll_list_hash[related_object.class.name.pluralize.underscore.to_sym] = scroll_list_dialog(form_object, related_object)
          full_output                                                              += @scroll_list_hash[related_object.class.name.pluralize.underscore.to_sym]
        end

        full_output
      end

      def scroll_list_dialog(form_object, related_object)
        form_object.render(partial: "scrollable_list/scroll_pick_list", layout: false,
                           locals:  { related_object: related_object })
      end
    end

    class InstanceTag
      def to_scroll_picker(related_object, options = {})
        full_output = @template_object.hidden_field(@method_name, options)

        # Path helpers aren't available here, so we build it manually ourselves, but this is a simple path, so we'll just build it ourselves.
        #full_output += link_to(ScrollingListHelper.scroll_list_name(related_object), eval("#{related_object.class.name.pluralize.underscore}_path related_object"), target: "_blank")

        full_output = "/#{related_object.class.name.pluralize.underscore}"
        full_output += "/#{related_object.id}" if (related_object)
        full_output = link_to(ScrollingListHelper.scroll_list_name(related_object),
                               full_output,
                               target: "_blank")
        full_output += " "
        full_output += link_to(I18n.t("scrolling_list.picker.change_button"), "#",
                               class: "btn scroll_picker_change_btn",
                               id:    "pick_#{sanitized_object_name}_#{sanitized_method_name}")
      end
    end
  end
end