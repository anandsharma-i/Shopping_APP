import 'dart:convert';
import 'dart:async';//provides tools for async code(timers etc)

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/http_exception.dart';

class Auth with ChangeNotifier
{
  //token expires after some time.
  String _token,_userId,_email;
  
  //expiry date/time of token
  DateTime _expiryDate;

  //timer for a user to auto log out
  //if times up(token expires)
  Timer _authTimer;

  String get email
  {
    if(_email!=null)
      return _email;
    return null;
  }
  bool get isAuth
  {
    return token!=null;
  }

  String get token
  {
    //if user is authenticated return token
    if(_expiryDate!=null&&_expiryDate.isAfter(DateTime.now())&&_token!=null)
      return _token;

    //else return null      
    return null;  
  }

  String get userId
  {
    return _userId;
  }

  Future<void> _authentication(String email,String password,String urlSegment) async
  {
    final url=Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:$urlSegment?key=AIzaSyABkkY-QE6id2F1giyyt2FJAoq-AUNEopI');

    try
    {
      final response=await http.post
      (
        url,
        body: json.encode
        (
          {
            'email':email,
            'password':password,
            'returnSecureToken':true,
          }
        ),
      );
      final responseData=json.decode(response.body);

      //if there is any error except network error
      if(responseData['error']!=null)
      {
        throw HttpException(responseData['error']['message']);        
      }
      //print(responseData['loacalId']);
      _token=responseData['idToken'];
      _userId=responseData['localId'];
      _email=email;

      //current time + parse_to_int{expiresIn(in secs in string format)} = expiry date
      _expiryDate=DateTime.now().add
      (
        Duration
        (
          seconds:int.parse(responseData['expiresIn']),
        ),
      );
      
      //to create a timer and store in authTime,
      //so that it auto logouts the user
      //after token expires
      _autoLogout();
      notifyListeners();
      
      //setting the on-device storage tunnel 
      final prefs=await SharedPreferences.getInstance();

      //taking the user data map and encoding into json object
      //which inturn is just a string in double quotes  
      final userData=json.encode
      (
        {
          'token':_token,
          'userId':_userId,
          'expiryDate':_expiryDate.toIso8601String(),
        }
      );

      //for writing the data
      prefs.setString('userData', userData);

    }
    catch(e)
    {
      /**
       * catches all network error and
       * error that don't have status codes.
       */
      throw e;
    }        
  }

  Future<void> signup(String email,String password) async
  {
    return _authentication(email, password,'signUp' );
  }
  Future<void> login(String email,String password) async
  {
    return _authentication(email, password,'signInWithPassword' );
  }

  //to checking whether the on device stored token
  //is valid or not
  Future<bool> tryAutoLogin() async
  {
    //setting the on-device storage tunnel 
    final prefs=await SharedPreferences.getInstance();

    //if no user data found
    if(!prefs.containsKey('userData'))
      return false;

    final extractedUserData=json.decode(prefs.getString('userData')) as Map<String,Object>;
    final expiryDate=DateTime.parse(extractedUserData['expiryDate']);

    //if the token is expired
    if(expiryDate.isBefore(DateTime.now()))
      return false;

    //if valid token is found,update all the user data
    //in auth provider class for further login process
    _token=extractedUserData['token'];  
    _userId=extractedUserData['userId'];
    _expiryDate=expiryDate;
    notifyListeners();
    _autoLogout();
    return true;
  }

  //for log out
  Future<void> logout() async
  {
    //resetting the auth provider data
    _token=null;
    _userId=null;
    _expiryDate=null;
    
    //cancel existing timer and reset
    if(_authTimer!=null)
    {
      _authTimer.cancel();
      _authTimer=null;
    }
    notifyListeners();
    final prefs=await SharedPreferences.getInstance();
    
    //for removing the shared preferences data
    //when log out is pressed to ensure
    //we don't auto login after logout
    //.clear removes all pref data
    //and .remove removes specific pref data
    //since in this app we onlt have one pref data
    //.clear is also fine
    //prefs.remove('userData');
    prefs.clear();
  }

  //for auto logout if token expires
  void _autoLogout()
  {
    //cancel existing timer 
    if(_authTimer!=null)
    {
      _authTimer.cancel();
    }
    final timeToExpiry=_expiryDate.difference(DateTime.now()).inSeconds;

    //storing the timer
    _authTimer=Timer
    (
      Duration(seconds: timeToExpiry),
      logout
    );
  }
}