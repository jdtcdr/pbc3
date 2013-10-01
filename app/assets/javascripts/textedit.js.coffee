initialize = ->
  $('.textedit').each (index, elem) ->
    input = $(elem)
    input.rte({
      content_css_url: "/assets/rte-light/rte.css",
      media_url: "/images/rte-light/",
      height: input.height(),
      width: input.width()
    });

$(document).ready(initialize)
$(document).on('page:load', initialize)
