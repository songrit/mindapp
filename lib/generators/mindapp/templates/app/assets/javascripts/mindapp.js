$(function() {
  $('body').show();
  $.extend(  $.mobile , {
    loadingMessage: 'please wait',
    pageLoadErrorMessage: "Error"
  });

  // TODO loop all $('.ui-header .ui-btn-text')
  if ($('.ui-header .ui-btn-text').first().text()=="") {
    $('.ui-crumbs').hide();
  };
});

function validate() { return true; }
