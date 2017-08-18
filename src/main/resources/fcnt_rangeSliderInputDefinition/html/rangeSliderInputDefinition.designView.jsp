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
            <div class="form-group" >
                <label>
                    <span message-key="ff.label.minValue"></span>
                </label>
                <input type="text" class="form-control" ng-model="input.minValue">
            </div>
        </div>

        <div class="col-md-6">
            <div class="form-group" >
                <label>
                    <span message-key="ff.label.maxValue"></span>
                </label>
                <input type="text" class="form-control" ng-model="input.maxValue">
            </div>
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

    </div>
</div>