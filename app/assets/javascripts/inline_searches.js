$(function () {
    $("#users th a, #users .pagination a").on("click", function () {
        $.getScript(this.href);
        return false;
    });
    $("#users_search input").keyup(function () {
        $.get($("#users_search").attr("action"), $("#users_search").serialize(), null, "script");
        return false;
    });

    $("#inline_search input").keyup(function () {
        if ($('#search_results').length > 0) {
            $('#search_results').addClass('hidden');
            $('#search_loading').removeClass('hidden');
            $('#search_loading').find('.loading').removeClass('hidden');
        }
        $.get($("#inline_search").attr("action"), $("#inline_search").serialize(), null, "script");
        return false;
    });

    $("#clients th a, #clients .pagination a").on("click", function () {
        $.getScript(this.href);
        return false;
    });
    $("#clients_search input").keyup(function () {
        $.get($("#clients_search").attr("action"), $("#clients_search").serialize(), null, "script");
        return false;
    });

    $("#districts th a, #districts .pagination a").on("click", function () {
        $.getScript(this.href);
        return false;
    });
    $("#districts_search input").keyup(function () {
        $.get($("#districts_search").attr("action"), $("#districts_search").serialize(), null, "script");
        return false;
    });

    var timer;

    function search() {
        $.get($("#jobs_search").attr("action"), $("#jobs_search").serialize(), null, "script");
    }

    $("#jobs_search input").keyup(function () {
        $(this).addClass("ajax-loading");
        clearTimeout(timer);
        timer = setTimeout(search, 500);
        if ($(this).val().length > 0) {
            $('#clear_job_search').removeClass('hidden');
            $(this).css('font-family', 'orgonboldregular ');
        }
        else {
            $('#clear_job_search').addClass('hidden');
            $(this).css('font-family', 'gothamlightregular');
        }

        return false;
    });

    $('#clear_job_search').on("click", function() {
        $("#jobs_search input").val('');
        $("#jobs_search input").trigger('keyup');
        return false;
    });
});