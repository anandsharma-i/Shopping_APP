import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/products_provider.dart';
import '../providers/product.dart';

//screen for editing a prod item
class EditProductScreen extends StatefulWidget 
{
  static const routeName='/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> 
{
  //sp property that tells flutter to focus
  //on this particular feild when in a form
  final _priceFocusNode=FocusNode();
  final _descriptionFocusNode=FocusNode();
  final _imageUrlFocusNode=FocusNode();

  //for stroring the image url for preview purpose only
  //since form widget handles everything about i/p
  //and we don't require to controll i/p manually
  final _imageUrlController=TextEditingController();

  //setting a global key for the form
  //to have access to the form widget data easily
  final _form=GlobalKey<FormState>();

  //to store the current form data
  var _editedProduct=Product
  (
    id: null,
    title:'',
    price: 0,
    description: '',
    imageUrl: ''
  );

  //this will be used to initilise edited product
  var _initValues=
  {
    'title':'',
    'description':'',
    'price':'',
    'imageUrl':'',
  };

  //to make sure the did change dependencies run once
  var _isInit=true;

  //to make sure screen is loading or not.
  var _isloading=false;  

  //to avoid memory leak , we must dispose off
  //the focus nodes or input controllers we have created
  @override
  void dispose() 
  {
    //before disposing the image url focus node
    //it's recommened to remove the listeners if any
    _imageUrlFocusNode.removeListener(_updateImageUrl); 
    _priceFocusNode.dispose();
    _descriptionFocusNode.dispose();
    _imageUrlController.dispose();
    _imageUrlFocusNode.dispose();
    super.dispose();
  }

  //updates the image preview when image focus node looses focus
  void _updateImageUrl()
  {
    //this is called if the image focus node looses focus
    if(!_imageUrlFocusNode.hasFocus)
    {
      //this is called if the image url is not valid
      if
      (       
        !_imageUrlController.text.startsWith('http')&&!_imageUrlController.text.startsWith('https')||
        !_imageUrlController.text.endsWith('.png')&&!_imageUrlController.text.endsWith('.jpg')&&
        !_imageUrlController.text.endsWith('.jpeg')
      )
      {
        return;
      }        
      
      //else screen update will occur
      setState(() {        
      });
    }
  }

  //adding listener to the imageurl focus node
  //so it updates the ui whenever the url i/p changes
  @override
  void initState() 
  {
   _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  //to update _initValues accordingly if the current to be edited
  //prod item already exists once before build runs
  @override
  void didChangeDependencies() 
  {   
    //this runs only first time 
    if(_isInit)
    {
      //recieving the product id from prev user prod screen
      final productId=ModalRoute.of(context).settings.arguments as String;
      
      //if the prod exists already then extract it's data
      if(productId!=null)
      {
        //initialising the to be edited prod with this
        //prod whose prod id is recieved from prev user prod screen
        _editedProduct=Provider.of<ProductsProvider>(context,listen: false).findById(productId);

        _initValues=
        {
          'title':_editedProduct.title,
          'description':_editedProduct.description,
          'price':_editedProduct.price.toString(),
          //'imageUrl':_editedProduct.imageUrl, //can't be initialised with URL as i/p controller is also used
          'imageUrl':'',
        };
        //hence only initialising i/p controller itself
        _imageUrlController.text=_editedProduct.imageUrl;
      }           
      _isInit=false;
    }
    super.didChangeDependencies();
  }

  //for saving the current state of the form
  Future<void> _saveForm() async
  {
    //to check if the form has all valid i/p
    final isValid=_form.currentState.validate();

    //don't save form data if the i/p is not valid
    if(!isValid)
    {
      return;
    }

    //for saving the current state of the form
    //this will further call the onsaved() for each
    //text form field of the particular form which has _form as it's key
    _form.currentState.save();
    
    setState(() {
      //set it to true before server call
      _isloading=true;      
    });

    //this prod already exists and
    //don't need to add the same prod again
    //instead only update the prod
    if(_editedProduct.id!=null)
    {
     await Provider.of<ProductsProvider>(context,listen: false).updateProduct(_editedProduct.id, _editedProduct);            
    }
    else//if the prod doesn't exists then add
    {
      try
      {
        //adding the user inputted product in the
        //product overview screen and waiting for server response
        await Provider.of<ProductsProvider>(context,listen: false).addProduct(_editedProduct);
      }
      catch(e)//for handling the error
      {
        await showDialog<Null>//returns a future obj
        (
          context: context, 
          builder: (ctx)
          {
            return AlertDialog
            (
              title: Text('An error occured!'),
              content: Text('Something went wrong'),
              actions: 
              [
                FlatButton
                (
                  child: Text('OK'),
                  
                  //to close error occured dialog box
                  //and return a future obj
                  onPressed: ()=>Navigator.of(ctx).pop(),                     
                )
              ],
            );
          }
        );
      }          
      /*finally
      {       
        //set it to false after server call
        setState(() {           
          _isloading=false;      
        });

        //going back to user products screen          
        Navigator.of(context).pop();
      }*/      
    }
    setState(() {
      //set it to false after update or add prod items or handling any error
      _isloading=false;      
    });

    //going back to user products screen       
    Navigator.of(context).pop();        
  }

  @override
  Widget build(BuildContext context) 
  {
    return Scaffold
    (
      appBar: AppBar
      (
        title: const Text('Edit Product'),        
        actions: 
        [
          IconButton
          (
            icon: Icon(Icons.save),

            onPressed: (){_saveForm();},             
          )
        ],
      ),
      //onTap: ()=>FocusScope.of(context).requestFocus(FocusNode()),
      body: _isloading?
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
      :GestureDetector//else generating form
      (
        //for dismissimg the soft keyboard
        onTap: ()=>FocusScope.of(context).requestFocus(FocusNode()),
        child: Padding
        (
          padding: const EdgeInsets.all(16.0),
          child: Form//speciall widget to handle user i/p
          (
            key: _form,
            child: SingleChildScrollView
            (
              child: Column
              (
                children: 
                [
                  SizedBox(height: 25,),
                  //similar to textfield but with more options
                  //For title I/P
                  TextFormField
                  (
                    //for initialising the text field
                    initialValue: _initValues['title'],
                  
                    //title of the text field
                    decoration: InputDecoration(labelText: 'Title',),
                    
                    //to move to next page of i/p form
                    textInputAction: TextInputAction.next,
                  
                    //to make sure we traverse from title to
                    //price field only.
                    onFieldSubmitted: (_)=>FocusScope.of(context).requestFocus(_priceFocusNode),
                  
                    //to validate the i/p
                    //return null if valid else return error msg
                    validator: (val)
                    {
                      if(val.isEmpty)
                        return 'Title cannot be left blank';
                      return null;  
                    },
                  
                    //this will be triggered  by saveForm()
                    onSaved: (val)
                    {
                      //updating only the title and rest data remains same.
                      _editedProduct=Product
                      (
                        id: _editedProduct.id,
                        title:val,
                        price: _editedProduct.price,
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  SizedBox(height: 25,),
                  //For price I/P
                  TextFormField
                  (
                    initialValue: _initValues['price'],
                    decoration: InputDecoration(labelText: 'Price',),
                    keyboardType: TextInputType.number,                  
                    textInputAction: TextInputAction.next,
                    focusNode: _priceFocusNode,
                    onFieldSubmitted: (_)=>FocusScope.of(context).requestFocus(_descriptionFocusNode),
                    validator: (val)
                    {
                      if(val.isEmpty)
                        return 'Please enter a price';
              
                      //returns null if val is invalid intead of
                      //throwing error
                      if(double.tryParse(val)==null) 
                         return 'Please enter a valid no.';
                      
                      //if the no. is zero or negative
                      if(double.parse(val)<=0)   
                        return 'Please enter a no. greater than zero.';
                      
                      return null;  
                    },
                    onSaved: (val)
                    {
                      _editedProduct=Product
                      (
                        id: _editedProduct.id,
                        title:_editedProduct.title,
                        price: double.parse(val),
                        description: _editedProduct.description,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  SizedBox(height: 25,),
                  //For description I/P
                  TextFormField
                  (
                    initialValue: _initValues['description'],
                    decoration: InputDecoration(labelText: 'Description',),                                                                                          
                    
                    //The max no. of i/p lines
                    maxLines: 3,                  
                    keyboardType: TextInputType.multiline,//preferred keyboard.
                    focusNode: _descriptionFocusNode,                  
                    validator: (val)
                    {
                      if(val.isEmpty)
                        return 'Description cannot be left blank';
                      else 
                      {
                        if(val.length<10)  
                        return 'Should be atleast 10 characters.';
                      }
                      return null;  
                    },
                    onSaved: (val)
                    {
                      _editedProduct=Product
                      (
                        id: _editedProduct.id,
                        title:_editedProduct.title,
                        price: _editedProduct.price,
                        description: val,
                        imageUrl: _editedProduct.imageUrl,
                        isFavorite: _editedProduct.isFavorite,
                      );
                    },
                  ),
                  SizedBox(height: 25,),
              
                  //For image preview and image Url I/P
                  Row
                  (
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: 
                    [
                      //image preview
                      Container
                      (
                        height: 100,
                        width: 100,
                        margin: EdgeInsets.only(top: 8,right: 10),
                        decoration: BoxDecoration
                        (
                          border:Border.all(width: 1,color: Colors.grey,),
                        ),
                        child: _imageUrlController.text.isEmpty?
                        Text('Enter a URL')
                        :FittedBox
                        (
                          child: Image.network(_imageUrlController.text),
                          fit: BoxFit.contain ,
                        ),
                      ),
              
                      //image Url i/p
                      Expanded
                      (
                        child: TextFormField
                        (                        
                          decoration: InputDecoration(labelText: 'Image URL',),
                          keyboardType: TextInputType.url,                  
                          textInputAction: TextInputAction.done,
                          controller: _imageUrlController,
                          focusNode: _imageUrlFocusNode,
                          validator: (val)
                          {
                            if(val.isEmpty)
                              return 'Image URL cannot be left blank';
                            if(!val.startsWith('http')&&!val.startsWith('https'))
                              return 'please enter a valid Image URL';
                            if(!val.endsWith('.png')&&!val.endsWith('.jpg')&&!val.endsWith('.jpeg'))  
                              return 'please enter a valid Image URL';
              
                            return null;  
                          },
                          onFieldSubmitted: (_)=>_saveForm(),
                          onEditingComplete: ()
                          {
                            setState(() {                          
                            });
                          },   
                          onSaved: (val)
                          {
                            _editedProduct=Product
                            (
                              id: _editedProduct.id,
                              title:_editedProduct.title,
                              price: _editedProduct.price,
                              description: _editedProduct.description,
                              imageUrl: val,
                              isFavorite: _editedProduct.isFavorite,
                            );
                          },                                             
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}