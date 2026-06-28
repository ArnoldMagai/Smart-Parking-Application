import 'package:flutter/material.dart';
import 'notifications_page.dart';
import 'privacy_policy_page.dart';
import 'terms_page.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../main.dart';

class ProfilePage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback onThemeToggle;

  const ProfilePage({Key? key, required this.isDarkMode, required this.onThemeToggle}) : super(key: key);
  
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}  

  class _ProfilePageState extends State<ProfilePage> {

   String? profileImagePath;
   final ImagePicker picker = ImagePicker();

    Future<void> loadProfileImage() async {

      final prefs = await SharedPreferences.getInstance();

      setState(() {
        profileImagePath =
            prefs.getString('profile_image');
      });
    }

    Future<void> pickImage(ImageSource source) async {

      final XFile? image =
          await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image == null) return;

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
          'profile_image',
          image.path);

      setState(() {
        profileImagePath = image.path;
      });
    }

    void showImagePickerOptions() {

      showModalBottomSheet(
        context: context,
        builder: (context) {

          return SafeArea(
            child: Wrap(
              children: [

                ListTile(
                  leading: const Icon(
                    Icons.camera_alt,
                  ),
                  title: const Text(
                    'Take Photo',
                  ),
                  onTap: () {
  
                    Navigator.pop(context);

                    pickImage(
                        ImageSource.camera);

                  },
                ),

                 ListTile(
                   leading: const Icon(
                     Icons.photo,
                  ),
                  title: const Text(
                    'Choose from Gallery',
                  ),
                  onTap: () {

                    Navigator.pop(context);

                    pickImage(
                        ImageSource.gallery);

                  },
                ),

              ],
            ),
          );
        },
      );
    }

    @override
    void initState() {
      super.initState();
      loadProfileImage();
    }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
          title: const Text('Profile'),
         actions: [
           TextButton(
             onPressed: () {},
             child: const Text('Save', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
       body: SingleChildScrollView(
         padding: const EdgeInsets.all(16.0),
         child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: showImagePickerOptions,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage:
                          profileImagePath != null

                          ?FileImage(
                            File(profileImagePath!),
                          ) as ImageProvider

                          : const NetworkImage('https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?auto=format&fit=crop&q=80&w=200',) as ImageProvider,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: showImagePickerOptions,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                        ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            _buildTextField(context, 'Full Name', 'John Doe'),
            const SizedBox(height: 16),
            _buildTextField(context, 'Phone Number', '+1 555-0123'),
            const SizedBox(height: 16),
            _buildTextField(context, 'Email (Optional)', 'john.doe@example.com'),
            const SizedBox(height: 32),
            _buildSection(context, [
              _buildListTile(
                Icons.language,
                'Language', 
                trailing: const Text(
                  'English',
                ),
                onTap: () {
                 showDialog(
                   context: context,
                   builder: (_) {
                     return AlertDialog(
                       title: const Text(
                         "Choose languge",
                       ),
                       content: Column(
                         mainAxisSize:
                            MainAxisSize.min,
                         children: [
                           ListTile(
                             title:
                                 const Text("English"),
                             onTap: () {Navigator.pop(context);},
                           ),
                           ListTile(
                             title:
                                 const Text("Swahili"),
                             onTap: () {Navigator.pop(context);},    
                            ),
                          ],  
                        ),    
                      );  
                    },
                  );
                },
              ),
              const Divider(height: 1),
              _buildListTile(
                Icons.notifications,
                'Notifications',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const NotificationsPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(widget.isDarkMode ? Icons.dark_mode : Icons.light_mode),
                title: const Text('Theme'),
                trailing: Text(widget.isDarkMode ? 'Dark' : 'Light', style: const TextStyle(color: Colors.grey)),
                onTap: widget.onThemeToggle,
              ),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, [
              _buildListTile(
                Icons.star,
                'Rate App',
                onTap: () {

                  showDialog(
                    context: context,
                    builder: (_) {

                      return AlertDialog(

                        title: const Text(
                            "Rate App"),
 
                        content: const Text(
                          "Thank you for using Smart Parking.",
                        ),
 
                        actions: [

                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context);
                            },
                            child: const Text(
                                "Later"),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                  context);
                            },
                            child: const Text(
                                "Rate"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
              const Divider(height: 1),
              _buildListTile(Icons.security, 'Privacy Policy', onTap: (){Navigator.push(context, MaterialPageRoute(builder: (_) => const PrivacyPolicyPage(),),);},),
              const Divider(height: 1),
              _buildListTile(Icons.description, 'Terms and Conditions', onTap: (){Navigator.push(context, MaterialPageRoute(builder: (_) => const TermsPage(),),);}),
            ]),
            const SizedBox(height: 16),
            _buildSection(context, [
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Log Out', style: TextStyle(color: Colors.red)),
                onTap: () async{
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.remove('driver_logged_in');
                  await prefs.remove('profile_image');
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const SmartParkingApp(),), (route) => false);
                }
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Delete My Account', style: TextStyle(color: Colors.red)),
                onTap: () {

                  showDialog(

                    context: context,

                    builder: (_) {

                      return AlertDialog(

                        title: const Text(
                          "Delete Account",
                        ),

                        content: const Text(
                          "This action cannot be undone.",
                        ),

                        actions: [

                          TextButton(
                            onPressed: () {
                              Navigator.pop(
                                  context);
                            },
                            child:
                                const Text("Cancel"),
                          ),

                          ElevatedButton(
                            onPressed: () {

                              Navigator.pop(
                                  context);

                            },
                            child:
                                const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ]),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(BuildContext context, String label, String initialValue) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).colorScheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          ),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildListTile(IconData icon, String title, {Widget? trailing, VoidCallback? onTap,}) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (trailing != null) trailing,
          if (trailing != null) const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}