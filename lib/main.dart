import 'dart:async';
import 'package:flutter/material.dart';
import 'db/database.dart';

void main() async {
  await DBManager.shared().init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: SqlTest());
  }
}

class SqlTest extends StatefulWidget {
  _SqlTestState createState() => _SqlTestState();
}

class _SqlTestState extends State<SqlTest> {
  final db = DBManager.shared();
  List<Map<String, dynamic>> _data = [];

  @override
  initState() {
    super.initState();
    if (mounted) {
      _refreshSomething();
    }
  }

  @override
  dispose() {
    super.dispose();
  }

  Widget _buildBody(BuildContext context) {
    return ListView.builder(
      itemBuilder: (context, index) {
        final map = _data[index];
        final id = map['id'];
        // DATA IS STRING IN ANDROID 
        // DATA IS STRING IN IOS
        final data = map['data_utf'];
        return ListTile(
          title: Text('$id'),
          subtitle: Text('Data is string :${data is String}'),
        );
      },
      itemCount: _data.length,
    );
  }

  Future<Null> _refreshSomething() async {
    final res = await db.fetchData();
    setState(() => _data = res);
    return null;
  }

  void _addDataToDB() async {
    final success = await db.saveData();
    if (success) {
      _refreshSomething();
    }
    print('SAVING DATA SUCCESS : $success');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('SQLITE BUG'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.add),
          onPressed: _addDataToDB,
        )
      ]),
      body: RefreshIndicator(
        child: _buildBody(context),
        onRefresh: _refreshSomething,
      ),
    );
  }
}
