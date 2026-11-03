import 'package:flutter/material.dart';
import '../theme.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String selectedFilter = 'All';
  String searchText = '';

  final List<TransactionItem> transactions = [
    TransactionItem(
      title: 'Rahul Kumar',
      subtitle: 'UPI Payment',
      amount: -250,
      date: 'Today, 5:20 PM',
      icon: Icons.arrow_upward_rounded,
      isSent: true,
    ),
    TransactionItem(
      title: 'Added Money',
      subtitle: 'UPI • Wallet Top-up',
      amount: 1000,
      date: 'Today, 2:15 PM',
      icon: Icons.add_rounded,
      isSent: false,
    ),
    TransactionItem(
      title: 'Priya Sharma',
      subtitle: 'Received Money',
      amount: 500,
      date: 'Yesterday, 7:42 PM',
      icon: Icons.arrow_downward_rounded,
      isSent: false,
    ),
    TransactionItem(
      title: 'Campus Canteen',
      subtitle: 'Scan & Pay',
      amount: -120,
      date: 'Yesterday, 1:10 PM',
      icon: Icons.qr_code_scanner_rounded,
      isSent: true,
    ),
    TransactionItem(
      title: 'Amazon',
      subtitle: 'UPI Payment',
      amount: -799,
      date: '22 Sep, 6:35 PM',
      icon: Icons.shopping_bag_outlined,
      isSent: true,
    ),
    TransactionItem(
      title: 'Added Money',
      subtitle: 'UPI • Wallet Top-up',
      amount: 2000,
      date: '21 Sep, 10:20 AM',
      icon: Icons.add_rounded,
      isSent: false,
    ),
  ];

  List<TransactionItem> get filteredTransactions {
    return transactions.where((transaction) {
      final matchesFilter =
          selectedFilter == 'All' ||
          (selectedFilter == 'Sent' && transaction.isSent) ||
          (selectedFilter == 'Received' && !transaction.isSent);

      final query = searchText.trim().toLowerCase();

      final matchesSearch =
          query.isEmpty ||
          transaction.title.toLowerCase().contains(query) ||
          transaction.subtitle.toLowerCase().contains(query);

      return matchesFilter && matchesSearch;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final list = filteredTransactions;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          'Transaction History',
          style: TextStyle(
            color: AstraTheme.textBlue,
            fontSize: 22,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showFilterInfo(context);
            },
            icon: const Icon(
              Icons.tune_rounded,
              color: AstraTheme.textBlue,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterRow(),
          Expanded(
            child: list.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      8,
                      18,
                      100,
                    ),
                    itemCount: list.length,
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                    itemBuilder: (context, index) {
                      final transaction = list[index];
                      return _buildTransactionCard(transaction);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 10),
      child: Container(
        decoration: BoxDecoration(
          color: AstraTheme.lightBlue,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AstraTheme.borderBlue,
          ),
        ),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search transactions',
            prefixIcon: Icon(
              Icons.search_rounded,
              color: AstraTheme.primaryBlue,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRow() {
    const filters = [
      'All',
      'Sent',
      'Received',
    ];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        children: filters.map((filter) {
          final isSelected = selectedFilter == filter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) {
                setState(() {
                  selectedFilter = filter;
                });
              },
              selectedColor: AstraTheme.primaryBlue,
              backgroundColor: Colors.white,
              side: BorderSide(
                color: isSelected
                    ? AstraTheme.primaryBlue
                    : AstraTheme.borderBlue,
              ),
              labelStyle: TextStyle(
                color: isSelected
                    ? Colors.white
                    : AstraTheme.textBlue,
                fontWeight: FontWeight.w700,
              ),
              showCheckmark: false,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildTransactionCard(TransactionItem transaction) {
    final bool positive = transaction.amount > 0;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AstraTheme.borderBlue,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: positive
                  ? const Color(0xFFEAFBF0)
                  : AstraTheme.lightBlue,
              shape: BoxShape.circle,
            ),
            child: Icon(
              transaction.icon,
              color: positive
                  ? Colors.green
                  : AstraTheme.primaryBlue,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.title,
                  style: const TextStyle(
                    color: AstraTheme.textBlue,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.subtitle,
                  style: const TextStyle(
                    color: AstraTheme.secondaryText,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.date,
                  style: const TextStyle(
                    color: AstraTheme.secondaryText,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Text(
            positive
                ? '+ ₹${transaction.amount.abs().toStringAsFixed(0)}'
                : '- ₹${transaction.amount.abs().toStringAsFixed(0)}',
            style: TextStyle(
              color: positive
                  ? Colors.green
                  : const Color(0xFFE53935),
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: AstraTheme.lightBlue,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                size: 38,
                color: AstraTheme.primaryBlue,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'No transactions found',
              style: TextStyle(
                color: AstraTheme.textBlue,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Try changing the search or filter.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AstraTheme.secondaryText,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showFilterInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(24),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Transaction Filters',
                style: TextStyle(
                  color: AstraTheme.textBlue,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 18),
              _filterOption('All Transactions', 'All'),
              _filterOption('Sent Payments', 'Sent'),
              _filterOption('Received Payments', 'Received'),
              const SizedBox(height: 15),
            ],
          ),
        );
      },
    );
  }

  Widget _filterOption(String title, String value) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(
        selectedFilter == value
            ? Icons.radio_button_checked
            : Icons.radio_button_off,
        color: AstraTheme.primaryBlue,
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AstraTheme.textBlue,
          fontWeight: FontWeight.w600,
        ),
      ),
      onTap: () {
        setState(() {
          selectedFilter = value;
        });
        Navigator.pop(context);
      },
    );
  }
}

class TransactionItem {
  final String title;
  final String subtitle;
  final double amount;
  final String date;
  final IconData icon;
  final bool isSent;

  const TransactionItem({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.date,
    required this.icon,
    required this.isSent,
  });
}