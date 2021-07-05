import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';

//to make sure how a particular cart item on cart screen looks like
class CartItem extends StatelessWidget 
{  
  //id is cart id and productId is the original productId used as key
  final String id,title,productId;
  final double price;
  final int quantity;

  CartItem(this.id,this.productId,this.price,this.quantity,this.title);

  @override
  Widget build(BuildContext context) 
  {       
    return Dismissible//for special swipe to dismiss feature
    (
      //unique key for the object that will be deleted
      key:ValueKey(id),

      //for back ground when dismissible animation is going on
      background: Container
      (
        color:Theme.of(context).errorColor,
        child: Icon
        (
          Icons.delete,
          color: Colors.white,   
          size: 40,       
        ),
        padding: EdgeInsets.all(20),
        margin: EdgeInsets.symmetric
        (
          horizontal: 15,
          vertical: 4,
        ),
        alignment: Alignment.centerRight,
      ),

      //direction of dismissible animation
      direction: DismissDirection.endToStart,

      //this expects a future object
      confirmDismiss: (direction)
      {
        //for showing the confirmation dialog box
        return showDialog
        (
          context: context, 
          builder: (ctx)=>AlertDialog
          (
            title: Text('Are you sure?'),
            content: Text('Do you want to remove item from the cart?'),
            actions: 
            [
              FlatButton
              (
                child: Text('No'),

                //for removing the confirmation dialog box
                //and return a future object(false)
                onPressed: (){Navigator.of(context).pop(false);},                 
              ),
              FlatButton
              (
                child: Text('Yes'),

                //for removing the confirmation dialog box
                //and return a future object(true)
                onPressed: (){Navigator.of(context).pop(true);},                 
              ),
            ],
          ),          
        );
      },

      //what to do after confirmation
      //delete only if YES option was selected
      onDismissed: (direction)
      {
        //not listening to changes
        //but using the global provider data
        Provider.of<Cart>(context,listen: false).removeitem(productId,price,title);
        
      },

      //each cart item
      child: Card
      (
        margin: EdgeInsets.symmetric
        (
          horizontal: 15,
          vertical: 4,
        ),
        child: Padding
        (
          padding: EdgeInsets.all(8),
          child: ListTile
          (
            leading: CircleAvatar
            (
              child: Padding
              (
                padding: EdgeInsets.all(3),
                child: FittedBox(child: Text('\$${price.toStringAsFixed(2)}')),
              ),
            ),
            title: Text(title),
            subtitle: Text('Total : \$${(price*quantity).toStringAsFixed(2)}'),
            trailing: Text('$quantity x'),
          ),
        ),
      ),
    );
  }
}