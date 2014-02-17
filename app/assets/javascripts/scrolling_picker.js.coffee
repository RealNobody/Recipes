root = exports ? this

# This class handles the picker logic.
#
# A picker consists of the following elements:
#   A hidden field for the currently selected item.
#     This field will have an ID of "<form_class_name>_<class_field_name>"
#     This is the selected item id which will actually set the value in the class object.
#   A link to the currently selected item.  This link will be used to show the user
#     what the selected item is.
#     The link will have an ID of "link_<form_class_name>_<class_field_name>"
#     This is a normal/un-overriden link which will open a new tab showing the selected item.
#   A link button to change or pick a new item.  This button will open a dialog which will
#     allow the user to select a different item of the right class.
#     The button will have an ID of "pick_<form_class_name>_<class_field_name>"
#     The button will have an attribute named "data-class-name".
#       This attribute is used to determine the type of objects that are to be looked
#       up when the dialog opens.  Specifically, the class name is used to build the
#       router path for the list of items to be shown in the dialog.
#     This link or button will have a class of scroll_picker_change_btn which will be used
#       to bind the button.
#   A select modal dialog.  The select modal dialog will be a "shared" dialog in that there
#     is one dialog per type of object to be selected.  This allows the first page of the list
#     to be pre-loaded, and for the items in the list to be cached if the list is re-shown.
#     The dialog will have an id of "pick-<data-class-name>-dialog"
#     The dialog will have a search box with a class of "pick-dialog-search-text".  When the
#       text in this box changes, the list is refreshed with a list of search results.
#     The dialog will have a scrolling list with a class of "scrolling-list scrolling-list-picker"
#       The scrolling-list class is to allow the list to have the basic scrolling list functionality
#       The scrolling-list-picker class is to allow this class to provide specific functionality
#       for the pick scrolling list.
#     The dialog has an attribute "data-caller-hidden-id"
#       This is the ID of the selected item that the dialog either was opened from, or that the
#       dialog has selected (when the dialog closes.)
#
# When a select button is clicked, the appropriate dialog is opened to allow the user to pick
# a new item.
#   Upon opening the dialog, the data-caller-hidden-id will be set, and the scrolling list
#   will be updated to select the current item for the clicked button.

