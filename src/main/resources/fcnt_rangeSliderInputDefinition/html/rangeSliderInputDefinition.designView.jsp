<div class="row">
    <div class="col-md-12">
        <div class="row" ng-if="!inTranslateMode">
            <div class="col-md-12">
                <label class="control-label">
                    <span message-key="ff.label.changeInputFieldName"></span>
                </label>
                <input type="text"
                       class="form-control"
                       ng-model="input.name"
                       ff-name-uniqueness-check
                       ff-logics-syncronizer/>
                <span class="help-block hide">
                    <span message-key="angular.ffFormBuilderDirective.message.duplicateInputName"></span>
                </span>
            </div>
        </div>
        <br/>
        <div class="form-group">
            <label>
                <span message-key="ff.label.changeLabel"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.label">
        </div>

        <div class="form-group">
            <label>
                <span message-key="ff.label.changeHelpText"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.helptext">
        </div>

        <div class="form-group">
            <div style="display: inline">
                <label>
                    <span>Vertical</span>
                </label>
            </div>
            <div style="display: inline; padding-left: 20px">
                <switch ng-model="input.vertical"></switch>
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group" ng-class="{'has-error': !isFieldValid('floor')}">
                <label>
                    <span id="floor" message-key="ff.label.floor"></span>
                </label>
                <input type="text"
                       class="form-control"
                       ng-model="input.floor"
                       ng-change="rsic.resetLegend()"
                       ff-field-value-validation="number"
                       field-id="floor">
            </div>
        </div>

        <div class="col-md-3">
            <div class="form-group" ng-class="{'has-error': !isFieldValid('minValue')}">
                <label>
                    <span id="minValue" message-key="ff.label.minValue"></span>
                </label>
                <input type="text"
                       class="form-control"
                       ng-model="input.minValue"
                       ng-disabled="input.enableLegend == true"
                       ff-field-value-validation="number"
                       field-id="minValue">
            </div>
        </div>

        <div class="col-md-3">
            <div class="form-group" ng-class="{'has-error': !isFieldValid('maxValue')}">
                <label>
                    <span id="maxValue" message-key="ff.label.maxValue"></span>
                </label>
                <input type="text"
                       class="form-control"
                       ng-model="input.maxValue"
                       ng-disabled="input.enableLegend == true"
                       ff-field-value-validation="number"
                       field-id="maxValue">
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group" ng-class="{'has-error': !isFieldValid('ceil')}">
                <label>
                    <span id="ceil" message-key="ff.label.ceil"></span>
                </label>
                <input type="text"
                       class="form-control"
                       ng-model="input.ceil"
                       ng-change="rsic.resetLegend()"
                       ff-field-value-validation="number"
                       field-id="ceil">
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group" ng-class="{'has-error': !isFieldValid('step')}">
                <label>
                    <span id="step" message-key="ff.label.step"></span>
                </label>
                <input type="text"
                       class="form-control"
                       ng-model="input.step"
                       ng-disabled="input.enableLegend == true"
                       ff-field-value-validation="positiveNumber"
                       field-id="step">
            </div>
        </div>

        <div class="col-md-6"
             ng-class="{'has-error': !isFieldValid('ticks')}"
             ng-if="input.enableLegend != true">
            <div style="display: inline">
                <label>
                    <span id="ticks" message-key="ff.label.ticks"></span>
                </label>
            </div>
            <div class="col-sm-offset-3" style="display: inline">
                <switch class="float-right" ng-model="input.ticks"></switch>
            </div>
            <input type="text"
                   ng-model="input.customTicks"
                   class="form-control"
                   ng-disabled="input.ticks != true"
                   placeholder="Custom tick variable"
                   ff-field-value-validation="positiveNumber"
                   field-id="ticks">
        </div>

        <div class="col-md-6" ng-if="input.enableLegend == false">

            <div class="form-group" style="position:relative; min-height: 1px; padding-right: 15px; width:25%; float: left">
                <label>
                    <span message-key="ff.label.translate"></span>
                </label>
                <select class="form-control" ng-model="input.translate" ng-change="normalizeTranslateOption()">
                    <option ng-repeat="(key, translateType) in translateTypes" value="{{key}}">{{translateType}}</option>
                </select>
            </div>

            <div class=form-group" style="position:relative; min-height: 1px; padding-right: 15px; width:25%; float: left">
                <label ng-if="input.translate.split('_')[0] == 'currency'">
                    <span message-key="ff.label.currency"></span>
                </label>
                <select class="form-control" ng-model="input.translate" ng-if="input.translate.split('_')[0] == 'currency'">
                    <option ng-repeat="(key, currencyType) in currencyTypes" value="currency_{{key}}">{{currencyType}}</option>
                </select>
            </div>

        </div>

        <div class="col-md-6">
            <div style="display: inline">
                <label>
                    <span>Enable legend</span>
                </label>
            </div>
            <div class="col-sm-offset-3" style="display: inline">
                <switch class="float-right" ng-model="input.enableLegend" ng-change="rsic.toggleLegend()"></switch>
            </div>
        </div>

        <div class="col-md-6" style="background-color: #d8e0f3" ng-if="input.enableLegend == true">
            <div class="form-group" style="position:relative; min-height: 1px; padding-right: 15px; width:33%; float: left; padding-top: 10px">
                <label>
                    <span>Values</span>
                </label>
                <div style="padding-bottom: 10px" ng-repeat="stepValue in input.stepsValues track by $index">
                    <input class="form-control"
                           style="height: 26px"
                           type="text"
                           ng-change="rsic.legendUpdater()"
                           ng-model="stepValue.value">
                </div>

            </div>

            <div class="form-group" style="position:relative; min-height: 1px; padding-right: 15px; width:50%; float: right; padding-top: 10px">
                <label>
                    <span>Legend</span>
                </label>
                <div style="padding-bottom: 10px" ng-repeat="legendValue in input.legend track by $index">
                    <input class="form-control"
                           style="height: 26px"
                           type="text"
                           ng-change="rsic.legendUpdater()"
                           ng-model="legendValue.value">
                </div>
            </div>
        </div>

    </div>
</div>