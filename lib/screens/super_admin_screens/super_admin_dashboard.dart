import 'package:aiq/screens/login_screen.dart';
import 'package:aiq/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../models/company.dart';
import '../../models/feedback_model.dart';
import '../../models/payment_model.dart';
import '../../viewmodels/super_admin_viewmodel.dart';
import '../../services/analytics_service.dart';
import '../../widgets/ai_analytics_chatbot.dart';

class SuperAdminDashboard extends StatefulWidget {
  const SuperAdminDashboard({super.key});
  @override
  State<SuperAdminDashboard> createState() => _SuperAdminDashboardState();
}

class _SuperAdminDashboardState extends State<SuperAdminDashboard> {
  int _selectedIndex = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers for the Dialog
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ownerNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController maxUsersController = TextEditingController();
  final TextEditingController industryController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passController = TextEditingController();
  String selectedPlan = 'Basic';

  final List<String> _titles = [
    "Global Overview",
    "Companies",
    "Revenue Analytics",
    "Feedbacks",
    "Profile",
    "AI Analytics"
  ];

  @override
  void dispose() {
    nameController.dispose();
    ownerNameController.dispose();
    emailController.dispose();
    maxUsersController.dispose();
    industryController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = Provider.of<SuperAdminViewModel>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: Column(
          children: [
            _buildDrawerHeader(colorScheme),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildNavTile(context, Icons.dashboard, "Dashboard", 0),
                  _buildNavTile(context, Icons.business, "Companies", 1),
                  _buildNavTile(context, Icons.monetization_on, "Revenue", 2),
                  _buildNavTile(context, Icons.feedback, "Feedbacks", 3),
                  _buildNavTile(context, Icons.person, "Profile", 4),
                  _buildNavTile(context, Icons.auto_awesome, "AI Analytics", 5),
                  const Divider(),
                  _buildNavTile(context, Icons.logout, "Logout", -1,
                      isLogout: true),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [
          _OverviewScreen(),
          CompaniesScreen(),
          RevenueScreen(),
          _SuperAdminFeedbackScreen(),
          SuperAdminProfileScreen(),
          _SuperAdminAiAnalyticsScreen(),
        ],
      ),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton(
              onPressed: () => _showAddCompanyDialog(context, viewModel),
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildDrawerHeader(ColorScheme colorScheme) {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.primary, colorScheme.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white24,
            child: Icon(Icons.admin_panel_settings,
                color: Colors.white, size: 35),
          ),
          const SizedBox(height: 15),
          const Text(
            'AIQ Platform',
            style: TextStyle(
                fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          const Text(
            'Super Admin Portal',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile(BuildContext context, IconData icon, String title,
      int index,
      {bool isLogout = false}) {
    final isSelected = _selectedIndex == index;
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(
        icon,
        color: isLogout
            ? Colors.red
            : (isSelected
                ? colorScheme.primary
                : colorScheme.onSurfaceVariant),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isLogout
              ? Colors.red
              : (isSelected ? colorScheme.primary : colorScheme.onSurface),
        ),
      ),
      selected: isSelected,
      onTap: () {
        if (isLogout) {
          showConfirmDialog("Confirmation ","Are you sure to Logout?" );
        } else {
          setState(() => _selectedIndex = index);
          Navigator.pop(context);
        }
      },
    );
  }
  void showConfirmDialog(String title,String content){
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(context: context, builder: (context)=>
        StatefulBuilder(builder: (context,setDialogState)=>AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(onPressed: (){
              Navigator.pop(context);
            }, child: Text("Cancel")),
            ElevatedButton(onPressed: (){
              FirebaseAuth.instance.signOut();
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (context)=>LoginScreen()));

            }, child:Text(
              "LogOut"
            ))


          ],

        )));


  }

