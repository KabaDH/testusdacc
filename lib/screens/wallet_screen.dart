import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:testusdacc/providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:testusdacc/repo/clients.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class WalletScreen extends StatefulHookConsumerWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => WalletScreenState();
}

class WalletScreenState extends ConsumerState<WalletScreen> {
  bool balanceHidden = false;
  List<String> currencies = ['USD Dollar', 'RUB Ruble'];

  @override
  void setState(VoidCallback fn) {
    super.setState(fn);
  }

  List<Widget> _buildShimmer() {
    List<Widget> output = [];
    //header Shimmer
    output.add(Shimmer.fromColors(
        baseColor: Colors.grey[600]!,
        highlightColor: Colors.grey[200]!,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          decoration: const BoxDecoration(color: Colors.white),
          child: const Text(
            '',
            style: TextStyle(color: Colors.black54, fontSize: 20),
          ),
        )));
    //Rows Shimmers
    final shimmer = Shimmer.fromColors(
        baseColor: Colors.grey[400]!,
        highlightColor: Colors.grey[100]!,
        child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 1),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              children: const [
                ListTile(
                    leading: SizedBox(
                      width: 50,
                      height: 50,
                    ),
                    title: Text(
                      '',
                      style: TextStyle(
                          fontSize: 18, overflow: TextOverflow.ellipsis),
                    ),
                    subtitle: Text(
                      '',
                      style: TextStyle(
                          fontSize: 14, overflow: TextOverflow.ellipsis),
                    ),
                    trailing: Text(
                      '',
                      style: TextStyle(
                          fontSize: 18, overflow: TextOverflow.ellipsis),
                    )),
                Divider(
                  thickness: 1.5,
                ),
              ],
            )));
    output.add(shimmer);
    output.add(shimmer);

    return output;
  }

  _buildHeader(String text) {
    bool yesterday = DateFormat('EE, MMM yy')
                .format(DateTime.now().subtract(const Duration(days: 1))) ==
            text
        ? true
        : false;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(color: Colors.grey),
      child: Text(
        (yesterday) ? 'Yesterday' : text,
        style: const TextStyle(color: Colors.black, fontSize: 20),
      ),
    );
  }

  _buildRow(List<dynamic> rowParams) {
    return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: const BoxDecoration(color: Colors.white),
        child: Column(
          children: [
            ListTile(
              leading: Container(
                width: 50,
                height: 50,
                padding: EdgeInsets.zero,
                decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black26)),
                child: clientsIconsRepo.containsKey(rowParams[2])
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(50.0),
                        child: Image.asset(
                          clientsIconsRepo[rowParams[2]] ?? 'assets/arrowLeft',
                          height: 50,
                          width: 50,
                          fit: BoxFit.fitWidth,
                        ),
                      )
                    : rowParams[3] < 0
                        ? Image.asset(
                            'assets/arrowRight.png',
                            fit: BoxFit.fitWidth,
                          )
                        : Image.asset(
                            'assets/arrowLeft.png',
                            fit: BoxFit.fitWidth,
                          ),
              ),
              title: Text(
                rowParams[2],
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 18, overflow: TextOverflow.ellipsis),
              ),
              subtitle: Text(
                DateFormat('HH:mm')
                    .format(DateTime.parse(rowParams[1].toString())),
                maxLines: 1,
                style: const TextStyle(
                    fontSize: 14, overflow: TextOverflow.ellipsis),
              ),
              trailing: rowParams[3] < 0
                  ? Text(
                      '- \$${double.parse(rowParams[3].toString()).abs()} ${rowParams[4]}',
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 18, overflow: TextOverflow.ellipsis),
                    )
                  : Text(
                      '+ \$${rowParams[3]} ${rowParams[4]}',
                      maxLines: 1,
                      style: const TextStyle(
                          fontSize: 18, overflow: TextOverflow.ellipsis),
                    ),
            ),
            const Divider(
              thickness: 1.5,
            ),
          ],
        ));
  }

  List<Widget> allTransac(
      {required AsyncValue<List<List<dynamic>>> listTrans}) {
    return listTrans.when(
        data: (data) {
          List<Widget> output = []; //это то, что будем возвращать в итоге
          List<DateTime> dates = [];
          //Находим в какие даты были транзакции
          for (var element in data) {
            dates.add(element[1]);
          }
          //Удаляем дубликаты
          dates = dates.toSet().toList();
          //Сортируем
          dates.sort((a, b) => b.compareTo(a));
          //Поблочно создаем вывод
          for (var element in dates) {
            output.add(_buildHeader(DateFormat('EE, MMM yy').format(element)));
            data.where((e) => e[1] == element).forEach((el) {
              output.add(_buildRow(el));
            });
          }

          return output;
        },
        error: (e, _) => [Text(e.toString())],
        loading: () => _buildShimmer());
  }

  @override
  Widget build(BuildContext context) {
    final walletBalance = ref.watch(providerWalletBallance);
    final transactionData = ref.watch(providerTransactionsList);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(
            Icons.keyboard_backspace,
            size: 30,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text('Goto the previous page'),
              duration: Duration(seconds: 1),
            ));
          },
        ),
        actions: [
          IconButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                  content: Text('Launch smth'),
                  duration: Duration(seconds: 1),
                ));
              },
              icon: const Icon(
                Icons.launch,
                size: 30,
              ))
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(
            height: 30,
          ),
          Container(
            width: 100,
            height: 100,
            decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.green,
                image: DecorationImage(
                    image: AssetImage('assets/usaflag.png'),
                    fit: BoxFit.fitHeight)),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Spacer(),
              const Spacer(),
              const Text(
                'USD Account',
                style: TextStyle(color: Colors.white38, fontSize: 24),
              ),
              const Spacer(),
              Flexible(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      balanceHidden = !balanceHidden;
                    });
                  },
                  child: Container(
                    height: 35,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.white38)),
                    child: const Center(
                      child: Text(
                        'Hide',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              const Spacer(),
              const Text(
                '\u0024',
                style: TextStyle(color: Colors.white, fontSize: 22),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                (balanceHidden) ? '*********' : walletBalance,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.w500),
              ),
              const Spacer()
            ],
          ),
          const SizedBox(
            height: 40,
          ),
          Container(
            width: double.infinity,
            padding:
                const EdgeInsets.only(left: 15, right: 15, top: 30, bottom: 30),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Transactions History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.white38),
                      borderRadius: BorderRadius.circular(10)),
                  child: DropdownButtonHideUnderline(
                      child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      icon: const Icon(Icons.keyboard_arrow_down),
                      dropdownColor: Colors.black38,
                      items: currencies
                          .map((e) => DropdownMenuItem(
                                value: e,
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                  ),
                                ),
                              ))
                          .toList(),
                      onChanged: (e) {},
                      value: 'USD Dollar',
                    ),
                  )),
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(10)),
                        child: DropdownButtonHideUnderline(
                            child: ButtonTheme(
                          alignedDropdown: true,
                          child: DropdownButton<String>(
                            icon: const Icon(Icons.keyboard_arrow_down),
                            dropdownColor: Colors.black38,
                            items: ['All', 'not All']
                                .map((e) => DropdownMenuItem(
                                      value: e,
                                      child: Text(
                                        e,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                        ),
                                      ),
                                    ))
                                .toList(),
                            onChanged: (e) {},
                            value: 'All',
                          ),
                        )),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(10)),
                        child: IconButton(
                          onPressed: () {
                            ref
                                .read(providerTransactionsList.notifier)
                                .initList();
                          },
                          icon: const Icon(
                            Icons.calendar_today_outlined,
                            color: Colors.white,
                          ),
                        )),
                  ],
                ),
              ],
            ),
          ),
          ...allTransac(listTrans: transactionData)
        ],
      ),
    );
  }
}
