class FormService{
  String isEmptyField(String value) {
    if (value.isEmpty) {
      return 'Required';
    }
    return null;
  }

  String validatePhoneNumber(String value){
    String isEmpty = isEmptyField(value);
    int len = value.length;

    if(isEmpty != null){
      return isEmpty;
    }
    // else if(len != 10){
    //   return "Mobile Number must be of 10 digits";
    // }
    return null;
  }

  String validateEmail(String value){
    String pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    String isEmpty = isEmptyField(value);

    if(isEmpty != null){
      return isEmpty;
    }
    else if(!regExp.hasMatch(value)){
      return "Invalid Email";
    }
    return null;
  }

  String validatePassword(String value){
    final String isEmpty = isEmptyField(value);
    final pattern = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';

    if (isEmpty != null) {
      return isEmpty;
    } else if (!new RegExp(pattern).hasMatch(value)) {
      return "at least six alphanumeric only, at least one letter and one number";
    }
    return null;
  }
}