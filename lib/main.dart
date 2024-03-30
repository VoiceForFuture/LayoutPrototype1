import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:fl_chart/fl_chart.dart';


void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VoiceForFuture',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'VoiceForFuture'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


Function generateRandomContent = () {
  final random = Random();
  final words = <String>[
    'Lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing',
    'elit', 'sed', 'do', 'eiusmod', 'tempor', 'incididunt', 'ut', 'labore',
    'et', 'dolore', 'magna', 'aliqua', 'Ut', 'enim', 'ad', 'minim', 'veniam',
    'quis', 'nostrud', 'exercitation', 'ullamco', 'laboris', 'nisi', 'ut',
    'aliquip', 'ex', 'ea', 'commodo', 'consequat', 'Duis', 'aute', 'irure',
    'reprehenderit', 'in', 'voluptate', 'velit', 'esse', 'cillum', 'dolore',
    'eu', 'fugiat', 'nulla', 'pariatur', 'Excepteur', 'sint', 'occaecat',
    'cupidatat', 'non', 'proident', 'sunt', 'in', 'culpa', 'qui', 'officia',
    'deserunt', 'mollit', 'anim', 'id', 'est', 'laborum',
  ];
  final length = random.nextInt(1000) + 1;
  return List.generate(length, (index) => words[random.nextInt(words.length)]).join(' ');
};

class _MyHomePageState extends State<MyHomePage> {

  String author = 'Neuer Autor'; // Default author
  String region = 'Berlin'; // Default region

  Map<int, Post> posts = {};

  Post addPost(String title, String content, [String author = '']) {
    final id = posts.length;
    if (author.isEmpty) {
      author = this.author;
    }
    posts[id] = Post(title: title, content: content, author: author);
    setState(() {
      posts = Map.from(posts);
    });
    return posts[id]!;
  }

  void addComment(int postId, String comment) {
    posts[postId]?.comments.add(comment);
    setState(() {
      posts = Map.from(posts);
    });
  }

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    // Generate some random posts
    for (var i = 0; i < 3; i++) {
      Post post = addPost('Beitrag $i', generateRandomContent(), 'Autor $i');
      post.score = Random().nextInt(42);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> widgetOptions = <Widget>[
      ForumSection(posts: posts.values.toList()),
      VotingSection(posts: posts.values.toList()),
      SettingsSection(author: author, setAuthor: (newAuthor) => setState(() => author = newAuthor), region: region, setRegion: (newRegion) => setState(() => region = newRegion)),
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text('Region: $region'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SearchPage(posts: posts.values.toList())),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filter functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Filter not implemented yet.'),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: widgetOptions.elementAt(_selectedIndex),
      ),
      floatingActionButton: _selectedIndex != 2 ? FloatingActionButton(
        onPressed: () {
          // Add new post
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewPostPage(addPost: addPost)),
          );
        },
        tooltip: 'Beitrag hinzufügen',
        child: const Icon(Icons.add),
      ) : null,
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.forum),
            label: 'Forum',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.how_to_vote),
            label: 'Abstimmungen',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}



class ForumSection extends StatelessWidget {
  final List<Post> posts;
  const ForumSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return PostList(posts: posts, onTabWidget: (post) => PostDetailPage(post: post), leading: const Icon(Icons.forum));
  }
}



class VotingSection extends StatelessWidget {
  final List<Post> posts;
  const VotingSection({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return PostList(posts: posts, onTabWidget: (post) => PostVotingPage(post: post), leading: const Icon(Icons.how_to_vote));
  }
}



class PostList extends StatelessWidget {
  final List<Post> posts;
  final Widget Function(Post post) onTabWidget;
  final Widget leading;
  const PostList({super.key, required this.posts, required this.onTabWidget, this.leading = const Icon(Icons.forum)});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        int len = min(post.content.length, 100);
        if (post.content.split('\n').isNotEmpty) {
          if (post.content.split('\n')[0].length < len) {
            len = post.content.split('\n')[0].length;
          }
        }
        return ListTile(
          leading: leading,
          title: Text(post.title),
          subtitle: Text('${post.content.substring(0, len)}... von ${post.author}'),
          // trailing: Text('Score: ${post.score}'),
          onTap: () {
            // Navigate to the detail page on tap
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => onTabWidget(post)),
            );
          },
        );
      },
    );
  }
}



class SettingsSection extends StatefulWidget {
  final String author;
  final Function(String newAuthor) setAuthor;
  final String region;
  final Function(String newRegion) setRegion;

  const SettingsSection({
    super.key,
    required this.author,
    required this.setAuthor,
    required this.region,
    required this.setRegion,
  });

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}


class _SettingsSectionState extends State<SettingsSection> {
  late TextEditingController _authorController;
  late TextEditingController _regionController;

  @override
  void initState() {
    super.initState();
    _authorController = TextEditingController(text: widget.author);
    _regionController = TextEditingController(text: widget.region);
  }

  @override
  void didUpdateWidget(covariant SettingsSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.author != oldWidget.author && widget.author != _authorController.text) {
      _authorController.value = _authorController.value.copyWith(
        text: widget.author,
        selection: _authorController.selection,
        composing: TextRange.empty,
      );
    }
    if (widget.region != oldWidget.region && widget.region != _regionController.text) {
      _regionController.value = _regionController.value.copyWith(
        text: widget.region,
        selection: _regionController.selection,
        composing: TextRange.empty,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextField(
            decoration: const InputDecoration(
              labelText: 'Region',
            ),
            controller: _regionController,
            onChanged: (newRegion) {
              widget.setRegion(newRegion);
            },
          ),
          const SizedBox(height: 16.0),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Author',
            ),
            controller: _authorController,
            onChanged: (newAuthor) {
              widget.setAuthor(newAuthor);
            },
          ),
        ],
      ),
    );
  }
}



