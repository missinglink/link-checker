$(function() {
  var socket;
  socket = io.connect('http://localhost', {port: 3000});
  $('body').addClass('linkchecker');
  $('a').each(function() {
    var link = $(this).attr('href');
    var javascript = 'javascript:';
    if (link.substring(0, javascript.length-1) !== javascript) {
      return socket.emit('url.add', { href: link });
    }
  });
        
  return socket.on('url.status', function(data) {
    return $('a').each(function() {
      if (data.url === $(this).attr('href')) {
        return $(this).before($('<span>').
          addClass('status').
          addClass('HTTP' + data.status).
          text(data.status).
          css('font-size', $(this).css('font-size')).
          css('line-height', $(this).css('line-height'))
        );
      }
    });
  });
});