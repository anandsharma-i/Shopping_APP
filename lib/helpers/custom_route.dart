import 'package:flutter/material.dart';

//custom page transition for specific pages
//(for routes on the fly creation)
class CustomRoute<T> extends MaterialPageRoute<T>
{
  //constructor
  CustomRoute
  (
    {
      WidgetBuilder builder,
      RouteSettings settings,
    }
  ):super(builder: builder,settings: settings);

  //for page transition effect
  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) 
  {    
    //if home page then no transition
    if(settings.name=='/')
      return child;
      
    //else fade transition
    return FadeTransition
    (
      opacity: animation,
      child: child,
    );  
  }
}

//custom page transition for all pages
//(this affects all route transition)
class CustomPageTransition extends PageTransitionsBuilder
{
   //for page transition effect
  @override
  Widget buildTransitions<T>(PageRoute<T> route,BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) 
  {        
    //if home page then no transition
    if(route.settings.name=='/')
      return child;

    //else fade transition  
    return FadeTransition
    (
      opacity: animation,
      child: child,
    );  
  }
}