import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/product.dart';
import '../providers/cart.dart';
import '../providers/auth.dart';
import '../screens/product_detail_screen.dart';

//how a product item must look like.
class ProductItem extends StatelessWidget
{ 
  // final String id,title,imageUrl;
  // ProductItem(this.id,this.imageUrl,this.title);

  @override
  Widget build(BuildContext context) 
  {
    //fetching the data for current product object directly from product.dart
    //for only one time and not listening for any further changes
    final product=Provider.of<Product>(context,listen: false);

    //fetching the data for cart object directly from cart.dart
    //for only one time and not listening for any further changes
    final cart=Provider.of<Cart>(context,listen: false);
    final authData=Provider.of<Auth>(context,listen: false);
    return ClipRRect//for rounded rect clip shape
    (
      borderRadius: BorderRadius.circular(10),
      child: GridTile//used for creating tiles for each prod
      (
        //for using ontap behaviour
        //which was not possible with Image.network
        child: GestureDetector
        (
          //for going to prod detail screen
          //and sending the curr prod id for further tasks.        
          onTap: ()
          {
            Navigator.of(context).pushNamed
            (
              ProductDetailScreen.routeName,
              arguments: product.id,
            );
          },
          
          /*For fade over a image when transitioning from
          old screen to a new screen, takes a tag which
          takes any unique id that will tell flutter
          to display a particular image for hero tansition
          */
          child: Hero
          (
            tag: product.id,
            //for fade in effect with a proper
            //image holder that will display a temp
            //image untill the expected image is displayed
            child: FadeInImage
            (
              placeholder:AssetImage('assets/images/product-placeholder.png'),
              image:NetworkImage(product.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        //for displaying info/options below each prod image(title/cart/fav)
        footer: GridTileBar
        (
          backgroundColor: Colors.black87,

          //listening for any further changes.
          //3rd arg is for any widget that might not
          //be expecting any changes in the widget tree
          //we wrapped under Consumer<Product>
          leading: Consumer<Product>
          (
            builder: (ctx,product,_)=>IconButton//fav button
            (          
              color: Theme.of(context).accentColor,
              icon: Icon
              (
                product.isFavorite?Icons.favorite:Icons.favorite_border,
              ),

              //for updating the fav status of current prod
              onPressed: ()
              {
                product.toggleFavoriteStatus(authData.token,authData.userId);
              },          
            ),            
          ),        
          title: Text//prod title
          (
            product.title,
            textAlign: TextAlign.center,
          ),
          trailing: IconButton//cart button
          (          
            color: Theme.of(context).accentColor,
            icon: Icon(Icons.shopping_cart),
            onPressed: ()
            {
              cart.addItem(product.id, product.price, product.title);
              
              //for hiding the prev showing
              // snackbar if it exists and displaying the current one.
              ScaffoldMessenger.of(context).hideCurrentSnackBar();

              //refers to the nearest scaffold parent widget
              ScaffoldMessenger.of(context).showSnackBar
              (
                //for opening a info dialog box
                SnackBar
                (
                  content: Text('Added item to cart!',),

                  //duration limit of the snackbar to stay on screen
                  duration: Duration(seconds: 2),

                  //undo button
                  action: SnackBarAction
                  (
                    label: 'UNDO', 

                    //for removing the last added item into cart.
                    onPressed: (){cart.removeSingleItem(product.id);},
                  ),
                )
              );
            },
          ),
        ),
      ),
    );
  }
}