root.PickerScrollingList = class PickerScrollingList
  constructor:        () ->
    @scrollingList = root.scrollingList
    @contentScrollingList = root.contentScrollList

  # When the user clicks a button to select a new item, this funciton
  # opens the dialog box and initializes it for the selected item.
  click_change:       (eventData) =>
    clicked_item = $(eventData.currentTarget)
    id_value = clicked_item.attr("id").substring(5)
    selected_id = $("#" + id_value).attr("value")
    dialog_item = $("#pick-" + clicked_item.attr("data-class-name") + "-dialog")
    scrolling_list = dialog_item.find(".scrolling-list-picker")
    href_item = $("#link_" + id_value)

    # switch the active item in the list.
    scrolling_list.find(".active").removeClass("active")

    search_url = @scrollingList.build_find_link(href_item.attr("href"))
    new_active_item = scrolling_list.find("a[href=\"" + search_url + "\"]")
    if (new_active_item.length <= 0)
      new_active_item = scrolling_list.find("a[href^=\"" + search_url + "?\"]")
    if (new_active_item.length <= 0)
      new_active_item = scrolling_list.find("a[href*=\"" + search_url + "?\"]")
    if (new_active_item && new_active_item.length > 0)
      new_active_item.closest("li").addClass("active")

    # If there is a "next" link in the scrolling list, update it
    # to set the value of the selected item, so if we refresh the page,
    # or if we scroll and the item isn't currently visible, it will be
    # selected appropriately.
    @contentScrollingList.set_next_link(scrolling_list, "scrolling-next", selected_id)
    @contentScrollingList.set_next_link(scrolling_list, "scrolling-previous", selected_id)

    dialog_item.attr("data-caller-hidden-id", id_value)

    dialog_item.modal()

  # When the dialog is opened, set the width of the elements to the width of the dialog.
  # I wonder if there is a better way to do this...
  pick_dialog_shown:  (eventData) =>
    clicked_item = $(eventData.currentTarget)

    @scrollingList.fire_scroll($("#" + clicked_item.attr("id") + " .scrolling-list"))

    search_area = $("#" + clicked_item.attr("id") + " .pick-dialog-search-text")
    well_area = $("#" + clicked_item.attr("id") + " .well")

    search_area.width(well_area.width() + 26)

  # when the list scrolls, set the maximum height to the height of the dialog.
  # I wonder if there is a better way to do this...
  pick_dialog_scroll: (eventData) ->
    clicked_item = $(eventData.currentTarget)
    max_height = clicked_item.closest(".modal-body").height() - 4 * 20 - clicked_item.closest(".modal-body").find(".pick-dialog-search-text").height()

    if (clicked_item.height() > max_height)
      clicked_item.css("max-height", max_height)

  # This is the function which handles the user clicking on an item in the list.
  # The item is selected, the dialog closed, and the caller is set to the
  # selected item.
  pick_click_item:    (eventData) =>
    clicked_item = $(eventData.currentTarget)
    dialog_item = clicked_item.closest(".modal")
    edit_item_id = dialog_item.attr("data-caller-hidden-id")
    edit_item = $("#" + edit_item_id)
    link_item = $("#link_" + edit_item_id)

    eventData.preventDefault()

    edit_item.attr("value", @contentScrollingList.get_item_link_id(clicked_item.attr("href")))
    link_item.attr("href", clicked_item.attr("href"))
    link_item.text(clicked_item.text())

    dialog_item.modal("hide")

  extract_id_from_element: (cur_id, scrolling_list, element_finder) ->
    unless (cur_id?)
      next_link = scrolling_list.find(element_finder)
      if (next_link.length > 0)
        cur_id = next_link.attr("href").match(/(\?|&)id=(new|\d*)/)
        if (cur_id && cur_id.length > 2)
          cur_id = cur_id[2]
        else
          cur_id = null

    cur_id

  # When the user types in a search value, update the list.
  search_change:           (eventData) =>
    dialog_box = $($(eventData.currentTarget).closest(".modal"))
    scrolling_list = dialog_box.find(".scrolling-list-picker")

    cur_id = null
    this.extract_id_from_element(cur_id, scrolling_list, ".active a")
    this.extract_id_from_element(cur_id, scrolling_list, ".scrolling-next a")
    this.extract_id_from_element(cur_id, scrolling_list, ".scrolling-previous a")
    this.extract_id_from_element(cur_id, scrolling_list, "li a")

    if (cur_id == null)
      cur_id = dialog_box.attr("data-selected-item-id")

    dialog_box.attr("data-selected-item-id", cur_id)
    @scrollingList.reset_scroll(scrolling_list,
      "/" + dialog_box.attr("data-class-name") + "/page/1?id=" + cur_id + "&search=" + eventData.currentTarget.value)

  bind_elements: ->
    $(".scrolling-list-picker").unbind("scroll", this.pick_dialog_scroll)
    $(".scrolling-list-picker").bind("scroll", { pick_scroll_class: this }, this.pick_dialog_scroll)

  document_ready: ->
    this.bind_elements()

    $(document).on("click", ".scroll_picker_change_btn", { pick_scroll_class: this }, this.click_change)

    # $(document).on("hidden", ".scrolling-picker-dialog", { pick_scroll_class: this }, this.pick_dialog_hidden)
    $(document).on("shown", ".scrolling-picker-dialog", { pick_scroll_class: this }, this.pick_dialog_shown)
    # $(document).on("scroll_items_changed", ".scrolling-list-picker", { pick_scroll_class: this }, this.scroll_items_added)

    $(document).on("input", ".pick-dialog-search-text", { pick_scroll_class: this }, this.search_change)
    $(document).on("click", ".scrolling-list-picker .scroll-item-link", { pick_scroll_class: this },
      this.pick_click_item)

    $(document).on("scroll_content_loaded", null, { pick_scroll_class: this }, (eventData) ->
      eventData.data.pick_scroll_class.bind_elements()
    )

root.pickerScrollingList = null

$(document).ready( ->
  if (!root.pickerScrollingList)
    root.pickerScrollingList = new root.PickerScrollingList()

  root.pickerScrollingList.document_ready()
)