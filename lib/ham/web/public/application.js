$(function() {
  $("[data-method=delete]").click(function(e) {
    e.preventDefault();
    var $form = $("<form>");

    $form.attr({
      'action': $(this).attr('href'),
      'method': 'post'
    });

    var $input = $("<input>");

    $input.attr({
      'type':  'hidden',
      'name':  '_method',
      'value': 'delete'
    });

    $form.append($input);
    $form.appendTo("body");
    $form.submit();
    return false;
  });
});

