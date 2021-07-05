import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import './providers/auth.dart';
import './providers/orders.dart';
import './providers/cart.dart';
import './providers/products_provider.dart';
import './helpers/custom_route.dart';
import './screens/splash_screen.dart';
import './screens/cart_screen.dart';
import './screens/product_detail_screen.dart';
import './screens/orders_screen.dart';
import './screens/user_product_screen.dart';
import './screens/edit_product_screen.dart';
import './screens/auth_screen.dart';
import './screens/products_overview_screen.dart';

void main() 
{
  runApp(MyApp());
}

class MyApp extends StatelessWidget 
{    
  @override
  Widget build(BuildContext context) 
  {
    //for building the provider class.
    return MultiProvider
    (
      //used for setting up multiple provider classes
      providers: 
      [
        ChangeNotifierProvider
        (
          create: (ctx)=>Auth(),
        ),

        //to make this provider depend on it's just above provider class registered
        ChangeNotifierProxyProvider<Auth,ProductsProvider>
        (
          //create is used for ^4.0
          //and above otherwise build is used.
          /*if we are instantiating a provider class
            then it's recommended to use 
            this(create) syntax.
          */
          update: (ctx,auth,prevProducts)=>ProductsProvider
          (
            auth.token,
            auth.userId,
            prevProducts==null?[]:prevProducts.items,
          ),
        ),
        ChangeNotifierProvider
        (
          create: (ctx)=>Cart(),
        ),
        ChangeNotifierProxyProvider<Auth,Orders>
        (
          update: (ctx,auth,prevOrders)=>Orders
          (
            auth.token,
            auth.userId,
            prevOrders==null?[]:prevOrders.orders,
          ),
        ),        
      ],

      //every child can listen to above set provider classes
      child:Consumer<Auth>//listening to auth provider
      ( 
        builder:(ctx,auth,_)
        {
          return MaterialApp
          (
            debugShowCheckedModeBanner: false,
            title: 'MyShop',
            theme: ThemeData
            (        
              primarySwatch: Colors.cyan,
              accentColor: Colors.pink,
              fontFamily: 'Lato',

              //fade transition effect for all route transition 
              pageTransitionsTheme: PageTransitionsTheme
              (
               builders: 
               {
                 TargetPlatform.android: CustomPageTransition(),
                 TargetPlatform.iOS: CustomPageTransition(),
               },
              ),
            ),
            home:auth.isAuth?//if user is authorized or not
            ProductsOverviewScreen()
            :FutureBuilder
            (
              //if the valid token exists on device storage
              //if yes then update the data on provider class and rebuild 
              //this material app widget since it's listening to the auth provider class
              //if valid token doesn't exists then show auth screen and the data
              //in the auth provider class remains unchanged(null)
              future: auth.tryAutoLogin(),
              builder:(ctx,authResultSnapshot) =>               
              authResultSnapshot.connectionState==ConnectionState.waiting?
              SplashScreen()
              :AuthScreen()
            ),
            routes: 
            {
              //'/':(_)=>ProductsOverviewScreen(),
              ProductDetailScreen.routeName:(_)=>ProductDetailScreen(),
              CartScreen.routeName:(_)=>CartScreen(),
              OrdersScreen.routeName:(_)=>OrdersScreen(),
              UserProductScreen.routeName:(_)=>UserProductScreen(),
              EditProductScreen.routeName:(_)=>EditProductScreen(),            
            },
          );
        },         
      )
    );
  }
}
