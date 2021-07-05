import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' show Orders;
import '../widgets/order_item.dart' ;
import '../widgets/app_drawer.dart';

//screen for displaying order items
class OrdersScreen extends StatefulWidget 
{
  static const routeName='/orders' ;

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> 
{
  //to store the initial future obj
  Future _ordersFuture;  

  //to make sure this future does not gets
  //instantiated again if the build method 
  //is called due to some other widget.
  Future _obtainOrdersFuture()
  {
    return Provider.of<Orders>(context, listen: false).fetchAndSetOrders();
  }

  //to make sure the  oorder items gets
  //fetched only once
  @override
  void initState() 
  {
    _ordersFuture=_obtainOrdersFuture();
    super.initState();
  }

  @override
  Widget build(BuildContext context) 
  {  
    return Scaffold
    (
      appBar: AppBar(title: Text('Your Orders')),        
      drawer: AppDrawer(),//custom side bar

      //displaying each order item
      body: FutureBuilder
      (
        future: _ordersFuture,

        //Snapshot is the data/response received by
        //the future obj above
        builder: (ctx, dataSnapshot) 
        {
          if (dataSnapshot.connectionState == ConnectionState.waiting) 
          {
            return Center//for generating loading page
            (
              child: Column
              (        
                mainAxisAlignment: MainAxisAlignment.center,            
                children: 
                [
                  //sp widget for loading spinner animation
                  CircularProgressIndicator(),
                  Text
                  (
                    'Loading....',
                    style: TextStyle
                    (
                      fontSize: 20,                
                    ),
                  ),
                ],
              ),
            );
          } 
          else 
          { 
            // error state
            if (dataSnapshot.error != null) 
            {                          
              return Center
              (
                child: Text('An error occurred!'),
              );
            } 
            else //succes state
            {
              return Consumer<Orders>
              (
                builder: (ctx, orderData, child) =>  orderData.orders.length==0 ?
                Center
                (
                  child: Text
                  (
                    'You have no orders.',
                    style: TextStyle
                    (
                      fontSize: 24,
                      color: Colors.black
                    ),
                  ),
                )
                :ListView.builder
                (
                  itemBuilder:(ctx,i)=>OrderItem(orderData.orders[i]),
                  itemCount: orderData.orders.length,
                ),
              );
            }
          }
        },
      ),
    );
  }
}