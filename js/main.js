$(function() {
  
  $('#nav ul li a').click(function(e) {
    e.preventDefault();

    var $disappear = $('.view.selected');
    var $appear = $($(this).attr('href'));

    if ($disappear[0] === $appear[0]) {
      $appear.addClass('shake');
      setTimeout(function() {
        $appear.removeClass('shake');
      }, 500);
    } else {
      $('li.selected').removeClass('selected');
      $(this).parent('li').addClass('selected');

      $disappear.removeClass('selected');
      $appear.addClass('selected fadeInLeft');

      setTimeout(function() {
        $appear.removeClass('fadeInLeft');
      }, 500);
    }
  });

});



