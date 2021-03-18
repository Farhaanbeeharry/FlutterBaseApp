import 'package:driver/Common/Classes/BaseClass.dart';

class StateMonitor {
  //View intances
  static Map<InstanceNames, List<View>> _viewInstances = {};
  static dynamic _getViewInstance<T extends View>(InstanceNames instanceName, [String instanceID]) {
    var instances = _viewInstances[instanceName];
    if(instanceID == null){
      if(instances == null) {return false;}
      else{
        List<T> ins = instances.cast<T>();
        return ins;
      }
    }else{
      if(instances == null){
        return false;
      }else{
        instances.forEach((instance) {
          if(instance.id == instanceID) return instance;
        });
        return false;
      }
    }

  }

  static void safelyGetAllViewInstances<T extends View>(
      InstanceNames instanceName, Function(List<T>) callback) {
    var ins = _viewInstances[instanceName];
    if (ins != null) {
      List<T> instances = ins.cast<T>();
      callback(instances);
    }
  }

  static void safelyGetViewInstance<T extends View>(
      InstanceNames instanceName, String id, Function(T) callback) {
    var ins = _viewInstances[instanceName];
    if (ins != null) {
      List<T> instances = ins.cast<T>();
      instances.forEach((instance) {
        if(instance.id == id) callback(instance);
      });
    }
  }

  static bool addViewInstance(InstanceNames instanceName, View instance) {
    // returns true if overridden
    var exists = _getViewInstance(instanceName, instance.id);
    if(!_viewInstances.containsKey(instanceName)) _viewInstances[instanceName] = [];
    _viewInstances[instanceName].add(instance);
    return exists != false;
  }

  static bool removeViewInstance(InstanceNames instanceName, View instance) {
    // returns true if removed
    var exists = _getViewInstance(instanceName, instance.id);
    if (exists != false) {
      _viewInstances.remove(instanceName);
      return true;
    } else {
      return false;
    }
  }
}

enum InstanceNames {
  AppScreen,
  LoginScreen,
  MapScreen,
  ConfirmPinScreen,
  SetUpPinScreen,
  MySchedulesScreen,
  MyLocationScreen,
  DashboardScreen,
  PasswordFormField,
  RegisterScreenBody,
  Clock
}
