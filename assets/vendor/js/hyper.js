/**
 * Theme: Hyper - Responsive Bootstrap 4 Admin Dashboard
 * Author: Coderthemes
 * Module/App: Main Js
 */


!function($) {
    "use strict";

    /**
    Portlet Widget
    */
    var Portlet = function() {
        this.$body = $("body"),
        this.$portletIdentifier = ".card",
        this.$portletCloser = '.card a[data-toggle="remove"]',
        this.$portletRefresher = '.card a[data-toggle="reload"]'
    };

    //on init
    Portlet.prototype.init = function() {
        // Panel closest
        var $this = this;
        $(document).on("click",this.$portletCloser, function (ev) {
            ev.preventDefault();
            var $portlet = $(this).closest($this.$portletIdentifier);
                var $portlet_parent = $portlet.parent();
            $portlet.remove();
            if ($portlet_parent.children().length == 0) {
                $portlet_parent.remove();
            }
        });

        // Panel Reload
        $(document).on("click",this.$portletRefresher, function (ev) {
            ev.preventDefault();
            var $portlet = $(this).closest($this.$portletIdentifier);
            // This is just a simulation, nothing is going to be reloaded
            $portlet.append('<div class="card-disabled"><div class="card-portlets-loader"></div></div>');
            var $pd = $portlet.find('.card-disabled');
            setTimeout(function () {
                $pd.fadeOut('fast', function () {
                    $pd.remove();
                });
            }, 500 + 300 * (Math.random() * 5));
        });
    },
    //
    $.Portlet = new Portlet, $.Portlet.Constructor = Portlet

}(window.jQuery),

function($) {
    'use strict';

    var AdvanceFormApp = function() {
        this.$body = $('body'),
        this.$window = $(window)
    };


    /**
     * Initlizes the select2
    */
    AdvanceFormApp.prototype.initSelect2 = function() {
        // Select2
        try { $('[data-toggle="select2"]').select2() }
        catch (error) { return null; }
    },

    /**
     * Initlized mask
    */
    AdvanceFormApp.prototype.initMask = function() {
        $('[data-toggle="input-mask"]').each(function (idx, obj) {
            var maskFormat = $(obj).data("maskFormat");
            var reverse = $(obj).data("reverse");
            if (reverse != null)
                $(obj).mask(maskFormat, {'reverse': reverse});
            else
                $(obj).mask(maskFormat);
        });
    },

    // Datetime and date range picker
    AdvanceFormApp.prototype.initDateRange = function() {
        var defaultOptions = {
            "cancelClass": "btn-light",
            "applyButtonClasses": "btn-success"
        };

        // date pickers
        $('[data-toggle="date-picker"]').each(function (idx, obj) {
            var objOptions = $.extend({}, defaultOptions, $(obj).data());
            $(obj).daterangepicker(objOptions);
        });

        //date pickers ranges only
        //var start = moment().subtract(29, 'days');
        //var end = moment();
        //var defaultRangeOptions = {
        //    startDate: start,
        //    endDate: end,
        //    ranges: {
        //    'Today': [moment(), moment()],
        //    'Yesterday': [moment().subtract(1, 'days'), moment().subtract(1, 'days')],
        //    'Last 7 Days': [moment().subtract(6, 'days'), moment()],
        //    'Last 30 Days': [moment().subtract(29, 'days'), moment()],
        //    'This Month': [moment().startOf('month'), moment().endOf('month')],
        //    'Last Month': [moment().subtract(1, 'month').startOf('month'), moment().subtract(1, 'month').endOf('month')]
        //    }
        //};

        //$('[data-toggle="date-picker-range"]').each(function (idx, obj) {
        //    var objOptions = $.extend({}, defaultRangeOptions, $(obj).data());
        //    var target = objOptions["targetDisplay"];
        //    //rendering
        //    $(obj).daterangepicker(objOptions, function(start, end) {
        //        if (target)
        //            $(target).html(start.format('MMMM D, YYYY') + ' - ' + end.format('MMMM D, YYYY'));
        //    });
        //});
    },

    // time picker
    AdvanceFormApp.prototype.initTimePicker = function() {
        var defaultOptions = {
            "showSeconds": true,
            "icons": {
                "up": "mdi mdi-chevron-up",
                "down": "mdi mdi-chevron-down"
            }
        };

        // time picker
        $('[data-toggle="timepicker"]').each(function (idx, obj) {
            var objOptions = $.extend({}, defaultOptions, $(obj).data());
            $(obj).timepicker(objOptions);
        });
    },

    // touchspin
    AdvanceFormApp.prototype.initTouchspin = function() {
        var defaultOptions = {
        };

        // touchspin
        $('[data-toggle="touchspin"]').each(function (idx, obj) {
            var objOptions = $.extend({}, defaultOptions, $(obj).data());
            $(obj).TouchSpin(objOptions);
        });
    },

    // maxlength
    AdvanceFormApp.prototype.initMaxlength = function() {
        var defaultOptions = {
            warningClass: "badge badge-success",
            limitReachedClass: "badge badge-danger",
            separator: ' out of ',
            preText: 'You typed ',
            postText: ' chars available.',
            placement: 'bottom',
        };

        // maxlength
        $('[data-toggle="maxlength"]').each(function (idx, obj) {
            var objOptions = $.extend({}, defaultOptions, $(obj).data());
            $(obj).maxlength(objOptions);
        });
    },

    /**
     * Initilize
    */
   AdvanceFormApp.prototype.init = function() {
        var $this = this;
        this.initSelect2();
        this.initMask();
        this.initDateRange();
        this.initTimePicker();
        this.initTouchspin();
        this.initMaxlength();
    },

    $.AdvanceFormApp = new AdvanceFormApp, $.AdvanceFormApp.Constructor = AdvanceFormApp


}(window.jQuery),

