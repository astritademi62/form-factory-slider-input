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
            <label>
                <span message-key="ff.label.startValue"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.startValue">
        </div>
        <div class="form-group">
            <label>
                <span message-key="ff.label.endValue"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.endValue">
        </div>
        <div class="form-group">
            <label>
                <span message-key="ff.label.step"></span>
            </label>
            <input type="text" class="form-control" ng-model="input.step">
        </div>
        <%--<div class="form-group">--%>
            <%--<label>--%>
                <%--<span message-key="ff.label.close.popup"></span>--%>
            <%--</label>--%>
            <%--<input type="text" class="form-control" ng-model="input.closePopupLabel">--%>
        <%--</div>--%>
        <%--<div class="checkbox">--%>
            <%--<label>--%>
                <%--<input type="checkbox" ng-model="input.displayInPopup" ng-true-value="'true'" ng-false-value="'false'">--%>
                <%--<span message-key="ff.label.display.in.popup"></span>--%>
            <%--</label>--%>
        <%--</div>--%>
        <%--<div class="checkbox">--%>
            <%--<label>--%>
                <%--<input type="checkbox" ng-model="input.enforceReading" ng-true-value="'true'" ng-false-value="'false'">--%>
                <%--<span message-key="ff.label.enforce.reading"></span>--%>
            <%--</label>--%>
        <%--</div>--%>
        <%--<div id="fic_imagePicker"></div>--%>
    </div>
</div>