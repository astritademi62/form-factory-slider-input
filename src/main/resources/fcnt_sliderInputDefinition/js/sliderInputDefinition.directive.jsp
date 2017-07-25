<%@ page contentType="text/javascript" %>
<%@ taglib prefix="formfactory" uri="http://www.jahia.org/formfactory/functions" %>
<%@ taglib prefix="jcr" uri="http://www.jahia.org/tags/jcr"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="functions" uri="http://www.jahia.org/tags/functions" %>


(function (){
    var sliderInput = function (ffTemplateResolver) {
        return {
            restrict: 'E',
            require: ['^ffController'],
            controller: SliderInputController,
            controllerAs: 'sic',
            bindToController: true,
            templateUrl: function(el, attrs) {
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
        .directive('ffSliderInput', ['ffTemplateResolver', sliderInput]);

    var SliderInputController = function ($scope, $timeout, $filter,
                                          i18n, $element, $document){
        var sic = this;

        sic.$onInit = function() {
            $scope.input.ticks = toBool($scope.input.ticks);
        }

        sic.parsed = {};
        sic.i18nMessageGetter = i18n.message;

        sic.minSlider = {
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

            sic.minSlider.options.showTicks = value;

        });

        $scope.$watchCollection('input', function (newValue, oldValue) {
            if (newValue !== undefined && newValue.initValue !== oldValue.initValue ){
                $scope.input.value = parseInt(newValue.initValue);
            }
            if (newValue !== undefined && newValue.minValue !== oldValue.minValue) {
                sic.minSlider.options.floor = parseInt(newValue.minValue);
                $scope.input.value = parseInt($scope.input.initValue);
            }
            if (newValue !== undefined && newValue.maxValue !== oldValue.maxValue) {
                sic.minSlider.options.ceil = parseInt(newValue.maxValue);
            }
            if (newValue !== undefined && newValue.step !== oldValue.step) {
                sic.minSlider.options.step = newValue.step;
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

    SliderInputController.$inject = ['$scope', '$timeout', '$filter', 'i18nService', '$element', '$document'];
})();


