import 'package:chat_app/app/view/chatScreen/chatScreen.dart';
import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chat_app/app/controller/search/bloc/search_bloc.dart';
import 'package:ionicons/ionicons.dart';

class Search extends StatefulWidget {
  Search({
    Key? key,
  }) : super(key: key);

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  TextEditingController textEditingController = TextEditingController();
  List<Map> searchResult = [];

  @override
  void dispose() {
    super.dispose();
    searchResult;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search"),
      ),
      body: BlocConsumer<SearchBloc, SearchState>(
        listener: (context, state) {
          if (state is SearchUserNotFound) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.message),
            ));
          } else if (state is SearchError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(state.error),
            ));
          }
        },
        builder: (context, state) {
          if (state is SearchLoaded) {
            searchResult = state.searchResult;
          }
          return Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              offset: const Offset(12, 26),
                              blurRadius: 50,
                              spreadRadius: 0,
                              color: Colors.grey.withOpacity(.1),
                            ),
                          ],
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        child: TextField(
                          controller: textEditingController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(
                              Icons.search,
                              color: Colors.blue, // Adjust icon color
                            ),
                            filled: true,
                            fillColor: Color.fromARGB(255, 221, 220, 220),
                            hintText: "Search...",
                            hintStyle: TextStyle(
                              color: Colors.black54, // Adjust hint text color
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              vertical: 10.0,
                              horizontal: 20.0,
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide.none, // Remove border side
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none, // Remove border side
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide.none, // Remove border side
                              borderRadius: BorderRadius.all(
                                Radius.circular(15.0),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      BlocProvider.of<SearchBloc>(context).add(
                        PerformSearchEvent(textEditingController.text),
                      );
                    },
                    icon: const Icon(EneftyIcons.search_status_outline),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildSearchResultList(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchResultList() {
    if (searchResult.isNotEmpty) {
      return ListView.builder(
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    friendId: searchResult[index]['uid'],
                    friendName: searchResult[index]['name'],
                    friendImage: searchResult[index]['image'],
                  ),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListTile(
                contentPadding: const EdgeInsets.all(0),
                leading: Container(
                  width: 50,
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                              fit: BoxFit.cover,
                              image:
                                  NetworkImage(searchResult[index]['image']))),
                    ),
                  ),
                ),
                title: Text(searchResult[index]['name']),
                subtitle: Text(searchResult[index]['email']),
                trailing: const Icon(Ionicons.chatbox_ellipses_outline),
              ),
            ),
          );
        },
        itemCount: searchResult.length,
      );
    } else {
      return const SizedBox(); // Return an empty SizedBox if searchResult is empty
    }
  }
}
