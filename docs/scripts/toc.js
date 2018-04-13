// Scrolling code from StackOverflow: https://stackoverflow.com/a/26808520
window.requestAnimFrame = (function(){
    return  window.requestAnimationFrame       ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame    ||
            function( callback ){
                window.setTimeout(callback, 1000 / 60);
            };
})();
function scrollToY(to) {
    var scrollY = window.scrollY || document.documentElement.scrollTop,
        scrollTargetY = to || 0,
        currentTime = 0;
    var time = Math.max(.1, Math.min(Math.abs(scrollY - scrollTargetY) / 5000, .8));
    function tick() {
        currentTime += 1 / 60;
        var p = currentTime / time;
        var t = Math.sin(p * (Math.PI / 2));
        if (p < 1) {
            requestAnimFrame(tick);
            window.scrollTo(0, scrollY + ((scrollTargetY - scrollY) * t));
        } else {
            window.scrollTo(0, scrollTargetY);
        }
    }
    tick();
}
// Insert the button element
var backToTop = document.createElement('button');
backToTop.id = 'back-to-top';
backToTop.innerHTML = 'Back to top';
backToTop.addEventListener('click', function(e) { e.preventDefault(); scrollToY(0); return false; });
document.body.insertBefore(backToTop, document.body.firstChild);
function scrollToElement(elem) {
    var to = elem.offsetTop, parent = elem.offsetParent;
    while( parent ) {
        to += parent.offsetTop;
        parent = parent.offsetParent;
    }
    scrollToY(to);
    // Highlight the element
    elem.classList.add('highlight-in');
    // After .5s, change the class from highlight-in to highlight-out
    window.setTimeout(function() {
        elem.classList.add('highlight-out')
        elem.classList.remove('highlight-in');
        // After another 2.5s, remove highlight-out
        window.setTimeout(function() {
            elem.classList.remove('highlight-out');
        }, 2500);
    }, 500);
}
function scrollToCurrentHash() {
    var elem = document.getElementById(window.location.hash.substring(1));
    if( elem ) scrollToElement(elem);
}
// Make any link with a hash as the href use nice scrolling
document.body.addEventListener('click', function(e) {
    if( e.target && e.target.matches('a[href^="#"]') ) {
        e.preventDefault();
        history.pushState({}, '', e.target.href);
        scrollToCurrentHash();
        return false;
    }
});
scrollToCurrentHash();
