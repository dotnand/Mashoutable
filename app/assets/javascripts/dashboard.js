//= require jquery-ui-1.8.16.custom.min
//= require select

$(document).ready(function () {
    // setup hidden dashboard components
    $('#pickouts').click(function () {
        hideDivs('pickouts');
        if ($('.pickouts').is(':hidden')) {
            $(this).parents().addClass('active');
            $('.pickouts').slideDown('200');
        } else {
            $('.pickouts').slideUp('slow');
        }
    });

    $('#analytics').click(function () {
        hideDivs('analytics');
        if ($('.analytics').is(':hidden')) {
            $(this).parents().addClass('active');
            $('.analytics').slideDown('200');
        } else {
            $('.analytics').slideUp('slow');
        }
    });

    $('#networks').click(function () {
        hideDivs('networks');
        if ($('.networks').is(':hidden')) {
            $(this).parents().addClass('active');
            $('.networks').slideDown('200');
        } else {
            $('.networks').slideUp('slow');
        }
    });

    /*Toggle network buttons*/
    $(".network-toggle input").click(function(){
        if(!$(this).hasClass('on')) {
           $(this).addClass('on');
        } else {
            $(this).removeClass('on');
        }
        return false;
    });
});

function hideDivs(className){
    if (className != 'pickouts') {
        $('.button').removeClass('active');
        $('.pickouts').slideUp('slow').hide();
    }

    if (className != 'analytics') {
        $('.button').removeClass('active');
        $('.analytics').slideUp('slow').hide();
    }

    if (className != 'networks') {
        $('.button').removeClass('active');
        $('.networks').slideUp('slow').hide();
    }
}

function bindUpdateBestieEditor(sourceId, editorId, value) {
    $(sourceId).click(function() {
        $(editorId).val(value);
        return false;
    });
}

function handleDeleteBestie(editorId, path) {
    handleBestieAction('DELETE', editorId, path);
}

function handleAddBestie(editorId, path) {
    handleBestieAction('POST', editorId, path);
}

function handleBestieAction(method, editorId, path) {
    var params = {'bestie': $(editorId).val()};

    $.ajax({url: path,
            type: method,
            data: params,
            success: function(data) { $("#besties").replaceWith(data); },
            async: false});

    return false;
}

function bindDeleteBestieButton(buttonId, editorId, path) {
    $(buttonId).click(function() {
        handleDeleteBestie(editorId, path);
    });
}

function bindAddBestieButton(buttonId, editorId, path) {
    $(buttonId).click(function() {
        handleAddBestie(editorId, path);
    });
}

function ajaxifyPagination(targetId, path) {
    $(targetId + " .pagination a").click(function() {
        var queryString = $(this).attr('href').split('?');

        $.ajax({type: "GET",
                url: path + (queryString[1] == undefined ? '' : '?' + queryString[1]),
                success: function(data) { $(targetId).replaceWith(data); }
        });

        return false;
    });
}

