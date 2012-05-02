//= require jquery.fancybox-1.3.4.pack.js

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

function generateOutFragment(value, targetId, add) {
    var target  = $(targetId);
    var current = target.val();

    if(add) {
        if(current.length == 0) {
            target.val(value);
        } else {
            target.val(current + ' ' + value);
        }
    } else {
        var regex = new RegExp('\\s*' + value, 'gi');

        if(current.search(regex) == 0) {
            target.val(current.replace(new RegExp(value + '\\s*', 'gi'), ''));
        } else {
            target.val(current.replace(regex, ''));
        }
    }
}

function generateDynamicOutPreview(outPreviewId) {
    var media     = $('#hidden-media').val();
    var targets   = $('#hidden-targets').val();
    var hashtags  = $('#hidden-hashtags').val();
    var trends    = $('#hidden-trends').val();
    var comment   = $('#hidden-comment').val();
    var video     = $('#hidden-video').val();
    var content   = ''

    var needsPadding  = function() { return ; }
    var addContent    = function(fragment) {
        if(content.length > 0) {
            content += ' ';
        }

        content += fragment;
        if(content.length > 140) {
            $('#mashout-chars-left').addClass('negative-char-count');
        } else {
            $('#mashout-chars-left').removeClass('negative-char-count');
        }
    }

    $.each([media, targets, hashtags, trends, comment, video], function() {
        if(this.length > 0) {
            addContent(this);
        }
    });

    $(outPreviewId).val(content);
    calculateCharsLeft();
}

function handleDynamicPreviewCheckboxChange(checkboxId, hiddenCheckboxId, outPreviewId) {
    var value     = unescape($(checkboxId).val());
    var isChecked = $(checkboxId + ':checked').length;

    generateOutFragment(value, hiddenCheckboxId, isChecked == 1);
    generateDynamicOutPreview(outPreviewId);
}

function bindDynamicPreviewTargetChange(checkboxId, hiddenCheckboxId, outPreviewId, checkboxClass) {
    $(checkboxId).change(function() {
        var value       = $(this).val();
        var hiddenValue = $(hiddenCheckboxId).val();
        var anyChecked  = $('.' + checkboxClass + ':checked').length > 0;

        // the current state of the checkbox
        var isChecking  = !($(checkboxId + ':checked').length < 1);

        if(hiddenValue.search(value) < 0) {
            // if the value is not present then add it
            handleDynamicPreviewCheckboxChange(checkboxId, hiddenCheckboxId, outPreviewId);
        } else if(hiddenValue.search(value) >= 0 && !isChecking && !anyChecked) {
            // if the value is present and the checkbox is not being checked then remove it
            generateOutFragment(value, hiddenCheckboxId, false);
            generateDynamicOutPreview(outPreviewId);
        }
        // otherwise do nothing
    });
}

function bindDynamicPreviewAutoCompleteSelectAndHandleTarget(wrapperId, selectId, hiddenFieldId, outPreviewId) {
    bindAutoCompleteSelect(wrapperId, selectId, function(oldValue, newValue) {
        var current = $(hiddenFieldId).val();
        var isNone  = newValue == 'NONE';

        generateOutFragment(current, hiddenFieldId, false);
        generateDynamicOutPreview(outPreviewId);
    });
}

function bindDynamicPreviewAutoCompleteSelectAndHandle(wrapperId, selectId, hiddenFieldId, outPreviewId) {
    bindAutoCompleteSelect(wrapperId, selectId, function(oldValue, newValue) {
        var current = $(hiddenFieldId).val();
        var isNone  = newValue == 'NONE';

        generateOutFragment(current, hiddenFieldId, false);
        generateOutFragment(isNone ? oldValue : unescape(newValue), hiddenFieldId, !isNone);
        generateDynamicOutPreview(outPreviewId);
    });
}

function bindDynamicPreviewVideoRadioClick(radioId, sourceId, hiddenRadioId, outPreviewId) {
    $(radioId).click(function() {
        var newValue = unescape($(sourceId).val());
        var oldValue = unescape($(hiddenRadioId).val());

        generateOutFragment(oldValue, hiddenRadioId, false);
        generateOutFragment(newValue, hiddenRadioId, true);
        generateDynamicOutPreview(outPreviewId);
    });
}

function bindDynamicPreviewCheckboxClick(checkboxId, hiddenCheckboxId, outPreviewId) {
    $(checkboxId).click(function() {
        handleDynamicPreviewCheckboxChange(checkboxId, hiddenCheckboxId, outPreviewId);
    });
}

function calculateCharsLeft() {
    $("#mashout-chars-left").text(140 - $('#out-preview').val().length);
}

function decorateMashoutTrendAutoCompleteSelect() {
    $('#mashout-trend-container .ui-autocomplete-input').css('width','300px');
    $('#mashout-location-container .ui-autocomplete-input').css('width','300px');
    $('#mashout-google-container .ui-autocomplete-input').css('width','300px');
    $('#mashout-region-container .ui-autocomplete-input').css('width','300px');
    $('#mashout-trendspottr-container .ui-autocomplete-input').css('width','300px');
}

function bindAutoCompleteSelect(wrapperId, selectId, callback) {
    $(wrapperId).bind('autocompleteselect', function (event, ui) {
        var oldValue = $(selectId).val();
        var newValue = ui.item.option.value;

        $(selectId).val(newValue);
        $(selectId).change();

        if(callback !== undefined) {
          callback(oldValue, newValue);
        }
    });
}

