import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/http_exception.dart';
import './product.dart';

//this class is the main data provider class.
//this is called mixin of class,similar to inheritance.
class ProductsProvider with ChangeNotifier
{
  //list of all product class objects
  List<Product> _items=
  [
    // Product
    // (
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product
    // (
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Trousers%2C_dress_%28AM_1960.022-8%29.jpg/512px-Trousers%2C_dress_%28AM_1960.022-8%29.jpg',
    // ),
    // Product
    // (
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product
    // (
    //   id: 'p4',
    //   title: 'A Pan',
    //   description: 'Prepare any meal you want.',
    //   price: 49.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1024px-Cast-Iron-Pan.jpg',
    // ),
  ];  

  final String authToken;
  final String userId;

  ProductsProvider(this.authToken,this.userId,this._items);

  //to return copy of current list of all products
  List<Product> get items
  {    
    return [..._items];
  }  

  //to return current list of only fav products
  List<Product> get favoriteItems
  {
    return _items.where((prod) => prod.isFavorite).toList();
  }

  //to find a product given the product id.
  Product findById(String id)
  {
    return _items.firstWhere((prod) => prod.id==id);
  }

  //for getting product items from DB and updating app
  Future<void> fetchAndSetProducts([bool filterByUser=false]) async
  {
    final filterString=filterByUser?'orderBy="creatorId"&equalTo="$userId"':'';
    //telling the server the user trying to
    //access the server is authorised and has 
    //valid token
    //also filtering the products according to
    //the creator id whose value is nothing but the userId
    //the & b/w the two string interpolation is imp.
    var url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/products.json?auth=$authToken&$filterString');

    try
    {
      //get request is for fetching the product item from DB
      //the response is of type Map<String,Map<String,Object>>
      //where each unique string id is mapped with each map(prod item).
      //hence we must use dynamic
      final response=await http.get(url);
      final extractedData=json.decode(response.body) as Map<String,dynamic>;

      //if DB is empty    
      if(extractedData==null)
      {
        return;
      }
      url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/userFavorites/$userId.json?auth=$authToken');
      final favoriteResponse=await http.get(url);
      final favData=json.decode(favoriteResponse.body);

      final List<Product> loadedProducts=[];

      extractedData.forEach
      (
        (prodId, prodData) 
        {
          loadedProducts.add
          (
            Product
            (
              id: prodId, 
              description: prodData['description'], 
              imageUrl: prodData['imageUrl'], 
              price: prodData['price'], 
              title: prodData['title'],

              //if there is no fav for this user then set it to false
              //alse if the particular prod item does not exists in the fav folder
              //of that particular user
              isFavorite: favData==null?false:favData[prodId]??false,
            )
          );
        }
      );
      _items=loadedProducts;
      notifyListeners();
    }
    catch(e)
    {
      throw(e);
    }    
  }

  //for adding a product item of type product class
  //async keywword is used to wrap whole code of the func
  //as asynchronous and automatically return future obj.  
  Future<void> addProduct(Product product) async
  {
    /*URL can't be simple string and needed to be parsed into URL objects
    Firebase requires .json at the end of url.
    Firebase provides feature of adding requests into specific folders
    in this case its '/products'
    */ 
    final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/products.json?auth=$authToken');

    try
    {
      /*post request for storing the product item in DB
      and also returning it back to edit product screen
      since .then return a future obj.
      await keyword is used to tell flutter
      that this will give a response in future
      so wait for the response and store in a var,
      but the prog execution won't hault.*/
      final response=await http.post
      (
        url,

        //converting the prod item obj into json obj
        //dart:convert is required
        body: json.encode
        (
          {
            'title':product.title,
            'description':product.description,
            'imageUrl':product.imageUrl,
            'price':product.price,
            'creatorId':userId,
            //'isFavorite':product.isFavorite,
          }
        ),
      );

      //have to instantiate again a new product class object
      //since product class objects are immmutable
      final newProduct=Product
      (
        /*json.decode(response.body) will simply
        decode the response.body json object into
        a map which dart/flutter understands
        then extracting the value of name key and
        storing it as id.
        */
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl:product.imageUrl,          
      );
      _items.add(newProduct);
      notifyListeners();
    }
    catch(error)
    {
      print(error);
      //re throwing again back to edit prod screen
      throw error;
    }   
  }

  //for updating a product item of type product class
  Future<void> updateProduct(String id,Product newProduct) async
  {
    //finding the index of the prod item
    final prodIndex=_items.indexWhere((prod) => prod.id==id);

    //if it exists then update
    if(prodIndex>=0)
    {
      //extracting the specific prod item from 
      //products folder using string interpolation.
      final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');
      
      //updating the specific prod item.
      await http.patch
      (
        url,
        body: json.encode
        (
          {
            'title':newProduct.title,
            'description':newProduct.description,
            'price':newProduct.price,
            'imageUrl':newProduct.imageUrl,
          }
        ),
      );
      _items[prodIndex]=newProduct;
      notifyListeners();
    }
    else//else generate error text
    {
      print('product can\'t be updated');
    }    
  }

  //for deleting a product item of type product class
  Future<void> deleteProduct(String id) async
  {
    //extracting the specific prod item from 
    //products folder using string interpolation.
    final url=Uri.parse('https://flutter-shop-app-db-9294c-default-rtdb.firebaseio.com/products/$id.json?auth=$authToken');

    //storing the index and the data of the
    // to be deleted prod item.Incase if request fails.
    final existingProductIndex=_items.indexWhere((prod) => prod.id==id);
    var existingProduct=_items[existingProductIndex];

    //for deleting the prod item from DB
    final response=await http.delete(url);

    //for deleting the prod item from app
    _items.removeAt(existingProductIndex);
            
    //delete request doesn't throw error if
    //anything goes wrong hence we have to
    //throw manually.      
    //rollback if any error occurs
    if(response.statusCode>=400)
    {
      _items.insert(existingProductIndex, existingProduct);
      throw HttpException('Could not delete product item');
    }
    existingProduct=null;                         
    notifyListeners();
  }
}


