$(function() {
  
  // Tab
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

  // Locale
  $('#locale').click(function(e) {
    e.preventDefault();

    if ($('#nav a[href="#doc"]').length) {
      $('#nav a[href="#doc"]').attr('href', '#doc-cn').click();
    } else {
      $('#nav a[href="#doc-cn"]').attr('href', '#doc').click();
    }

    var item = $(this);
    item.addClass('flip');
    setTimeout(function() {
      item.removeClass('flip');
    }, 500);

  });
});

