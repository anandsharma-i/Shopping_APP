import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../widgets/app_drawer.dart' as ad;
import '../models/http_exception.dart';

enum AuthMode 
{
   Signup, 
   Login 
}

class AuthScreen extends StatelessWidget 
{
  static const routeName = '/auth';

  @override
  Widget build(BuildContext context) 
  {
    final deviceSize = MediaQuery.of(context).size;
    // final transformConfig = Matrix4.rotationZ(-8 * pi / 180);
    // transformConfig.translate(-10.0);
    return Scaffold
    (
      // resizeToAvoidBottomInset: false,
      body: GestureDetector
      (
        onTap: ()=>FocusScope.of(context).requestFocus(FocusNode()),
        child: Stack
        (
          children: <Widget>
          [
            //background color of the user authentication screen.
            Container
            (
              decoration: BoxDecoration
              (
                gradient: LinearGradient
                (
                  colors: 
                  [
                    Color.fromRGBO(215, 117, 255, 1).withOpacity(0.5),
                    Color.fromRGBO(255, 188, 117, 1).withOpacity(0.9),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: [0, 1],
                ),
              ),
            ),
            SingleChildScrollView
            (
              child: Container
              (
                //for taking whole device height and width
                height: deviceSize.height,
                width: deviceSize.width,

                //authentication card and MyShop logo
                child: Column
                (
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>
                  [
                    //MyShop logo
                    Flexible
                    (
                      child: Container
                      (
                        margin: EdgeInsets.only(bottom: 20.0),
                        padding:
                            EdgeInsets.symmetric(vertical: 8.0, horizontal: 94.0),
      
                        //for sp 3d tranformation effect
                        //tranlate is used for offset and rotationZ 
                        //for rotation of widget around z-axis given angle in radians    
                        //.. operator allows the 2nd last o/p to be the
                        //final o/p of the entire chain and last func can be
                        //called with the given obj itself.
                        transform: Matrix4.rotationZ(-8 * pi / 180)
                          ..translate(-10.0),
                        // ..translate(-10.0),
                        decoration: BoxDecoration
                        (
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.cyan,
                          boxShadow: 
                          [
                            BoxShadow
                            (
                              blurRadius: 8,
                              color: Colors.black26,
                              offset: Offset(0, 2),
                            )
                          ],
                        ),
                        child: Text
                        (
                          'MyShop',
                          style: TextStyle
                          (
                            color: Theme.of(context).accentTextTheme.title.color,
                            fontSize: 50,
                            fontFamily: 'Anton',
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ),
                    ),

                    //authentication card
                    Flexible
                    (
                      flex: deviceSize.width > 600 ? 2 : 1,
                      child: AuthCard(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

//responsible for displaying the authentication form and related buttons
class AuthCard extends StatefulWidget 
{
  const AuthCard({
    Key key,
  }) : super(key: key);

  @override
  _AuthCardState createState() => _AuthCardState();
}

class _AuthCardState extends State<AuthCard> with SingleTickerProviderStateMixin
{
  final GlobalKey<FormState> _formKey = GlobalKey();
  AuthMode _authMode = AuthMode.Login;
  Map<String, String> _authData = 
  {
    'email': '',
    'password': '',
  };
  var _isLoading = false;
  final _passwordController = TextEditingController();
  
  //controller var for controlling the animation.
  AnimationController _controller;

  //the slide(offset) animation to be controlled
  Animation<Offset> _slideAnimation;

  //the opacity animation to be controlled
  Animation<double> _opacityAnimation;  

  @override
  void initState() {        
    super.initState();

    //initialising the animation controller
    _controller=AnimationController
    (
      //pointer to the widget to be animated
      vsync: this,
      duration: Duration(milliseconds: 300)
    );
    
    //tween knows how to animate
    //be(Tween) two values
    //slide animation effect
    _slideAnimation=Tween<Offset>
    (
      //only height will change and width remains same
      //throughout the animation
      begin: Offset(0,-1.5),//from top of y-axis
      end: Offset(0,0),//to bottom at origin
    ).animate
    ( 
      /**.animate is the animation logic
       * CurverAnimation is the type of animation
       * to be followed
     */    
      CurvedAnimation
      (
        //the widget where this animation logic will be applied
        parent: _controller, 

        //type of curve
        curve: Curves.fastOutSlowIn,
      )
    );

    //opacity animation logic
    _opacityAnimation=Tween
    (
      begin: 0.0,
      end: 1.0,      
    ).animate
    (
      CurvedAnimation
      (
        parent: _controller, 
        curve: Curves.easeIn,
      )      
    );

    //adding listeners to call build
    //whenever height animation changes
    //to constantly update the UI
    //_heightAnimation.addListener(()=>setState(() {}));    
  }

//disposing the listeners
  @override
  void dispose() {    
    super.dispose();
    _controller.dispose();
  }
  
  void _showErrorDialog(String message)
  {
    showDialog
    (
      context: context, 
      builder: (ctx)=>AlertDialog
      (
        title: Text('An Error Occured!'),
        content: Text(message),
        actions: 
        [
          FlatButton
          (
            child: Text('Okay'),
            onPressed: ()
            {
              Navigator.of(ctx).pop();
            },             
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async
  {
    if (!_formKey.currentState.validate()) 
    {
      // Invalid!
      return;
    }
    _formKey.currentState.save();
    setState(() {
      _isLoading = true;
    });

    try
    {
      if (_authMode == AuthMode.Login) 
      {
        // Log user in
        await Provider.of<Auth>(context,listen:false).login(_authData['email'], _authData['password']);
      } else {
        // Sign user up
        await Provider.of<Auth>(context,listen:false).signup(_authData['email'], _authData['password']);
      }
    Navigator.of(context).pushReplacementNamed('/products-overview');       

    } on HttpException catch(e)
    {
      var errorMessage='Authentication failed.';
      if(e.toString().contains('EMAIL_EXISTS'))
      {
        errorMessage='This email address is already in use.';
      }
      else if(e.toString().contains('INVALID_EMAIL'))
      {
        errorMessage='This is not a valid email address.';
      }
      else if(e.toString().contains('WEAK_PASSWORD'))
      {
        errorMessage='This password is too weak.';
      }
      else if(e.toString().contains('EMAIL_NOT_FOUND'))
      {
        errorMessage='Could not find a user with that email.';
      }
      else if(e.toString().contains('INVALID_PASSWORD'))
      {
        errorMessage='Invalid password.';
      }  
      //error dialog box display
    _showErrorDialog(errorMessage);
    }catch(e)//generic catch
    {
      const errorMessage='Could not authenticate you. Please try again later';
    };
        
    setState(() {
      _isLoading = false;
    });
  }

  void _switchAuthMode() 
  {
    if (_authMode == AuthMode.Login) 
    {
      setState(() {
        _authMode = AuthMode.Signup;
      });
      //starts the animation
      _controller.forward();
    } else {
      setState(() {
        _authMode = AuthMode.Login;
      });
      //starts the animation backwards
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) 
  {
    final deviceSize = MediaQuery.of(context).size;
    return Card
    (
      shape: RoundedRectangleBorder
      (
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 8.0,

      //automatically animates the container 
      //behind the scenes without
      // manually setting the controller
      child: AnimatedContainer
      (
        //duration of animation
        duration: Duration(milliseconds: 300),

        //type of animation  
        curve: Curves.easeIn,
        height: _authMode == AuthMode.Signup ? 320 : 280,
        //height: _heightAnimation.value.height,
        constraints:
            BoxConstraints(minHeight: _authMode == AuthMode.Signup ? 320 : 280,),
        width: deviceSize.width * 0.75,
        padding: EdgeInsets.all(16.0),

        //takes the form child as arg        
        child: Form
        (
          key: _formKey,
          child: SingleChildScrollView
          (
            child: Column
            (
              children: <Widget>
              [
                TextFormField
                (
                  decoration: InputDecoration(labelText: 'E-Mail'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) 
                  {
                    if (value.isEmpty || !value.contains('@')) 
                    {
                      return 'Invalid email!';
                    }
                    return null;
                    //return null;
                  },
                  onSaved: (value) 
                  {
                    _authData['email'] = value;
                  },
                ),
                TextFormField
                (
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  controller: _passwordController,
                  validator: (value) 
                  {
                    if (value.isEmpty || value.length < 5) 
                    {
                      return 'Password is too short!';
                    }
                  },
                  onSaved: (value) 
                  {
                    _authData['password'] = value;
                  },
                ),

                //for the confirmed password animation
                //to appear from zero height and not exists visually
                //before then                                
                AnimatedContainer
                (
                  constraints: BoxConstraints
                  (
                    //if in login mode height remains zero
                    minHeight: _authMode == AuthMode.Signup?60:0,
                    maxHeight: _authMode == AuthMode.Signup?120:0,
                  ),
                  duration: Duration(milliseconds: 300),
                  curve: Curves.easeIn,

                  //fade transition effect 
                  //have to be manually controlled
                  child: FadeTransition
                  (
                    //automatically adds the listener 
                    //and does neccessary changes
                    opacity: _opacityAnimation,

                    //for slide transition effect
                    child: SlideTransition
                    (
                      position: _slideAnimation,
                      child: TextFormField
                      (
                        enabled: _authMode == AuthMode.Signup,
                        decoration: InputDecoration(labelText: 'Confirm Password'),
                        obscureText: true,
                        validator: _authMode == AuthMode.Signup
                            ? (value) 
                            {
                              if (value != _passwordController.text) 
                              {
                                return 'Passwords do not match!';
                              }
                            }
                            : null,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20,),
                                  
                if (_isLoading)
                  CircularProgressIndicator()
                else
                  RaisedButton
                  (
                    child:
                        Text(_authMode == AuthMode.Login ? 'LOGIN' : 'SIGN UP'),
                    onPressed: _submit,
                    shape: RoundedRectangleBorder
                    (
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 30.0, vertical: 8.0),
                    color: Theme.of(context).primaryColor,
                    textColor: Theme.of(context).primaryTextTheme.button.color,
                  ),
                FlatButton
                (
                  child: Text
                  (
                      '${_authMode == AuthMode.Login ? 'SIGNUP' : 'LOGIN'} INSTEAD'
                  ),
                  onPressed: _switchAuthMode,
                  padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 4),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textColor: Theme.of(context).primaryColor,
                ),
              ],
            ),
          ),
        ),
      ),                                        
    );
  }
}
