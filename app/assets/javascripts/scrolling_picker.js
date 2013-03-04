//= require recipes
//= history
//= scrolling_list

var scrollingPickList;

Recipes.ScrollingList.PickList = function ()
{
};

Recipes.ScrollingList.PickList.prototype =
{
  click_change: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;
    var clicked_item = $ (eventData.currentTarget);
    var id_value = clicked_item.attr ("id");
    var linked_item = $ ("#" + id_value.substring (5));
    var selected_id = linked_item.attr ("value");
    var class_name = clicked_item.attr ("data-class-name");
    var dialog_item = $ ("#pick-" + class_name + "-dialog");
    var scroll_div = dialog_item.find (".scrolling-list-picker");
    var href_item = $ ("#link_" + id_value.substring (5));

    // switch the active item in the list.
    scroll_div.find (".active").removeClass ("active");

    var search_url = scrollingList.build_find_link (href_item.attr ("href"));
    var new_active_item = scroll_div.find ("a[href=\"" + search_url + "\"]");
    if (! new_active_item || new_active_item.length <= 0)
      new_active_item = scroll_div.find ("a[href^=\"" + search_url + "?\"]");
    if (new_active_item && new_active_item.length > 0)
      new_active_item.closest ("li").addClass ("active");

    // If there is a "next" link in the scrolling list, update it
    // to set the value of the selected item, so if we refresh the page,
    // or if we scroll and the item isn't currently visible, it will be
    // selected appropriately.
    next_link = scroll_div.find (".scrolling-next a");
    if (next_link && next_link.length > 0)
    {
      next_link_url = next_link.attr ("href");
      next_link_url = next_link_url.replace (/([\?&])id=\d+/, "$1id=" + selected_id);
      next_link.attr ("href", next_link_url);
    }

    next_link = scroll_div.find (".scrolling-previous a");
    if (next_link && next_link.length > 0)
    {
      next_link_url = next_link.attr ("href");
      next_link_url = next_link_url.replace (/([\?&])id=\d+/, "$1id=" + selected_id);
      next_link.attr ("href", next_link_url);
    }

    dialog_item.modal ();
  },

  pick_dialog_hidden: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;
  },

  pick_dialog_shown: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;
    var clicked_item = $ (eventData.currentTarget);

    scrollingList.fire_scroll ($ ("#" + clicked_item.attr ("id") + " .scrolling-list-picker"));
  },

  pick_dialog_scroll: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;
    var clicked_item = $ (eventData.currentTarget);
    var max_height = clicked_item.closest (".modal-body").height () - 3 * 20;

    if (clicked_item.height () > max_height)
    {
      clicked_item.css ("max-height", max_height);
    }
  },

  pick_click_item: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;
    var clicked_item = $ (eventData.currentTarget);

    eventData.preventDefault ();

    clicked_item.closest (".modal").modal ("hide");
  },

  scroll_items_added: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;

    pick_scroll_class.bind_scroll_links ();
  },

  re_bind_elements: function (eventData)
  {
    var pick_scroll_class = eventData.data.pick_scroll_class;

    pick_scroll_class.bind_elements();
    scrollingList.bind_elements ();
  },

  bind_elements: function ()
  {
    $ (".scroll_picker_change_btn").unbind ("click", this.click_change);
    $ (".scroll_picker_change_btn").click ({ pick_scroll_class: this }, this.click_change);

    $ (".scrolling-picker-dialog").unbind ("hidden", this.pick_dialog_hidden);
    $ (".scrolling-picker-dialog").bind ("hidden", {pick_scroll_class: this}, this.pick_dialog_hidden);
    $ (".scrolling-picker-dialog").unbind ("shown", this.pick_dialog_shown);
    $ (".scrolling-picker-dialog").bind ("shown", {pick_scroll_class: this}, this.pick_dialog_shown);

    $ (".scrolling-list-picker").unbind ("scroll", this.pick_dialog_scroll);
    $ (".scrolling-list-picker").bind ("scroll", {pick_scroll_class: this}, this.pick_dialog_scroll);

    $ (".scrolling-list-picker").unbind ("scroll_items_changed", this.scroll_items_added);
    $ (".scrolling-list-picker").bind ("scroll_items_changed", { pick_scroll_class: this }, this.scroll_items_added)

    this.bind_scroll_links ();
  },

  bind_scroll_links: function ()
  {
    $ (".scrolling-list-picker .scroll-item-link").unbind ("click", this.pick_click_item);
    $ (".scrolling-list-picker .scroll-item-link").bind ("click", {pick_scroll_class: this}, this.pick_click_item);
  },

  document_ready: function ()
  {
    this.bind_elements ();

    $ ("*").bind ("scroll_content_loaded", { pick_scroll_class: this }, this.re_bind_elements);
  }
}

$ (document).ready (
    function ()
    {
      if (! scrollingPickList)
        scrollingPickList = new Recipes.ScrollingList.PickList ();

      scrollingPickList.document_ready ();
    }
);