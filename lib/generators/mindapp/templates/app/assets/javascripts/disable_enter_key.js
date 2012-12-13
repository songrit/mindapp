$(function() {
  $("input").keypress(function (evt) {
    //Deterime where our character code is coming from within the event
    var charCode = evt.charCode || evt.keyCode;
    if (charCode  == 13) { //Enter key's keycode
      alert("กรุณาใช้เม้าส์คลิ้กที่ปุ่มเพื่อดำเนินการต่อ");
      return false;
    }
  });
})
