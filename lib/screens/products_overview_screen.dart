import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/cart.dart';
import '../providers/products_provider.dart';
import '../screens/cart_screen.dart';
import '../widgets/badge.dart';
import '../widgets/products_grid.dart';
import '../widgets/app_drawer.dart';

//to store the values for popup menu items
enum FilterOptions
{
  Favorites,
  All
}

//screen for displaying all the products.
class ProductsOverviewScreen extends StatefulWidget 
{   
  @override
  State<ProductsOverviewScreen> createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> 
{  
  //var to store the bool value
  //of the option whether to show
  //only fav prod or all prod
  var _showFavoritesOnly=false;
  var _isInit=true;
  var _isLoading=false;

  //for swipe down to refresh feature
  Future<void> _refreshProducts(BuildContext context) async
  {
    await Provider.of<ProductsProvider>(context,listen: false).fetchAndSetProducts();
  }
  
  //for getting product items from DB and updating app
  @override
  void didChangeDependencies() 
  {
    if(_isInit) 
    {
      setState(() {
        _isLoading=true;
      });
      Provider.of<ProductsProvider>(context).fetchAndSetProducts().then
      (
        (_) 
        {
           setState(() {
             _isLoading=false;
           });
        }  
      );
      
      _isInit=false;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) 
  {    
    return Scaffold
    (
      appBar: AppBar
      (
        title: Text('MyShop'),
        actions: 
        [
          PopupMenuButton
          (
            onSelected: (FilterOptions selectedValue)
            {

              //for updating fav var according to the popup
              //option selected
              setState(() {
                if(selectedValue==FilterOptions.Favorites)
                {
                  _showFavoritesOnly=true;
                }
                else
                {
                  _showFavoritesOnly=false;
                }
              });

            },
            icon: Icon(Icons.more_vert),
            itemBuilder: (_)=>
            [
              PopupMenuItem
              (
                child: Text('Only Favorites'),
                value: FilterOptions.Favorites,
              ),
              PopupMenuItem
              (
                child: Text('Show All'),
                value: FilterOptions.All,
              ),
            ]
          ),
          Consumer<Cart>//will be notified if cart data changes
          (                      
            builder:(_,cart,ch)
            { 
              //custom widget for displaying cart item no. over cart badge
              return Badge
              (
                child: ch,
                value: cart.itemCount.toString(),
              );
            },  
            
            //this child will be passed to builder()
            //automatically by flutter and it's buil method
            //won't be called when cart changes
            child: IconButton
            (
              icon: Icon(Icons.shopping_cart),
              onPressed: ()
              {
                Navigator.of(context).pushNamed(CartScreen.routeName);
              },               
            ),                      
          )
        ],
      ),
      drawer: AppDrawer(),//for custom side bar
      body: _isLoading ?
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
      :RefreshIndicator//for swipe down to refresh feature
      (
        onRefresh: ()=>_refreshProducts(context),
        //taking the bool var for further task
        child: ProductsGrid(_showFavoritesOnly)
      ),
    );
  }
}