function($) {
    'use strict';

    var NotificationApp = function() {
    };


    /**
     * Send Notification
     * @param {*} heading heading text
     * @param {*} body body text
     * @param {*} position position e.g top-right, top-left, bottom-left, etc
     * @param {*} loaderBgColor loader background color
     * @param {*} icon icon which needs to be displayed
     * @param {*} hideAfter automatically hide after seconds
     * @param {*} stack
     */
    NotificationApp.prototype.send = function(heading, body, position, loaderBgColor, icon, hideAfter, stack, showHideTransition) {
        // default
        if (!hideAfter)
            hideAfter = 3000;
        if (!stack)
            stack = 1;

        var options = {
            heading: heading,
            text: body,
            position: position,
            loaderBg: loaderBgColor,
            icon: icon,
            hideAfter: hideAfter,
            stack: stack
        };

        if(showHideTransition)
            options.showHideTransition = showHideTransition;
        else
            options.showHideTransition = 'fade';

        $.toast().reset('all');
        $.toast(options);
    },

    $.NotificationApp = new NotificationApp, $.NotificationApp.Constructor = NotificationApp

}(window.jQuery),

function($) {
    "use strict";

    var Components = function() {};

    //initializing tooltip
    Components.prototype.initTooltipPlugin = function() {
        $.fn.tooltip && $('[data-toggle="tooltip"]').tooltip()
    },

    //initializing popover
    Components.prototype.initPopoverPlugin = function() {
        $.fn.popover && $('[data-toggle="popover"]').popover()
    },

    //initializing Slimscroll
    Components.prototype.initSlimScrollPlugin = function() {
        //You can change the color of scroll bar here
        //$.fn.slimScroll && $(".slimscroll").slimScroll({
        //    height: 'auto',
        //    position: 'right',
        //    size: "8px",
        //    touchScrollStep: 20,
        //    color: '#9ea5ab'});
    },

    //initializing form validation
    Components.prototype.initFormValidation = function() {
        $(".needs-validation").on('submit', function (event) {
            $(this).addClass('was-validated');
            if ($(this)[0].checkValidity() === false) {
                event.preventDefault();
                event.stopPropagation();
                return false;
            }
            return true;
        });
    },


    //initilizing
    Components.prototype.init = function() {
        var $this = this;
        this.initTooltipPlugin(),
        this.initPopoverPlugin(),
        this.initSlimScrollPlugin(),
        this.initFormValidation();
    },

    $.Components = new Components, $.Components.Constructor = Components

}(window.jQuery),

