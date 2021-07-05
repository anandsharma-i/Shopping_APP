import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth.dart';
import '../helpers/custom_route.dart';
import '../screens/orders_screen.dart';
import '../screens/user_product_screen.dart';

//for custom side bar
class AppDrawer extends StatelessWidget 
{
  var userName;

  //for setting the username in app drawer  

  @override
  Widget build(BuildContext context) 
  {
    
    userName=Provider.of<Auth>(context,listen: false).email; 
    if(userName!=null)   
    {
      userName='Hello! $userName';
    }    
     
    return Drawer//sp widget used for side bars
    (
      child: Column
      (
        children: 
        [
          AppBar
          (
            title: FittedBox
            (
              fit: BoxFit.cover,
              child: Text(userName!=null?userName:'Hello! Friend')
            ),

            //for hiding the back button
            //coz that makes no sense
            automaticallyImplyLeading: false,
          ),
          Divider(),//for displaying visually appealing divider lines
          ListTile
          (
            leading: Icon(Icons.shop),
            title: Text('Shop'),

            //for going to the product overview screen
            //and making it the first screen itself
            onTap: ()
            {
              Navigator.of(context).pushReplacementNamed('/');
            },
          ),
          Divider(),
          ListTile
          (
            leading: Icon(Icons.payment),
            title: Text('Orders'),

            //for going to the orders screen
            //and making it the first screen itself
            onTap: ()
            {
              //Navigator.of(context).pushReplacementNamed(OrdersScreen.routeName);

              //this is a custom route transition
              //for on the fly route creation
              Navigator.of(context).pushReplacement
              (
                CustomRoute
                (
                  //Since customroute class extends material page route class
                  //hence we can use builder
                  builder: (ctx)=>OrdersScreen(),
                )
              );
            },
          ),
          Divider(),
          ListTile
          (
            leading: Icon(Icons.edit),
            title: Text('Manage Products'),

            //for going to the user products screen
            //and making it the first screen itself
            onTap: ()
            {
              Navigator.of(context).pushReplacementNamed(UserProductScreen.routeName);
            },
          ),
          Divider(),
          ListTile
          (
            leading: Icon(Icons.exit_to_app),
            title: Text('Logout'),

            //for going to the user products screen
            //and making it the first screen itself
            onTap: ()
            {         
              //to close drawer properly before 
              //logout to avoid errors
              Navigator.of(context).pop(); 

              //to go to home route whenever the logout button
              //is pressed and ensure that auth screen is loaded
              Navigator.of(context).pushReplacementNamed('/');

              //logout
              Provider.of<Auth>(context,listen: false).logout();
            },
          ),
        ],
      ),
    );
  }
}