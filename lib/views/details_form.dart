import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'dart:convert';
import 'package:ghastep/views/dry.dart';
import 'package:ghastep/views/urlconfig.dart';
import 'package:ghastep/widgets/inputs.dart';
import 'package:ghastep/main.dart'; // Import to access global instance


class DetailsForm extends StatefulWidget {
  const DetailsForm({super.key});

  @override
  _DetailsFormState createState() => _DetailsFormState();
}

class _DetailsFormState extends State<DetailsForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String mobile = "";
  String token = "";
  College? _selectedCollege;
  final FocusNode _collegeFocusNode = FocusNode();
  final FlutterSecureStorage storage = const FlutterSecureStorage();

  // College search related variables
  final TextEditingController _collegeSearchController =
      TextEditingController();
  Timer? _debounceTimer;
  List<College> _colleges = [];
  bool _isLoadingColleges = false;
  // String _searchQuery = '';
  final ScrollController _scrollController = ScrollController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _collegeFocusNode.addListener(_onCollegeFocusChange);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _collegeSearchController.dispose();
    _collegeFocusNode.removeListener(_onCollegeFocusChange);
    _collegeFocusNode.dispose();
    _debounceTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }
  Future<String?> getCityFromIP() async {
  try {
    final response = await http.get(Uri.parse('http://ip-api.com/json'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['city']; // or 'regionName', 'country'
    }
  } catch (e) {
    print('Error fetching location: $e');
  }
  return null;
}


  void _onCollegeFocusChange() {
    if (_collegeFocusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  Future<void> _loadUserData() async {
    mobile = await storage.read(key: 'mobile') ?? '';
    token = await storage.read(key: 'token') ?? '';
    setState(() {});
  }

  Future<void> _fetchColleges(String prefix) async {
    if (prefix.isEmpty || token.isEmpty) {
      setState(() => _colleges = []);
      return;
    }

    setState(() => _isLoadingColleges = true);

    try {
      final response = await http.get(
        Uri.parse('$baseurl/app/colleges/search/$prefix/$token'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        print(
            '++++++++++++++++++++++++++++++++Response data: $data, api: $baseurl/app/colleges/search/$prefix/$token');
        setState(() {
          _colleges = data.map((college) => College.fromJson(college)).toList();
        });
      } else {
        showCustomSnackBar(
          context: context,
          message: 'Failed to load colleges',
          isSuccess: false,
        );
        setState(() => _colleges = []);
      }
    } catch (e) {
      showCustomSnackBar(
        context: context,
        message: 'Error: ${e.toString()}',
        isSuccess: false,
      );
      setState(() => _colleges = []);
    } finally {
      setState(() => _isLoadingColleges = false);
    }
  }

  void _onCollegeSearchChanged(String query) {
    // Clear selected college if user manually deletes the text
    if (query.isEmpty) {
      setState(() {
        _selectedCollege = null;
      });
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      _fetchColleges(query);
    });
  }

  Future<void> _updateUserDetails() async {
    if (_formKey.currentState!.validate() && !_isLoading) {
      String url = '$baseurl/app-users/update-app-user-details';
      setState(() {
        _isLoading = true;
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          body: {
            'token': token,
            'name': _nameController.text.trim(),
            'email': _emailController.text.trim(),
            'college': _selectedCollege?.collegeName ?? "",
            // 'college': _selectedCollege?.collegeName ??
            //     _collegeSearchController.text.trim(),
          },
        );
        print(
            '++++++++++++++++++++++++++++++++Response data: ${response.body}, api: $url');
        print({
          'token': token,
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'college': _selectedCollege?.collegeName ??
              _collegeSearchController.text.trim(),
        });
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['errFlag'] == 0) {
            try {
              // Log user data for Meta
              final currentCity = await getCityFromIP();
              await facebookAppEvents.setUserData(
                email: _emailController.text.trim(),
                firstName: _nameController.text.trim().split(" ").first,
                lastName: _nameController.text.trim().split(" ").length > 1
                    ? _nameController.text.trim().split(" ").sublist(1).join(" ")
                    : '',
                phone: mobile,
                city: currentCity ?? 'Unknown',
                country: 'IN',
              );

              // Track registration event
              await facebookAppEvents.logEvent(
                name: 'CompleteRegistration',
                parameters: {
                  'email': _emailController.text.trim(),
                  'name': _nameController.text.trim(),
                  'mobile': mobile,
                  'city': currentCity ?? 'Unknown',
                  'country': 'IN',
                  'college': _selectedCollege?.collegeName ??
                      _collegeSearchController.text.trim(),
                },
              );
            } catch (e) {
              // Log the error but don't block the user flow
              print('Facebook tracking error: $e');
            }

            // Success feedback + navigation
            showCustomSnackBar(
              context: context,
              message: data['message'],
              isSuccess: true,
            );
            await storage.write(
                key: 'userName', value: _nameController.text.trim());
            Navigator.pushNamed(context, "/select_course");
          } else {
            // Error from backend
            showCustomSnackBar(
              context: context,
              message: 'Please select a college',
              isSuccess: false,
            );
          }
        } else {
          // Server error
          showCustomSnackBar(
            context: context,
            message: 'Failed to update details. Please try again.',
            isSuccess: false,
          );
        }
      } catch (e) {
        // Exception handling
        showCustomSnackBar(
          context: context,
          message: 'An error occurred: $e',
          isSuccess: false,
        );
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Enter your details'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // College Search Field
                    const Text(
                      "College name",
                      style: TextStyle(
                        color: Color(0xFF323836),
                        fontSize: 16,
                        fontFamily: 'SF Pro Display',
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _collegeSearchController,
                      focusNode: _collegeFocusNode,
                      onChanged: _onCollegeSearchChanged,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide:
                              const BorderSide(color: Color(0xFFDDDDDD)),
                        ),
                        hintText: 'Search college...',
                        suffixIcon: _collegeSearchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close, size: 20),
                                onPressed: () {
                                  _collegeSearchController.clear();
                                  setState(() {
                                    _selectedCollege = null;
                                    _colleges = [];
                                  });
                                  _onCollegeSearchChanged('');
                                },
                              )
                            : const Icon(Icons.search),
                        prefixIcon: _isLoadingColleges
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.grey),
                                ),
                              )
                            : null,
                      ),
                      validator: (value) {
                        if ((_selectedCollege == null) &&
                            (value == null || value.isEmpty)) {
                          return 'Please select a college';
                        }
                        return null;
                      },
                    ),

                    // College List
                    if (_colleges.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.3,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemCount: _colleges.length,
                          itemBuilder: (context, index) {
                            final college = _colleges[index];
                            return ListTile(
                              title: Text(college.collegeName),
                              onTap: () {
                                setState(() {
                                  _selectedCollege = college;
                                  _collegeSearchController.text =
                                      college.collegeName;
                                  _colleges = [];
                                });
                                _collegeFocusNode.unfocus();
                              },
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 20),
                    formInputWithLabel(
                      _nameController,
                      "Enter your name",
                      "Name",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    formInputWithLabel(
                      TextEditingController(text: mobile),
                      "Mobile Number",
                      "Mobile",
                      readOnly: true,
                    ),
                    const SizedBox(height: 20),
                    formInputWithLabel(
                      _emailController,
                      "Enter your email",
                      "Email",
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your email';
                        } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                            .hasMatch(value)) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _updateUserDetails,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: _isLoading
                      ? const Color(0xFF247E80).withOpacity(0.7)
                      : const Color(0xFF247E80),
                  disabledBackgroundColor:
                      const Color(0xFF247E80).withOpacity(0.7),
                ),
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontFamily: 'SF Pro Display',
                              fontWeight: FontWeight.w500,
                              height: 1.50,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Proceed',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'SF Pro Display',
                          fontWeight: FontWeight.w500,
                          height: 1.50,
                        ),
                      ),
              ),
              // Proceed Button at Bottom
            ],
          ),
        ),
      ),
    );
  }
}

class College {
  final int id;
  final String collegeName;
  final String createdDate;
  final int createdAdminUserId;
  final int status;

  College({
    required this.id,
    required this.collegeName,
    required this.createdDate,
    required this.createdAdminUserId,
    required this.status,
  });

  factory College.fromJson(Map<String, dynamic> json) {
    return College(
      id: json['id'],
      collegeName: json['college_name'],
      createdDate: json['created_date'],
      createdAdminUserId: json['created_admin_user_id'],
      status: json['status'],
    );
  }
}
