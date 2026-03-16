import 'package:flutter/material.dart';

const gold = Color(0xFFD5EB45);
const bg = Color(0xff0B0D12);
const card = Color(0xff12141A);

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,

      body: CustomScrollView(
        slivers: [

          /// 🔥 APP BAR
          const SliverAppBar(
            pinned: true,
            backgroundColor: bg,
            title: Text("Payments"),
            centerTitle: true,
          ),

          /// 💰 BALANCE CARD
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: _balanceCard(),
            ),
          ),

          /// 🎯 FILTER
          const SliverToBoxAdapter(
            child: _filterTabs(),
          ),

          /// 💳 LIST
          SliverList(
            delegate: SliverChildListDelegate(
              const [
                PaymentCardNew(
                  name: "Rahul Das",
                  plan: "Gold Plan",
                  amount: "₹2000",
                  dueDate: "12 Feb",
                  due: true,
                ),
                PaymentCardNew(
                  name: "Arjun",
                  plan: "Premium Plan",
                  amount: "₹3000",
                  dueDate: "Paid",
                  due: false,
                ),
              ],
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 120))
        ],
      ),
    );
  }
}
Widget _balanceCard() {
  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: card,
      borderRadius: BorderRadius.circular(28),
      boxShadow: [
        BoxShadow(
          color: gold.withOpacity(0.15),
          blurRadius: 30,
        )
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [

        Text("Total Balance", style: TextStyle(color: Colors.white54)),

        SizedBox(height: 6),

        Text("₹45,000",
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),

        SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _stat("This Month", "₹30K"),
            _stat("Pending", "₹8K"),
            _stat("Today", "₹5K"),
          ],
        )
      ],
    ),
  );
}

class _stat extends StatelessWidget {
  final String t, v;
  const _stat(this.t, this.v);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(v,
            style: const TextStyle(
                color: gold, fontWeight: FontWeight.bold)),
        Text(t,
            style: const TextStyle(
                fontSize: 11, color: Colors.white54)),
      ],
    );
  }
}

class _filterTabs extends StatelessWidget {
  const _filterTabs();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: const [
            _tab("All", true),
            _tab("Paid", false),
            _tab("Due", false),
          ],
        ),
      ),
    );
  }
}

class _tab extends StatelessWidget {
  final String text;
  final bool active;
  const _tab(this.text, this.active);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: active ? gold : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(text,
              style: TextStyle(
                  color: active ? Colors.black : Colors.white)),
        ),
      ),
    );
  }
}

class PaymentCardNew extends StatelessWidget {
  final String name, plan, amount, dueDate;
  final bool due;

  const PaymentCardNew({
    super.key,
    required this.name,
    required this.plan,
    required this.amount,
    required this.dueDate,
    required this.due,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = due ? Colors.red : Colors.green;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),

      decoration: BoxDecoration(
        color: card,
        borderRadius: BorderRadius.circular(22),
      ),

      child: Row(
        children: [

          /// STATUS STRIPE
          Container(
            width: 6,
            height: 80,
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(22)),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [

                  Text(name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold)),

                  const SizedBox(height: 4),

                  Text(plan,
                      style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12)),

                  const SizedBox(height: 6),

                  Text(
                    due ? "Due on $dueDate" : "Paid",
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 12),
                  )
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [

                Text(amount,
                    style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold)),

                const SizedBox(height: 8),

                if (due)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: gold,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text("Collect",
                        style: TextStyle(
                            color: Colors.black,
                            fontSize: 11)),
                  )
              ],
            ),
          )
        ],
      ),
    );
  }
}