  static InputDecoration getInputDecoration(
      String label, IconData icon, ColorScheme colorScheme) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: colorScheme.primary),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.outline.withOpacity(0.5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: colorScheme.primary, width: 2),
      ),
      filled: true,
      fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.3),
    );
  }

  void _showAddCompanyDialog(BuildContext context, SuperAdminViewModel vm) {
    nameController.clear();
    passController.clear();
    ownerNameController.clear();
    emailController.clear();
    industryController.clear();
    phoneController.clear();
    maxUsersController.text = "10";
    selectedPlan = 'Basic';

    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text("Register New Company"),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: getInputDecoration(
                          "Company Name", Icons.business, colorScheme),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: industryController,
                      decoration: getInputDecoration(
                          "Industry", Icons.category, colorScheme),
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ownerNameController,
                      decoration: getInputDecoration(
                          "Admin Name", Icons.person, colorScheme),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: getInputDecoration(
                          "Admin Email", Icons.email, colorScheme),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v!.contains('@') ? null : "Invalid Email",
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passController,
                      decoration: getInputDecoration(
                          "Set Password", Icons.password, colorScheme),
                      keyboardType: TextInputType.visiblePassword,
                      validator: (v) =>
                      v!.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]')) ? null : "Password must have atleast one special character",
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: getInputDecoration(
                          "Contact Number", Icons.phone, colorScheme),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPlan,
                      decoration: getInputDecoration(
                          "Subscription Plan", Icons.card_membership, colorScheme),
                      items: ['Basic', 'Pro', 'Enterprise'].map((String plan) {
                        return DropdownMenuItem(value: plan, child: Text(plan));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedPlan = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: maxUsersController,
                      decoration: getInputDecoration(
                          "Max Users", Icons.groups, colorScheme),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? "") == null
                          ? "Enter a number"
                          : null,
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
               onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  try {
                    await vm.addCompany(
                      name: nameController.text,
                      pass: passController.text,
                      ownerEmail: emailController.text,
                      ownerName: ownerNameController.text,
                      plan: selectedPlan,
                      maxUsers: int.parse(maxUsersController.text),
                      industry: industryController.text.isEmpty
                          ? null
                          : industryController.text,
                      phoneNumber: phoneController.text.isEmpty
                          ? null
                          : phoneController.text,
                    );
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("Company and Admin account created!")),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Error: $e")),
                      );
                    }
                  }
                }
              },
              child: const Text("Add Company"),
            ),
          ],
        ),
      ),
    );
  }
}

class CompaniesScreen extends StatelessWidget {
  const CompaniesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SuperAdminViewModel>(context);

