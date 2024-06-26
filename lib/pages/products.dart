import 'package:data_table_2/data_table_2.dart';
import 'package:easy_pos/helpers/sql_helper.dart';
import 'package:easy_pos/models/product.dart';
import 'package:easy_pos/pages/products_ops.dart';
import 'package:easy_pos/widgets/app_table.dart';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class ProductsPage extends StatefulWidget {
  const ProductsPage({super.key});

  @override
  State<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends State<ProductsPage> {
  List<Product>? products;
  bool _showWidget = false;
  int pressedCount = 0;
  bool stockFilterPressed = false;
  bool availableFilterPressed = false;
  @override
  void initState() {
    getProducts();
    super.initState();
  }

  void getProducts() async {
    try {
      var sqlHelper = GetIt.I.get<SqlHelper>();
      if (stockFilterPressed){}
      var data = await sqlHelper.db!.rawQuery("""
      select P.* ,C.name as categoryName,C.description as categoryDesc 
      from products P
      inner join categories C
      where P.categoryId = C.id And stock >10
      """);

      if (data.isNotEmpty) {
        products = [];
        for (var item in data) {
          products!.add(Product.fromJson(item));
        }
      } else {
        products = [];
      }
    } catch (e) {
      print('Error In get data $e');
      products = [];
    }
    setState(() {});
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
              onPressed: () async {
                var result = await Navigator.push(context,
                    MaterialPageRoute(builder: (ctx) => ProductsOpsPage()));
                if (result ?? false) {
                  getProducts();
                }
              },
              icon: const Icon(Icons.add))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // search,filter,sort row
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [
              Container(
                width: 295,
                height: 50,
                child: TextField(
                  onChanged: (value) async {
                    var sqlHelper = GetIt.I.get<SqlHelper>();
                    var result = await sqlHelper.db!.rawQuery("""
        SELECT * FROM Products
        WHERE name LIKE '%$value%' OR description LIKE '%$value%' OR price LIKE '%$value%';
          """);
                    if (result.isNotEmpty) {
                      products = [];
                      for (var item in result) {
                        products!.add(Product.fromJson(item));
                      }
                    } else {
                      products = [];
                    }
                    setState(() {});
                    // print('values:${result}');
                  },
                  decoration: const InputDecoration(
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(5.0),
                          bottomLeft: Radius.circular(5.0),
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(1)),
                      ),
                      hintText: 'search'),
                ),
              ),
              Container(
                padding: const EdgeInsets.all(2),
                width: 40,
                height: 50,

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(5.0),
                    bottomRight: Radius.circular(5.0),
                  ),
                  color: Theme.of(context).primaryColor,
                  border: Border(
                    top: BorderSide(color: Colors.black, width: 1.0),
                    right: BorderSide(color: Colors.black, width: 1.0),
                    bottom: BorderSide(color: Colors.black, width: 1.0),
                  ),
                ),

                // color: Theme.of(context).primaryColor,
                child: IconButton(
                    alignment: Alignment.center,
                    iconSize: 18,
                    onPressed: () {
                      setState(() {
                        pressedCount % 2 == 0
                            ? (getSortedData('price', 'ASC'), pressedCount++)
                            : (getSortedData('price', 'DESC'), pressedCount++);
                      });
                    },
                    icon: Icon(
                      Icons.sort,
                      color: Colors.white,
                    )),
              ),
              Container(

                  // padding: const EdgeInsets.all(2),
                  width: 35,
                  height: 50,
                  child: IconButton(
                      iconSize: 18,
                      onPressed: () {
                        setState(() {
                          _showWidget = !_showWidget;
                        });
                      },
                      icon: Icon(
                        _showWidget
                            ? Icons.filter_alt_off_rounded
                            : Icons.filter_alt,
                        color: Theme.of(context).primaryColor,
                        size: 25,
                      )))
            ]),
            SizedBox(
              height: 10,
            ),
            if (_showWidget)
              Row(
                  // mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                        width: 370,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 228, 227, 227),
                          borderRadius: BorderRadius.circular(1.0),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            // sort button
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(30, 25),
                                    backgroundColor: stockFilterPressed
                                        ? Colors.blue
                                        : Colors.white),
                                onPressed: () async {
                                  setState(() {
                                    stockFilterPressed = !stockFilterPressed;
                                  });
                                },
                                child: Text(
                                  'stock more than 10',
                                  style: TextStyle(
                                      color: stockFilterPressed
                                          ? Colors.white
                                          : Colors.blue),
                                )),
                            ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    minimumSize: Size(30, 25),
                                    backgroundColor:  availableFilterPressed
                                        ? Colors.blue
                                        : Colors.white),
                                onPressed: () async {
                                  setState(() {
                                    availableFilterPressed =
                                        !availableFilterPressed;
                                  });
                                },
                                child: Text(
                                  'Available',
                                  style: TextStyle(
                                      color: availableFilterPressed
                                          ? Colors.white
                                          : Colors.blue),
                                )),
                            SizedBox(
                              width: 5,
                            ),
                          ],
                        )),
                  ]),
            const SizedBox(
              height: 10,
            ),
            Expanded(
                child: AppTable(
                    minWidth: 1400,
                    columns: const [
                      DataColumn(label: Text('Id')),
                      DataColumn(label: Text('Name')),
                      DataColumn(label: Text('Description')),
                      DataColumn(label: Text('Price')),
                      DataColumn(label: Text('Stock')),
                      DataColumn(label: Text('isAvailable')),
                      DataColumn(label: Text('image')),
                      DataColumn(label: Text('categoryId')),
                      DataColumn(label: Text('categoryName')),
                      DataColumn(label: Text('categoryDesc')),
                      DataColumn(label: Center(child: Text('Actions'))),
                    ],
                    source: ProductsSource(
                      productsEx: products,
                      onUpdate: (productData) async {
                        var result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (ctx) => ProductsOpsPage(
                                      product: productData,
                                    )));
                        if (result ?? false) {
                          getProducts();
                        }
                      },
                      onDelete: (productData) {
                        onDeleteRow(productData.id!);
                      },
                    ))),
          ],
        ),
      ),
    );
  }

  Future<void> getSortedData(String columnName, String sortType) async {
    var sqlHelper = GetIt.I.get<SqlHelper>();
    var data;
    if (sortType == "ASC") {
      data = await sqlHelper.db!.rawQuery("""
SELECT * FROM Products ORDER BY $columnName ASC;
""");
    }
    if (sortType == "DESC") {
      data = await sqlHelper.db!.rawQuery("""
SELECT * FROM Products ORDER BY $columnName DESC;
""");
    }
    if (data.isNotEmpty) {
      products = [];
      for (var item in data) {
        products!.add(Product.fromJson(item));
      }
    } else {
      products = [];
    }
    setState(() {});
  }

  Future<void> onDeleteRow(int id) async {
    try {
      var dialogResult = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Delete Product'),
              content:
                  const Text('Are you sure you want to delete this product?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          });

      if (dialogResult ?? false) {
        var sqlHelper = GetIt.I.get<SqlHelper>();
        var result = await sqlHelper.db!.delete(
          'products',
          where: 'id =?',
          whereArgs: [id],
        );
        if (result > 0) {
          getProducts();
        }
      }
    } catch (e) {
      print('Error In delete data $e');
    }
  }
}