function bindTrendAutoCompleteSelectAndHandle(wrapperId, selectId, path) {
    bindAutoCompleteSelect(wrapperId, selectId, function(oldValue, newValue) { handleTrendAutoCompleteSelection(path); });
}

function bindTargetAutoCompleteSelectAndHandle(wrapperId, selectId, path) {
    bindAutoCompleteSelect(wrapperId, selectId, function(oldValue, newValue) { handleTargetAutoCompleteSelection(path); });
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
    var params          = {}
    var trendSelection  = $('#mashout-target-selection').val();
    var tweopleExists   = $('#mashout-target-tweople-source-selection').length > 0;

    params['mashout-target'] = trendSelection;

    if(tweopleExists) {
        params['mashout-tweople-source'] = $('#mashout-target-tweople-source-selection').val();
    }

    $.ajax({url: path,
            data: params,
            success: function(data) { $('#mashout-target-container').replaceWith(data); },
            async: false});

    createAutocompleteComboboxes(function() {
        $('#mashout-target-container .ui-autocomplete-input').css('width','300px');
    });

    selectAutocomplete('#mashout-target-container', '#mashout-target-selection', trendSelection);

    if(tweopleExists) {
        selectAutocomplete('#mashout-target-tweople-container', '#mashout-target-tweople-source-selection', params['mashout-tweople-source']);
    }
}

function handleTrendAutoCompleteSelection(path) {
    var params          = {};
    var trendExists     = $('#mashout-trend-container').length > 0;
    var locationExists  = $('#mashout-location-container').length > 0;
    var regionExists    = $('#mashout-region-container').length > 0;

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
}

function bindCaptureOutPreviewVideoLink(sourceId, outPreviewId, targetId) {
  $(sourceId).click(function() {
      var content = $(outPreviewId).val();
      var link    = content.match(/http:\/\/out.am\/\w+/, 'gi');

      $(targetId).val(link === undefined ? '' : link);
  });
}

function bindMashoutClearPreviewClick() {
    $('#preview-clear-out').click(function() {
        // clear the visible checkboxes
        $('#mashout-form input[type=checkbox]').each(function() {
            $(this).prop("checked", false);
        });

        // clear the hidden checkbox fields
        $('#mashout-form #hidden-hashtags').val('');
        $('#mashout-form #hidden-trends').val('');

        // clear the drop-downs, except target orientated ones
        selectAutocomplete('#mashout-comment-container', '#mashout-comment', 'NONE');
        selectAutocomplete('#mashout-media-container', '#mashout-media', 'NONE');

        // clear the hidden drop-down fields
        $('#mashout-form #hidden-comment').val('');
        $('#mashout-form #hidden-media').val('');
        $('#mashout-form #hidden-targets').val('');

        // clear the video radio buttons and radio hidden field
        var videoRadioButton = $("#mashout-form input[name='mashout-video']");
        if(videoRadioButton.length > 0) {
            videoRadioButton.prop("checked", false);
            $('#mashout-form #hidden-video').val('');
        }

        $('#out-preview').val('');
        calculateCharsLeft();
        return false;
    });
}

function bindMashoutTargetToReply(targetId, replyId) {
    $(targetId).click(function() { $(replyId).prop("checked", ($(this).prop("checked"))); });
}

function bindMashoutMasterTargetToChildTargets(masterTargetId) {
    $("#" + masterTargetId).click(function() { $("." + masterTargetId).prop("checked", ($(this).prop("checked"))); $("." + masterTargetId).change(); });
}

function bindMashoutShowMoreTweets(sourceId, targetId) {
    $(sourceId).click(function() {
        $(targetId).toggle();
        return false;
    });
}

function updateDynamicTrendspottrSearch(queryTargetId) {
    var searchTerms = $(queryTargetId).data('searchList')

    if(searchTerms) {
        $(queryTargetId).val(searchTerms.join(' '))
    } else {
        $(queryTargetId).val()
    }
}

function bindDynamicTrendSpottrCheckboxClick(checkboxName, targetId) {
    $('input[name="' + checkboxName + '"]').click(function() {
        var value     = $(this).val()
        var isChecked = $(this).attr('checked') == 'checked'

        if (!$(targetId).data('searchList')) {
            $(targetId).data('searchList', [])
        }

        if (isChecked) {
            $(targetId).data('searchList').push(value)
        } else {
            var index = $(targetId).data('searchList').indexOf(value)

            if (index != -1) {
                $(targetId).data('searchList').splice(index, 1)
            }
        }

        updateDynamicTrendspottrSearch(targetId)
    })
}

function handleTrendSpottrSearchSubmission(buttonId, targetId, path) {
    var params = {}

    params.trend_location = $('#mashout-trendspottr-selection').val()
    params.trend_search = $('#trendspottr-query').val()


    $.ajax({url: path,
            data: params,
            success: function(data) {
                $(targetId).html(data)
                $(targetId).removeClass('hidden')
                $('#mashout-trendspottr-container img.spinner').remove()
                $(buttonId).prop('disabled', false)
            }
    })

    return false
}

function bindTrendSpottrSearchButton(buttonId, targetId, path) {
    $(buttonId).click(function() {
        $(buttonId).prop('disabled', true)
        $('#mashout-trendspottr-container').append('<img class="spinner" src="/assets/spinner.gif" />')
        handleTrendSpottrSearchSubmission(buttonId, targetId, path)
        return false
    })
}

