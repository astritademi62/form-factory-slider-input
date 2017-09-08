

<div class="form-group"
     ng-class="{'has-error': form[input.name].$invalid&&form[input.name].$dirty}"
     ng-show="resolveLogic()">
    <label class="col-sm-2 control-label">
        {{input.label}}
        <span ng-if="isRequired()"
              ng-show="form.$dirty">
            <sup>&nbsp;<i class="fa fa-asterisk fa-sm"></i></sup>
        </span>
    </label>
    <div class="col-sm-10" ff-validations ff-logic>
            <input type="hidden"
                   name="{{input.name}}"
                   ng-required="isRequired()"
                   ng-model="input.value"
                   ng-model-options="{'allowInvalid':true}">
        <div class="slider" style="{{returnDivHeight()}}">
            <rzslider rz-slider-model="input.value" rz-slider-options="minSlider.options"></rzslider>
        </div>
        <div style="padding-top: 10px">
            <span class="help-block"
                  ng-show="input.helptext != undefined">
            {{input.helptext}}
        </span>
        </div>

        <span class="help-block"
              ng-repeat="(validationName, validation) in input.validations"
              ng-show="form[input.name].$error[(validationName | normalize)]&&form[input.name].$dirty">
                {{validation.message}}
        </span>
    </div>
    <div class="clearfix"/>
</div>