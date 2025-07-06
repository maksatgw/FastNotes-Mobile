import 'package:fastnotes_flutter/presentation/auth/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:fastnotes_flutter/core/app_colors.dart';
import 'package:fastnotes_flutter/presentation/home/home_provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

class HomeScreenView extends StatefulWidget {
  const HomeScreenView({super.key});

  @override
  State<HomeScreenView> createState() => _HomeScreenViewState();
}

class _HomeScreenViewState extends State<HomeScreenView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Build işleminden sonra çalışmasını sağla
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeProvider = Provider.of<HomeProvider>(context, listen: false);
      homeProvider.getNotesInit();
      homeProvider.getLoggedInUser(); // Kullanıcı bilgilerini yükle
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 100) {
        Provider.of<HomeProvider>(context, listen: false).changeCurrentPage();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final String _appBarTitle = 'Home';
  final String _searchHint = 'Search...';
  final String _myNotesTitle = 'My Notes';
  final String _noNotesFound = 'No notes found';
  final String _errorMessage = 'Bir hata oluştu';
  final String _errorMessageRetry = 'Tekrar dene';
  final String _logOut = 'Log out';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Consumer<HomeProvider>(
        builder: (context, provider, child) {
          return Drawer(
            child: ListView(
              children: [
                DrawerHeader(
                  decoration: BoxDecoration(
                    color: AppColors.coconutWhite,
                  ),
                  child: Row(
                    children: [
                      if (provider.loggedInUserPhotoUrl != null &&
                          provider.loggedInUserPhotoUrl!.isNotEmpty)
                        CircleAvatar(
                          backgroundImage: NetworkImage(
                            provider.loggedInUserPhotoUrl!,
                          ),
                        ),
                      const SizedBox(width: 10),
                      Text(
                        provider.loggedInUserDisplayName ?? '',
                      ),
                    ],
                  ),
                ),

                ListTile(
                  title: Text(_logOut),
                  onTap: () {
                    Provider.of<AuthProvider>(
                      context,
                      listen: false,
                    ).logout(context);
                  },
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.pushNamed('note-new');
        },
        child: Icon(Icons.add),
      ),
      body: SafeArea(
        child: Consumer<HomeProvider>(
          builder: (context, provider, child) {
            final notes = provider.notes;
            final isLoading = provider.isLoading;
            final hasError = provider.hasError;
            final errorMessage = provider.errorMessage;

            if (isLoading) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            if (hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "$_errorMessage: $errorMessage $_errorMessageRetry",
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.red,
                        ),
                      ),
                      IconButton(
                        onPressed: () => provider.getNotesInit(),
                        icon: Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (notes.isEmpty) {
              return Center(
                child: Text(_noNotesFound),
              );
            }

            // Main Scroll View
            return RefreshIndicator(
              onRefresh: () async {
                await provider.getNotesInit();
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                controller: _scrollController,
                slivers: [
                  SliverAppBar(
                    floating: true,
                    snap: true,
                    title: Text(_appBarTitle),
                    centerTitle: true,
                    elevation: 0,
                    leading: IconButton(
                      onPressed: () {
                        Scaffold.of(context).openDrawer();
                      },
                      icon: Icon(Icons.menu),
                    ),
                  ),

                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        height: 48,
                        width: double.infinity,
                        child: TextField(
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                          decoration: InputDecoration(
                            hint: Row(
                              children: [
                                Icon(Icons.search, size: 16),
                                SizedBox(width: 8),
                                Text(_searchHint),
                              ],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: AppColors.coconutWhite,
                          ),
                        ),
                      ),
                    ),
                  ),

                  _defaultSpacing(),

                  // My Notes Title
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: SizedBox(
                        child: Text(
                          _myNotesTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                    ),
                  ),

                  _defaultSpacing(),

                  // Notes List
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Slidable(
                          key: Key(notes[index].id.toString()),
                          endActionPane: ActionPane(
                            motion: ScrollMotion(),
                            children: [
                              SlidableAction(
                                onPressed: (context) {
                                  provider.deleteNote(notes[index].id!);
                                },
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                              ),
                            ],
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(notes[index].title ?? ''),
                            subtitle: Text(notes[index].content ?? ''),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              context.pushNamed(
                                'note-detail',
                                pathParameters: {
                                  'id': notes[index].id.toString(),
                                },
                                extra: notes[index],
                              );
                            },
                          ),
                        );
                      },
                      childCount: notes.length,
                    ),
                  ),

                  // Loading More
                  SliverToBoxAdapter(
                    child: provider.isLoadingMore
                        ? const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  SliverToBoxAdapter _defaultSpacing() {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: 16,
      ),
    );
  }
}
