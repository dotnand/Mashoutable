//= require jquery-1.6.1.min
//= require jquery.tweet
//= require global
//= require_self

$(function() {
  $(document).ajaxSend(function(e, xhr, options) {
      var token = $("meta[name='csrf-token']").attr('content');
      xhr.setRequestHeader('X-CSRF-Token', token);
  });
});
