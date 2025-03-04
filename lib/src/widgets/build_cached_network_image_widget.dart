import 'package:cached_network_image/cached_network_image.dart';
import 'package:expense_tracker/src/utils/utils.dart';
import 'package:flutter/material.dart';

class BuildCachedNetworkImageWidget extends StatelessWidget {
  final BorderRadius? borderRadius;
  final Color? color;
  final double? height;
  final double? width;
  final BoxFit? boxFit;
  final String imageUrl;
  final BoxShape? boxShape;
  final Widget? placeHolder;

  const BuildCachedNetworkImageWidget({
    Key? key,
    required this.imageUrl,
    this.boxShape,
    this.borderRadius,
    this.placeHolder,
    this.boxFit,
    this.height,
    this.width,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: borderRadius,
        color: color,
        shape: boxShape ?? BoxShape.rectangle,
      ),
      width: width ?? screenWidth(context),
      height: height ?? screenHeight(context),
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        imageBuilder: (context, imageProvider) => Container(
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            shape: boxShape ?? BoxShape.rectangle,
            image: DecorationImage(
              image: imageProvider,
              fit: boxFit ?? BoxFit.cover,
            ),
          ),
        ),
        placeholder: (context, url) => placeHolder ?? const SizedBox(),
        errorWidget: (context, url, error) => const Icon(Icons.error),
      ),
    );
  }
}
