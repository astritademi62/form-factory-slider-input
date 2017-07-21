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

        }
    };
    angular.module('formFactory')
        .directive('ffSliderInput', ['ffTemplateResolver', sliderInput]);

    var SliderInputController = function ($scope, $timeout, $filter,
                                          i18n, $element, $document){
        var sic = this;
        sic.parsed = {};
        sic.i18nMessageGetter = i18n.message;

        sic.minSlider = {
            value: 1,
            options: {
                floor: 0,
                ceil: 100,
                step: 1,
                showSelectionBar: true
            }
        }

        $scope.$watchCollection('input', function (newValue, oldValue) {
            if (newValue !== undefined && newValue.startValue !== oldValue.startValue) {
                sic.minSlider.options.floor = parseInt(newValue.startValue);
            }
            if (newValue !== undefined && newValue.endValue !== oldValue.endValue) {
                sic.minSlider.options.ceil = parseInt(newValue.endValue);
            }
            if (newValue !== undefined && newValue.step !== oldValue.step) {
                sic.minSlider.options.step = parseInt(newValue.step);
            }
        });

        if ($element.hasClass('rz-slider-model')) {
            $element.show();
        }

    }

    SliderInputController.$inject = ['$scope', '$timeout', '$filter', 'i18nService', '$element', '$document'];
})();