function ($) {
    'use strict';

    var App = function () {
        this.$body = $('body'),
            this.$window = $(window)
    };

    /**
    Resets the scroll
     */
    App.prototype._resetSidebarScroll = function() {
        // sidebar - scroll container
        //$('.slimscroll-menu').slimscroll({
        //    height: 'auto',
        //    position: 'right',
        //    size: "8px",
        //    color: '#9ea5ab',
        //    wheelStep: 5,
        //    touchScrollStep: 20
        //});
    },
    /**
     * Initlizes the menu - top and sidebar
    */
    App.prototype.initMenu = function () {
        var $this = this;

        // Left menu collapse
        $('.button-menu-mobile').on('click', function (event) {
            event.preventDefault();
            $this.$body.toggleClass('sidebar-enable');
            if ($this.$window.width() >= 768) {
                $this.$body.toggleClass('enlarged');
            } else {
                $this.$body.removeClass('enlarged');
            }

            // sidebar - scroll container
            $this._resetSidebarScroll();
        });

        // sidebar - main menu
        //$(".side-nav").metisMenu();

        // sidebar - scroll container
        $this._resetSidebarScroll();

        // right side-bar toggle
        $('.right-bar-toggle').on('click', function (e) {
            $('body').toggleClass('right-bar-enabled');
        });

        $(document).on('click', 'body', function (e) {
            if ($(e.target).closest('.right-bar-toggle, .right-bar').length > 0) {
                return;
            }

            if ($(e.target).closest('.left-side-menu, .side-nav').length > 0 || $(e.target).hasClass('button-menu-mobile')
                || $(e.target).closest('.button-menu-mobile').length > 0) {
                return;
            }

            $('body').removeClass('right-bar-enabled');
            $('body').removeClass('sidebar-enable');
            return;
        });

        // activate the menu in left side bar based on url
        $(".side-nav a").each(function () {
            var pageUrl = window.location.href.split(/[?#]/)[0];
            if (this.href == pageUrl) {
                $(this).addClass("active");
                $(this).parent().addClass("active"); // add active to li of the current link
                $(this).parent().parent().addClass("in");
                $(this).parent().parent().prev().addClass("active"); // add active class to an anchor
                $(this).parent().parent().parent().addClass("active");
                $(this).parent().parent().parent().parent().addClass("in"); // add active to li of the current link
                $(this).parent().parent().parent().parent().parent().addClass("active");
            }
        });

        $(".topnav-menu li a").each(function () {
            var pageUrl = window.location.href.split(/[?#]/)[0];
            if (this.href == pageUrl) {
                $(this).addClass("active");
                $(this).parent().parent().addClass("active"); // add active to li of the current link
                $(this).parent().parent().parent().parent().addClass("active");
            }
        });

        // Topbar - main menu
        $('.navbar-toggle').on('click', function (event) {
            $(this).toggleClass('open');
            $('#navigation').slideToggle(400);
        });

        $('.dropdown-menu a.dropdown-toggle').on('click', function(e) {
            if (!$(this).next().hasClass('show')) {
              $(this).parents('.dropdown-menu').first().find('.show').removeClass("show");
            }
            var $subMenu = $(this).next(".dropdown-menu");
            $subMenu.toggleClass('show');

            return false;
        });
    },

        /**
         * Init the layout - with broad sidebar or compact side bar
        */
        App.prototype.initLayout = function () {
            // in case of small size, add class enlarge to have minimal menu
            if (this.$window.width() >= 768 && this.$window.width() <= 1028) {
                this.$body.addClass('enlarged');
            } else {
                if (this.$body.data('keep-enlarged') != true) {
                    this.$body.removeClass('enlarged');
                }
            }
        },

        //initilizing
        App.prototype.init = function () {
            var $this = this;
            this.initLayout();
            this.initMenu();
            //creating portles
            $.Portlet.init();
            $.AdvanceFormApp.init();
            $.Components.init();

            // on window resize, make menu flipped automatically
            $this.$window.on('resize', function(e) {
                e.preventDefault();
                $this.initLayout();
                $this._resetSidebarScroll();
            });
        },

        $.App = new App, $.App.Constructor = App


}(window.jQuery),
    //initializing main application module

function ($) {
    "use strict";
    $(document).ready(function() {
      $.App.init();
    })
}(window.jQuery);
