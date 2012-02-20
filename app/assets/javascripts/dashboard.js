//= require jquery-ui-1.8.16.custom.min
//= require select

$(document).ready(function () {
    // setup hidden dashboard components
    $('.pickouts').hide();
    $('.analytics').hide();
    $('.networks').hide();
    $('#dropdown-buttons h4').removeClass('active');

    $('#pickouts').click(function () {
        if ($('.pickouts').is(':hidden')) {
            $('.pickouts').slideDown('200');
        } else if ( $(this).hasClass('active') ){
            $('.pickouts').slideUp('200');
            $(this).removeClass('active');
        }

        $('#dropdown-buttons h4').removeClass('active');
        $(this).addClass('active');
    });

    $('#analytics').click(function () {
        if ($('.analytics').is(':hidden')) {
            $('.analytics').slideDown('200');
        } else if ( $(this).hasClass('active') ){
            $('.analytics').slideUp('200');
            $(this).removeClass('active');
        }

        $('#dropdown-buttons h4').removeClass('active');
        $(this).addClass('active');
    });

    $('#networks').click(function () {
        if ($('.networks').is(':hidden')) {
            $('.networks').slideDown('200');
        } else if ( $(this).hasClass('active') ){
            $('.networks').slideUp('200');
            $(this).removeClass('active');
        }

        $('#dropdown-buttons h4').removeClass('active');
        $(this).addClass('active');
    });
});

function bindUpdateBestieEditor(sourceId, editorId, value) {
    $(sourceId).click(function() {
        $(editorId).val(value); 
        return false;
    });
}

function handleDeleteBestie(editorId, path) {
    var params = {'bestie': $(editorId).val()};

    $.ajax({url: path, 
            type: 'DELETE',
            data: params, 
            success: function(data) { $("#besties").replaceWith(data); },
            async: false});
        
    return false;
}

function bindDeleteBestieButton(buttonId, editorId, path) {
    $("#delete-bestie-button").click(function() { 
        handleDeleteBestie(editorId, path);
    }); 
}
