import 'package:flutter/material.dart';

class Roles {
  static const student = 'student';
  static const staff = 'staff';
}

class IncidentStatus {
  static const submitted = 'Submitted';
  static const inProgress = 'In Progress';
  static const resolved = 'Resolved';
  static const all = [submitted, inProgress, resolved];
}

class IncidentCategory {
  final String name;
  final IconData icon;
  const IncidentCategory(this.name, this.icon);
}

const incidentCategories = [
  IncidentCategory('Facilities', Icons.apartment),
  IncidentCategory('Water', Icons.water_drop_outlined),
  IncidentCategory('Electricity', Icons.bolt),
  IncidentCategory('Safety', Icons.shield_outlined),
  IncidentCategory('Sanitation', Icons.delete_outline),
  IncidentCategory('Other', Icons.more_horiz),
];

// Edit these to match real places on your campus
const campusLocations = [
  'Student Residence',
  'Classroom Block',
  'Library',
  'Cafeteria',
  'Sports Ground',
  'Other',
];