class ProductsSource extends DataTableSource {
  List<Product>? productsEx;

  void Function(Product) onUpdate;
  void Function(Product) onDelete;
  ProductsSource(
      {required this.productsEx,
      required this.onUpdate,
      required this.onDelete});

  @override
  DataRow? getRow(int index) {
    return DataRow2(cells: [
      DataCell(Text('${productsEx?[index].id}')),
      DataCell(Text('${productsEx?[index].name}')),
      DataCell(Text('${productsEx?[index].description}')),
      DataCell(Text('${productsEx?[index].price}')),
      DataCell(Text('${productsEx?[index].stock}')),
      DataCell(Text('${productsEx?[index].isAvailable}')),
      DataCell(Center(
        child: Image.network(
          '${productsEx?[index].image}',
          fit: BoxFit.contain,
        ),
      )),
      DataCell(Text('${productsEx?[index].categoryId}')),
      DataCell(Text('${productsEx?[index].categoryName}')),
      DataCell(Text('${productsEx?[index].categoryDesc}')),
      DataCell(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
              onPressed: () {
                onUpdate(productsEx![index]);
              },
              icon: const Icon(Icons.edit)),
          IconButton(
              onPressed: () {
                onDelete(productsEx![index]);
              },
              icon: const Icon(
                Icons.delete,
                color: Colors.red,
              )),
        ],
      )),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => productsEx?.length ?? 0;

  @override
  int get selectedRowCount => 0;
}
