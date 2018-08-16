var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;

function linkMaps() {
  if(!iOS) { return }
  var maps = document.querySelectorAll('a.adr')
  Array.prototype.forEach.call(maps, function(link) {
    link.href = "http://maps.apple.com/?q=" + link.href.split('=')[2]
  })
}

function unorphanize() {
  var textElements = document.querySelectorAll( 'h1,h2,h3,h4,h5,h6,p:not(.excluded)' );

  for ( var i = 0; i < textElements.length; i++ ) {
    var textElement = textElements[ i ];
    
    textElement.innerHTML = textElement.innerHTML.replace(/\s([^\s<]+)\s*$/,'&nbsp;$1');
  }
}

document.addEventListener("DOMContentLoaded", function(event) { 
  linkMaps()
  unorphanize()
})
