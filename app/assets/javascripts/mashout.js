//= require fancybox/jquery.fancybox-1.3.4.pack

$(function() {
    $('#mashout-target-container .ui-autocomplete-input').css('width','300px');
    $('#mashout-media-container .ui-autocomplete-input').css('width','300px');
    $('#mashout-comment-container .ui-autocomplete-input').css('width','300px');

    decorateMashoutTrendAutoCompleteSelect();

    $("#mashout-chars-left").keypress(function() {
        return false;
    });

    $("#out-preview").keyup(function(){
        calculateCharsLeft();
    });

    // setup ready to mashout floating step
    if($('#sidebar').offset() != null) {
        var top = $('#sidebar #ready-to-mashout .content').offset().top - parseFloat($('#sidebar #ready-to-mashout .content').css('top').replace(/auto/, 0));

        $(window).scroll(function (event) {
            // what the y position of the scroll is
            var y = $(this).scrollTop();

            // whether that's below the form
            if (y >= top) {
                // if so, ad the fixed class
                $('#sidebar #ready-to-mashout .content').addClass('fixed');
            } else {
                // otherwise remove it
                $('#sidebar #ready-to-mashout .content').removeClass('fixed');
            }
        });
    }
});

function calculateCharsLeft() {
    $("#mashout-chars-left").text(140 - $('#out-preview').val().length);
}

function decorateMashoutTrendAutoCompleteSelect() {
  $('#mashout-trend-container .ui-autocomplete-input').css('width','300px');
  $('#mashout-location-container .ui-autocomplete-input').css('width','300px');
  $('#mashout-google-container .ui-autocomplete-input').css('width','300px');
  $('#mashout-region-container .ui-autocomplete-input').css('width','300px');
}

function bindAutoCompleteSelect(wrapperId, selectId, callback) {
    $(wrapperId).bind('autocompleteselect', function (event, ui) {
        $(selectId).val(ui.item.option.value);
        $(selectId).change();

        if(callback !== undefined) {
          callback();
        }
    });
}

function bindTrendAutoCompleteSelectAndHandle(wrapperId, selectId, path) {
    bindAutoCompleteSelect(wrapperId, selectId, function() { handleTrendAutoCompleteSelection(path); });
}

function bindTargetAutoCompleteSelectAndHandle(wrapperId, selectId, path) {
    bindAutoCompleteSelect(wrapperId, selectId, function() { handleTargetAutoCompleteSelection(path); });
}

function elementExists(id) {
    return $(id).length > 0;
}

function selectAutocomplete(wrapperId, selectId, value) {
    if(elementExists(wrapperId) && value !== undefined) {
        $(selectId).next().val($(selectId + " option[value='" + value + "']").text()).blur();
    }
}

function handleTargetAutoCompleteSelection(path) {
    trendSelection = $('#mashout-target-selection').val();

    $.ajax({url: path,
            data: {'mashout-target': trendSelection },
            success: function(data) { $('#mashout-target-container').replaceWith(data); },
            async: false});

    createAutocompleteComboboxes(function() {
      $('#mashout-target-container .ui-autocomplete-input').css('width','300px');
    });

    selectAutocomplete('#mashout-target-container', '#mashout-target-selection', trendSelection);
}

function handleTrendAutoCompleteSelection(path) {
    params          = {};
    trendExists     = $('#mashout-trend-container').length > 0;
    locationExists  = $('#mashout-location-container').length > 0;
    regionExists    = $('#mashout-region-container').length > 0;

    if(trendExists) {
      params.trend_source = $('#mashout-trend-selection').val();
    }

    if(locationExists) {
      params.trend_location = $('#mashout-location-selection').val();
    }

    if(regionExists) {
      params.trend_region = $('#mashout-region-selection').val();
    }

    $.ajax({url: path,
            data: params,
            success: function(data) { $('#mashout-trend').replaceWith(data); },
            async: false});

    createAutocompleteComboboxes(function() {
        decorateMashoutTrendAutoCompleteSelect();
    });

    if(trendExists) {
      selectAutocomplete('#mashout-trend-container', '#mashout-trend-selection', params.trend_source);
    }

    if(locationExists) {
      selectAutocomplete('#mashout-location-container', '#mashout-location-selection', params.trend_location);
    }

    if(regionExists) {
      selectAutocomplete('#mashout-region-container', '#mashout-region-selection', params.trend_region);
    }
}

function bindMashoutPreviewClick(path) {
    $('#preview-out').click(function() {
        params = 'mashout-target=' + $('#mashout-target-selection').val() + '&' +
                 'mashout-media=' + $('#mashout-media').val() + '&' +
                 'mashout-comment=' + $('#mashout-comment').val() + '&' +
                 'trend-location=' + $('#mashout-location-selection').val() + '&' +
                 'trend-source=' + $('#mashout-trend-selection').val() + '&' +
                 'trend-region=' + $('#mashout-region-selection').val() + '&' +
                 'mashout-video=' + $('.mashout-video:checked').val();

        $("#mashout-hashtag-checkboxes :checked").each(function() {
            params += '&mashout-hashtag[]=' + $(this).val();
        });

        $("#mashout-trend-checkboxes :checked").each(function() {
            params += '&mashout-trend[]=' + $(this).val();
        });

        $("input.target-checkbox").each(function() {
            if($(this).attr('checked') != undefined) {
              params += '&mashout-targets[]=' + $(this).val();
            }
        });

        $.ajax({url: path,
                data: encodeURI(params),
                success: function(data) { $('#out-preview').val(data); calculateCharsLeft(); },
                async: false});

        return false;
    });
}

function bindMashoutClearPreviewClick() {
    $('#preview-clear-out').click(function() {
        $('#out-preview').val('');
        calculateCharsLeft();
        return false;
    });
}

function bindMashoutTargetToReply(targetId, replyId) {
    $(targetId).click(function() { $(replyId).prop("checked", ($(this).prop("checked"))); });
}

function bindMashoutMasterTargetToChildTargets(masterTargetId) {
    $("#" + masterTargetId).click(function() { $("." + masterTargetId).prop("checked", ($(this).prop("checked"))); });
}

function bindMashoutShowMoreTweets() {
    $('#target-tweets-toggle').click(function() {
        $("#target-tweets-slider").slideToggle();
        return false;
    });
}

