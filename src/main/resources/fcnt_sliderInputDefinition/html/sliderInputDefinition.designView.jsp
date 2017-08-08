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

        <div class="form-group" >
        <label>
            <span message-key="ff.label.initValue"></span>
        </label>
        <input type="text" class="form-control" ng-model="input.initValue">
        </div>

        <div class="form-group">
            <label>
                <span message-key="ff.label.minValue"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.floor">
        </div>

        <div class="form-group">
            <label>
                <span message-key="ff.label.maxValue"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.ceil">
        </div>

        <div class="form-group">
            <label>
                <span message-key="ff.label.step"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.step">
        </div>

        <div class="form-group text-left">
            <label>
                <span message-key="ff.label.ticks"></span>
            <switch class="form-control" ng-model="input.ticks"></switch>
            </label>
        </div>

        <div class="form-group">
            <label>
                <span message-key="ff.label.translate"></span>
            </label>

            <select ng-model="input.translate" ng-change="normalizeTranslateOption()">
                <option ng-repeat="(key, translateType) in translateTypes" value="{{key}}">{{translateType}}</option>
            </select>
            <label ng-if="input.translate.split('_')[0] == 'currency'">
                <span message-key="ff.label.currency"></span>
                <select ng-model="input.translate">
                    <option ng-repeat="(key, currencyType) in currencyTypes" value="currency_{{key}}">{{currencyType}}</option>
                </select>
            </label>

        </div>
    </div>
</div>