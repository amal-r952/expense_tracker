import 'dart:io';
import 'package:expense_tracker/src/bloc/user_bloc.dart';
import 'package:expense_tracker/src/utils/app_assets.dart';
import 'package:expense_tracker/src/utils/object_factory.dart';
import 'package:expense_tracker/src/widgets/build_cached_network_image_widget.dart';
import 'package:expense_tracker/src/widgets/build_loading_widget.dart';
import 'package:expense_tracker/src/widgets/build_svg_icon.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';

import '../utils/constants.dart';
import '../utils/utils.dart';

class ProfilePictureEditWidget extends StatefulWidget {
  final String imageUrl;
  final Function(String?) image;

  const ProfilePictureEditWidget({
    Key? key,
    required this.imageUrl,
    required this.image,
  }) : super(key: key);

  @override
  State<ProfilePictureEditWidget> createState() =>
      _ProfilePictureEditWidgetState();
}

class _ProfilePictureEditWidgetState extends State<ProfilePictureEditWidget> {
  XFile? userImage;
  bool isUploading = false;
  String downloadUrl = "";
  UserBloc userBloc = UserBloc();

  @override
  void initState() {
    if (widget.imageUrl != "") {
      setState(() {
        downloadUrl = widget.imageUrl;
      });
    }
    userBloc.uploadImageResponse.listen((event) {
      print("UPLOAD IMAGE RESPONSE: $event");
      widget.image(event);
      setState(() {
        downloadUrl = event;
        isUploading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        userImage = await pickImage();
        if (userImage != null) {
          setState(() {
            isUploading = true;
          });
          await userBloc.uploadImage(
            folderName:
                '${ObjectFactory().appHive.getUserProfileEmail()}-expenseImages',
            imageFile: File(userImage!.path),
          );
        }
        setState(() {});
      },
      child: Container(
        height: 200,
        width: screenWidth(context, dividedBy: 1.3),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          shape: BoxShape.rectangle,
          border: Border.all(
            width: 0.5,
            color: Theme.of(context).dividerColor,
          ),
        ),
        child: downloadUrl == ""
            ? Center(
                child: isUploading
                    ? const Center(
                        child: BuildLoadingWidget(),
                      )
                    : const BuildSvgIcon(
                        assetImagePath: AppAssets.invoiceIcon,
                        iconHeight: 70,
                      ),
              )
            : isUploading
                ? const Center(
                    child: BuildLoadingWidget(),
                  )
                : BuildCachedNetworkImageWidget(
                    imageUrl: downloadUrl,
                    borderRadius: BorderRadius.circular(12.0),
                    boxFit: BoxFit.cover,
                  ),
      ),
    );
  }
}
