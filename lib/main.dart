import 'package:cumt_login/login.dart';
import 'package:cumt_login/prefs.dart';
import 'package:cumt_login/account.dart';
import 'package:cumt_login/methods.dart';
import 'package:cumt_login/locations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

final List<String> imgs = [
  'images/1.jpg',
  'images/2.jpg',
  'images/3.jpg',
];

main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Prefs.init();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => ThemeProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: const LoginPage(),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  final TextEditingController _usernameController = TextEditingController();

  final TextEditingController _passwordController = TextEditingController();

  CumtLoginAccount cumtLoginAccount = CumtLoginAccount();


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _usernameController.text = Prefs.cumtLoginUsername;
    _passwordController.text = Prefs.cumtLoginPassword;
    _handleLogin(context);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 在resumed的时候自动登录校园网
    if (state == AppLifecycleState.resumed) {
      _handleLogin(context);
    }
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  Widget build(BuildContext context) {
    if (DateTime.now().isAfter(DateTime(2023, 3, 25))) {
      return const Scaffold(
        body: Center(
          child: Text(
            "该测试版已过期\n请加QQ群：839372371或957634136获取最新版本",
            textAlign: TextAlign.center,
          ),
        ),
      );
    }
    return GestureDetector(
        onTap: () => FocusScope.of(context).requestFocus(FocusNode()),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('矿小助CUMT校园网登录 2.0'),
          ),
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Swiper(
                        itemCount: imgs.length,
                        itemBuilder: (context, index) {
                          return Image.asset(
                            imgs[index],
                            fit: BoxFit.fitHeight,
                          );
                        },
                        viewportFraction: 0.7,
                        scale: 0.7,
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    buildTextFieldiD("账号", _usernameController,showPopButton: true),
                    const SizedBox(height: 16.0),
                    buildTextFieldiD("密码", _passwordController,
                        obscureText: true),
                    const SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        TextButton(
                            onPressed: () => _showLocationMethodPicker(),
                            child: Row(
                              children: [
                                Text(
                                    "${cumtLoginAccount.cumtLoginLocation?.name} ${cumtLoginAccount.cumtLoginMethod?.name}"),
                                const Icon(Icons.arrow_drop_down),
                              ],
                            )),
                        ElevatedButton(
                          onPressed: () => _handleLogin(context),
                          child: const Text('登录'),
                        ),
                        OutlinedButton(
                          onPressed: () => _handleLogout(context),
                          child: const Text('注销'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 150,
                    ),
                  ],
                ),
              ),
            ],
          ),
          drawer: const DrawerList(),
        ));
  }

  void _showLocationMethodPicker() {
    Picker(
        adapter: PickerDataAdapter<dynamic>(pickerData: [
          CumtLoginLocationExtension.nameList,
          CumtLoginMethodExtension.nameList,
        ], isArray: true),
        changeToFirst: true,
        hideHeader: false,
        onConfirm: (Picker picker, List value) {
          setState(() {
            cumtLoginAccount
                .setCumtLoginLocationByName(picker.getSelectedValues()[0]);
            cumtLoginAccount
                .setCumtLoginMethodByName(picker.getSelectedValues()[1]);
          });
        }).showModal(context);
  }

  Widget buildTextFieldiD(
      String labelText, TextEditingController textEditingController,
      {obscureText = false,showPopButton = false}) {

    Icon prefixIcon;
    if (labelText=='账号') {
      prefixIcon = Icon(Icons.person);
    } else {
      prefixIcon = Icon(Icons.code);
    }

    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.centerRight,
        children: [
          TextField(
            autofocus: true,
            controller: textEditingController,
            obscureText: obscureText,
            decoration: InputDecoration(
              hintText: '请输入你的${labelText}',
              helperStyle: const TextStyle(color: Colors.grey),
              prefixIcon: prefixIcon,
              //获取焦点时，高亮的边框样式
              focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.lightBlueAccent,
              )),
              labelText: labelText,
              border: const OutlineInputBorder(),
              enabledBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(
                color: Colors.black45,
              )),
            ),
          ),
          showPopButton
              ? PopupMenuButton<CumtLoginAccount>(
                  icon: const Icon(Icons.arrow_drop_down_outlined),
              onCanceled: () {
                    FocusScope.of(context).unfocus();
                  },
                  onSelected: (account) {
                    setState(() {
                      cumtLoginAccount = account.clone();
                      _usernameController.text = cumtLoginAccount.username!;
                      _passwordController.text = cumtLoginAccount.password!;
                    });
                  },
                  itemBuilder: (context) {
                    return CumtLoginAccount.list.map((account) {
                      return PopupMenuItem<CumtLoginAccount>(
                        value: account,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                "${account.username}"
                                " ${account.cumtLoginLocation?.name} ${account.cumtLoginMethod?.name}",
                              ),
                            ),
                            IconButton(
                                onPressed: () {
                                  CumtLoginAccount.removeList(account);
                                  _showSnackBar(context, "删除成功");
                                  Navigator.of(context).pop();
                                },
                                icon: const Icon(Icons.close))
                          ],
                        ),
                      );
                    }).toList();
                  })
              : Container(),
        ],
      ),
    );
  }

  void _handleLogout(BuildContext context) {
    CumtLogin.logout(account: cumtLoginAccount).then((value) {
      _showSnackBar(context, value);
    });
  }

  void _showSnackBar(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _handleLogin(BuildContext context) {
    if (_usernameController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _showSnackBar(context, '账号或密码不能为空');
      return;
    }
    cumtLoginAccount.username = _usernameController.text.trim();
    cumtLoginAccount.password = _passwordController.text.trim();

    CumtLogin.login(account: cumtLoginAccount).then((value) {
      setState(() {
        _showSnackBar(context, value);
      });
    });
  }
}

