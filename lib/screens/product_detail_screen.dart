import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';

//for displaying the product detail screen.
class ProductDetailScreen extends StatelessWidget 
{ 
  static const routeName='/product-detail';
  //final String title;

  //ProductDetailScreen(this.title);  
  @override
  Widget build(BuildContext context) 
  {
    //getting the productId sent from product_overview screen
    //via prod item widget which used product.dart provider
    final productId=ModalRoute.of(context).settings.arguments as String;

    //getting the product for current prod id from product provider.
    final loadedProduct=Provider.of<ProductsProvider>
    (
      context,
      
      //this won't listen on calling notifyListeners.
      //default is true.which means
      //this build will be called only once.
      listen: false,
    ).findById(productId);  

    return Scaffold
    (      
      /*Custom scroll view
      is used to assign different behavior 
      to diff components(appbar etc) when we scroll
       */
      body: CustomScrollView
      (
        slivers: 
        [
          //sets the appbar during the entire scrolling time.
          SliverAppBar
          (
            //height of the appbar when expanded
            expandedHeight: 300,

            //makes the appbar pinned after scroll
            pinned: true,
            flexibleSpace: FlexibleSpaceBar
            (
              //appbar title 
              title: ClipRRect
              (
                borderRadius: BorderRadius.circular(10),
                child: Container
                (                
                  color: Colors.white54,//Theme.of(context).primaryColor,
                  padding: EdgeInsets.all(10),
                  child: Text(loadedProduct.title)
                ),
              ),

              //if app bar expands then background is
              //displayed(prod item image)
              background: Hero
              (
                //for hero effect to occur
                //when any image is tapped on prev prod overview screen
                //via prod item.
                tag: loadedProduct.id,
                child: Image.network
                (
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),   
            ),
          ),

          //other members except image of the scroll view
          SliverList
          (
            //other members except image of the scroll view
            delegate: SliverChildListDelegate
            (
              [
                SizedBox(height: 10,),
                Text
                (
                  '\$${loadedProduct.price}',
                  style: TextStyle
                  (
                    color: Colors.grey,
                    fontSize: 20,                
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10,),
                Container
                (
                  width: double.infinity,
                  padding: EdgeInsets.all(10),
                  child: Text
                  (
                    '${loadedProduct.description}',
                    textAlign: TextAlign.center,
                    softWrap: true,
                    style: TextStyle
                    (
                      color: Colors.black,
                      fontSize: 25,                
                    )
                  ),
                ),
                SizedBox(height: 800,)
              ],
            ),
          ),
        ],        
      ),
    );
  }
}