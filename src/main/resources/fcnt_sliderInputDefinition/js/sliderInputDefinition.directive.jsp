<%@ page contentType="text/javascript" %>
<%@ taglib prefix="formfactory" uri="http://www.jahia.org/formfactory/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>


(function () {

    angular.module('formFactory').requires.push('rzModule');

    var sliderInput = function (ffTemplateResolver, $log, $injector) {
        return {
            restrict: 'E',
            require: ['^ffController'],
            controller: SliderInputController,
            controllerAs: 'sic',
            bindToController: true,
            templateUrl: function (el, attrs) {
                return ffTemplateResolver.resolveTemplatePath('${formfactory:addFormFactoryModulePath('/form-factory-definitions/slider-input', renderContext)}', attrs.viewType);
            },
            link: linkFunc
        };
        function linkFunc(scope, el, attr, ctrl) {

            if (isNaN(scope.input.value) || scope.input.value == undefined) {
                scope.input.value = parseInt(scope.input.initValue);
            } else {
                scope.input.value = parseInt(scope.input.initValue);
            }
            scope.isDesignView = attr.viewType == "designView";
        }
    };
    angular.module('formFactory')
        .directive('ffSliderInput', ['ffTemplateResolver', '$log', '$injector', sliderInput]);

    var SliderInputController = function ($scope, $timeout, $filter,
                                          i18n, $element, $document, toaster, $rootScope, $compile) {
        var sic = this;
        sic.parsed = {};
        sic.i18nMessageGetter = i18n.message;
        sic.resetLegend = resetLegend;
        sic.toggleLegend = toggleLegend;
        sic.legendUpdater = legendUpdater;
        sic.sizeOfSlider = sizeOfSlider;

        $scope.translateTypes = { // these are the translate options
            default : 'Default',
            currency_$: 'Currency',
            percentage: 'Percentage'
        };
        $scope.currencyTypes = { // [ "$", "£", "€" ] these are the currency types for the currency translation option
            '&#36;' : String.fromCharCode(36),
            '&#x00A3;' : String.fromCharCode(163),
            '&#8364;' : String.fromCharCode(8364)
        }

        //initial value of minSlider object
        $scope.minSlider = {
            options: {
                floor: parseInt($scope.input.floor),
                ceil: parseInt($scope.input.ceil),
                step: $scope.input.step,
                vertical: verticalization(),
                showTicks: ticksNormalizer(),
                showTicksValues: toBool($scope.input.enableLegend),
                stepsArray: $scope.stepsArray,
                showSelectionBarFromValue: parseInt($scope.input.initValue),
                readOnly: $scope.readOnly,
                translate: null
            }
        }

        //It works now, but you have to recompile to see it update in builder mode.
        sic.$onInit = function () {
            //init vertical switch
            $scope.input.vertical = toBool($scope.input.vertical);
            //init show ticks switch
            $scope.input.ticks = toBool($scope.input.ticks);
            //init legend
            $scope.input.enableLegend = toBool($scope.input.enableLegend);
            if ($scope.input.enableLegend) {
               initStepsArray();
            }
            // on init if ticks are disabled the default ticks value should equal the steps value
            if ($scope.input.ticks == false) {
                $scope.input.customTicks = $scope.input.step;
            }
            //If selectedType is not set, then set it to default
            $scope.input.translate = $scope.input.translate ? $scope.input.translate : 'default';

            $scope.normalizeTranslateOption();

            $timeout(function(){
                if (!$scope.isDesignView) {
                    $scope.$on('updateSliderOptions', function(e, data) {
                        if (_.isArray(data)){
                            for (var i in data){
                                if(data[i].property == 'value'){
                                    $scope.input[data[i].property] = data[i].value;
                                } else {
                                    $scope.minSlider.options[data[i].property] = data[i].value;
                                }
                            }
                        } else {
                            if(data.property == 'value'){
                                $scope.input[data.property] = data.value;
                            } else {
                                $scope.minSlider.options[data.property] = data.value;
                            }
                        }
                    });
                }
            });
        }

        $scope.$watch(function() {
            return $scope.input.ticks;
        }, function(value) {
            $scope.input.ticks = value;
            $scope.minSlider.options.showTicks = ticksNormalizer();
        });

        $scope.$watch(function() {
            return $scope.input.vertical;
        }, function(value) {
            $scope.input.vertical = value;
            $scope.minSlider.options.vertical = verticalization();
            recompileRzSlider();
        });

        // watch input options for the minSlider object and overwrite the old values with the new values
        $scope.$watchCollection('input', function (newValue, oldValue) {
            if (newValue !== undefined && newValue.initValue !== oldValue.initValue) {
                if (isNaN(newValue.initValue) || newValue.initValue == "" || newValue.initValue == undefined){
                    errorToast('ff.toast.message.errorNumber');
                } else {
                    $scope.input.value = parseInt(newValue.initValue);
                    $scope.minSlider.options.showSelectionBarFromValue = parseInt(newValue.initValue);
                    $rootScope.$broadcast('updateSliderOptions', [
                        {
                            property: 'showSelectionBarFromValue',
                            value: $scope.minSlider.options.showSelectionBarFromValue
                        },
                        {
                            property: 'value',
                            value: parseInt($scope.input.initValue)
                        }
                    ]);
                }
            }
            if (newValue !== undefined && newValue.floor !== oldValue.floor) {
                if (isNaN(newValue.floor) || newValue.floor == "" || newValue.floor == undefined){
                    errorToast('ff.toast.message.errorNumber');
                } else {
                    $scope.minSlider.options.floor = parseInt(newValue.floor);
                    $scope.minSlider.options.showSelectionBarFromValue = parseInt($scope.input.initValue);
                    $scope.input.value = parseInt($scope.input.initValue);
                    var properties = [
                        {
                            property: 'floor',
                            value: $scope.minSlider.options.floor
                        },
                        {
                            property: 'ceil',
                            value: parseInt($scope.input.ceil)
                        },
                        {
                            property: 'showSelectionBarFromValue',
                            value: $scope.minSlider.options.showSelectionBarFromValue
                        },
                        {
                            property: 'stepsArray',
                            value: null
                        },
                        {
                            property: 'value',
                            value: parseInt($scope.input.initValue)
                        }
                    ]
                    if (!$scope.input.enableLegend) {
                        properties.push({
                            property: 'showTicksValues',
                            value: $scope.input.enableLegend
                        });
                    }
                    $rootScope.$broadcast('updateSliderOptions', properties);
                }
            }
            if (newValue !== undefined && newValue.ceil !== oldValue.ceil) {
                if (isNaN(newValue.ceil) || newValue.ceil == "" || newValue.ceil == undefined){
                    errorToast('ff.toast.message.errorNumber');
                } else {
                    $scope.minSlider.options.ceil = parseInt(newValue.ceil);
                    $rootScope.$broadcast('updateSliderOptions', [
                        {
                            property: 'floor',
                            value: parseInt($scope.input.floor)
                        },
                        {
                            property: 'ceil',
                            value: $scope.minSlider.options.ceil
                        },
                        {
                            property: 'showSelectionBarFromValue',
                            value: parseInt($scope.input.initValue)
                        },
                        {
                            property: 'stepsArray',
                            value: null
                        },
                        {
                            property: 'value',
                            value: parseInt($scope.input.initValue)
                        },
                        {
                            property: 'showTicksValues',
                            value: $scope.input.enableLegend
                        }
                    ]);
                    if (!$scope.input.enableLegend) {
                        $scope.$broadcast('rzSliderForceRender');
                    }
                }
            }
            if (newValue !== undefined && newValue.step !== oldValue.step) {
                if (isNaN(newValue.step) || newValue.step == "" || newValue.step == undefined || newValue.step < 0){
                    errorToast('ff.toast.message.errorPositiveNumber');
                } else {
                    $scope.minSlider.options.step = newValue.step;
                    $rootScope.$broadcast('updateSliderOptions', {
                        property: 'step',
                        value: $scope.minSlider.options.step
                    });
                }
            }
            if (newValue !== undefined && newValue.translate !== oldValue.translate) {
                oldValue.translate = newValue.translate;
                $rootScope.$broadcast('updateSliderOptions', {
                    property: 'translate',
                    value: $scope.minSlider.options.translate
                });
                $scope.$broadcast('rzSliderForceRender');
            }
            if (newValue !== undefined && newValue.customTicks !== oldValue.customTicks){
                if (isNaN(newValue.customTicks) || newValue.customTicks == "" || newValue.customTicks == undefined || newValue.customTicks < 0){
                    errorToast('ff.toast.message.errorPositiveNumber');
                } else {
                    $scope.input.customTicks = newValue.customTicks;
                    $scope.minSlider.options.showTicks = ticksNormalizer();
                    $rootScope.$broadcast('updateSliderOptions', {
                        property: 'showTicks',
                        value: $scope.minSlider.options.showTicks
                    });
                }
            }

        });

        //this func parses a string value to bool value
        function toBool(value) {
            if (typeof value === 'boolean') {
                return value;
            }
            else {
                return value === 'true';
            }
        }

        $scope.returnDivHeight = function() {
            if (toBool($scope.input.vertical) == true || $scope.input.vertical == true) {
                return "padding-left: 50px; height: 500px";
            } else {
                return "height: auto";
            }
        }

        function recompileRzSlider(){
            $timeout(function(){
                var element = $element.find('.slider');
                if (sic.sliderScope != null){
                    sic.sliderScope.$destroy();
                    sic.sliderScope = null;
                    element.empty();
                }
                sic.sliderScope = $scope.$new();
                var newElement = angular.element(document.createElement('rzslider'));
                newElement.attr('rz-slider-model', 'input.value').attr('rz-slider-options', 'minSlider.options');
                element.html(newElement);
                $compile(element.contents())(sic.sliderScope);
            });
        }

        function verticalization() {
            if (toBool($scope.input.vertical) == true || $scope.input.vertical == true) {
                return $scope.input.vertical;
            } else {
                return false;
            }
        }

        // func that updates ticks value
        function ticksNormalizer() {
            if(toBool($scope.input.ticks) == true || $scope.input.ticks == true){
                return parseInt($scope.input.customTicks);
            } else {
                return false;
            }
        }

        //func that updates translate option
        $scope.normalizeTranslateOption = function() {
            $scope.minSlider.options.translate = $scope.getTranslation();
        }

        //func that gets/sets translation
        $scope.getTranslation = function(){
            return function(value){
                switch($scope.input.translate.split('_')[0]) {
                    case 'currency' :
                        return $scope.input.translate.split('_')[1] + value;
                    case 'percentage':
                        return value + '%';
                    default:
                        return value;
                }
            }
        }

        //init stepsArray for the legend
        function initStepsArray() {
            $scope.stepsArray = [];
            if ($scope.input.legend != null && $scope.input.legend.length > 0 && $scope.input.stepsValues != null && $scope.input.stepsValues.length > 0) {
                for (var j = 0; j < sizeOfSlider(); j++) {
                    $scope.stepsArray[j] = {
                        value: $scope.input.stepsValues[j].value,
                        legend: $scope.input.legend[j].value
                    };
                }
                $scope.minSlider.options.stepsArray = $scope.stepsArray;
            } else {
                $scope.input.stepsValues = [];
                for (var i = $scope.minSlider.options.floor; i <= $scope.minSlider.options.ceil; i++) {
                    $scope.input.stepsValues.push({value: i});
                }
                for (var j = 0; j < sizeOfSlider(); j++) {
                    $scope.input.legend[j] = {value: ''};
                    $scope.stepsArray[j] = {
                        value: $scope.input.stepsValues[j].value,
                        legend: $scope.input.legend[j].value
                    };
                }
            }
            $scope.input.translate = $scope.translateTypes.default;
            $scope.minSlider.options.stepsArray = $scope.stepsArray;
            var properties = [
                {
                    property: 'translate',
                    value: null
                },
                {
                    property: 'showTicks',
                    value: false
                },
                {
                    property: 'floor',
                    value: parseInt($scope.input.floor)
                },
                {
                    property: 'ceil',
                    value: parseInt($scope.input.ceil)
                },
                {
                    property: 'showTicksValues',
                    value: $scope.input.enableLegend
                },
                {
                    property: 'showSelectionBarFromValue',
                    value: parseInt($scope.input.initValue)
                },
                {
                    property: 'stepsArray',
                    value: $scope.stepsArray
                }
            ];
            $rootScope.$broadcast('updateSliderOptions', properties);
        }

        function resetLegend() {
            $scope.input.enableLegend = false;
            $scope.minSlider.options.showTicksValues = toBool($scope.input.enableLegend);
            $scope.input.translate = $scope.translateTypes.default;
            $scope.input.legend = [];
            $scope.input.stepsValues = [];
            var properties = [
                {
                    property: 'floor',
                    value: parseInt($scope.input.floor)
                },

                {
                    property: 'ceil',
                    value: parseInt($scope.input.ceil)
                },
                {
                    property: 'showTicksValues',
                    value: $scope.input.enableLegend
                },
                {
                    property: 'showSelectionBarFromValue',
                    value: parseInt($scope.input.initValue)
                },
                {
                    property: 'stepsArray',
                    value: null
                },
                {
                    property: 'translate',
                    value: null
                },
                {
                    property: 'value',
                    value: parseInt($scope.input.initValue)
                }
            ];
            $rootScope.$broadcast('updateSliderOptions', properties);
        }

        //finds the total number of ticks on the slider
        function sizeOfSlider(){
            if ($scope.minSlider.options.floor <= 0 && $scope.minSlider.options.ceil >= 0){
                return Math.abs($scope.minSlider.options.floor) + Math.abs($scope.minSlider.options.ceil) + 1;
            } else if ($scope.minSlider.options.floor < 0 && $scope.minSlider.options.ceil < 0){
                return Math.abs($scope.minSlider.options.floor) - Math.abs($scope.minSlider.options.ceil) + 1;
            } else {
                return $scope.minSlider.options.ceil - $scope.minSlider.options.floor + 1;
            }
        }

        function toggleLegend() {
            if ($scope.input.enableLegend) {
                initStepsArray();
                $scope.minSlider.options.stepsArray = $scope.stepsArray;
                $scope.minSlider.options.showTicksValues = $scope.input.enableLegend;
                $rootScope.$broadcast('updateSliderOptions', [
                    {
                        property: 'stepsArray',
                        value: $scope.minSlider.options.stepsArray
                    },
                    {
                        property: 'showTicksValues',
                        value: $scope.minSlider.options.showTicksValues
                    },
                    {
                        property: 'value',
                        value: parseInt($scope.input.initValue)
                    }
                ]);
            } else {
                $scope.stepsArray = null;
                $scope.minSlider.options.showTicksValues = $scope.input.enableLegend;
                $rootScope.$broadcast('updateSliderOptions', [
                    {
                        property: 'stepsArray',
                        value: $scope.stepsArray
                    },
                    {
                        property: 'showTicksValues',
                        value: $scope.minSlider.options.showTicksValues
                    },
                    {
                        property: 'value',
                        value: parseInt($scope.input.initValue)
                    }
                ]);
            }
        }

        function legendUpdater() {
            var tmpLegend = angular.copy($scope.input.legend);
            var tmpstepsValues = angular.copy($scope.input.stepsValues);
            $scope.stepsArray = [];

            for (var j = 0; j < sizeOfSlider(); j++) {
                $scope.stepsArray[j] = {
                    value: tmpstepsValues[j].value,
                    legend: tmpLegend[j].value
                };
            }
            $scope.minSlider.options.stepsArray = $scope.stepsArray;
            $scope.input.legend = tmpLegend;
            $scope.input.stepValues = tmpstepsValues;
            var properties = [
                {
                    property: 'floor',
                    value: parseInt($scope.input.floor)
                },
                {
                    property: 'value',
                    value: parseInt($scope.input.initValue)
                },
                {
                    property: 'ceil',
                    value: parseInt($scope.input.ceil)
                },
                {
                    property: 'showTicksValues',
                    value: $scope.input.enableLegend
                },
                {
                    property: 'showSelectionBarFromValue',
                    value: parseInt($scope.input.initValue)
                },
                {
                    property: 'stepsArray',
                    value: $scope.stepsArray
                }
            ];
            $rootScope.$broadcast('updateSliderOptions', properties);
        }

        function errorToast(errorMsg) {
            $timeout(function() {
                toaster.pop({
                    type: 'error',
                    title: i18n.message('ff.toast.title.invalidInput'),
                    body: i18n.message(errorMsg),
                    toastId: 'rsic',
                    timeout: 2000
                });
            });
        }
    }

    SliderInputController.$inject = ['$scope', '$timeout', '$filter', 'i18nService',
        '$element', '$document', 'toaster', '$rootScope', '$compile'];
})();



