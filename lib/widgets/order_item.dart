import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart' as ord;

//to make sure how a particular order item on order screen looks like
class OrderItem extends StatefulWidget 
{

  //for storing the order item class object of order provider class
  final ord.OrderItem order;

  OrderItem(this.order);

  @override
  State<OrderItem> createState() => _OrderItemState();
}

class _OrderItemState extends State<OrderItem> 
{
  //bool var to decide whether
  //to expand an order item or not.
  var _expanded=false;

  @override
  Widget build(BuildContext context) 
  {
    return AnimatedContainer
    (
      duration: Duration(milliseconds: 300),

      //height of each order item card when
      //in expanded mode and normal mode
      height: _expanded ? 
      min(widget.order.products.length * 20.0 + 102, 200) : 100,

      child: Card
      (
        margin: EdgeInsets.all(10),
        child:Column
        (
          children: 
          [
            ListTile
            (            
              title: Text('\$${widget.order.amount.toStringAsFixed(2)}'),
              subtitle: Text
              (
                DateFormat('dd/MM/yyyy  hh:mm').format(widget.order.dateTime),
              ),
              trailing: Container
              (
                width: 100,
                child: Row
                (
                  children: 
                  [
                    IconButton
                    (                  
                      icon: Icon(Icons.delete),
                      
                      //updating _expanded on tap behavior
                      onPressed: ()
                      {                                         
                        Provider.of<ord.Orders>(context,listen: false).deleteOrder(widget.order.id);
                      },              
                    ),
                    IconButton
                    (
                      //displaying the respective icon as per the chosen options
                      icon: Icon(_expanded?Icons.expand_less:Icons.expand_more),
                      
                      //updating _expanded on tap behavior
                      onPressed: ()
                      {
                        setState(() {
                          _expanded=!_expanded;
                        });
                      },              
                    ),
                  ],
                ),
              ),
            ),
    
            //if expand order item option is selected
            //display extra details            
            AnimatedContainer
            (
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal:15,vertical: 4),
              
              //height of each expanded order item card when
              //in expanded mode and normal mode
              //to make sure the expanded container
              //never exeeds 100 height
              height: _expanded ? min(widget.order.products.length * 20.0 + 10, 100) : 0,
              
              child: ListView
              (              
               //mapping the products(list of products(cart item objects)
               //which is a class of cart provider class) with the corresponding custom widget
               children: widget.order.products.map((prod) => Row
               (
                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                 children: 
                 [
                   //title of each cart item
                   Text
                   (
                     prod.title,
                     style: TextStyle
                     (
                       fontSize: 18,
                       fontWeight: FontWeight.bold,
                     ),
                   ),
    
                   //total amount of each cart item
                   Text
                   (
                     '${prod.quantity}x \$${prod.price.toStringAsFixed(2)}',
                     style: TextStyle
                     (
                       fontSize: 18,
                       color: Colors.grey,
                     ),
                   )
                 ],
               )).toList(),             
              ),
            )
          ],
        ),
      ),
    );
  }
}