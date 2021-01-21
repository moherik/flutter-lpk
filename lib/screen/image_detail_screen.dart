import 'package:flutter/material.dart';

class ImageDetailScreen extends StatefulWidget {
  String url;

  ImageDetailScreen(String url) {
    this.url = url;
  }

  @override
  _ImageDetailScreenState createState() => _ImageDetailScreenState();
}

class _ImageDetailScreenState extends State<ImageDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Hero(
              tag: 'imageHero${widget.url}',
              child: Image.network('${widget.url}', loadingBuilder:
                  (BuildContext context, Widget child,
                      ImageChunkEvent progress) {
                if (progress == null) return child;

                return Center(
                  child: CircularProgressIndicator(
                    value: progress.expectedTotalBytes != null
                        ? progress.cumulativeBytesLoaded /
                            progress.expectedTotalBytes
                        : null,
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}
