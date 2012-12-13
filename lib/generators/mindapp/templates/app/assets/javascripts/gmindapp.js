$(function() {
  $('body').show();
  $.extend(  $.mobile , {
    loadingMessage: 'กรุณารอสักครู่',
    pageLoadErrorMessage: "ขออภัย ไม่สามารถดำเนินการได้"
  });

  // TODO loop all $('.ui-header .ui-btn-text')
  if ($('.ui-header .ui-btn-text').first().text()=="") {
    $('.ui-crumbs').hide();
  };
});

function validate() { return true; }
