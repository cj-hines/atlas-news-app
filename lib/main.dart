import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Atlas News',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0x0f0f81)),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Color _clickColor = Colors.transparent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Atlas News'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('articles').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final articles = snapshot.data?.docs ?? [];
          return ListView.separated(
            itemCount: articles.length,
            itemBuilder: (context, index) {
              var article = articles[index];
              return MouseRegion(
                onEnter: (event) => setState(() => _clickColor = Colors.grey[200]!),
                onExit: (event) => setState(() => _clickColor = Colors.transparent),
                child: Container(
                  color: _clickColor,
                  child: ListTile(
                    leading: Image.network(article['thumbnail'], width: 100, fit: BoxFit.cover),
                    title: Text(article['headline']),
                    onTap: () => _launchURL(article['url']),
                  ),
                ),
              );
            },
            separatorBuilder: (context, index) => Divider(color: Theme.of(context).dividerColor),
          );
        },
      ),
    );
  }

  void _launchURL(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw '$url does not exist!';
    }
  }
}

