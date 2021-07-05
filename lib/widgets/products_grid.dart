import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../widgets/product_item.dart';

//for displaying the products in a gridview.
//this is a helper widget for product overview screen
class ProductsGrid extends StatelessWidget 
{
  //recieving the bool var for displaying
  //only fav prod or all prod
  final bool showFavs;

  ProductsGrid(this.showFavs);

  @override
  Widget build(BuildContext context) 
  {
    //getting the data from product provider class.    
    final productsData=Provider.of<ProductsProvider>(context);

    //getting the exact list of products from extracted data.
    //only for using for itemCount for gridview
    //fetching either all items or only fav items.
    final products= showFavs?productsData.favoriteItems:productsData.items;
    
    return products.length==0 ?
    Center
    (
      child: Text
      (
        'You have not added any products',
        style: TextStyle
        (
          fontSize: 24,
          color: Colors.black
        ),
      ),
    )
    :GridView.builder
    (
      padding: const EdgeInsets.all(10),
      itemCount: products.length,

      //notify the listeners if any product object (and not product provider)
      // data changes
      itemBuilder: (ctx,i)=>ChangeNotifierProvider.value      
      (     
        //create: (ctx)=>products[i],

        /*if we are not instantiating a provider class
        and just reusing already instantiated
        then it's recommended to use
        this(value) syntax.
       */

        //seting listener/provider for already instantiated product object
        value: products[i],

        //for creating and displaying each product item
        child: ProductItem(),                          
      ),
      
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount
      (
        //to count the max no. of columns of grid items.
        crossAxisCount: 2,
        childAspectRatio: 3/2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,    
      ),                     
    );
  }
}