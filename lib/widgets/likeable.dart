import 'package:flutter/material.dart';

class Likeable extends StatefulWidget {
  final Widget child;

  const Likeable({Key key, this.child}) : super(key: key);

  @override
  _LikeableState createState() => _LikeableState();
}

class _LikeableState extends State<Likeable>
    with SingleTickerProviderStateMixin {
  AnimationController _animationController;
  Animation _animation;

  bool liked = false;

  void toggleLike() {
    setState(() {
      liked = !liked;
      if (liked)
        _animationController.forward();
      else
        _animationController.reverse();
    });
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      value: 0,
      duration: Duration(milliseconds: 140),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutQuad,
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (_, __) => Padding(
        padding: EdgeInsets.only(bottom: 10 * _animation.value),
        child: Stack(
          overflow: Overflow.visible,
          children: [
            GestureDetector(
              onDoubleTap: toggleLike,
              child: widget.child,
            ),
            Positioned(
              bottom: -15,
              left: 5,
              child: AnimatedHeart(scale: _animation.value),
            ),
          ],
        ),
      ),
    );
  }
}

class AnimatedHeart extends StatelessWidget {
  final double scale;

  const AnimatedHeart({Key key, this.scale}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: scale,
      child: Stack(
        alignment: Alignment.center,
        overflow: Overflow.visible,
        children: [
          Icon(
            Icons.favorite,
            color: Theme.of(context).scaffoldBackgroundColor,
            size: 28,
          ),
          Positioned(
            bottom: 2,
            left: 2.7,
            child: Text(
              '❤️',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
