import 'package:flutter/material.dart';
import 'package:protalk_frontend/frames/Test.dart';
import 'package:protalk_frontend/flutter/examples/api/lib/widgets/navigator/navigator.0.dart';
//import 'package:flutter_svg/flutter_svg.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ProTalk Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SplashWithLogo(),
      routes: {
        '/screen1' : (context) => const Screen1(),
        '/screen2' : (context) => const Screen2(),
        '/test' : (context) => const ModeSelectionScreen(),
      },
    );
  }
} 

class Screen1 extends StatelessWidget {
  const Screen1 ({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(title: const Text('Регистрация'),),
      body: const Center(child: Text('Регистрация'),),
    );
  }
}

class Screen2 extends StatelessWidget {
  const Screen2 ({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold (
      appBar: AppBar(title: const Text('Вход'),),
      body: const Center(child: Text('Вход'),),
    );
  }
}

class SplashWithLogo extends StatefulWidget {
  const SplashWithLogo({super.key});

  @override
  State<SplashWithLogo> createState() => _SplashWithLogoState();
}

class _SplashWithLogoState extends State<SplashWithLogo> {
  bool _showMainScreen = false;
  bool _animateLogo = false;

  @override
  void initState () {
    super.initState();
    Future.delayed( const Duration (seconds: 2), () {
      setState(() {
        _animateLogo = true;
      });
      Future.delayed( const Duration (milliseconds: 500), (){
        setState(() {
          _showMainScreen = true;
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF2F2F2F),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _showMainScreen ? 1.0 : 0.0, 
            duration: const Duration(milliseconds: 500),
            child:  Center (
              child:Column (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/screen1'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 140, vertical: 30),
                    ),
                    child: const Text('Регистрация'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/screen2'),
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 160, vertical: 30),
                     ),
                     child: const Text('Вход'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                     onPressed: () => Navigator.pushNamed(context, '/test'),
                     style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 160, vertical: 30),
                     ),
                     child: const Text('Тест'),
                  ),
                ],
              ) ,
              ),
            ),

          //Center(
           //child: AnimatedContainer(
           // duration: const Duration( milliseconds: 500 ),
            //curve: Curves.easeInOut,
            //margin:  _animateLogo ? EdgeInsets.only( bottom: MediaQuery.of (context).size.height * 0.3) : EdgeInsets.zero,
            //child: SvgPicture.asset(
              //'assets/images/Logo.svg',
              // width: _animateLogo ? 100 : 200,
              // height: _animateLogo ? 100 : 200,
              // ),
            //) 
          //) 
        ]
      )
    );
  }
}
