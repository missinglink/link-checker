socket = io.connect 'http://localhost', port: 3000

for link, i in document.querySelectorAll 'a[href]'
  if link.toString().substring(0, 'javascript:'.length-1) isnt 'javascript:'
    link.setAttribute 'data-role', "lc-#{i}"
    socket.emit 'url.add', {href: link.toString(), n: i}

socket.on 'url.status', (data) ->
  if data? and data.status? and data.n?
    span = document.createElement 'span'
    span.className = "status HTTP#{data.status}"
    span.appendChild document.createTextNode data.status
    link = document.querySelector("[data-role=lc-#{data.n}]")
    link.parentNode.insertBefore span, link
