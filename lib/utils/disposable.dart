// Copyright (c) 2015, Devon Carew. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'dart:async';

import 'package:logging/logging.dart';

final Logger _logger = new Logger('disposable');

abstract class Disposable {
  void dispose();
}

class Disposables implements Disposable {
  final bool catchExceptions;

  List<Disposable> _disposables = [];

  Disposables({this.catchExceptions: true});

  void add(Disposable disposable) => _disposables.add(disposable);

  void addAll(Iterable<Disposable> list) => _disposables.addAll(list);

  bool remove(Disposable disposable) => _disposables.remove(disposable);

  void dispose() {
    for (Disposable disposable in _disposables) {
      if (catchExceptions) {
        try {
          disposable.dispose();
        } catch (e, st) {
          _logger.severe('exception during dispose', e, st);
        }
      } else {
        disposable.dispose();
      }
    }

    _disposables.clear();
  }
}

class StreamSubscriptions implements Disposable {
  final bool catchExceptions;

  List<StreamSubscription> _subscriptions = [];

  StreamSubscriptions({this.catchExceptions: true});

  void add(StreamSubscription subscription) => _subscriptions.add(subscription);

  bool remove(StreamSubscription subscription) =>
      _subscriptions.remove(subscription);

  void cancel() {
    for (StreamSubscription subscription in _subscriptions) {
      if (catchExceptions) {
        try {
          subscription.cancel();
        } catch (e, st) {
          _logger.severe('exception during subscription cancel', e, st);
        }
      } else {
        subscription.cancel();
      }
    }

    _subscriptions.clear();
  }

  void dispose() => cancel();
}

class DisposeableSubscription implements Disposable {
  final StreamSubscription sub;
  DisposeableSubscription(this.sub);
  void dispose() { sub.cancel(); }
}
