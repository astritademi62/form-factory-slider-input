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
            }
        };
        angular.module('formFactory')
            .directive('ffRangeSliderInput', ['ffTemplateResolver', rangeSliderInput]);

        var RangeSliderInputController = function ($scope, $timeout, $filter, toaster,
                                              i18n, $element, $document){
            var rsic = this;

            rsic.$onInit = function() {
                $scope.input.ticks = toBool($scope.input.ticks);

                // on init if ticks are disabled the default ticks value should equal the steps value
                if ($scope.input.ticks == false) {
                    $scope.input.customTicks = $scope.input.step;
                }
                //If selectedType is not set, then set it to default
                $scope.input.translate = $scope.input.translate ? $scope.input.translate : 'default';

                $scope.normalizeTranslateOption();
            }

            rsic.parsed = {};
            rsic.i18nMessageGetter = i18n.message;

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

            rsic.minSlider = {
                minValue: parseInt($scope.input.minValue),
                maxValue: parseInt($scope.input.maxValue),
                options: {
                    floor: parseInt($scope.input.floor),
                    ceil: parseInt($scope.input.ceil),
                    step: $scope.input.step,
                    showTicks: ticksNormalizer(),
                    showSelectionBar: true,
                    readOnly: $scope.readOnly,
                    translate: null
                }
            }

            $scope.$watch(function() {
                return rsic.minSlider.minValue;
            }, function(value) {
                $scope.input.value.minValue = value;
            });

            $scope.$watch(function() {
                return rsic.minSlider.maxValue;
            }, function(value) {
                $scope.input.value.maxValue = value;
            });

            $scope.$watch(function() {
                return $scope.input.ticks;
            }, function(value) {
                $scope.input.ticks = value;
                rsic.minSlider.options.showTicks = ticksNormalizer();
            });

            $scope.$watchCollection('input', function (newValue, oldValue) {

                if (newValue !== undefined && newValue.minValue !== oldValue.minValue ) {
                    if(isNaN(newValue.minValue) || newValue.minValue == "" || newValue.minValue == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        rsic.minSlider.minValue = parseInt(newValue.minValue);
                        $scope.input.value.minValue = rsic.minSlider.minValue;
                    }
                }

                if (newValue !== undefined && newValue.maxValue !== oldValue.maxValue ) {
                    if(isNaN(newValue.maxValue) || newValue.maxValue == "" || newValue.maxValue == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        rsic.minSlider.maxValue = parseInt(newValue.maxValue);
                        $scope.input.value.maxValue = rsic.minSlider.maxValue;
                    }
                }
                if (newValue !== undefined && newValue.floor !== oldValue.floor) {
                    if (isNaN(newValue.floor) || newValue.floor == "" || newValue.floor == undefined) {
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        rsic.minSlider.options.floor = parseInt(newValue.floor);
                        rsic.minSlider.minValue = parseInt($scope.input.minValue);
                        rsic.minSlider.maxValue = parseInt($scope.input.maxValue);
                        $scope.input.value = {
                            minValue: rsic.minSlider.minValue,
                            maxValue: rsic.minSlider.maxValue
                        }
                    }
                }
                if (newValue !== undefined && newValue.ceil !== oldValue.ceil) {
                    if (isNaN(newValue.ceil) || newValue.ceil == "" || newValue.ceil == undefined){
                        errorToast('ff.toast.message.errorNumber');
                    } else {
                        rsic.minSlider.options.ceil = parseInt(newValue.ceil);
                    }
                }
                if (newValue !== undefined && newValue.step !== oldValue.step) {
                    if (isNaN(newValue.step) || newValue.step == "" || newValue.step == undefined || newValue.step < 0){
                        errorToast('ff.toast.message.errorPositiveNumber');
                    } else {
                        rsic.minSlider.options.step = newValue.step;
                        if ($scope.input.ticks == false || toBool($scope.input.ticks) == false) {
                            $scope.input.customTicks = newValue.step;
                        }
                    }
                }
                if (newValue !== undefined && newValue.customTicks !== oldValue.customTicks){
                    if (isNaN(newValue.customTicks) || newValue.customTicks == "" || newValue.customTicks == undefined || newValue.customTicks < 0){
                        errorToast('ff.toast.message.errorPositiveNumber');
                    } else {
                        $scope.input.customTicks = newValue.customTicks;
                        rsic.minSlider.options.showTicks = ticksNormalizer();
                    }
                }
                if (newValue !== undefined && newValue.translate !== oldValue.translate) {
                    $scope.input.translate = newValue.translate;
                    $scope.$broadcast('rzSliderForceRender');
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

            function ticksNormalizer() {
                if(toBool($scope.input.ticks) == true || $scope.input.ticks == true){
                    return parseInt($scope.input.customTicks);
                } else {
                    return false;
                }
            }

            //func that updates translate option
            $scope.normalizeTranslateOption = function() {
                rsic.minSlider.options.translate = $scope.getTranslation();
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

        RangeSliderInputController.$inject = ['$scope', '$timeout', '$filter', 'toaster', 'i18nService', '$element', '$document'];
    })();


