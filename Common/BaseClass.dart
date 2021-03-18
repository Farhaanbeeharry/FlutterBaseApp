import 'dart:async';

import 'package:driver/Common/Classes/common.dart';
import 'package:driver/Common/Classes/stateMonitor.dart';
import 'package:flutter/material.dart';

abstract class Controller {
  BuildContext context;
  View view;
  Map<String, dynamic> widget;
  bool ready = false;

  getWidget(String name) {
    return widget[name] == null ? false : widget[name];
  }

  onInit() {}
  initState() async {}

  onReady(callback) {
    if (this.ready)
      callback();
    else {
      new Timer(new Duration(milliseconds: 100), () => {onReady(callback)});
    }
  }
}

mixin View<T extends StatefulWidget> on State<T> {
  Controller viewController;
  bool _disposed = false;
  bool _ready = false;
  List<dynamic> callbacks = [];
  String id;

  _init([Map<String, dynamic> widgets]) {
    viewController.view = this;
    viewController.widget = widgets;
    this.viewController.ready = true;
    _addInstance(getName());
  }

  _addInstance(InstanceNames instanceName) {
    StateMonitor.addViewInstance(instanceName, this);
  }

  InstanceNames
      getName(); // override to the name of that instance of the object
  Widget getBody(); // the widget that comprises the main view
  Controller getController(); // the controller for that view
  Map<String, dynamic> getWidget() {
    // make the parameters passed to the widget accessible
    // override to return your own.. see example at passwordFormField
    return null;
  }

  @override
  void initState() {
    super.initState();
    this.viewController = this.getController();
    this.id = Common.generate(25);
    this._ready = true;
    this._checkSetStateQueue();
    this.viewController.initState();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
    StateMonitor.removeViewInstance(getName(), this);
  }

  @override
  Widget build(BuildContext context) {
    this._init(this.getWidget());
    this.viewController.context = context;
    this.viewController.onInit();
    return this.getBody();
  }

  callSetState(callback) {
    if (!this._disposed) {
      if (!this._ready) {
        this.callbacks.add(callback);
      } else {
        setState(() => {if (callback != null) callback()});
        this._checkSetStateQueue();
      }
    }
  }

  _checkSetStateQueue() {
    if (!this._ready) return;

    if (this.callbacks.length > 0) {
      setState(() {
        for (var callback in this.callbacks) if (callback != null) callback();
      });
    }
  }
}
