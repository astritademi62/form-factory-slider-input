<%@ page contentType="text/javascript" %>
    <%@ taglib prefix="formfactory" uri="http://www.jahia.org/formfactory/functions" %>
    <%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr"%>
    <%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
    <%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>


    (function (){

        angular.module('formFactory').requires.push('rzModule');

        var rangeSliderInput = function (ffTemplateResolver) {
            return {
                restrict: 'E',
                require: ['^ffController'],
                controller: RangeSliderInputController,
                controllerAs: 'rsic',
                bindToController: true,
                templateUrl: function(el, attrs) {
                    return ffTemplateResolver.resolveTemplatePath('${formfactory:addFormFactoryModulePath('/form-factory-definitions/range-slider-input', renderContext)}', attrs.viewType);
                },
                link: linkFunc
            };
            function linkFunc(scope, el, attr, ctrl) {
                //set initial min and max range values
                if (isNaN(scope.input.value) || scope.input.value == undefined) {
                    scope.input.value = {
                        minValue : parseInt(scope.input.minValue),
                        maxValue : parseInt(scope.input.maxValue),
                        rendererName: 'rangeSliderInput'
                    }

                } else {
                    scope.input.value = {
                        minValue : parseInt(scope.input.minValue),
                        maxValue : parseInt(scope.input.maxValue),
                        rendererName: 'rangeSliderInput'
                    }
                }
                scope.isDesignView = attr.viewType == "designView";
            }
        };
        angular.module('formFactory')
            .directive('ffRangeSliderInput', ['ffTemplateResolver', rangeSliderInput]);

        var RangeSliderInputController = function ($scope, $timeout, $filter, toaster,
                                              i18n, $element, $document, $rootScope, $compile){
            var rsic = this;
            rsic.parsed = {};
            rsic.i18nMessageGetter = i18n.message;
            rsic.resetLegend = resetLegend;
            rsic.toggleLegend = toggleLegend;
            rsic.legendUpdater = legendUpdater;
            rsic.sizeOfSlider = sizeOfSlider;

            $scope.translateTypes = {                 // these are the translate options
                default : 'Default',
                currency_$: 'Currency',
                percentage: 'Percentage'
            };
            $scope.currencyTypes = {                  // [ "$", "£", "€" ] these are the currency types for the currency translate option
                '&#36;' : String.fromCharCode(36),
                '&#x00A3;' : String.fromCharCode(163),
                '&#8364;' : String.fromCharCode(8364)
            }

            $scope.ranSlider = {
                minValue: parseInt($scope.input.minValue),
                maxValue: parseInt($scope.input.maxValue),
                options: {
                    floor: parseInt($scope.input.floor),
                    ceil: parseInt($scope.input.ceil),
                    step: $scope.input.step,
                    vertical: verticalization(),
                    showTicks: ticksNormalizer(),
                    showTicksValues: toBool($scope.input.enableLegend),
                    stepsArray: $scope.stepsArray,
                    showSelectionBar: true,
                    readOnly: $scope.readOnly,
                    translate: null
                }
            }

            rsic.$onInit = function() {
                //init vertical switch
                $scope.input.vertical = toBool($scope.input.vertical);
                //init show ticks switch
                $scope.input.ticks = toBool($scope.input.ticks);
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
                                    if(data[i].property == 'minValue' || data[i].property == 'maxValue'){
                                        $scope.ranSlider[data[i].property] = data[i].value;
                                    } else {
                                        $scope.ranSlider.options[data[i].property] = data[i].value;
                                    }
                                }
                            } else {
                                if(data.property == 'minValue' || data.property == 'maxValue'){
                                    $scope.ranSlider[data.property] = data.value;
                                } else {
                                    $scope.ranSlider.options[data.property] = data.value;
                                }
                            }
                        });
                    }
                });
            }

            $scope.$watch(function() {
                return $scope.ranSlider.minValue;
            }, function(value) {
                $scope.input.value.minValue = value;
            });

            $scope.$watch(function() {
                return $scope.ranSlider.maxValue;
            }, function(value) {
                $scope.input.value.maxValue = value;
            });

            $scope.$watch(function() {
                return $scope.input.ticks;
            }, function(value) {
                $scope.input.ticks = value;
                $scope.ranSlider.options.showTicks = ticksNormalizer();
            });

            $scope.$watch(function() {
                return $scope.input.vertical;
            }, function(value) {
                $scope.input.vertical = value;
                $scope.ranSlider.options.vertical = verticalization();
                recompileRzSlider();
            });

            $scope.$watchCollection('input', function (newValue, oldValue) {

                if (newValue !== undefined && newValue.minValue !== oldValue.minValue ) {
                    if(isNaN(newValue.minValue) || newValue.minValue == "" || newValue.minValue == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        $scope.ranSlider.minValue = parseInt(newValue.minValue);
                        $scope.input.value.minValue = $scope.ranSlider.minValue;
                        $rootScope.$broadcast('updateSliderOptions',
                            {
                                property: 'minValue',
                                value: $scope.ranSlider.minValue
                            },
                            {
                                property: 'maxValue',
                                value: parseInt($scope.input.maxValue)
                            });
                    }
                }

                if (newValue !== undefined && newValue.maxValue !== oldValue.maxValue ) {
                    if(isNaN(newValue.maxValue) || newValue.maxValue == "" || newValue.maxValue == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        $scope.ranSlider.maxValue = parseInt(newValue.maxValue);
                        $scope.input.value.maxValue = $scope.ranSlider.maxValue;
                        $rootScope.$broadcast('updateSliderOptions',
                            {
                                property: 'minValue',
                                value: parseInt($scope.input.minValue)
                            },
                            {
                                property: 'maxValue',
                                value: $scope.ranSlider.maxValue
                            });
                    }
                }
                if (newValue !== undefined && newValue.floor !== oldValue.floor) {
                    if (isNaN(newValue.floor) || newValue.floor == "" || newValue.floor == undefined) {
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        $scope.ranSlider.options.floor = parseInt(newValue.floor);
                        $scope.ranSlider.minValue = parseInt($scope.input.minValue);
                        $scope.ranSlider.maxValue = parseInt($scope.input.maxValue);
                        $scope.input.value = {
                            minValue: $scope.ranSlider.minValue,
                            maxValue: $scope.ranSlider.maxValue
                        }
                        var properties = [
                            {
                                property: 'floor',
                                value: $scope.ranSlider.options.floor
                            },
                            {
                                property: 'ceil',
                                value: parseInt($scope.input.ceil)
                            },
                            {
                                property: 'stepsArray',
                                value: null
                            },
                            {
                                property: 'minValue',
                                value: $scope.ranSlider.minValue
                            },
                            {
                                property: 'maxValue',
                                value: $scope.ranSlider.maxValue
                            }
                        ];
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
                        $scope.ranSlider.options.ceil = parseInt(newValue.ceil);
                        var properties = [
                            {
                                property: 'floor',
                                value: parseInt($scope.input.floor)
                            },
                            {
                                property: 'ceil',
                                value: $scope.ranSlider.options.ceil
                            },
                            {
                                property: 'stepsArray',
                                value: null
                            },
                            {
                                property: 'minValue',
                                value: parseInt($scope.input.minValue)
                            },
                            {
                                property: 'maxValue',
                                value: parseInt($scope.input.maxValue)
                            },
                            {
                                property: 'showTicksValues',
                                value: $scope.input.enableLegend
                            }
                        ];
                        $rootScope.$broadcast('updateSliderOptions', properties);
                    }
                }
                if (newValue !== undefined && newValue.step !== oldValue.step) {
                    if (isNaN(newValue.step) || newValue.step == "" || newValue.step == undefined || newValue.step < 0){
                        errorToast('ff.toast.message.errorPositiveNumber');
                    } else {
                        $scope.ranSlider.options.step = newValue.step;
                        if ($scope.input.ticks == false || toBool($scope.input.ticks) == false) {
                            $scope.input.customTicks = newValue.step;
                            $rootScope.$broadcast('updateSliderOptions', {
                                property: 'step',
                                value: $scope.ranSlider.options.step
                            });
                        }
                    }
                }
                if (newValue !== undefined && newValue.customTicks !== oldValue.customTicks){
                    if (isNaN(newValue.customTicks) || newValue.customTicks == "" || newValue.customTicks == undefined || newValue.customTicks < 0){
                        errorToast('ff.toast.message.errorPositiveNumber');
                    } else {
                        $scope.input.customTicks = newValue.customTicks;
                        $scope.ranSlider.options.showTicks = ticksNormalizer();
                        $rootScope.$broadcast('updateSliderOptions', {
                            property: 'showTicks',
                            value: $scope.ranSlider.options.showTicks
                        });
                    }
                }
                if (newValue !== undefined && newValue.translate !== oldValue.translate) {
                    $scope.input.translate = newValue.translate;
                    $rootScope.$broadcast('updateSliderOptions', {
                        property: 'translate',
                        value: $scope.input.translate
                    });
                }

            });

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
                    if (rsic.sliderScope != null){
                        rsic.sliderScope.$destroy();
                        rsic.sliderScope = null;
                        element.empty();
                    }
                    rsic.sliderScope = $scope.$new();
                    var newElement = angular.element(document.createElement('rzslider'));
                    newElement.attr('rz-slider-model', 'ranSlider.minValue').attr('rz-slider-high', 'ranSlider.maxValue').attr('rz-slider-options', 'ranSlider.options');
                    element.html(newElement);
                    $compile(element.contents())(rsic.sliderScope);
                });
            }

            function verticalization() {
                if (toBool($scope.input.vertical) == true || $scope.input.vertical == true) {
                    return $scope.input.vertical;
                } else {
                    return false;
                }
            }

            function ticksNormalizer() {
                if(toBool($scope.input.ticks) == true || $scope.input.ticks == true){
                    return parseInt($scope.input.customTicks);
                } else {
                    return false;
                }
            }

            //func that updates translate option
            $scope.normalizeTranslateOption = function() {
                $scope.ranSlider.options.translate = $scope.getTranslation();
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
                    $scope.ranSlider.options.stepsArray = $scope.stepsArray;
                } else {
                    $scope.input.stepsValues = [];
                    for (var i = $scope.ranSlider.options.floor; i <= $scope.ranSlider.options.ceil; i++) {
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
                $scope.ranSlider.options.stepsArray = $scope.stepsArray;
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
                        property: 'stepsArray',
                        value: $scope.stepsArray
                    },
                    {
                        property: 'minValue',
                        value: parseInt($scope.input.minValue)
                    },
                    {
                        property: 'maxValue',
                        value: parseInt($scope.input.maxValue)
                    }
                ];
                $rootScope.$broadcast('updateSliderOptions', properties);
            }

            function resetLegend() {
                $scope.input.enableLegend = false;
                $scope.ranSlider.options.showTicksValues = toBool($scope.input.enableLegend);
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
                        property: 'stepsArray',
                        value: null
                    },
                    {
                        property: 'minValue',
                        value: parseInt($scope.input.minValue)
                    },
                    {
                        property: 'maxValue',
                        value: parseInt($scope.input.maxValue)
                    },
                    {
                        property: 'translate',
                        value: null
                    }
                ];
                $rootScope.$broadcast('updateSliderOptions', properties);
            }

            //finds the total number of ticks on the slider
            function sizeOfSlider(){
                if ($scope.ranSlider.options.floor <= 0 && $scope.ranSlider.options.ceil >= 0){
                    return Math.abs($scope.ranSlider.options.floor) + Math.abs($scope.ranSlider.options.ceil) + 1;
                } else if ($scope.ranSlider.options.floor < 0 && $scope.ranSlider.options.ceil < 0){
                    return Math.abs($scope.ranSlider.options.floor) - Math.abs($scope.ranSlider.options.ceil) + 1;
                } else {
                    return $scope.ranSlider.options.ceil - $scope.ranSlider.options.floor + 1;
                }
            }

            function toggleLegend() {
                if ($scope.input.enableLegend) {
                    initStepsArray();
                    $scope.ranSlider.options.stepsArray = $scope.stepsArray;
                    $scope.ranSlider.options.showTicksValues = $scope.input.enableLegend;
                    $rootScope.$broadcast('updateSliderOptions', [
                        {
                            property: 'stepsArray',
                            value: $scope.ranSlider.options.stepsArray
                        },
                        {
                            property: 'showTicksValues',
                            value: $scope.ranSlider.options.showTicksValues
                        },
                        {
                            property: 'minValue',
                            value: parseInt($scope.input.minValue)
                        },
                        {
                            property: 'maxValue',
                            value: parseInt($scope.input.maxValue)
                        }
                    ]);
                } else {
                    $scope.stepsArray = null;
                    $scope.ranSlider.options.showTicksValues = $scope.input.enableLegend;
                    $rootScope.$broadcast('updateSliderOptions', [
                        {
                            property: 'stepsArray',
                            value: $scope.stepsArray
                        },
                        {
                            property: 'showTicksValues',
                            value: $scope.ranSlider.options.showTicksValues
                        },
                        {
                            property: 'minValue',
                            value: parseInt($scope.input.minValue)
                        },
                        {
                            property: 'maxValue',
                            value: parseInt($scope.input.maxValue)
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
                $scope.ranSlider.options.stepsArray = $scope.stepsArray;
                $scope.input.legend = tmpLegend;
                $scope.input.stepValues = tmpstepsValues;
                var properties = [
                    {
                        property: 'floor',
                        value: parseInt($scope.input.floor)
                    },
                    {
                        property: 'minValue',
                        value: parseInt($scope.input.minValue)
                    },
                    {
                        property: 'maxValue',
                        value: parseInt($scope.input.maxValue)
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

        RangeSliderInputController.$inject = ['$scope', '$timeout', '$filter', 'toaster', 'i18nService',
                                                '$element', '$document', '$rootScope', '$compile'];
    })();


