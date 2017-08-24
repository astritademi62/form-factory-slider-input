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

            //initial value of minSlider object
            $scope.minSlider = {
                options: {
                    floor: parseInt($scope.input.floor),
                    ceil: parseInt($scope.input.ceil),
                    step: $scope.input.step,
                    showTicks: ticksNormalizer(),
                    showSelectionBarFromValue: parseInt($scope.input.initValue),
                    readOnly: $scope.readOnly,
                    translate: null
                }
            }

            //It works now, but you have to recompile to see it update in builder mode.
            sic.$onInit = function () {
                //init show ticks switch
                $scope.input.ticks = toBool($scope.input.ticks);
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
                    if (!isNaN(newValue.initValue)){
                        $scope.input.value = parseInt(newValue.initValue);
                        $scope.minSlider.options.showSelectionBarFromValue = parseInt(newValue.initValue);
                    } else {
                        errorToast();
                    }
                }
                if (newValue !== undefined && newValue.floor !== oldValue.floor) {
                    if (!isNaN(newValue.floor)){
                        $scope.minSlider.options.floor = parseInt(newValue.floor);
                        $scope.minSlider.options.showSelectionBarFromValue = parseInt($scope.input.initValue);
                        $scope.input.value = parseInt($scope.input.initValue);
                    } else {
                        errorToast();
                    }
                }
                if (newValue !== undefined && newValue.ceil !== oldValue.ceil) {
                    if (!isNaN(newValue.ceil)){
                        $scope.minSlider.options.ceil = parseInt(newValue.ceil);
                    } else {
                        errorToast();
                    }
                }
                if (newValue !== undefined && newValue.step !== oldValue.step) {
                    if (!isNaN(newValue.step)){
                        $scope.minSlider.options.step = newValue.step;
                    } else {
                        errorToast();
                    }
                }
                if (newValue !== undefined && newValue.translate !== oldValue.translate) {
                    oldValue.translate = newValue.translate;
                    $scope.$broadcast('rzSliderForceRender');
                }
                if (newValue !== undefined && newValue.customTicks !== oldValue.customTicks){
                    if (!isNaN(newValue.customTicks)){
                        $scope.input.customTicks = newValue.customTicks;
                        $scope.minSlider.options.showTicks = ticksNormalizer();
                    } else {
                        errorToast();
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

            function errorToast() {
                $timeout(function() {
                    toaster.pop({
                        type: 'error',
                        title: i18n.message('ff.toast.title.invalidInput'),
                        body: i18n.message('ff.toast.message.errorMessage'),
                        toastId: 'rsic',
                        timeout: 4000
                    });
                });
            }
        }

        SliderInputController.$inject = ['$scope', '$timeout', '$filter', 'i18nService', '$element', '$document', 'toaster'];
    })();


