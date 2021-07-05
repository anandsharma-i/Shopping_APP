import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../providers/cart.dart';
import '../models/http_exception.dart';

//structure for each order item
class OrderItem 
{  
  final String id;
  final double amount;
  
  //list of cart item provider objects
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem
  (
    {
      this.amount,
      this.dateTime,
      this.id,
      this.products,
    }
  );
}

//this is provider class that will trigger the change notifications
class Orders with ChangeNotifier
{
  //list of orderitem provider class objects
  List<OrderItem> _orders=[];
  final String authToken;
  final String userId;
  
  Orders(this.authToken,this.userId,this._orders);

  //to return copy of current list of all order items 
  List<OrderItem> get orders
  {
    return [..._orders];
  }

  //for fetching the order data from DB
  Future<void> fetchAndSetOrders() async
  {
    final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final response=await http.get(url);    
    final extractedData=json.decode(response.body) as Map<String,dynamic>;
    
    //if DB is empty
    if(extractedData==null)
    {
      return;
    }

    final List<OrderItem> loadedOrders=[];

    extractedData.forEach
    (
      (orderId,orderData) 
      {
        loadedOrders.add
        (
          OrderItem
          (
            id: orderId,
            amount: orderData['amount'],
            dateTime: DateTime.parse(orderData['dateTime']),
            products: (orderData['products'] as List<dynamic>).map
            (
              (item) => CartItem
              (
                id: item['id'], 
                price: item['price'], 
                quantity: item['quantity'], 
                title: item['title'],
              )
            ).toList(),
          ),
        );
      }
    );

    //reversing just to get the latest order on top 
    //of the screen
    _orders=loadedOrders.reversed.toList();
    notifyListeners();
  }

  //for adding order items
  Future<void> addOrder(List<CartItem> cartProducts,double total) async
  {    
    final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/orders/$userId.json?auth=$authToken');
    final timestamp=DateTime.now();
    final response=await http.post
    (
      url,body: json.encode
      (
        {
          'amount':total,
          'dateTime':timestamp.toIso8601String(),//std string representation
          'products':cartProducts.map
          (
            (cp) => 
            {
              'id':cp.id,
              'title':cp.title,
              'quantity':cp.quantity,
              'price':cp.price, 
            }
          ).toList(),
          
        }
      ),
    );

    _orders.insert
    (
      0,
      OrderItem
      (
       id:json.decode(response.body)['name'],
       amount: total,
       dateTime: timestamp,
       products: cartProducts
      )
    );
    notifyListeners();
  }
  Future<void> deleteOrder(String id) async
  {
    final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/orders/$userId/$id.json?auth=$authToken');

    final existingProductIndex=_orders.indexWhere((order) => order.id==id);
    var existingProduct=_orders[existingProductIndex];

    //for deleting the prod item from DB
    final response=await http.delete(url);

    //for deleting the prod item from app
    _orders.removeAt(existingProductIndex);
            
    //delete request doesn't throw error if
    //anything goes wrong hence we have to
    //throw manually.      
    //rollback if any error occurs
    if(response.statusCode>=400)
    {
      _orders.insert(existingProductIndex, existingProduct);
      throw HttpException('Could not delete product item');
    }
    existingProduct=null;                         
    notifyListeners();
  }
}