import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  static const welcomeImage = 'welcome.jpg';

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
      ),
      home: Center(
        child: AdaptiveScaffold(
          compact: CompactView(welcomeImage: welcomeImage, formKey: _formKey),
          full: FullView(welcomeImage: welcomeImage, formKey: _formKey),
        ),
      ),
    );
  }
}

class LoginForm extends StatefulWidget {
   LoginForm({
    Key? key,
    required GlobalKey<FormState> formKey,
  })  : _formKey = formKey,
        super(key: key);

  final GlobalKey<FormState> _formKey;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {

  bool obscure = true;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
           Text(
            'Welcome back',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
           Text(
            'Login to manage your account.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
           SizedBox(height: 24),
          Form(
            key: widget._formKey,
            child: Column(children: [
              TextFormField(
                decoration:  InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Username *',
                ),
              ),
               SizedBox(height: 24),
              TextFormField(
                obscureText: obscure,
                decoration:  InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Password *',
                  suffix: IconButton(
                    icon: Icon(
                        obscure?Icons.visibility:Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        obscure = !obscure;
                      });
                  },)
                ),
              )
            ]),
          ),
           SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              elevation: 0,
              backgroundColor: Colors.blue,
              minimumSize:  Size(1024, 60),
            ),
            child:  Text(
              'Login',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class HeroImage extends StatelessWidget {
   HeroImage({
    Key? key,
    required this.welcomeImage,
  }) : super(key: key);

  final String welcomeImage;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(welcomeImage),
              fit: BoxFit.cover,
            ),
          ),
        ),
        Positioned(
          bottom: 24,
          left: 24,
          child: Text(
            'Start your\njourney with us.',
            maxLines: 2,
            style: textTheme.headlineMedium!.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Positioned(
          top: 24,
          left: 24,
          child: Row(
            children: [
               Icon(
                Icons.sunny_snowing,
                color: Colors.white,
                size: 30,
              ),
               SizedBox(width: 8),
              Text(
                'Big Corp.',
                maxLines: 2,
                style: textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}

class CompactView extends StatelessWidget {
   CompactView({
    Key? key,
    required this.welcomeImage,
    required GlobalKey<FormState> formKey,
  })  : _formKey = formKey,
        super(key: key);

  final String welcomeImage;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.4,
            child: HeroImage(welcomeImage: welcomeImage),
          ),
          LoginForm(formKey: _formKey),
        ],
      );
    });
  }
}

class FullView extends StatelessWidget {
   FullView({
    Key? key,
    required this.welcomeImage,
    required GlobalKey<FormState> formKey,
  })  : _formKey = formKey,
        super(key: key);

  final String welcomeImage;
  final GlobalKey<FormState> _formKey;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Row(
        children: [
          Flexible(child: LoginForm(formKey: _formKey)),
          Flexible(
            child: HeroImage(welcomeImage: welcomeImage),
          ),
        ],
      );
    });
  }
}

class AdaptiveScaffold extends StatelessWidget {
  final Widget full;
  final Widget compact;

   AdaptiveScaffold({
    required this.full,
    required this.compact,
    super.key,
  });

  factory AdaptiveScaffold.single({required Widget body}) {
    return AdaptiveScaffold(full: body, compact: body);
  }

  factory AdaptiveScaffold.multi({
    required Widget full,
    required Widget compact,
  }) {
    return AdaptiveScaffold(full: full, compact: compact);
  }

  @override
  Widget build(Object context) {
    return LayoutBuilder(builder: (context, constraints) {
      if (constraints.isMobile) {
        return Scaffold(body: compact);
      } else {
        return Scaffold(body: full);
      }
    });
  }
}

extension BreakpointUtils on BoxConstraints {
  bool get isTablet => maxWidth > 730;
  bool get isDesktop => maxWidth > 1200;
  bool get isMobile => !isTablet && !isDesktop;
}