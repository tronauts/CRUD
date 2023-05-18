import 'package:flutter/material.dart';
import 'form_kontak.dart';
import 'database/db_helper.dart';
import 'model/kontak.dart';

class ListKontakPage extends StatefulWidget {
  const ListKontakPage({Key? key}) : super(key: key);

  @override
  _ListKontakPageState createState() => _ListKontakPageState();
}

class _ListKontakPageState extends State<ListKontakPage> {
  List<Kontak> listKontak = [];
  DbHelper db = DbHelper();

  @override
  void initState() {
    //menjalankan fungsi getallkontak saat pertama kali dimuat
    _getAllKontak();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue.shade900,
        title: Center(
          child: Text("My Contact"),
        ),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (context) {
                  return ListKontakPage();
                }));
              },
              icon: Icon(Icons.refresh))
        ],
      ),
      body: ListView.builder(
          itemCount: listKontak.length,
          itemBuilder: (context, index) {
            Kontak kontak = listKontak[index];
            return Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Container(
                margin: EdgeInsets.only(right: 10, left: 10),
                padding: EdgeInsets.all(5),
                //color: Colors.white,
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.shade300,
                      offset: Offset(3.0, 8.0), //(x,y)
                      blurRadius: 10.0,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(width: 1, color: Colors.blue.shade900),
                ),
                child: ListTile(
                  //textColor: Colors.white,
                  leading: Icon(
                    Icons.account_circle_rounded,
                    color: Colors.blue.shade900,
                    size: 50,
                  ),
                  title: Text(
                    '${kontak.name}',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade900),
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Text("Email: ${kontak.email}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Text("Phone: ${kontak.mobileNo}"),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                        ),
                        child: Text("Company: ${kontak.company}"),
                      )
                    ],
                  ),
                  trailing: FittedBox(
                    fit: BoxFit.fill,
                    child: Row(
                      children: [
                        // button edit
                        IconButton(
                          onPressed: () {
                            _openFormEdit(kontak);
                          },
                          icon: Icon(Icons.edit),
                          color: Colors.green,
                        ),
                        // button hapus
                        IconButton(
                          icon: Icon(Icons.delete),
                          color: Colors.red,
                          onPressed: () {
                            //membuat dialog konfirmasi hapus
                            AlertDialog hapus = AlertDialog(
                              title: Text("Information"),
                              content: Container(
                                height: 100,
                                child: Column(
                                  children: [
                                    Text(
                                        "Yakin ingin Menghapus Data ${kontak.name}")
                                  ],
                                ),
                              ),
                              //terdapat 2 button.
                              //jika ya maka jalankan _deleteKontak() dan tutup dialog
                              //jika tidak maka tutup dialog
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      _deleteKontak(kontak, index);
                                      Navigator.pop(context);
                                    },
                                    child: Text("Ya")),
                                TextButton(
                                  child: Text('Tidak'),
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                ),
                              ],
                            );
                            showDialog(
                                context: context, builder: (context) => hapus);
                          },
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
      //membuat button mengapung di bagian bawah kanan layar
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        //backgroundColor: Colors.white,
        onPressed: () {
          _openFormCreate();
        },
      ),
    );
  }

  //mengambil semua data Kontak
  Future<void> _getAllKontak() async {
    //list menampung data dari database
    var list = await db.getAllKontak();

    //ada perubahanan state
    setState(() {
      //hapus data pada listKontak
      listKontak.clear();

      //lakukan perulangan pada variabel list
      list!.forEach((kontak) {
        //masukan data ke listKontak
        listKontak.add(Kontak.fromMap(kontak));
      });
    });
  }

  //menghapus data Kontak
  Future<void> _deleteKontak(Kontak kontak, int position) async {
    await db.deleteKontak(kontak.id!);
    setState(() {
      listKontak.removeAt(position);
    });
  }

  // membuka halaman tambah Kontak
  Future<void> _openFormCreate() async {
    var result = await Navigator.push(
        context, MaterialPageRoute(builder: (context) => FormKontak()));
    if (result == 'save') {
      await _getAllKontak();
    }
  }

  //membuka halaman edit Kontak
  Future<void> _openFormEdit(Kontak kontak) async {
    var result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => FormKontak(kontak: kontak)));
    if (result == 'update') {
      await _getAllKontak();
    }
  }
}