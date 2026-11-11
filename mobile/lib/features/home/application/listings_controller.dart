import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/buyer_mock.dart';

class ListingsController extends Notifier<List<BuyerListing>> {
  @override
  List<BuyerListing> build() => BuyerMock.listings;

  void post(BuyerListing listing) => state = [listing, ...state];

  BuyerListing? find(String id) {
    for (final listing in state) {
      if (listing.id == id) return listing;
    }
    return null;
  }
}

class SavedListingsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => {'saas'};

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
  }
}

final listingsProvider =
    NotifierProvider<ListingsController, List<BuyerListing>>(
      ListingsController.new,
    );

final savedListingsProvider =
    NotifierProvider<SavedListingsController, Set<String>>(
      SavedListingsController.new,
    );

class InterestedListingsController extends Notifier<Set<String>> {
  @override
  Set<String> build() => <String>{};

  void toggle(String id) {
    final next = {...state};
    if (!next.add(id)) next.remove(id);
    state = next;
  }
}

final interestedListingsProvider =
    NotifierProvider<InterestedListingsController, Set<String>>(
      InterestedListingsController.new,
    );
