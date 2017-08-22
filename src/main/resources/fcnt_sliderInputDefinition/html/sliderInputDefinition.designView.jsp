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

        <div class="col-md-6">
            <div class="form-group">
                <label>
                    <span message-key="ff.label.floor"></span>
                </label>
                <input type="text" class="form-control" ng-model="input.floor">
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group" >
                <label>
                    <span message-key="ff.label.initValue"></span>
                </label>
                <input type="text" class="form-control" ng-model="input.initValue">
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group">
                <label>
                    <span message-key="ff.label.ceil"></span>
                </label>
                <input type="text" class="form-control" ng-model="input.ceil">
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group">
                <label>
                    <span message-key="ff.label.step"></span>
                </label>
                <input type="text" class="form-control" ng-model="input.step">
            </div>
        </div>

        <div class="col-md-6">
            <div style="display: inline">
                <label>
                    <span message-key="ff.label.ticks"></span>
                </label>
            </div>
            <div class="col-sm-offset-3" style="display: inline">
                <switch class="float-right" ng-model="input.ticks"></switch>
            </div>
            <input type="text"
                   ng-model="input.customTicks"
                   class="form-control"
                   ng-disabled="input.ticks != true"
                   placeholder="Custom tick variable">
        </div>

        <div class="col-md-6">
            <div style="position:relative; min-height: 1px; padding-right: 15px; width:25%; float: left">
                <label>
                    <span message-key="ff.label.translate"></span>
                </label>
                <select class="form-control" ng-model="input.translate" ng-change="normalizeTranslateOption()">
                    <option ng-repeat="(key, translateType) in translateTypes" value="{{key}}">{{translateType}}</option>
                </select>
            </div>

            <div style="position:relative; min-height: 1px; padding-right: 15px; width:25%; float: left">
                <label ng-if="input.translate.split('_')[0] == 'currency'">
                    <span message-key="ff.label.currency"></span>
                </label>
                <select class="form-control" ng-model="input.translate" ng-if="input.translate.split('_')[0] == 'currency'">
                    <option ng-repeat="(key, currencyType) in currencyTypes" value="currency_{{key}}">{{currencyType}}</option>
                </select>
            </div>
        </div>
    </div>

    </div>
</div>