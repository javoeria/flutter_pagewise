import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:http/http.dart' as http;
import 'package:built_collection/built_collection.dart' show BuiltList;

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Pagewise Demo',
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
          appBar: AppBar(
            title: Text('Pagewise'),
            bottom: TabBar(tabs: [
              Tab(
                text: 'List',
              ),
              Tab(text: 'Grid'),
              Tab(text: 'SliverList'),
              Tab(text: 'SliverGrid')
            ]),
          ),
          body: TabBarView(
            children: [
              PagewiseListViewExample(),
              PagewiseGridViewExample(),
              PagewiseSliverListExample(),
              PagewiseSliverGridExample()
            ],
          )),
    );
  }
}

class PagewiseGridViewExample extends StatelessWidget {
  static const int PAGE_SIZE = 6;

  @override
  Widget build(BuildContext context) {
    return PagewiseGridView<ImageModel>.count(
      pageSize: PAGE_SIZE,
      crossAxisCount: 3,
      mainAxisSpacing: 8.0,
      crossAxisSpacing: 8.0,
      childAspectRatio: 0.555,
      padding: EdgeInsets.all(15.0),
      itemBuilder: this._itemBuilder,
      pageFuture: (pageIndex) =>
          BackendService.getImages(pageIndex! * PAGE_SIZE, PAGE_SIZE),
    );
  }

  Widget _itemBuilder(context, ImageModel entry, _) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: DecorationImage(
                          image: NetworkImage(entry.thumbnailUrl!),
                          fit: BoxFit.fill)),
                ),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                        height: 30.0,
                        child: SingleChildScrollView(
                            child: Text(entry.title!,
                                style: TextStyle(fontSize: 12.0))))),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  entry.id,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8.0)
            ]));
  }
}

class PagewiseListViewExample extends StatelessWidget {
  static const int PAGE_SIZE = 10;

  @override
  Widget build(BuildContext context) {
    return PagewiseListView<PostModel>(
        pageSize: PAGE_SIZE,
        itemBuilder: this._itemBuilder,
        pageFuture: (pageIndex) =>
            BackendService.getPosts(pageIndex! * PAGE_SIZE, PAGE_SIZE)
    );
  }

  Widget _itemBuilder(context, PostModel entry, _) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.person,
            color: Colors.brown[200],
          ),
          title: Text(entry.title!),
          subtitle: Text(entry.body!),
        ),
        Divider()
      ],
    );
  }
}

class PagewiseSliverListExample extends StatelessWidget {
  static const int PAGE_SIZE = 6;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      SliverAppBar(
        title: Text('This is a sliver app bar'),
        snap: true,
        floating: true,
      ),
      PagewiseSliverList<PostModel>(
          pageSize: PAGE_SIZE,
          itemBuilder: this._itemBuilder,
          pageFuture: (pageIndex) =>
              BackendService.getPosts(pageIndex! * PAGE_SIZE, PAGE_SIZE))
    ]);
  }

  Widget _itemBuilder(context, PostModel entry, _) {
    return Column(
      children: <Widget>[
        ListTile(
          leading: Icon(
            Icons.person,
            color: Colors.brown[200],
          ),
          title: Text(entry.title!),
          subtitle: Text(entry.body!),
        ),
        Divider()
      ],
    );
  }
}

class PagewiseSliverGridExample extends StatelessWidget {
  static const int PAGE_SIZE = 6;

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverAppBar(
          title: Text('This is a sliver app bar'),
          floating: true,
          snap: true,
        ),
        SliverPadding(
          padding: const EdgeInsets.all(8.0),
          sliver: PagewiseSliverGrid<ImageModel>.count(
            pageSize: 6,
            crossAxisCount: 3,
            mainAxisSpacing: 8.0,
            crossAxisSpacing: 8.0,
            childAspectRatio: 0.555,
            itemBuilder: this._itemBuilder,
            pageFuture: (pageIndex) =>
                BackendService.getImages(pageIndex! * PAGE_SIZE, PAGE_SIZE),
          ),
        )
      ],
    );
  }

  Widget _itemBuilder(context, ImageModel entry, _) {
    return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[600]!),
        ),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.grey[200],
                      image: DecorationImage(
                          image: NetworkImage(entry.thumbnailUrl!),
                          fit: BoxFit.fill)),
                ),
              ),
              SizedBox(height: 8.0),
              Expanded(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: SizedBox(
                        height: 30.0,
                        child: SingleChildScrollView(
                            child: Text(entry.title!,
                                style: TextStyle(fontSize: 12.0))))),
              ),
              SizedBox(height: 8.0),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  entry.id,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(height: 8.0)
            ]));
  }
}

class BackendService {
  static Future<BuiltList<PostModel>> getPosts(offset, limit) async {
    final responseBody = (await http.get(
            Uri.parse('https://jsonplaceholder.typicode.com/posts?_start=$offset&_limit=$limit')))
        .body;

    // The response body is an array of items
    var postList = PostModel.fromJsonList(json.decode(responseBody));
    if(postList == null) {
      postList = BuiltList<PostModel>();
    }
    return postList;
  }

  static Future<BuiltList<ImageModel>> getImages(offset, limit) async {
    final responseBody = (await http.get(
            Uri.parse('https://jsonplaceholder.typicode.com/photos?_start=$offset&_limit=$limit')))
        .body;

    // The response body is an array of items.
    var imageList = ImageModel.fromJsonList(json.decode(responseBody));
    if(imageList == null) {
      imageList = BuiltList<ImageModel>();
    }
    return imageList;
  }
}

class PostModel {
  String? title;
  String? body;

  PostModel.fromJson(obj) {
    this.title = obj['title'];
    this.body = obj['body'];
  }

  static BuiltList<PostModel>? fromJsonList(jsonList) {
    List<PostModel> list = jsonList.map<PostModel>((obj) => PostModel.fromJson(obj)).toList();
    return BuiltList<PostModel>(list);
  }
}

class ImageModel {
  String? title;
  late String id;
  String? thumbnailUrl;

  ImageModel.fromJson(obj) {
    this.title = obj['title'];
    this.id = obj['id'].toString();
    this.thumbnailUrl = obj['thumbnailUrl'];
  }

  static BuiltList<ImageModel>? fromJsonList(jsonList) {
    List<ImageModel> list = jsonList.map<ImageModel>((obj) => ImageModel.fromJson(obj)).toList();
    return BuiltList<ImageModel>(list);
  }
}
