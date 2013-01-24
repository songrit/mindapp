$(function() {
  $("input").keypress(function (evt) {
    //Deterime where our character code is coming from within the event
    var charCode = evt.charCode || evt.keyCode;
    if (charCode  == 13) { //Enter key's keycode
      alert("Please click the button");
      return false;
    }
  });
})
