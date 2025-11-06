import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/user_management_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/database/database_helper.dart';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  State<UserManagementPage> createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'User Management',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _showAddUserDialog(),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add New User'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _buildUsersList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUsersList() {
    return Consumer<UserManagementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final users = provider.users;
        if (users.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.people_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No users found',
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          itemCount: users.length,
          itemBuilder: (context, index) {
            final user = users[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: user['role'] == 'Admin'
                      ? AppColors.primary
                      : AppColors.secondary,
                  child: Text(
                    user['name'].toString().substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(user['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${user['email']} | @${user['username']}'),
                    Text(
                      'Role: ${user['role']}',
                      style: TextStyle(
                        color: user['role'] == 'Admin'
                            ? AppColors.primary
                            : AppColors.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: PopupMenuButton(
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') {
                      _showEditUserDialog(user);
                    } else if (value == 'delete') {
                      _showDeleteConfirmation(user);
                    }
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAddUserDialog() {
    showDialog(
      context: context,
      builder: (context) => _AddUserDialog(
        onUserAdded: () {
          Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
        },
      ),
    );
  }

  void _showEditUserDialog(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => _EditUserDialog(
        user: user,
        onUserUpdated: () {
          Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
        },
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user['name']}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              await DatabaseHelper.instance.deleteUser(user['id']);
              if (mounted) {
                Navigator.pop(context);
                Provider.of<UserManagementProvider>(context, listen: false).loadUsers();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User deleted successfully')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

/// Add User Dialog
class _AddUserDialog extends StatefulWidget {
  final VoidCallback onUserAdded;

  const _AddUserDialog({required this.onUserAdded});

  @override
  State<_AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<_AddUserDialog> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  String _selectedRole = 'Cashier';
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New User'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                  helperText: 'Min 3 characters, no spaces',
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value!.length < 3) return 'Min 3 characters';
                  if (value.contains(' ')) return 'No spaces allowed';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  helperText: 'Min 6 characters',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (value!.length < 6) return 'Min 6 characters';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cashier', child: Text('Cashier')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value ?? 'Cashier'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Add User'),
        ),
      ],
    );
  }

  Future<void> _addUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final success = await DatabaseHelper.instance.registerUser(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          username: _usernameController.text.trim(),
          password: _passwordController.text,
          role: _selectedRole,
        );

        if (success && mounted) {
          Navigator.pop(context);
          widget.onUserAdded();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User added successfully')),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Email or username already exists'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

/// Edit User Dialog
class _EditUserDialog extends StatefulWidget {
  final Map<String, dynamic> user;
  final VoidCallback onUserUpdated;

  const _EditUserDialog({
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<_EditUserDialog> createState() => _EditUserDialogState();
}

class _EditUserDialogState extends State<_EditUserDialog> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  late String _selectedRole;
  bool _isLoading = false;
  bool _changePassword = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user['name']);
    _emailController = TextEditingController(text: widget.user['email']);
    _passwordController = TextEditingController();
    _selectedRole = widget.user['role'];
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit User: ${widget.user['name']}'),
      content: Form(
        key: _formKey,
        child: SizedBox(
          width: 400,
          child: ListView(
            shrinkWrap: true,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (!value!.contains('@')) return 'Invalid email';
                  return null;
                },
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: widget.user['username'],
                decoration: const InputDecoration(
                  labelText: 'Username (Cannot be changed)',
                  border: OutlineInputBorder(),
                  filled: true,
                  fillColor: Colors.grey,
                ),
                enabled: false,
              ),
              const SizedBox(height: 12),

              CheckboxListTile(
                title: const Text('Change Password'),
                value: _changePassword,
                onChanged: (value) {
                  setState(() {
                    _changePassword = value ?? false;
                    if (!_changePassword) {
                      _passwordController.clear();
                    }
                  });
                },
              ),

              if (_changePassword)
                Column(
                  children: [
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        border: const OutlineInputBorder(),
                        helperText: 'Min 6 characters',
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (_changePassword) {
                          if (value?.isEmpty ?? true) return 'Required';
                          if (value!.length < 6) return 'Min 6 characters';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Cashier', child: Text('Cashier')),
                  DropdownMenuItem(value: 'Admin', child: Text('Admin')),
                ],
                onChanged: (value) => setState(() => _selectedRole = value ?? 'Cashier'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _updateUser,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : const Text('Save Changes'),
        ),
      ],
    );
  }

  Future<void> _updateUser() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        Map<String, dynamic> updateData = {
          'name': _nameController.text.trim(),
          'email': _emailController.text.trim(),
          'role': _selectedRole,
        };

        if (_changePassword && _passwordController.text.isNotEmpty) {
          updateData['password'] = _passwordController.text;
        }

        final success = await DatabaseHelper.instance.updateUser(
          widget.user['id'],
          updateData,
        );

        if (success && mounted) {
          Navigator.pop(context);
          widget.onUserUpdated();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User updated successfully')),
          );
        } else {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Failed to update user'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}