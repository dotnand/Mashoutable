//= require jquery-ui-1.8.16.custom.min
//= require select

function bindEditNetworkPreferencesClick(buttonId, path) {
    $(buttonId).click(function() { 
        var params = 'mashout-network-twitter=' + $('#mashout-network-twitter').val() + '&' +
                     'mashout-network-facebook=' + $('#mashout-network-facebook').val() + '&' +
                     'mashout-network-youtube=' + $('#mashout-network-youtube').val();
                     
        $.ajax({url: path,
                type: 'DELETE',
                data: encodeURI(params),
                success: function(data) { $('.network-toggle').replaceWith(data); },
                async: false});

        return false;
    });
}

function bindSendButtonClick(buttonId, outId, outTargetId, formId) {
    $(buttonId).click(function() {
        var out       = $(outId);
        var outTarget = $(outTargetId);

        outTarget.val(out.val());
        $(formId).submit();

        return false;
    });
}

function bindYouTubeHelpText(buttonId, targetId) {
    $(buttonId).click(function() {
        $(targetId).toggle();
    });
}

function enableNetworkButton(buttonId, enabled) {
    var button = $(buttonId);

    if(enabled) {
        button.addClass('on');
    } else {
        button.removeClass('on');
    }
}

function bindNetworkToggleButton(buttonId, targetId) {
    $(buttonId).click(function() {
        var button  = $(this);
        var isOn    = button.hasClass('on');

        enableNetworkButton(buttonId, !isOn);
        $(targetId).val(!isOn);

        return false;
    });
}

function bindSettingsPanelButton(settingsName) {
      $('#' + settingsName).click(function () {
          var settingsClassName = '.' + settingsName;

          hideDashboardSettings(settingsName);

          if ($(settingsClassName).is(':hidden')) {
              $(this).parents().addClass('active');
              $(settingsClassName).slideDown('200').animate({ scrollTop: 0 }, 0);
          } else {
              $(settingsClassName).slideUp('slow').animate({ scrollTop: 0 }, 0);
          }

          return false;
      });
}

function hideDashboardSettings(className) {
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

