import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../screens/edit_product_screen.dart';
import '../widgets/user_product_item.dart';
import '../widgets/app_drawer.dart';

//screen for displaying the user prod items
class UserProductScreen extends StatelessWidget 
{    
  static const routeName='/user-products';

  //for swipe down to refresh feature
  Future<void> _refreshProducts(BuildContext context) async
  {
    //passing true as an arg to make
    //sure the produc items fetched are
    //filtered according to the users
    await Provider.of<ProductsProvider>(context,listen: false).fetchAndSetProducts(true);
  }

  @override
  Widget build(BuildContext context) 
  {
    //final productData=Provider.of<ProductsProvider>(context);

    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Your Products'),
        actions: 
        [
          IconButton
          (
            icon: Icon(Icons.add),

            //going to edit product screen
            //for adding new prod item and hence no args need to be sent
            onPressed: (){Navigator.of(context).pushNamed(EditProductScreen.routeName);},             
          )
        ],
      ),
      drawer: AppDrawer(),//custom app drawer

      //to automatically display refresh indicator 
      //until some task returns a future response
      body: FutureBuilder
      (
        //calling instantly the future when
        //build is called to make sure the user product
        //screen is updated according to the user
        future: _refreshProducts(context),
        builder: (ctx,snapShot)=>
        snapShot.connectionState==ConnectionState.waiting?
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
        :RefreshIndicator
        (
          //takes a func that returns a future obj
          //to let flutter know when to stop
          //displaying refresh indicator
          onRefresh: ()=>_refreshProducts(context),

          //on swipe down refresh this part of the code only rebuilds
          child: Consumer<ProductsProvider>
          (
            builder:(ctx,productData,_) =>  productData.items.length==0 ?
            Center
            (
              child: Text
              (
                'You have not added any products.',
                style: TextStyle
                (
                  fontSize: 24,
                  color: Colors.black
                ),
              ),
            )
            :Padding
            (
              padding: EdgeInsets.all(8),
              child: ListView.builder
              (
                itemBuilder: (_,i)=>Column
                (
                  children: 
                  [
                    //displaying each user product item
                    UserProductItem
                    (
                      productData.items[i].id,
                      productData.items[i].imageUrl, 
                      productData.items[i].title,
                    ),
                    Divider(),
                  ],
                ),
                itemCount: productData.items.length,
              ),
            ),
          ),
        ),
      ),
    );
  }
}