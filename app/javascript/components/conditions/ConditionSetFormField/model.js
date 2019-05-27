import { observable, action, reaction } from 'mobx';

import ConditionModel from './ConditionFormField/model';

/**
 * Represents a set of conditions (e.g. ['Question Foo' Equals 'Bar', ...]).
 */
class ConditionSetModel {
  @observable
  formId;

  @observable
  namePrefix;

  @observable
  originalConditions = [];

  @observable
  conditions = [];

  @observable
  conditionableId;

  @observable
  conditionableType;

  @observable
  refableQings = [];

  @observable
  hide;

  /** If enabled, only allow 'equals' or 'includes' as the operation. */
  @observable
  forceEqualsOp = false;

  constructor(initialValues = {}) {
    Object.assign(this, initialValues);

    // Make sure conditions are always instances of the model.
    // TODO: MobX-state-tree can do this automatically for us.
    reaction(
      () => this.originalConditions,
      (originalConditions) => {
        this.originalConditions = this.mapConditionsToStores(originalConditions);
      },
      { fireImmediately: true },
    );
    reaction(
      () => this.conditions,
      (conditions) => {
        this.conditions = this.mapConditionsToStores(conditions);
      },
      { fireImmediately: true },
    );

    // If about to show the set and it's empty, add a blank condition.
    reaction(
      () => this.hide,
      (hide) => {
        if (!hide) {
          this.handleAddBlankCondition();
        }
      },
      { fireImmediately: true },
    );
  }

  mapConditionsToStores(conditions) {
    // Only modify if necessary to prevent a cycle.
    if (conditions.some((condition) => !(condition instanceof ConditionModel))) {
      return conditions.map((condition) => new ConditionModel(condition));
    }
    return conditions;
  }

  @action
  handleAddClick = () => {
    this.conditions.push(new ConditionModel({
      key: Math.round(Math.random() * 100000000),
    }));
  }

  @action
  handleAddBlankCondition = () => {
    if (this.conditions.length === 0) {
      this.handleAddClick();
    }
  }
}

export default ConditionSetModel;