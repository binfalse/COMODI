function reloadPostition ()
{
    var url = window.location.href;
    $('html, body').animate(
            {
                scrollTop: $(url.substring (url.indexOf ("#"))).offset().top
            }, 800);
}

function activateSmoothScroll ()
{
    if (!$("#objectproperties").length)
    {
        console.log ("page doesn't seem to be ready, yet. going to wait another 200ms");
        setTimeout (activateSmoothScroll, 200);
        return;
    }
    $('a[href*="#"]').click(function()
            {
                if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname)
                {
                    var target = $(this.hash);
                    target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
                    if (target.length)
                    {
                        $('html, body').animate(
                                {
                                    scrollTop: target.offset().top
                                }, 1000);
                        return false;
                    }
                }
            });
    if (window.location.href.indexOf ("#") > -1)
        $("#overview-fig").load("image/svg+xml", function()
                {
                    reloadPostition ();
                });
}


$(function() {
    activateSmoothScroll ();
});
