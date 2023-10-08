import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'sing_in.dart';
import 'sign_up.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Image.asset(
              'images/screen2.jpg',
              height: double.maxFinite,
              width: double.maxFinite,
              fit: BoxFit.fill,
            ),
            Positioned(
              bottom: 50,
              left: 30,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      Get.to(const SignIn(), transition: Transition.leftToRight);
                    },
                    child: Container(
                      height: 50,
                      width: 350,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Colors.transparent,
                          border: Border.all(color: Colors.white)),
                      child: const Text('Sign In'),
                    ),
                  ),
                  SizedBox(height: 10),
                  InkWell(
                    onTap: () {
                      Get.to(const SignUp(), transition: Transition.leftToRight);
                    },
                    child: Container(
                      height: 50,
                      width: 350,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                          vertical: 11, horizontal: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.transparent,
                        border: Border.all(color: Colors.white),
                      ),
                      child: const Text('Create an Account'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
