import 'package:flutter/material.dart';

class Likeable extends StatefulWidget {
  final Widget? child;
  final bool initiallyLiked;

  final void Function(bool newValue)? onLikeChanged;

  const Likeable({
    Key? key,
    this.child,
    this.initiallyLiked = false,
    this.onLikeChanged,
  }) : super(key: key);

  @override
  _LikeableState createState() => _LikeableState();
}

class _LikeableState extends State<Likeable>
    with SingleTickerProviderStateMixin {
  static const _animationDuration = 140;

  late final _animationController = AnimationController(
    vsync: this,
    value: 0,
    duration: Duration(milliseconds: _animationDuration),
  );
  late final _animation = CurvedAnimation(
    parent: _animationController,
    curve: Curves.easeOutQuad,
  );

  late final void Function(bool newValue) _onLikeChanged =
      widget.onLikeChanged ?? (_) {};

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

    if (widget.initiallyLiked) toggleLike();
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
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onDoubleTap: () => _onLikeChanged(liked),
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

  const AnimatedHeart({Key? key, this.scale = 1.0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Transform.scale(
        scale: scale,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            Icon(
              Icons.favorite,
              color: Theme.of(context).scaffoldBackgroundColor,
              size: 28,
            ),
            Positioned(
              child: Text(
                '❤️',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
