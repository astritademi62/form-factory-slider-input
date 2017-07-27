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

                if (isNaN(scope.input.value) || scope.input.value == undefined) {
                    //set initial min and max range values
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
                options: {
                    floor: parseInt($scope.input.minValue),
                    ceil: parseInt($scope.input.maxValue),
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
                    $scope.input.value.minValue = parseInt(newValue.minRange);
                }
                if (newValue !== undefined && newValue.maxRange !== oldValue.maxRange ){
                    $scope.input.value.maxValue = parseInt(newValue.maxRange);
                }
                if (newValue !== undefined && newValue.minValue !== oldValue.minValue) {
                    rsic.minSlider.options.floor = parseInt(newValue.minValue);
                    $scope.input.value = {
                        minValue: parseInt($scope.input.minRange),
                        maxValue: parseInt($scope.input.maxRange)
                    }
                }
                if (newValue !== undefined && newValue.maxValue !== oldValue.maxValue) {
                    rsic.minSlider.options.ceil = parseInt(newValue.maxValue);
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


