import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

//structure for each prod item
class Product with ChangeNotifier
{
  final String id,title,description,imageUrl;
  final double price;
  bool isFavorite;
  Product
  (
    {
     @required this.id,
     @required this.description,
     @required this.imageUrl,     
     @required this.price,
     @required this.title,
     this.isFavorite=false,
    }
  );
  
  //for setting fav value
  void _setFavValue(bool newVal)
  {
    isFavorite=newVal;
    notifyListeners();
  }

  //for toggling the fav status of each items
  //and notifying the listeners
  Future<void> toggleFavoriteStatus(String token,String userId) async
  {
    final oldStatus=isFavorite;
    isFavorite=!isFavorite;
    notifyListeners();

    final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/userFavorites/$userId/$id.json?auth=$token');

    try
    {
      //put request to overwrite fav status
      //of the current user's current prod item.
      final response= await http.put
      (
        url,
        body: json.encode
        (          
            isFavorite,          
        ),
      );
      if(response.statusCode>=400)//rollback for manual wrong url errors
      {
        _setFavValue(oldStatus);
      }
    }
    catch(e)//rollback for network errors
    {
      _setFavValue(oldStatus);      
    }           
  }
}