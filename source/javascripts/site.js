if (document.readyState == 'interactive') { ready() }
else document.addEventListener( "DOMContentLoaded", ready )

var iOS = /iPad|iPhone|iPod/.test(navigator.userAgent) && !window.MSStream;
var listening = {}

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


function matches ( el, selector ) {
  return ( el.matches || el.matchesSelector || el.msMatchesSelector || el.mozMatchesSelector || el.webkitMatchesSelector || el.oMatchesSelector ).call( el, selector );
}


function listen() {
  document.querySelector( '.toggle-nav' ).addEventListener( 'click', function( event ) {
    document.querySelector('html').classList.toggle( 'show-nav' )
    event.preventDefault()
    event.stopPropagation()
  })
}

function ready() {
  linkMaps()
  unorphanize()
  listen()
}
