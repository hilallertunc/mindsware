import 'package:flutter/material.dart';

final ThemeData mindsWareTheme = ThemeData(
  primaryColor: const Color(0xFF4A90E2), 
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), 
  colorScheme: ColorScheme.light(
    primary: const Color(0xFF4A90E2),  
    secondary: const Color(0xFF50C878),  
    tertiary: const Color(0xFFFFA726), 
    background: const Color(0xFFF5F5F5),
    surface: Colors.white,
    onPrimary: Colors.white,            
    onSecondary: Colors.white,          
    onTertiary: Colors.black,           
    onBackground: const Color(0xFF212121), 
    onSurface: const Color(0xFF757575),   
  ),
  textTheme: const TextTheme(
    headlineMedium: TextStyle(color: Color(0xFF212121), fontWeight: FontWeight.bold),
    bodyMedium: TextStyle(color: Color(0xFF757575)),
  ),
);
