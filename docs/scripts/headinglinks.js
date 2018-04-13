// This script inserts a link next to each h2 and h3 with the anchor
document.querySelectorAll('.content h2[id], .content h3[id]').forEach(function(heading) {
    var link = document.createElement('a');
    link.classList.add('heading-link');
    link.innerHTML = '&para;';
    link.href = '#' + heading.id;
    heading.appendChild(link);
});
