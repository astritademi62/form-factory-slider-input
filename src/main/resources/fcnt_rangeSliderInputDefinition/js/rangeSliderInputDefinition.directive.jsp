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
                        minValue : parseInt(scope.input.minRange),
                        maxValue : parseInt(scope.input.maxRange)
                    }

                } else {
                    scope.input.value = {
                        minValue : parseInt(scope.input.minRange),
                        maxValue : parseInt(scope.input.maxRange)
                    }
                }
            }
        };
        angular.module('formFactory')
            .directive('ffRangeSliderInput', ['ffTemplateResolver', rangeSliderInput]);

        var RangeSliderInputController = function ($scope, $timeout, $filter,
                                              i18n, $element, $document){
            var rsic = this;

            rsic.$onInit = function() {
                $scope.input.ticks = toBool($scope.input.ticks);
            }

            rsic.parsed = {};
            rsic.i18nMessageGetter = i18n.message;

            rsic.minSlider = {
                minValue: parseInt($scope.input.minRange),
                maxValue: parseInt($scope.input.maxRange),
                options: {
                    floor: parseInt($scope.input.floor),
                    ceil: parseInt($scope.input.ceil),
                    step: $scope.input.step,
                    showTicks: toBool($scope.input.ticks),
                    showSelectionBar: true
                }
            }

            $scope.$watch(function() {
                return $scope.input.ticks;
            }, function(value) {
                rsic.minSlider.options.showTicks = value;
            });

            $scope.$watchCollection('input', function (newValue, oldValue) {
                if (newValue !== undefined && newValue.minRange !== oldValue.minRange ){
                    rsic.minSlider.minValue = parseInt(newValue.minRange);
                    $scope.input.value.minValue = rsic.minSlider.minValue;
                }
                if (newValue !== undefined && newValue.maxRange !== oldValue.maxRange ){
                    rsic.minSlider.maxValue = parseInt(newValue.maxRange);
                    $scope.input.value.maxValue = rsic.minSlider.maxValue;
                }
                if (newValue !== undefined && newValue.floor !== oldValue.floor) {
                    rsic.minSlider.options.floor = parseInt(newValue.floor);
                    rsic.minSlider.minValue = parseInt($scope.input.minRange);
                    rsic.minSlider.maxValue = parseInt($scope.input.maxRange);
                    $scope.input.value = {
                        minValue: rsic.minSlider.minValue,
                        maxValue: rsic.minSlider.maxValue
                    }
                }
                if (newValue !== undefined && newValue.ceil !== oldValue.ceil) {
                    rsic.minSlider.options.ceil = parseInt(newValue.ceil);
                }
                if (newValue !== undefined && newValue.step !== oldValue.step) {
                    rsic.minSlider.options.step = newValue.step;
                }
            });

            if ($element.hasClass('rz-slider-model')) {
                $element.show();
            }

            function toBool(value) {
                if (typeof value === 'boolean') {
                    return value;
                }
                else {
                    return value === 'true';
                }
            }

        }

        RangeSliderInputController.$inject = ['$scope', '$timeout', '$filter', 'i18nService', '$element', '$document'];
    })();


