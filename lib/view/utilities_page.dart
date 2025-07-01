import 'package:flutter/material.dart';
import 'package:get/get.dart';

class UtilitiesPage extends StatefulWidget {
  const UtilitiesPage({Key? key}) : super(key: key);

  @override
  State<UtilitiesPage> createState() => _UtilitiesPageState();
}

class _UtilitiesPageState extends State<UtilitiesPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _amountController = TextEditingController();

  final _billAmountController = TextEditingController();

  String _selectedNetwork = 'MTN';
  String _selectedBill = 'Electricity';

  late TabController _tabController;

  final deepAmber = const Color(0xFFFFB300);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Utilities"),
        backgroundColor: deepAmber,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.black,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.phone_android), text: 'Airtime'),
            Tab(icon: Icon(Icons.receipt), text: 'Bills'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildAirtimeForm(),
          _buildBillForm(),
        ],
      ),
    );
  }

  Widget _buildAirtimeForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextInput(
              controller: _phoneController,
              label: "Phone Number",
              icon: Icons.phone_android,
              validator: (value) {
                if (value == null || value.length < 10) {
                  return "Enter a valid phone number";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextInput(
              controller: _amountController,
              label: "Amount (GHS)",
              icon: Icons.attach_money,
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || double.tryParse(value) == null) {
                  return "Enter a valid amount";
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedNetwork,
              dropdownColor: Colors.grey[900],
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration("Select Network", Icons.network_cell),
              items: ['MTN', 'Vodafone', 'AirtelTigo']
                  .map((net) => DropdownMenuItem(value: net, child: Text(net)))
                  .toList(),
              onChanged: (value) => setState(() => _selectedNetwork = value!),
            ),
            const SizedBox(height: 30),
            _buildActionButton("Buy Airtime", Icons.send_to_mobile, _buyAirtime),
          ],
        ),
      ),
    );
  }

  Widget _buildBillForm() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            value: _selectedBill,
            dropdownColor: Colors.grey[900],
            style: const TextStyle(color: Colors.white),
            decoration: _inputDecoration("Select Bill Type", Icons.receipt_long),
            items: ['Electricity', 'Water', 'DSTV', 'GOtv']
                .map((bill) => DropdownMenuItem(value: bill, child: Text(bill)))
                .toList(),
            onChanged: (value) => setState(() => _selectedBill = value!),
          ),
          const SizedBox(height: 16),
          _buildTextInput(
            controller: _billAmountController,
            label: "Amount (GHS)",
            icon: Icons.payments,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 30),
          _buildActionButton("Pay Bill", Icons.check_circle, _payBill),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: deepAmber),
      prefixIcon: Icon(icon, color: deepAmber),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: deepAmber),
        borderRadius: BorderRadius.circular(10),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: deepAmber, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  Widget _buildTextInput({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      validator: validator,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildActionButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.black),
        label: Text(label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
        style: ElevatedButton.styleFrom(
          backgroundColor: deepAmber,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  void _buyAirtime() {
    if (_formKey.currentState!.validate()) {
      Get.snackbar(
        "Airtime Purchased",
        "GHS ${_amountController.text} sent to ${_phoneController.text} on $_selectedNetwork",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      _phoneController.clear();
      _amountController.clear();
    }
  }

  void _payBill() {
    if (_billAmountController.text.isEmpty) {
      Get.snackbar(
        "Error",
        "Please enter a valid amount.",
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    Get.snackbar(
      "Bill Payment Successful",
      "You have paid your $_selectedBill bill of GHS ${_billAmountController.text}.",
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    _billAmountController.clear();
  }
}
