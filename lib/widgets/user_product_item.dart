import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';

//to make sure how a particular user product item on user product screen looks like
class UserProductItem extends StatelessWidget 
{
  final String id,title,imageUrl;

  UserProductItem(this.id,this.imageUrl,this.title);

  @override
  Widget build(BuildContext context) 
  {
    final scaffold=Scaffold.of(context);
    return ListTile
    (
      title: Text(title), 
      leading: CircleAvatar
      (
        backgroundImage: NetworkImage(imageUrl),
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
              icon: Icon(Icons.edit),

              //going to edit product screen
              //with id arg to make sure correct prod item is getting edited
              onPressed: ()
              {
                Navigator.of(context).pushNamed(EditProductScreen.routeName,arguments: id);
              },   
              color: Theme.of(context).primaryColor,          
            ),
            IconButton
            (
              icon: Icon(Icons.delete),

              //deleting the current prod item
              onPressed: () async
              {
                try
                {
                  await Provider.of<ProductsProvider>(context,listen: false).deleteProduct(id);
                }
                catch(e)//displaying the error visually
                {
                  //.of(context) is not used inside async
                  // func to avoid any error.
                  //it will be updating and flutter  might
                  //not be able to figure it out.
                  //hence storing it in a var and using it.
                  scaffold.showSnackBar
                  (
                    SnackBar(content: Text('Deleting Failed!',textAlign: TextAlign.center,),),
                  );
                }                
              },     
              color: Theme.of(context).errorColor,        
            ),
          ],
        ),
      ),
    );
  }
}