class DrawerList extends StatefulWidget {
  const DrawerList({Key? key}) : super(key: key);

  @override
  State<DrawerList> createState() => _DrawerListState();
}

class _DrawerListState extends State<DrawerList> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
        child: ListView(
      padding: EdgeInsets.all(10),
      children: [
        const UserAccountsDrawerHeader(
          accountName: Text(''),
          accountEmail: Text(""),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/2.jpg'),
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(
          height: 360,
        ),
        Row(
          children: [
            Text(
              '主题颜色切换',
              style: TextStyle(fontSize: 20),
            ),
            SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: EdgeInsets.all(10),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setThemeData(ThemeData(
                                scaffoldBackgroundColor: Colors.blue[100],
                                canvasColor: Colors.blue[100],
                                colorScheme: ColorScheme(
                                    primary: Colors.blue[300]!,
                                    secondary: Colors.blueAccent[400]!,
                                    background: Colors.blue[100]!,
                                    error: Colors.redAccent[700]!,
                                    brightness: Brightness.light,
                                    onBackground: Colors.blue[300]!,
                                    onError: Colors.white,
                                    onPrimary: Colors.white,
                                    onSecondary: Colors.blue[300]!,
                                    onSurface: Colors.blue[300]!,
                                    surface: Colors.blue[50]!)));
                      },
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.blueAccent,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setThemeData(ThemeData(
                                scaffoldBackgroundColor: Colors.red[100],
                                canvasColor: Colors.red[100],
                                colorScheme: ColorScheme(
                                    primary: Colors.red[300]!,
                                    secondary: Colors.red[400]!,
                                    background: Colors.red[100]!,
                                    error: Colors.redAccent[700]!,
                                    brightness: Brightness.light,
                                    onBackground: Colors.red[300]!,
                                    onError: Colors.white,
                                    onPrimary: Colors.white,
                                    onSecondary: Colors.red[300]!,
                                    onSurface: Colors.red[300]!,
                                    surface: Colors.red[50]!)));
                      },
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.redAccent,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setThemeData(ThemeData(
                                scaffoldBackgroundColor: Colors.yellow[100],
                                canvasColor: Colors.yellow[100],
                                colorScheme: ColorScheme(
                                    primary: Colors.yellow[300]!,
                                    secondary: Colors.yellow[400]!,
                                    background: Colors.yellow[100]!,
                                    error: Colors.yellowAccent[700]!,
                                    brightness: Brightness.light,
                                    onBackground: Colors.yellow[300]!,
                                    onError: Colors.white,
                                    onPrimary: Colors.white,
                                    onSecondary: Colors.yellow[300]!,
                                    onSurface: Colors.yellow[300]!,
                                    surface: Colors.yellow[50]!)));
                      },
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.yellowAccent,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setThemeData(ThemeData(
                                scaffoldBackgroundColor: Colors.grey[100],
                                canvasColor: Colors.grey[100],
                                colorScheme: ColorScheme(
                                    primary: Colors.grey[300]!,
                                    secondary: Colors.grey[400]!,
                                    background: Colors.grey[100]!,
                                    error: Colors.blueGrey[700]!,
                                    brightness: Brightness.light,
                                    onBackground: Colors.grey[300]!,
                                    onError: Colors.white,
                                    onPrimary: Colors.white,
                                    onSecondary: Colors.grey[300]!,
                                    onSurface: Colors.grey[300]!,
                                    surface: Colors.grey[50]!)));
                      },
                      child: Row(
                        children: const [
                          SizedBox(
                            width: 10,
                          ),
                          Icon(
                            Icons.circle,
                            size: 20,
                            color: Colors.blueGrey,
                          ),
                        ],
                      ),
                    ),
                  ],
                )),
          ],
        ),
        const SizedBox(
          height: 50,
        ),
        InkWell(
          onTap: () {
            ThemeData lightTheme = ThemeData.light();
            ThemeData darkTheme = ThemeData.dark();

            bool isDarkTheme = false;

            setState(() {
              isDarkTheme = !isDarkTheme;
            });

            if (isDarkTheme) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeData(darkTheme);
            } else {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeData(lightTheme);
            }
          },
          child: Row(
            children: const [
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.dark_mode,
                size: 20,
              ),
              SizedBox(width: 16),
              Text(
                '黑夜模式',
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () {
            ThemeData lightTheme = ThemeData.light();
            ThemeData darkTheme = ThemeData.dark();

            bool isDarkTheme1 = true;

            setState(() {
              isDarkTheme1 = !isDarkTheme1;
            });

            if (isDarkTheme1) {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeData(darkTheme);
            } else {
              Provider.of<ThemeProvider>(context, listen: false)
                  .setThemeData(lightTheme);
            }
          },
          child: Row(
            children: const [
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.sunny,
                size: 20,
                color: Colors.orangeAccent,
              ),
              SizedBox(width: 16),
              Text(
                '日间模式',
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        InkWell(
          onTap: () {
            Provider.of<ThemeProvider>(context, listen: false).setThemeData(
                ThemeData(
                    scaffoldBackgroundColor: Colors.green[100],
                    canvasColor: Colors.green[100],
                    colorScheme: ColorScheme(
                        primary: Colors.green[300]!,
                        secondary: Colors.greenAccent[400]!,
                        background: Colors.green[100]!,
                        error: Colors.redAccent[700]!,
                        brightness: Brightness.light,
                        onBackground: Colors.green[300]!,
                        onError: Colors.white,
                        onPrimary: Colors.white,
                        onSecondary: Colors.green[300]!,
                        onSurface: Colors.green[300]!,
                        surface: Colors.green[50]!)));
          },
          child: Row(
            children: const [
              SizedBox(
                width: 20,
              ),
              Icon(
                Icons.remove_red_eye_rounded,
                size: 20,
                color: Colors.cyanAccent,
              ),
              SizedBox(width: 16),
              Text(
                '护眼模式',
                style: TextStyle(fontSize: 20),
              )
            ],
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        AboutListTile(
          applicationName: '校园网自动登录',
          applicationVersion: '2.0.0',
          icon: const CircleAvatar(
            backgroundColor: Colors.white,
            child: Icon(
              Icons.report,
              color: Colors.grey,
              size: 20,
            ),
          ),
          applicationLegalese: '校园网自动登录',
          aboutBoxChildren: const [
            Text(
              "本App用于测试矿小助新功能\n"
              "3月15日之后将停用并移植到新版矿小助中\n"
              "如果遇到问题请加QQ群反馈\n"
              "1群：839372371\n"
              "2群：957634136",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
          applicationIcon: Image.asset(
            'images/1.jpg',
            width: 50,
            height: 50,
          ),
          child: const Text('关于', style: TextStyle(fontSize: 20)),
        ),
      ],
    ));
  }
}

class ThemeProvider with ChangeNotifier {
  ThemeData _themeData = ThemeData.light();

  ThemeData get themeData => _themeData;

  void setThemeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }
}
