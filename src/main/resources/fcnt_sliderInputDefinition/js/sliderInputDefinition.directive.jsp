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
            }
        };
        angular.module('formFactory')
            .directive('ffSliderInput', ['ffTemplateResolver', '$log', '$injector', sliderInput]);

        var SliderInputController = function ($scope, $timeout, $filter,
                                              i18n, $element, $document, toaster) {
            var sic = this;
            sic.parsed = {};
            sic.i18nMessageGetter = i18n.message;
            sic.resetLegend = resetLegend;
            sic.toggleLegend = toggleLegend;
            sic.legendUpdater = legendUpdater;
            sic.sizeOfSlider = sizeOfSlider;

            $scope.translateTypes = {                 // these are the translate options
                default : 'Default',
                currency_$: 'Currency',
                percentage: 'Percentage'
            };
            $scope.currencyTypes = {                  // [ "$", "£", "€" ] these are the currency types for the currency translation option
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
                    showTicks: ticksNormalizer(),
                    showSelectionBarFromValue: parseInt($scope.input.initValue),
                    readOnly: $scope.readOnly,
                    translate: null,
                    stepsArray: null
                }
            }

            //It works now, but you have to recompile to see it update in builder mode.
            sic.$onInit = function () {
                //init show ticks switch
                $scope.input.ticks = toBool($scope.input.ticks);
                $scope.input.enableLegend = toBool($scope.input.enableLegend);
                // on init if ticks are disabled the default ticks value should equal the steps value
                if ($scope.input.ticks == false) {
                    $scope.input.customTicks = $scope.input.step;
                }
                //If selectedType is not set, then set it to default
                $scope.input.translate = $scope.input.translate ? $scope.input.translate : 'default';

                $scope.normalizeTranslateOption();
            }

            $scope.$watch(function() {
                return $scope.input.ticks;
            }, function(value) {
                $scope.input.ticks = value;
                $scope.minSlider.options.showTicks = ticksNormalizer();
            });

            // watch input options for the minSlider object and overwrite the old values with the new values
            $scope.$watchCollection('input', function (newValue, oldValue) {
                if (newValue !== undefined && newValue.initValue !== oldValue.initValue) {
                    if (isNaN(newValue.initValue) || newValue.initValue == "" || newValue.initValue == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        $scope.input.value = parseInt(newValue.initValue);
                        $scope.minSlider.options.showSelectionBarFromValue = parseInt(newValue.initValue);
                    }
                }
                if (newValue !== undefined && newValue.floor !== oldValue.floor) {
                    if (isNaN(newValue.floor) || newValue.floor == "" || newValue.floor == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        $scope.minSlider.options.floor = parseInt(newValue.floor);
                        $scope.minSlider.options.showSelectionBarFromValue = parseInt($scope.input.initValue);
                        $scope.input.value = parseInt($scope.input.initValue);
                        if (!$scope.input.enableLegend) {
                            $scope.$broadcast('rzSliderForceRender');
                        }
                    }
                }
                if (newValue !== undefined && newValue.ceil !== oldValue.ceil) {
                    if (isNaN(newValue.ceil) || newValue.ceil == "" || newValue.ceil == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        $scope.minSlider.options.ceil = parseInt(newValue.ceil);
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
                    }
                }
                if (newValue !== undefined && newValue.translate !== oldValue.translate) {
                    oldValue.translate = newValue.translate;
                    $scope.$broadcast('rzSliderForceRender');
                }
                if (newValue !== undefined && newValue.customTicks !== oldValue.customTicks){
                    if (isNaN(newValue.customTicks) || newValue.customTicks == "" || newValue.customTicks == undefined || newValue.customTicks < 0){
                        errorToast('ff.toast.message.errorPositiveNumber');
                    } else {
                        $scope.input.customTicks = newValue.customTicks;
                        $scope.minSlider.options.showTicks = ticksNormalizer();
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

            function resetLegend() {
                $scope.input.enableLegend = false;
                $scope.input.legend = [];
                $scope.input.stepsValues = [];
                $scope.minSlider.options.stepsArray = null;
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
                var tmpstepVals = [];
                for (var i = $scope.minSlider.options.floor; i <= $scope.minSlider.options.ceil; i++) {
                    tmpstepVals.push(i);
                }
                for (var j = 0; j < sizeOfSlider(); j++) {
                    $scope.input.legend[j] = {value: ''};
                    $scope.input.stepsValues[j] = {value: tmpstepVals[j]};
                }
                if ($scope.input.enableLegend) {
                    $scope.stepsArray = [];

                    console.log($scope.input.legend);
                    for (var j = 0; j < sizeOfSlider(); j++) {
                        $scope.stepsArray.push({
                            value: parseInt($scope.input.stepsValues[j].value),
                            legend: $scope.input.legend[j].value
                        });
                    }
                    $scope.minSlider.options.stepsArray = $scope.stepsArray;
                    $scope.$broadcast('rzSliderForceRender');
                }
            }

            function legendUpdater() {
                var tmpLegend = angular.copy($scope.input.legend);
                var tmpstepsValues = angular.copy($scope.input.stepsValues);
                $scope.stepsArray = [];

                for (var j = 0; j < sizeOfSlider(); j++) {
                    $scope.stepsArray.push({
                        value: parseInt(tmpstepsValues[j].value),
                        legend: tmpLegend[j].value
                    });
                }
                $scope.minSlider.options.stepsArray = $scope.stepsArray;
                $scope.input.legend = tmpLegend;
                $scope.input.stepValues = tmpstepsValues;
                $scope.$broadcast('rzSliderForceRender');
            }

            function errorToast(errorMsg) {
                $timeout(function() {
                    toaster.pop({
                        type: 'error',
                        title: i18n.message('ff.toast.title.invalidInput'),
                        body: i18n.message(errorMsg),
                        toastId: 'rsic',
                        timeout: 3000
                    });
                });
            }
        }

        SliderInputController.$inject = ['$scope', '$timeout', '$filter', 'i18nService', '$element', '$document', 'toaster'];
    })();



