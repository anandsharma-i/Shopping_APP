import 'package:flutter/material.dart';

//custom widget for displaying cart item no. over cart badge
class Badge extends StatelessWidget 
{
  const Badge({
    Key key,
    @required this.child,
    @required this.value,
    this.color,
  }) : super(key: key);

  final Widget child;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) 
  {
    return Stack
    (
      alignment: Alignment.center,
      children: [
        child,//the badge icon recieved from prod over view screen

        //the text that will be displayed over badge icon
        Positioned
        (
          right: 8,
          top: 8,
          child: Container
          (
            padding: EdgeInsets.all(2.0),
            // color: Theme.of(context).accentColor,
            decoration: BoxDecoration
            (
              borderRadius: BorderRadius.circular(10.0),
              color: color != null ? color : Colors.pinkAccent,
            ),
            constraints: BoxConstraints(
              minWidth: 16,
              minHeight: 16,
            ),
            child: Text
            (
              value,
              textAlign: TextAlign.center,
              style: TextStyle
              (
                fontSize: 10,
              ),
            ),
          ),
        )
      ],
    );
  }
}
