function selectText(text) {
  var range, selection;
  if (document.body.createTextRange) {
    range = document.body.createTextRange();
    range.moveToElementText(text);
    range.select();
  } else if (window.getSelection) {
    selection = window.getSelection();
    range = document.createRange();
    range.selectNodeContents(text);
    selection.removeAllRanges();
    selection.addRange(range);
  }
  if (document.execCommand) {
    try {
      document.execCommand('copy');
      $(text).popover('show');
      setTimeout(function() {
        $(text).popover('hide');
      }, 2000);
    } catch (err) {
      console.log("Unable to copy", err);
    }
  }

}
