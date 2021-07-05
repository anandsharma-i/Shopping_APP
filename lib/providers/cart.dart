import 'package:flutter/foundation.dart';

//structure for single cart item
class CartItem
{
  //this is cart id and not product id
  final String id,title;
  final int quantity;
  final double price;
  CartItem
  (
    {
      @required this.id,
      @required this.price,
      @required this.quantity,
      @required this.title,
    }
  );
}

//this is provider class that will trigger the change notifications
class Cart with ChangeNotifier
{
  //mapping each cart item with the 
  //corresponding product id;
  Map<String,CartItem>_items={};//initialisation is very imp to avoid errors.

  //getter to extract the copy of cart items.
  Map<String,CartItem> get items
  {
    return {..._items};
  }

  //return no. of cart items
  int get itemCount
  {
    return _items.length;
  }

  //returns the total cart value
  double get totalAmount
  {
    var total=0.0;

    //iterates throu every key-value pair in a map.
    _items.forEach
    (
      (key, cart) 
      {
         total+=cart.price*cart.quantity;
      }
    );

    return total;
  }

  //for adding items into cart
  void addItem(String prodId,double price,String title,)
  {
    //if the prod already in cart
    //then change the quantity
    if(_items.containsKey(prodId))
    {
      _items.update(prodId, (existingCartItem) => CartItem
      (
        id: existingCartItem.id, 
        price: existingCartItem.price, 
        title: existingCartItem.title,
        quantity: existingCartItem.quantity+1,         
      ));
    }
    else//if the item is not in cart then add in cart.
    {
      _items.putIfAbsent
      (
        prodId, ()
        {
         return CartItem(id: DateTime.now().toString(), price: price, quantity: 1, title: title);
        }
      );
    }
    notifyListeners();
  }

  //for removing cart items
  void removeitem(String productId,double price,String title,)//this is the product id and not cart id
  {
    //for deleting whole product even if
    // it has more than one quantity
    //_items.remove(productId);    

    var q;

    //extracting the quantity of the item to be removed
    _items.update(productId, (existingCartItem)
    { 
      q=existingCartItem.quantity;
      return CartItem
      (
        id: existingCartItem.id, 
        price: existingCartItem.price, 
        title: existingCartItem.title,
        quantity: existingCartItem.quantity,         
      );
    });

    //removing item
    _items.remove(productId);
    
    //adding the item back again if quantity was >1 with 
    //every details remaing same(recieved args) but updating the quantity
    //by reducing one item
    if(q>1)      
    {
      _items.putIfAbsent
      (
        productId, ()
        {
          return CartItem(id: DateTime.now().toString(), price: price, quantity: q-1, title: title);
        }
      );
    }        
    notifyListeners();
  }

  //for removing only single cart item(UNDO option)
  void removeSingleItem(String productId)  
  {
    //if the prod item is not found in the cart
    if(!_items.containsKey(productId))
    {
      return;
    }

    //if the quantity is >1 then update by quantity=quantity-1
    if(_items[productId].quantity>1)
    {
       _items.update(productId, (existingCartItem)
        {         
          return CartItem
          (
            id: existingCartItem.id, 
            price: existingCartItem.price, 
            title: existingCartItem.title,
            quantity: existingCartItem.quantity-1,         
          );
        });
    }
    else//else remove item if only 1 quantity of that prod is present
    {
      _items.remove(productId);
    }
    notifyListeners();
  }

  //for clearing the whole cart(ORDER NOW)
  void clearCart()
  {
    _items={};
    notifyListeners();
  }
}