import 'dart:convert';
import 'package:api_project/products.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Details',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ImageList(),
    );
  }
}

class ImageList extends StatefulWidget {
  @override
  _ImageListState createState() => _ImageListState();
}

class _ImageListState extends State<ImageList> {
  late Future<List<ProductModels>> _imageData;

  @override
  void initState() {
    super.initState();
    _imageData = fetchImageData();
  }

  Future<List<ProductModels>> fetchImageData() async {
    var responseData = [];
    final response =
        await http.get(Uri.parse('https://dummyjson.com/products'));
    if (response.statusCode == 200) {
      responseData.add(json.decode(response.body));
      return responseData
          .map((json) => ProductModels.fromJson(json))
          .toList();
    } else {
      throw Exception('Failed to load image data');
    }
  }

  void _navigateToDetailScreen(
      BuildContext context, ProductModels imageData) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageDetailScreen(
          title: imageData.products[0].title,
          description: imageData.products[0].description,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Image Details'),
      ),
      body: FutureBuilder<List<ProductModels>>(
        future: _imageData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            return ListView.builder(
              itemCount: snapshot.data![0].products.length,
              itemBuilder: (context, index) {
                var product = snapshot.data![0].products[index];
                return GestureDetector(
                  onTap: () {
                    _navigateToDetailScreen(context, snapshot.data![index]);
                  },
                  child: Column(
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          leading: Container(
                            width: 50,
                            height: 50,
                            child: Image.network(
                              snapshot.data![0].products[index].thumbnail,
                              fit: BoxFit.cover,
                            ),
                          ),
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.title,
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'ID: ${product.id}',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 9.0),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}


class ImageDetailScreen extends StatelessWidget {
  final String title;
  final String description;

  ImageDetailScreen({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Container(
        color: Color.fromARGB(255, 236, 231, 238), // Change the background color here
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              description,
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
      ),
    );
  }
}

class ImageData {
  final int id;
  final String title;
  final String description;
  final String thumbnailUrl;

  ImageData({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  factory ImageData.fromJson(json) {
    return ImageData(
      id: json['id'],
      title: json['title'],
      description: json['url'], 
      thumbnailUrl: json['thumbnailUrl'],
    );
  }
}