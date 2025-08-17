import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
class Profile {
  final String id;
  final String name;

  Profile({required this.id, required this.name});

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      id: json['_id'] ?? '',
      name: json['name'] ?? 'No Name',
    );
  }
}


Future<List<Profile>> fetchProfiles() async {
  final url = Uri.parse('https://empjewellery.shop/profilesDetails?profileType=customer');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final profiles = (data['profiles'] as List)
        .map((json) => Profile.fromJson(json))
        .toList();
    return profiles;
  } else {
    throw Exception('Failed to load profiles');
  }
}


class ProfileListScreen extends StatefulWidget {
  @override
  _ProfileListScreenState createState() => _ProfileListScreenState();
}

class _ProfileListScreenState extends State<ProfileListScreen> {
  late Future<List<Profile>> _futureProfiles;

  @override
  void initState() {
    super.initState();
    _futureProfiles = fetchProfiles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      body: FutureBuilder<List<Profile>>(
        future: _futureProfiles,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final profiles = snapshot.data!;
          if (profiles.isEmpty) {
            return const Center(child: Text('No customers found.'));
          }

          return ListView.builder(
            itemCount: profiles.length,
            itemBuilder: (context, index) {
              final profile = profiles[index];
              return ListTile(
                title: Text(profile.name),
                leading: const CircleAvatar(child: Icon(Icons.person)),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => AddPaymentPage(profile: profile),
                  //   ),
                  // );
                },
              );
            },
          );
        },
      ),
    );
  }
}
