import 'package:docs_clone/screens/document_screen.dart';
import 'package:docs_clone/screens/home.dart';
import 'package:docs_clone/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:routemaster/routemaster.dart';

final loggedOutRoute = RouteMap(routes: {
  '/': (rout) => const MaterialPage(child: LoginScreen()),
});

final loggedInRoute = RouteMap(routes: {
  '/': (route) => const MaterialPage(child: HomeScreen()),
  '/document/:id': (route) => MaterialPage(
          child: DocumentScreen(
        id: route.pathParameters['id'] ?? '',
      ))
});