    return StreamBuilder<List<Company>>(
      stream: viewModel.companiesStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return Center(child: Text("Error: ${snapshot.error}"));
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text("No companies found."));
        }

        final companies = snapshot.data!;
        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: companies.length,
          itemBuilder: (context, index) {
            final company = companies[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                onTap: () => _showEditCompanyDialog(context, viewModel, company),
                leading: CircleAvatar(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  child: Icon(Icons.business,
                      color: Theme.of(context).colorScheme.primary),
                ),
                title: Text(company.name,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${company.plan} Plan • Max ${company.maxUsers} Users"),
                    Text("${company.ownerName} (${company.ownerEmail})"),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: company.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            company.isActive ? "Active" : "Inactive",
                            style: TextStyle(
                              color: company.isActive ? Colors.green : Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (company.industry != null) ...[
                          const SizedBox(width: 8),
                          Text("• ${company.industry}", style: const TextStyle(fontSize: 12)),
                        ]
                      ],
                    ),
                  ],
                ),
                isThreeLine: true,
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.payment, color: Colors.blue),
                      onPressed: () => _showRecordPaymentDialog(context, viewModel, company),
                      tooltip: "Record Payment",
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      onPressed: () => _confirmDelete(context, viewModel, company),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showRecordPaymentDialog(BuildContext context, SuperAdminViewModel vm, Company company) {
    final amountController = TextEditingController();
    double suggestedAmount = 0;
    if (company.plan == 'Basic') suggestedAmount = company.maxUsers * SuperAdminViewModel.priceBasic;
    if (company.plan == 'Pro') suggestedAmount = company.maxUsers * SuperAdminViewModel.pricePro;
    if (company.plan == 'Enterprise') suggestedAmount = company.maxUsers * SuperAdminViewModel.priceEnterprise;
    amountController.text = suggestedAmount.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Record Payment for ${company.name}"),
        content: TextField(
          controller: amountController,
          decoration: _SuperAdminDashboardState.getInputDecoration("Amount (₹)", Icons.account_balance_wallet, Theme.of(context).colorScheme),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              final amount = double.tryParse(amountController.text) ?? 0;
              if (amount > 0) {
                vm.recordManualPayment(company, amount);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Payment recorded successfully")));
              }
            },
            child: const Text("Confirm Payment"),
          ),
        ],
      ),
    );
  }

  void _showEditCompanyDialog(BuildContext context, SuperAdminViewModel vm, Company company) {
    final nameController = TextEditingController(text: company.name);
    final ownerNameController = TextEditingController(text: company.ownerName);
    final emailController = TextEditingController(text: company.ownerEmail);
    final maxUsersController = TextEditingController(text: company.maxUsers.toString());
    final industryController = TextEditingController(text: company.industry ?? "");
    final phoneController = TextEditingController(text: company.phoneNumber ?? "");
    final passController = TextEditingController(text: company.companyPass);
    String selectedPlan = company.plan;
    bool isActive = company.isActive;
    bool isTrackingEnabled = company.settings['tracking_enabled'] ?? true;
    
    final formKey = GlobalKey<FormState>();
    final colorScheme = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text("Edit ${company.name}"),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: nameController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Company Name", Icons.business, colorScheme),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: industryController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Industry", Icons.category, colorScheme),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Company Status (Active)"),
                      value: isActive,
                      onChanged: (val) => setDialogState(() => isActive = val),
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: ownerNameController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Admin Name", Icons.person, colorScheme),
                      validator: (v) => v!.isEmpty ? "Required" : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: emailController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Admin Email", Icons.email, colorScheme),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                          v!.contains('@') ? null : "Invalid Email",
                    ),
                    TextFormField(
                      controller: passController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Set Password ", Icons.password, colorScheme),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) =>
                      v!.contains(RegExp(r'[!@#%^&*(),.?":{}|<>]')) ? null : "Password should have a special character ",
                    ),


                    const SizedBox(height: 16),
                    TextFormField(
                      controller: phoneController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Contact Number", Icons.phone, colorScheme),
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    const Divider(),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedPlan,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Subscription Plan", Icons.card_membership, colorScheme),
                      items: ['Basic', 'Pro', 'Enterprise'].map((String plan) {
                        return DropdownMenuItem(value: plan, child: Text(plan));
                      }).toList(),
                      onChanged: (val) => setDialogState(() => selectedPlan = val!),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: maxUsersController,
                      decoration: _SuperAdminDashboardState.getInputDecoration(
                          "Max Users", Icons.groups, colorScheme),
                      keyboardType: TextInputType.number,
                      validator: (v) => int.tryParse(v ?? "") == null
                          ? "Enter a number"
                          : null,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text("Activity Tracking"),
                      subtitle: const Text("Enable desktop activity logging"),
                      value: isTrackingEnabled,
                      onChanged: (val) => setDialogState(() => isTrackingEnabled = val),
                    ),
                  ],
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel")),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  final updatedCompany = company.copyWith(
                    name: nameController.text,
                    companyPass: passController.text,
                    ownerEmail: emailController.text,
                    ownerName: ownerNameController.text,
                    plan: selectedPlan,
                    maxUsers: int.parse(maxUsersController.text),
                    industry: industryController.text.isEmpty ? null : industryController.text,
                    phoneNumber: phoneController.text.isEmpty ? null : phoneController.text,
                    isActive: isActive,
                    settings: {
                      ...company.settings,
                      'tracking_enabled': isTrackingEnabled,
                    },
                  );
                  vm.updateCompany(updatedCompany);
                  Navigator.pop(context);
                }
              },
              child: const Text("Save Changes"),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(
      BuildContext context, SuperAdminViewModel vm, Company company) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Company"),
        content: Text(
            "Are you sure you want to delete ${company.name}? This will remove all their data."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              vm.removeCompany(company.companyId);
              Navigator.pop(context);
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class RevenueScreen extends StatelessWidget {
  const RevenueScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SuperAdminViewModel>(context);

    return StreamBuilder<List<Company>>(
      stream: viewModel.companiesStream,
      builder: (context, companySnapshot) {
        return StreamBuilder<List<PaymentRecord>>(
          stream: viewModel.paymentsStream,
          builder: (context, paymentSnapshot) {
            if (companySnapshot.connectionState == ConnectionState.waiting ||
                paymentSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final companies = companySnapshot.data ?? [];
            final payments = paymentSnapshot.data ?? [];

            final projectedRevenue = viewModel.calculateProjectedMonthlyRevenue(companies);
            final actualRevenue = viewModel.calculateTotalActualRevenue(payments);
            final actualCosts = viewModel.calculateTotalCosts(actualRevenue);
            final netProfit = viewModel.calculateNetProfit(actualRevenue);

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Financial Summary", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRevenueCard(
                          context,
                          "Total Revenue",
                          "₹${actualRevenue.toStringAsFixed(0)}",
                          Icons.account_balance_wallet,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRevenueCard(
                          context,
                          "Projected (Monthly)",
                          "₹${projectedRevenue.toStringAsFixed(0)}",
                          Icons.trending_up,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRevenueCard(
                          context,
                          "Actual Costing (10%)",
                          "₹${actualCosts.toStringAsFixed(0)}",
                          Icons.request_quote,
                          Colors.orange,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildRevenueCard(
                          context,
                          "Net Profit",
                          "₹${netProfit.toStringAsFixed(0)}",
                          Icons.savings,
                          Colors.teal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text("Recent Transactions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  if (payments.isEmpty)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: Text("No transactions recorded yet.")))
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: payments.length,
                      itemBuilder: (context, index) {
                        final payment = payments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: const Icon(Icons.receipt_long, color: Colors.grey),
                            title: Text(payment.companyName),
                            subtitle: Text("${payment.timestamp.day}/${payment.timestamp.month}/${payment.timestamp.year} • ${payment.plan} Plan"),
                            trailing: Text(
                              "+₹${payment.amount.toStringAsFixed(0)}",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildRevenueCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 15),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
        ],
      ),
    );
  }
}

class SuperAdminProfileScreen extends StatelessWidget {
  const SuperAdminProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            leading: Icon(Icons.admin_panel_settings),
            title: Text("Super Admin"),
            subtitle: Text("Platform owner and company lifecycle manager"),
          ),
          ListTile(
            leading: Icon(Icons.security),
            title: Text("Controls"),
            subtitle: Text("Companies, billing, feedback, AI analytics"),
          ),
        ],
      );
}

class _SuperAdminFeedbackScreen extends StatelessWidget {
  const _SuperAdminFeedbackScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SuperAdminViewModel>(context);

    return StreamBuilder<List<FeedbackModel>>(
      stream: viewModel.feedbackStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        final feedback = snapshot.data ?? [];
        if (feedback.isEmpty) {
          return const Center(child: Text("No feedback submitted yet."));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: feedback.length,
          itemBuilder: (context, index) {
            final item = feedback[index];
            const statuses = ["Open", "In Review", "Resolved"];
            final selectedStatus =
                statuses.contains(item.status) ? item.status : statuses.first;
            return Card(
              child: ListTile(
                leading: const Icon(Icons.feedback_outlined),
                title: Text("${item.companyName} • ${item.category}"),
                subtitle: Text("${item.userName} (${item.role}): ${item.message}"),
                trailing: DropdownButton<String>(
                  value: selectedStatus,
                  underline: const SizedBox(),
                  items: statuses
                      .map((status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ))
                      .toList(),
                  onChanged: (status) {
                    if (status != null) {
                      viewModel.updateFeedbackStatus(item.feedbackId, status);
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
}

class _SuperAdminAiAnalyticsScreen extends StatelessWidget {
  const _SuperAdminAiAnalyticsScreen();

  @override
  Widget build(BuildContext context) {
    final viewModel = Provider.of<SuperAdminViewModel>(context);

    return StreamBuilder<List<Company>>(
      stream: viewModel.companiesStream,
      builder: (context, companySnapshot) {
        return StreamBuilder<List<PaymentRecord>>(
          stream: viewModel.paymentsStream,
          builder: (context, paymentSnapshot) {
            return StreamBuilder<List<FeedbackModel>>(
              stream: viewModel.feedbackStream,
              builder: (context, feedbackSnapshot) {
                final companies = companySnapshot.data ?? [];
                final payments = paymentSnapshot.data ?? [];
                final feedback = feedbackSnapshot.data ?? [];
                final projectedRevenue =
                    viewModel.calculateProjectedMonthlyRevenue(companies);
                final actualRevenue =
                    viewModel.calculateTotalActualRevenue(payments);
                final docs = <Map<String, dynamic>>[
                  {
                    "title": "Platform Snapshot",
                    "content":
                        "Companies ${companies.length}, projected monthly revenue ${projectedRevenue.toStringAsFixed(0)}, actual revenue ${actualRevenue.toStringAsFixed(0)}, feedback items ${feedback.length}.",
                    "metadata": {"type": "platform"}
                  },
                  ...companies.map((company) => {
                        "title": "Company ${company.name}",
                        "content":
                            "Plan ${company.plan}, max users ${company.maxUsers}, active ${company.isActive}, owner ${company.ownerName}, industry ${company.industry ?? 'unknown'}.",
                        "metadata": {
                          "type": "company",
                          "companyId": company.companyId
                        }
                      }),
                  ...payments.take(30).map((payment) => {
                        "title": "Payment ${payment.companyName}",
                        "content":
                            "Amount ${payment.amount}, status ${payment.status}, plan ${payment.plan}, timestamp ${payment.timestamp}.",
                        "metadata": {
                          "type": "payment",
                          "paymentId": payment.paymentId
                        }
                      }),
                  ...feedback.take(30).map((item) => {
                        "title": "Feedback ${item.companyName}",
                        "content":
                            "${item.category}, rating ${item.rating}/5, status ${item.status}: ${item.message}.",
                        "metadata": {
                          "type": "feedback",
                          "feedbackId": item.feedbackId
                        }
                      }),
                ];

                return AiAnalyticsChatbot(
                  role: "Super Admin",
                  documents: docs,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _OverviewScreen extends StatelessWidget {
  const _OverviewScreen();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Platform Status",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                    context, "Companies", "12", Icons.business, Colors.blue),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatCard(
                    context, "Users", "450", Icons.people, Colors.green),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStatCard(
              context, "System Health", "Optimal", Icons.speed, Colors.orange),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value,
      IconData icon, Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 15),
          Text(value,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Text(label,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