class NewPostPage extends StatelessWidget {
  final Function(String title, String content) addPost;
  final String defaultTitle;
  final String defaultContent;

  const NewPostPage({
    super.key, 
    required this.addPost,
    this.defaultTitle = 'Irgendein Titel',
    this.defaultContent = 'Spannender Inhalt...',
  });

  @override
  Widget build(BuildContext context) {
    // Initialize text editing controllers with default values
    final titleController = TextEditingController(text: defaultTitle);
    final contentController = TextEditingController(text: defaultContent);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Neuer Beitrag'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Titel',
                ),
              ),
              const SizedBox(height: 16.0),
              TextField(
                controller: contentController,
                decoration: const InputDecoration(
                  labelText: 'Inhalt',
                ),
                maxLines: null,
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Use addPost callback to add the post
                  addPost(titleController.text, contentController.text);

                  // Optionally, clear the controllers or navigate away
                  titleController.clear();
                  contentController.clear();
                  Navigator.pop(context);
                },
                child: const Text('Beitrag'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class Post {
  static int _idCounter = 0;
  final int id = _idCounter++;
  final String title;
  final String content;
  final String author;
  final String creationDate = DateTime.now().toString();
  final List<String> comments = [];
  int score = 0;
  final Map<String, int> votes = {
    'Stimme zu': 1,
    'Keine Meinung': 1,
    'Stimme nicht zu': 1,
  };

  Post({required this.title, required this.content, required this.author});

  void addComment(int postId, String comment) {
    comments.add(comment);
  }

  void updateScore(int postId, int score) {
    this.score += score;
  }
}


class PostDetailPage extends StatefulWidget {
  final Post post;

  const PostDetailPage({super.key, required this.post});

  @override
  State<PostDetailPage> createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
  
  final TextEditingController _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  void _submitComment() {
    widget.post.addComment(widget.post.id, _commentController.text);
    setState(() {
      widget.post.comments;
    });
    _commentController.clear();
  }

  late final _focusNode = FocusNode(
    onKeyEvent: (FocusNode node, KeyEvent evt) {
      if (HardwareKeyboard.instance.isControlPressed && evt.logicalKey.keyLabel == 'Enter') {
        if (evt is KeyDownEvent) {
          _submitComment();
        }
        return KeyEventResult.handled;
      }
      else {
        return KeyEventResult.ignored;
      }
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    'Relevanz: ${widget.post.score}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(width: 16),
                  IconButton(
                    icon: const Icon(Icons.arrow_upward),
                    onPressed: () {
                      widget.post.updateScore(widget.post.id, 1);
                      setState(() {});
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.arrow_downward),
                    onPressed: () {
                      widget.post.updateScore(widget.post.id, -1);
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Von ${widget.post.author} am ${widget.post.creationDate}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                widget.post.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Kommentare',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final comment in widget.post.comments)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(comment),
                ),
              widget.post.comments.isEmpty
                  ? const Text('Noch keine Kommentare. Sei der Erste!')
                  : const SizedBox.shrink(),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        hintText: 'Kommentar hinzufügen...',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: null,
                      focusNode: _focusNode,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _submitComment,
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class PostVotingPage extends StatefulWidget {
  final Post post;

  const PostVotingPage({super.key, required this.post});

  @override
  State<PostVotingPage> createState() => _PostVotingPageState();
}

class _PostVotingPageState extends State<PostVotingPage> {
  final List<Color> _colors = [Colors.green, Colors.blue, Colors.red, Colors.yellow, Colors.purple, Colors.orange, Colors.teal];
  List<PieChartSectionData> getSections() {
    final totalVotes = widget.post.votes.values.fold<int>(0, (sum, item) => sum + item);
    return widget.post.votes.entries.indexed.map((x) {
      final i = x.$1;
      final entry = x.$2;
      const double fontSize = 16;
      const double radius = 50;
      final votePercentage = ((entry.value / totalVotes) * 100).toStringAsFixed(1);
      return PieChartSectionData(
        color: _colors[i],
        value: entry.value.toDouble(),
        title: '${entry.key} ($votePercentage%)',
        radius: radius,
        titleStyle: const TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 0, 0, 0)),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Abstimmung für ${widget.post.title}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.post.title,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                widget.post.content,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 16),
              Text(
                'Relevanz: ${widget.post.score}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Von ${widget.post.author} am ${widget.post.creationDate}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 16),
              Text(
                'Abstimmung',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Container(
                alignment: Alignment.center,
                height: 300,
                child: PieChart(
                  PieChartData(
                    sections: getSections(),
                    centerSpaceRadius: 40,
                    sectionsSpace: 2,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final vote in widget.post.votes.keys)
                    TextButton(
                      onPressed: () {
                        widget.post.votes[vote] = widget.post.votes[vote]! + 1;
                        setState(() {});
                      },
                      child: Text(vote),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class SearchPage extends StatefulWidget {
  final List<Post> posts;

  const SearchPage({super.key, required this.posts});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<Post> _searchResults = [];
  String _searchQuery = "";

  void _updateSearchQuery(String newQuery) {
    setState(() {
      _searchQuery = newQuery.toLowerCase();
      _searchResults = widget.posts.where((post) {
        return post.title.toLowerCase().contains(_searchQuery) ||
               post.content.toLowerCase().contains(_searchQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Beiträge durchsuchen'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Suche...',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.search),
              ),
              autofocus: true,
              onChanged: _updateSearchQuery,
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                final post = _searchResults[index];
                return ListTile(
                  title: Text(post.title),
                  subtitle: Text('${post.content.substring(0, min<int>(post.content.length, 100))}... by ${post.author}'),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => PostDetailPage(post: post)),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
