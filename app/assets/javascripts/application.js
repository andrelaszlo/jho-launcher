// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// the compiled file.
//
// WARNING: THE FIRST BLANK LINE MARKS THE END OF WHAT'S TO BE PROCESSED, ANY BLANK LINE SHOULD
// GO AFTER THE REQUIRES BELOW.
//
//= require_tree .

$(function() {
  var msgs = ["Oui, je m’inscris", "Mais grave !", "Oh oui !", "Carrément !"];
  var btn = document.querySelector("input[type='submit']");

  function updateMsg() {
    let msg = msgs.shift();
    msgs.push(msg);
    btn.value = msg;
  }

  setInterval(updateMsg, 500);

  $("#modal-iframe").iziModal({
    iframe: true,
    iframeHeight: 338,
    openFullscreen: true,
    transitionIn: 'fadeInDown',
    iframeURL: "https://player.vimeo.com/video/245712135?title=0&byline=0&portrait=0&autoplay=1",
    background: 'black',
    headerColor: 'black',
    title: 'jho.fr',
    closeOnEscape: true,
    closeButton: true,
    
  });

  $(document).on('click', '.trigger', function (event) {
    event.preventDefault();
    $('#modal-iframe').iziModal('open')
  });
});



