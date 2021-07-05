import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/orders.dart';
import '../providers/cart.dart' show Cart;//has a class named CartItem
import '../widgets/cart_item.dart' ;//as ci; also has a class named CartItem
/*To avoid name clashes there are two methods.
1. using 'as' keyword to use it as a prefix
2. using 'show' keyword to import only specific 
selected class of the file.  
*/

//screen for displaying the cart items
class CartScreen extends StatelessWidget 
{ 
  static const routeName='/cart';
  @override
  Widget build(BuildContext context) 
  {
    //listen to all changes of cart
    final cart=Provider.of<Cart>(context);

    return Scaffold
    (
      appBar: AppBar
      (
        title: Text('Your Cart'),
      ),
      body: Column
      (
        children: 
        [
          //topmost card that displays the total cart value and ORDER NOW button
          Card
          (
            margin: EdgeInsets.all(15),
            child: Padding
            (
              padding: EdgeInsets.all(8),
              child: Row
              (
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: 
                [
                  Text
                  (
                    'Total',
                    style: TextStyle(fontSize: 20,),
                  ),                

                  //takes up all the extra space
                  Spacer(),

                  //to o/p cart value in a special rounded oval clip manner
                  Chip
                  (
                    backgroundColor: Theme.of(context).primaryColor,
                    label: Text
                    (
                      '\$${cart.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(color: Theme.of(context).primaryTextTheme.title.color),
                    ),
                  ),
                  OrderButton(cart: cart)
                ],
              ),
            ),
          ),

          SizedBox(height: 10,),

          //displaying all the cart items
          cart.itemCount==0 ?
          Center
          (
            child: Text
            (
              'Your cart is empty.',
              style: TextStyle
              (
                fontSize: 24,
                color: Colors.black
              ),
            ),
          )
          :Expanded
          (
            child: ListView.builder
            (
              itemBuilder:(ctx,i)
              {
                  return CartItem//ci.CartItem
                  (
                    cart.items.values.toList()[i].id,//value(cart id)
                    cart.items.keys.toList()[i],//key(prod id)
                    cart.items.values.toList()[i].price,
                    cart.items.values.toList()[i].quantity, 
                    cart.items.values.toList()[i].title
                  );
              },
              itemCount: cart.itemCount,
            )
          )
        ],
      ),
    );
  }
}

class OrderButton extends StatefulWidget 
{
  const OrderButton({
    Key key,
    @required this.cart,
  }) : super(key: key);

  final Cart cart;

  @override
  State<OrderButton> createState() => _OrderButtonState();
}

class _OrderButtonState extends State<OrderButton> 
{
  var _isLoading=false;

  @override
  Widget build(BuildContext context) 
  {
    return FlatButton
    (
      child:_isLoading ?
      Center//for generating loading page
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
      )
      :Text
      (
        'ORDER NOW',
        style: TextStyle
        (
          color: Theme.of(context).primaryColor
        ),
      ),

      //to add cart items to order items
      onPressed: (widget.cart.totalAmount<=0||_isLoading)?
      null//disable button if cart is emptyor page is loading
      :() async
      {
        setState(() {
          _isLoading=true;
        });
        await Provider.of<Orders>(context,listen: false).addOrder
        (
          //sending the list of cart items
          widget.cart.items.values.toList(), 

          //sending cart total
          widget.cart.totalAmount,
        );

        setState(() {
          _isLoading=false;
        });

        //clearing all cart items and updating cart screen
        widget.cart.clearCart();
      },                    
    );
  }
}